class MoveDex_Scene
    include MoveInfoDisplay

    MAX_LENGTH_MOVE_LIST = 7
	MOVE_LIST_SUMMARY_MOVE_NAMES_Y_INIT = 56
    MOVE_LIST_X_LEFT = 32

    def generateMoveList
        @currentMoveList = []
        GameData::Move.each do |moveData|
            next unless moveData.learnable?
            @currentMoveList.push(moveData.id)
        end

        @currentMoveList.sort_by! { |move|
            GameData::Move.get(move).name
        }
    end

    def pbStartScene(index = 0)
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @scroll   = index
        move_path = "Graphics/Pictures/move_info_display_backwards_l"
        move_path += "_dark" if darkMode?
        @moveInfoDisplayBitmap = AnimatedBitmap.new(_INTL(move_path))
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)

        bg_path = "Graphics/Pictures/Movedex/bg_moves_main"
        bg_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(_INTL(bg_path))
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["selectionarrow"] = IconSprite.new(0, 0, @viewport)
        @sprites["selectionarrow"].setBitmap("Graphics/Pictures/selarrow")
        @sprites["selectionarrow"].visible = false
        @sprites["selectionarrow"].x = 6

		# Create the move extra info display
        @moveInfoDisplay = SpriteWrapper.new(@viewport)
        @moveInfoDisplay.bitmap = @moveInfoDisplayBitmap.bitmap
        @sprites["moveInfoDisplay"] = @moveInfoDisplay
        # Create overlay for selected move's extra info (shows move's BP, description)
        @extraInfoOverlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetNarrowFont(@extraInfoOverlay.bitmap)
        @sprites["extraInfoOverlay"] = @extraInfoOverlay

        generateMoveList

        drawPage

        pbScroll
    end

    def drawPage
        overlay = @sprites["overlay"].bitmap
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor

        overlay.clear

        drawFormattedTextEx(overlay, 50, 2, Graphics.width, "<outln2>Moves Dex</outln2>", base, shadow, 18)

		# render the moves lists
		displayIndex = 0
		listIndex = -1
        selected_move = nil
        if @currentMoveList.empty?
            drawFormattedTextEx(overlay, MOVE_LIST_X_LEFT + 60, 90, 450, _INTL("None"), base, shadow)
		else
            @currentMoveList.each_with_index do |move, _index|
                listIndex += 1
                next if listIndex < @scroll
                maxWidth = displayIndex == 0 ? 200 : 212
                moveName, moveColor, moveShadow = getFormattedMoveName(move, 200)
                offsetX = 0
                selected_move = move if listIndex == @scroll
                moveDrawY = MOVE_LIST_SUMMARY_MOVE_NAMES_Y_INIT + 32 * displayIndex
                drawFormattedTextEx(overlay, MOVE_LIST_X_LEFT + offsetX, moveDrawY, 450, moveName, moveColor, moveShadow)
                if listIndex == @scroll
                    @sprites["selectionarrow"].y = moveDrawY - 4
                    @sprites["selectionarrow"].visible = true
                end
                displayIndex += 1
                break if displayIndex > MAX_LENGTH_MOVE_LIST
            end
		end

        drawMoveInfo(selected_move) if selected_move
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
        @moveInfoDisplayBitmap.dispose
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

	def drawMoveInfo(selected_move)
        writeMoveInfoToInfoOverlayBackwardsL(@extraInfoOverlay.bitmap,selected_move) unless selected_move.nil?
    end

    def getFormattedMoveName(move, maxWidth = 99_999)
        move_data = GameData::Move.get(move)
        moveName = move_data.name

        # Chop letters off of excessively long names to make them fit into the maximum width
        overlay = @sprites["overlay"].bitmap
        expectedMoveNameWidth = overlay.text_size(moveName).width
        if expectedMoveNameWidth > maxWidth
            charactersToShave = 3
            loop do
                testString = moveName[0..-charactersToShave] + "..."
                expectedTestStringWidth = overlay.text_size(testString).width
                excessWidth = expectedTestStringWidth - maxWidth
                break if excessWidth <= 0
                charactersToShave += 1
            end
            shavedName = moveName[0..-charactersToShave]
            shavedName = shavedName[0..-1] if shavedName[shavedName.length-1] == " "
            moveName = shavedName + "..."
        end

        color = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor
        return moveName, color, shadow
    end

    def pbScroll
        @scroll = 0
        drawPage

        linesShown = 7

        loop do
            Graphics.update
            Input.update
            pbUpdate
            doRefresh = false
            if Input.repeat?(Input::UP)
                if @scroll > 0
                    pbPlayCursorSE
                    @scroll -= 1
                    doRefresh = true
                elsif Input.trigger?(Input::UP)
                    pbPlayCursorSE
                    @scroll = @currentMoveList.length - 1
                    doRefresh = true
                end
            elsif Input.repeat?(Input::DOWN)
                if @scroll < @currentMoveList.length - 1
                    pbPlayCursorSE
                    @scroll += 1
                    doRefresh = true
                elsif Input.trigger?(Input::DOWN)
                    pbPlayCursorSE
                    @scroll = 0
                    doRefresh = true
                end
            elsif Input.repeat?(Input::JUMPUP) # Jump multiple lines
                if @scroll > 0
                    pbPlayCursorSE
                    @scroll -= MAX_LENGTH_MOVE_LIST
                    @scroll = 0 if @scroll < 0
                    doRefresh = true
                else
                    pbPlayBuzzerSE
                end
            elsif Input.repeat?(Input::JUMPDOWN)
                offsetMax = @currentMoveList.length - 1
                if @scroll < offsetMax
                    pbPlayCursorSE
                    @scroll += MAX_LENGTH_MOVE_LIST
                    @scroll = offsetMax if @scroll > offsetMax
                    doRefresh = true
                else
                    pbPlayBuzzerSE
                end
            elsif Input.trigger?(Input::BACK)
                pbPlayCancelSE
                @scroll = -1
                drawPage
                break
            end
            drawPage if doRefresh
        end
    end
end