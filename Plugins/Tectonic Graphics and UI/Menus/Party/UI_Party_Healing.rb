class PokemonPartyPanel_Healing < PokemonPartyPanel
    def initialize(pokemon,index,viewport=nil)
        @currentHP = pokemon.hp
        super
    end
    
    def hp; return @currentHP; end

    def currentHP=(value)
        @currentHP = value
        @refreshBitmap = true
        refresh
    end
end

class PokemonPartyHealingDisplayScreen
    POKEMON_ICON_SIZE = 64
    BASE_COLOR   = Color.new(248,248,248)
    SHADOW_COLOR = Color.new(40,40,40)

    def initialize(party)
        @sprites = {}
        @party = party
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999

        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @overlay = @sprites["overlay"].bitmap
        pbSetSmallFont(@overlay)

        # Add party Pokémon sprites
        for i in 0...Settings::MAX_PARTY_SIZE
            if @party[i]
                @sprites["pokemon#{i}"] = PokemonPartyPanel_Healing.new(@party[i],i,@viewport)
            else
                @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i],i,@viewport)
            end
            @sprites["pokemon#{i}"].y += 12
        end
    end

    def healingAnimationDuration
        if $PokemonSystem.textspeed >= 3
            return 10
        else
            return 16
        end
    end

    def playHealingAnimation(previousHealthValues,fullyHealed)
        for i in 0...Settings::MAX_PARTY_SIZE
            if @party[i]
                @sprites["pokemon#{i}"].currentHP = previousHealthValues[i]
            end
        end

        for animationFrame in 0..healingAnimationDuration do
            pbWait(1)

            for i in 0...Settings::MAX_PARTY_SIZE
                if @party[i]
                    hpDifference = @sprites["pokemon#{i}"].pokemon.hp - previousHealthValues[i]
                    currentHPInAnimation = previousHealthValues[i] + hpDifference * (animationFrame/healingAnimationDuration.to_f)
                    @sprites["pokemon#{i}"].currentHP = currentHPInAnimation
                end
            end
        end

        pbMessage(_INTL("Your entire team is healthy!")) if fullyHealed

        loop do
            Graphics.update
            Input.update
            pbUpdate
            if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
                pbEndScene
                pbPlayCloseMenuSE
                return
            end
        end
    end

    # End the scene here
    def pbEndScene
        pbDisposeSpriteHash(@sprites)
        # DISPOSE OF BITMAPS HERE #
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end
end

def showPartyHealing(party,previousHealthValues,fullyHealed = false)
    scene = PokemonPartyHealingDisplayScreen.new(party)
    scene.playHealingAnimation(previousHealthValues,fullyHealed)
end