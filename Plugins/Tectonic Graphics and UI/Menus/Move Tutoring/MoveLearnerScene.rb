#===============================================================================
# Scene class for handling appearance of the screen
#===============================================================================
class MoveLearner_Scene
    include MoveInfoDisplay

    VISIBLEMOVES = 4
    MOVE_ENTRY_HEIGHT = 40

    def pbDisplay(msg, brief = false)
        UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
    end

    def pbConfirm(msg)
        UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbStartScene(pokemon, moves)
        @pokemon = pokemon
        @moves = moves
        moveCommands = []
        moves.each { |m| moveCommands.push(GameData::Move.get(m).name) }
        # Create sprite hash
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @sprites = {}
        bg_path = "Move Tutor/reminderbg"
        bg_path += "_dark" if darkMode?
        addBackgroundPlane(@sprites, "bg", bg_path, @viewport)
        @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
        @sprites["pokeicon"].setOffset(PictureOrigin::Center)
        @sprites["pokeicon"].x = 312
        @sprites["pokeicon"].y = 58
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        sel_path = "Graphics/Pictures/Move Tutor/reminderSel"
        sel_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(sel_path)
        @sprites["background"].y = 74
        @sprites["background"].src_rect = Rect.new(0, 48, 254, 48)
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["commands"] = Window_CommandPokemon.new(moveCommands, 32)
        @sprites["commands"].height = 32 * (VISIBLEMOVES + 1)
        @sprites["commands"].visible = false
        @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
        @sprites["msgwindow"].visible = false
        @sprites["msgwindow"].viewport = @viewport
        @typebitmap = AnimatedBitmap.new(addLanguageSuffix("Graphics/Pictures/types"))

        # Create overlay for selected move's extra info (shows move's BP, description)
        move_path = "Graphics/Pictures/move_info_display_backwards_l"
        move_path += "_dark" if darkMode?
        @moveInfoDisplayBitmap = AnimatedBitmap.new(_INTL(move_path))
        @moveInfoDisplay = SpriteWrapper.new(@viewport)
        @moveInfoDisplay.bitmap = @moveInfoDisplayBitmap.bitmap
        @sprites["moveInfoDisplay"] = @moveInfoDisplay
        @extraInfoOverlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetNarrowFont(@extraInfoOverlay.bitmap)
        @sprites["extraInfoOverlay"] = @extraInfoOverlay

        pbDrawMoveList
        pbDeactivateWindows(@sprites)
        # Fade in all sprites
        pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def pbDrawMoveList
        overlay = @sprites["overlay"].bitmap
        overlay.clear

        base = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor
        title_base = MessageConfig::DARK_TEXT_MAIN_COLOR
        title_shadow = MessageConfig::DARK_TEXT_SHADOW_COLOR

        textpos = []
        imagepos = []

        # Draw the title
        textpos.push([_INTL("Teach which move?"), 16, 2, 0, title_base, title_shadow])

        # Draw the pokemon's info
        type1_number = GameData::Type.get(@pokemon.type1).id_number
        type2_number = GameData::Type.get(@pokemon.type2).id_number
        type1rect = Rect.new(0, type1_number * 28, 64, 28)
        type2rect = Rect.new(0, type2_number * 28, 64, 28)
        if @pokemon.type1 == @pokemon.type2
            overlay.blt(392, 44, @typebitmap.bitmap, type1rect)
        else
            overlay.blt(358, 44, @typebitmap.bitmap, type1rect)
            overlay.blt(428, 44, @typebitmap.bitmap, type2rect)
        end

        # Draw the selectable move elements
        yPos = 74
        for i in 0...VISIBLEMOVES
            moveobject = @moves[@sprites["commands"].top_item + i]
            if moveobject
                moveData = GameData::Move.get(moveobject)
                # type_number = GameData::Type.get(moveData.type).id_number
                # imagepos.push([addLanguageSuffix("Graphics/Pictures/types"), 12, yPos + 8, 0, type_number * 28, 64, 28])
                textpos.push([moveData.name, 126, yPos, 2, base, shadow])
            end
            yPos += MOVE_ENTRY_HEIGHT
        end

        # Draw the selection cursor
        sel_path = "Graphics/Pictures/Move Tutor/reminderSel"
        sel_path += "_dark" if darkMode?
        imagepos.push([sel_path,
                       0, 72 + (@sprites["commands"].index - @sprites["commands"].top_item) * MOVE_ENTRY_HEIGHT, 0, 0, 254, 48,])

        # Draw the selected move
        selectedMoveID = @moves[@sprites["commands"].index]
        drawMoveInfo(selectedMoveID)

        # Draw the reminder arrow buttons
        if @sprites["commands"].index < @moves.length - 1
            imagepos.push(["Graphics/Pictures/Move Tutor/reminderButtons", 48, 244, 0, 0, 76, 32])
        end
        if @sprites["commands"].index > 0
            imagepos.push(["Graphics/Pictures/Move Tutor/reminderButtons", 134, 244, 76, 0, 76, 32])
        end

        # Actually render everything
        pbDrawImagePositions(overlay, imagepos)
        pbDrawTextPositions(overlay, textpos)
    end

    def drawMoveInfo(selected_move)
        writeMoveInfoToInfoOverlayBackwardsL(@extraInfoOverlay.bitmap, selected_move, false)
    end

    # Processes the scene
    def pbChooseMove
        oldcmd = -1
        pbActivateWindow(@sprites, "commands") do
            loop do
                oldcmd = @sprites["commands"].index
                Graphics.update
                Input.update
                pbUpdate
                if @sprites["commands"].index != oldcmd
                    @sprites["background"].x = 0
                    @sprites["background"].y = 74 + (@sprites["commands"].index - @sprites["commands"].top_item) * MOVE_ENTRY_HEIGHT
                    pbDrawMoveList
                end
                if Input.trigger?(Input::BACK)
                    return nil
                elsif Input.trigger?(Input::USE)
                    return @moves[@sprites["commands"].index]
                end
            end
        end
    end

    # End the scene here
    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @typebitmap.dispose
        @viewport.dispose
        @moveInfoDisplayBitmap.dispose
    end
end
