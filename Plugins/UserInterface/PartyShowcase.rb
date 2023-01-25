class PokemonPartyShowcase_Scene
    POKEMON_ICON_SIZE = 64
    BASE_COLOR   = Color.new(80, 80, 88)
    SHADOW_COLOR = Color.new(160, 160, 168)

    def initialize(party,snapshot = false,snapShotName=nil)
        @sprites = {}
        @party = party
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999

        addBackgroundPlane(@sprites, "bg", "Party/showcase_bg", @viewport)

        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @overlay = @sprites["overlay"].bitmap
        pbSetSmallFont(@overlay)

        # Add party Pokémon sprites
        for i in 0...Settings::MAX_PARTY_SIZE
            next unless @party[i]
            renderShowcaseInfo(i,@party[i])
        end

        # Draw tribal bonus info at the bottom
        fullDescription = ""
        $Tribal_Bonuses.getActiveBonusesList(false).each_with_index do |label,index|
            fullDescription += "," unless index == 0
            fullDescription += label
        end
        if fullDescription.blank?
            fullDescription = "No Tribal Bonuses"
        else
            fullDescription = "Tribes: " + fullDescription
        end
        fullDescription = "<ac>#{fullDescription}</ac>"
        drawFormattedTextEx(@overlay, 8, Graphics.height - 20, Graphics.width, fullDescription, BASE_COLOR, SHADOW_COLOR)

        pbFadeInAndShow(@sprites) { pbUpdate }
        pbScreenCapture(snapShotName)

        loop do
            Graphics.update
            Input.update
            pbUpdate
            if Input.trigger?(Input::BACK)
                pbEndScene
                pbPlayCloseMenuSE
                return
            end
        end
    end

    def renderShowcaseInfo(index,pokemon)
        displayX =  ((index % 2) * (Graphics.width / 2)) + 4
        displayY = (index / 2) * (Graphics.height / 3 - 8) + 4

        mainIconY = displayY + 20
        newPokemonIcon = PokemonIconSprite.new(pokemon,@viewport)
        newPokemonIcon.x = displayX
        newPokemonIcon.y = mainIconY
        @sprites["pokemon#{index}"] = newPokemonIcon

        # Display pokemon name
        nameAndLevel = pokemon.name + " Lv. " + pokemon.level.to_s
        drawTextEx(@overlay, displayX + 4, displayY, 200, 1, nameAndLevel, BASE_COLOR, SHADOW_COLOR)

        # Display item icon
        if pokemon.item
            itemX = displayX + POKEMON_ICON_SIZE - 8
            itemY = mainIconY + POKEMON_ICON_SIZE - 8
            newItemIcon = ItemIconSprite.new(itemX,itemY,pokemon.item,@viewport)
            newItemIcon.zoom_x = 0.5
            newItemIcon.zoom_y = 0.5
            @sprites["item#{index}"] = newItemIcon
        end

        # Display moves
        pokemon.moves.each_with_index do |pokemonMove,moveIndex|
            moveName = GameData::Move.get(pokemonMove.id).real_name
            drawTextEx(@overlay, displayX + POKEMON_ICON_SIZE + 8, mainIconY + moveIndex * 16, 200, 1, moveName, BASE_COLOR, SHADOW_COLOR)
        end

        # Display ability name
        abilityName = pokemon.ability.real_name
        drawTextEx(@overlay, displayX + 4, mainIconY + POKEMON_ICON_SIZE + 8, 200, 1, abilityName, BASE_COLOR, SHADOW_COLOR)
    
        # Display style values
        styleValueX = displayX + 224
        styleHash = pokemon.ev
        styleValues = [styleHash[:HP],styleHash[:ATTACK],styleHash[:DEFENSE],styleHash[:SPECIAL_ATTACK],styleHash[:SPECIAL_DEFENSE],styleHash[:SPEED]]
        styleValues.each_with_index do |styleValue,styleIndex|
            drawTextEx(@overlay, styleValueX, displayY + 16 * styleIndex, 80, 1, styleValue.to_s, BASE_COLOR, SHADOW_COLOR)
        end
    end

    # End the scene here
    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        # DISPOSE OF BITMAPS HERE #
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end
end