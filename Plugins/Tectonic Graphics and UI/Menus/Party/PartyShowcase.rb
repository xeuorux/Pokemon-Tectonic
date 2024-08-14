class PokemonPartyShowcase_Scene
    POKEMON_ICON_SIZE = 64
    base   = Color.new(80, 80, 88)
    shadow = Color.new(160, 160, 168)

    def initialize(trainer,snapshot: false,snapShotName: nil,fastSnapshot: false, npcTrainer: false, illusionsFool: true, flags: [], startWithIndex: 0)
        base = MessageConfig::DARK_TEXT_MAIN_COLOR
        shadow = MessageConfig::DARK_TEXT_SHADOW_COLOR

        @sprites = {}
        @party = trainer.party.clone
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999
        @npcTrainer = npcTrainer

        if @npcTrainer
            backgroundFileName = "Party/showcase_bg_npc"
        else
            backgroundFileName = "Party/showcase_bg"
            backgroundFileName += "_postgame" if gameWon?
        end
        addBackgroundPlane(@sprites, "bg", backgroundFileName, @viewport)

        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @overlay = @sprites["overlay"].bitmap
        pbSetSmallFont(@overlay)

        # Fake lead
        if startWithIndex != 0
            storage = @party[0]
            @party[0] = @party[startWithIndex]
            @party[startWithIndex] = storage
        end

        # Illusion
        if illusionsFool && @party[0].hasAbility?(:ILLUSION)
            storage = @party[0]
            @party[0] = @party[@party.length - 1]
            @party[@party.length - 1] = storage
        end

        # Add party Pokémon sprites
        for i in 0...Settings::MAX_PARTY_SIZE
            next unless @party[i]
            renderShowcaseInfo(i,@party[i])
        end

        bottomBarY = Graphics.height - 20

        # Draw tribal bonus info at the bottom
        pbDrawImagePositions(@overlay,[["Graphics/Pictures/icon_tribal_bonus",4,bottomBarY-4]])

        trainer.tribalBonus.updateTribeCount
        bonusesList = trainer.tribalBonus.getActiveBonusesList(false)
        tribesTotal = GameData::Tribe::DATA.keys.count
        fullDescription = ""
        if bonusesList.empty?
            fullDescription = _INTL("None")
        elsif bonusesList.length == tribesTotal
            fullDescription = _INTL("All")
        elsif bonusesList.length <= 2
            bonusesList.each_with_index do |label,index|
                fullDescription += "," unless index == 0
                fullDescription += label
            end
        else
            fullDescription = bonusesList.length.to_s
        end

        drawFormattedTextEx(@overlay, 32, bottomBarY, Graphics.width, fullDescription, base, shadow)

        # Show trainer name
        if @npcTrainer
            playerName = "<ar>#{trainer.full_name}</ar>"
            drawFormattedTextEx(@overlay, Graphics.width - 304, bottomBarY, 300, playerName, base, shadow)
        elsif $PokemonSystem.name_on_showcases != 1
            playerName = "<ar>#{trainer.name}</ar>"
            drawFormattedTextEx(@overlay, Graphics.width - 164, bottomBarY, 160, playerName, base, shadow)
        end

        unless npcTrainer
            # Show game version
            settingsLabel = "v#{Settings::GAME_VERSION}"
            settingsLabel += "-dev" if Settings::DEV_VERSION
            drawFormattedTextEx(@overlay, Graphics.width / 2 + 60, bottomBarY, 160, settingsLabel, base, shadow)

            numIcons = 0
            numIcons += 1 if Randomizer.on?
            numIcons += 1 if flags.include?("cursed")
            numIcons += 1 if flags.include?("cursed")

            # Show randomizer icon
            distanceBetweenIcons = 28
            bottomIconX = Graphics.width / 2 - (numIcons * distanceBetweenIcons) / 2
            if Randomizer.on?
                pbDrawImagePositions(@overlay,[["Graphics/Pictures/Party/icon_randomizer",bottomIconX,bottomBarY-4]])
                bottomIconX += distanceBetweenIcons
            end

            # Show cursed icon
            if flags.include?("cursed")
                pbDrawImagePositions(@overlay,[["Graphics/Pictures/Party/icon_cursed",bottomIconX+2,bottomBarY-4]])
                bottomIconX += distanceBetweenIcons
            end

            # Show perfect icon
            if flags.include?("perfect")
                pbDrawImagePositions(@overlay,[["Graphics/Pictures/Party/icon_perfect",bottomIconX,bottomBarY-4]])
                bottomIconX += distanceBetweenIcons
            end
        end

        pbFadeInAndShow(@sprites) { pbUpdate }

        pbScreenCapture(snapShotName, !fastSnapshot) if snapshot

        loop do
            Graphics.update
            Input.update
            pbUpdate
            if Input.trigger?(Input::BACK) || fastSnapshot
                pbEndScene
                pbPlayCloseMenuSE
                return
            end
        end
    end

    MAX_MOVE_NAME_WIDTH = 140

    def renderShowcaseInfo(index,pokemon)
        base = MessageConfig::DARK_TEXT_MAIN_COLOR
        shadow = MessageConfig::DARK_TEXT_SHADOW_COLOR
        
        displayX = ((index % 2) * (Graphics.width / 2)) + 6
        displayY = (index / 2) * (Graphics.height / 3 - 8) + 6

        mainIconY = displayY + 20
        newPokemonIcon = PokemonIconSprite.new(pokemon,@viewport)
        newPokemonIcon.x = displayX
        newPokemonIcon.y = mainIconY
        @sprites["pokemon#{index}"] = newPokemonIcon

        # Display pokemon name
        nameAndLevel = _INTL("#{pokemon.name} Lv. #{pokemon.level.to_s}")
        drawTextEx(@overlay, displayX + 4, displayY, 200, 1, nameAndLevel, base, shadow)

        # Display item icon
        if pokemon.hasItem?
            pixelsBetweenItems = 20
            itemX = displayX + POKEMON_ICON_SIZE - 8 - pixelsBetweenItems * (pokemon.items.length - 1)
            itemY = mainIconY + POKEMON_ICON_SIZE - 8
            pokemon.items.each_with_index do |item, itemIndex|
                newItemIcon = ItemIconSprite.new(itemX,itemY,item,@viewport)
                newItemIcon.zoom_x = 0.5
                newItemIcon.zoom_y = 0.5
                newItemIcon.type = pokemon.itemTypeChosen
                @sprites["item_#{index}_#{itemIndex}"] = newItemIcon

                itemX += pixelsBetweenItems
            end
        end

        unless @npcTrainer
            # Display ball caught in icon
            newItemIcon = ItemIconSprite.new(displayX + 200,mainIconY + POKEMON_ICON_SIZE + 16,pokemon.poke_ball,@viewport)
            newItemIcon.zoom_x = 0.5
            newItemIcon.zoom_y = 0.5
            @sprites["ball_#{index}"] = newItemIcon
        end

        # Display gender
        #genderX = displayX + 2
        #genderY = itemY - 6
        genderX = displayX + 196
        genderY = displayY
        if pokemon.male?
            drawTextEx(@overlay, genderX, genderY, 80, 1, _INTL("♂"), Color.new(0,112,248), Color.new(120,184,232))
        elsif pokemon.female?
            drawTextEx(@overlay, genderX, genderY, 80, 1, _INTL("♀"), Color.new(232,32,16), Color.new(248,168,184))
        end

        # Draw shiny icon
        if pokemon.shiny?
            shinyIconFileName = pokemon.shiny_variant? ? "Graphics/Pictures/shiny_variant" : "Graphics/Pictures/shiny"
            pbDrawImagePositions(@overlay,[[shinyIconFileName,displayX,mainIconY,0,0,16,16]])
        end

        # Display moves
        pokemon.moves.each_with_index do |pokemonMove,moveIndex|
            moveName = GameData::Move.get(pokemonMove.id).name
            expectedMoveNameWidth = @overlay.text_size(moveName).width
            if expectedMoveNameWidth > MAX_MOVE_NAME_WIDTH
                charactersToShave = 3
                loop do
                    testString = moveName[0..-charactersToShave] + "..."
                    expectedTestStringWidth = @overlay.text_size(testString).width
                    excessWidth = expectedTestStringWidth - MAX_MOVE_NAME_WIDTH
                    break if excessWidth <= 0
                    charactersToShave += 1
                end
                shavedName = moveName[0..-charactersToShave]
                shavedName = shavedName[0..-1] if shavedName[shavedName.length-1] == " "
                moveName = shavedName + "..."
            end
            drawTextEx(@overlay, displayX + POKEMON_ICON_SIZE + 8, mainIconY + 2 + moveIndex * 16, 200, 1, moveName, base, shadow)
        end

        # Display ability name
        abilityName = pokemon.ability&.name || _INTL("No Ability")
        drawTextEx(@overlay, displayX + 4, mainIconY + POKEMON_ICON_SIZE + 8, 200, 1, abilityName, base, shadow)
    
        # Display Style Points
        styleValueX = displayX + 222
        styleHash = pokemon.ev
        styleValues = [styleHash[:HP],styleHash[:ATTACK],styleHash[:DEFENSE],styleHash[:SPECIAL_ATTACK],styleHash[:SPECIAL_DEFENSE],styleHash[:SPEED]]
        styleValues.each_with_index do |styleValue,styleIndex|
            #styleOpacity = (0.5 + styleValue / 40.0) * 255
            thisColor = base.clone
            thisColor.alpha = 120 if styleValue == 0
            thisShadow = shadow.clone
            thisShadow.alpha = 120 if styleValue == 0
            drawTextEx(@overlay, styleValueX, 2 + displayY + 18 * styleIndex, 80, 1, styleValue.to_s, thisColor, thisShadow)
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

def enemyTrainerShowcase(trainerClass,trainerName,version=0, illusionsFool: false)
    trainer = pbLoadTrainer(trainerClass,trainerName,version)
    trainerShowcase(trainer, npcTrainer: true, illusionsFool: illusionsFool)
end

def trainerShowcase(trainer, npcTrainer: false, illusionsFool: false, flags: [], startWithIndex: 0)
    pbFadeOutIn {
        PokemonPartyShowcase_Scene.new(trainer, npcTrainer: npcTrainer, illusionsFool: illusionsFool, flags: flags, startWithIndex: startWithIndex)
    }
end

def createVisualTrainerDocumentation
    GameData::Trainer.each do |trainerData|
        trainer = pbLoadTrainer(trainerData.trainer_type,trainerData.name,trainerData.version)
        screenshotName = "#{trainerData.trainer_type} #{trainerData.name}"
        screenshotName += " (#{trainerData.version})" if trainerData.version > 0
        screenshotName += " "
        PokemonPartyShowcase_Scene.new(trainer,snapshot: true,snapShotName: screenshotName,fastSnapshot: true, npcTrainer: true)
    end
end