class MoveDex_Scene
    include MoveInfoDisplay

    MAX_LENGTH_MOVE_LIST = 7
	MOVE_LIST_SUMMARY_MOVE_NAMES_Y_INIT = 56
    MOVE_LIST_X_LEFT = 32
    SIGNATURE_COLOR = Color.new(211, 175, 44)

    def generateMoveList
        moveList = []
        GameData::Move.each do |moveData|
            next unless moveData.learnable?
            next unless moveInfoViewable?(moveData.id)
            dex_item = {
                :move => moveData.id,
                :data => moveData
            }
            moveList.push(dex_item)
        end

        moveList.sort_by! { |dex_item|
            dex_item[:data].name
        }

        return moveList
    end

    def searchStartingList
        return SEARCHES_STACK ? @moveList : generateMoveList
    end

    def autoDisqualifyFromSearch(moveID)
        return !moveInfoViewable?(moveID)
    end

    def pbStartScene(index = 0)
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @scroll   = index
        move_path = "Graphics/Pictures/move_info_display_backwards_l"
        move_path += "_dark" if darkMode?
        @moveInfoDisplayBitmap = AnimatedBitmap.new(_INTL(move_path))
        @sprites = {}

        @searchResults = false
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        setBackground

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

        # Create the search screen sprites
        search_path = "Movedex/bg_search"
        search_path += "_dark" if darkMode?
        addBackgroundPlane(@sprites, "searchbg", search_path, @viewport)
        @sprites["searchoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["searchoverlay"].bitmap)
        @sprites["searchbg"].visible = false
        @searchCursorbitmap	= AnimatedBitmap.new(addLanguageSuffix("Graphics/Pictures/Pokedex/cursor_search"))
        @sprites["searchCursor"] = SpriteWrapper.new(@viewport)
        @sprites["searchCursor"].bitmap = @searchCursorbitmap.bitmap
        @sprites["searchCursor"].visible = false

        @moveList = generateMoveList

        pbRefresh

        navigateMoveDex
    end
    
    def searchResults=(value)
        @searchResults = value
        setBackground
    end

    def setBackground
        bg_path = "Graphics/Pictures/Movedex/bg_moves_main"
        bg_path += "_search" if @searchResults
        bg_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(_INTL(bg_path))
        echoln("Background")
    end

    def pbRefresh
        overlay = @sprites["overlay"].bitmap
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor
        zBase = MessageConfig::LIGHT_TEXT_MAIN_COLOR
        zShadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR

        overlay.clear

        textpos = [
            [_INTL("MoveDex"), Graphics.width / 8, -2, 2, zBase, zShadow],
        ]
        if @searchResults
            textpos.push([_INTL("Search results"), 112, 302, 2, base, shadow])
            textpos.push([@moveList.length.to_s, 112, 334, 2, base, shadow])
            textpos.push([_INTL("ACTION/Z to search further."), Graphics.width - 5, -2, 1, zBase, zShadow])
        else
            textpos.push([_INTL("ACTION/Z to search."), Graphics.width - 5, -2, 1, zBase, zShadow])
        end
        pbDrawTextPositions(overlay, textpos)

        #drawFormattedTextEx(overlay, 164, 2, 450, _INTL("{1} Moves",@moveList.length), base, shadow)

		# render the moves lists
		displayIndex = 0
		listIndex = -1
        @selected_move = nil
        if @moveList.empty?
            drawFormattedTextEx(overlay, MOVE_LIST_X_LEFT, 90, 450, _INTL("None"), base, shadow)
		else
            @moveList.each_with_index do |dex_item, _index|
                listIndex += 1
                next if listIndex < @scroll
                maxWidth = displayIndex == 0 ? 200 : 212
                moveName, moveShadow = getFormattedMoveName(dex_item[:data], 200)
                @selected_move = dex_item[:move] if listIndex == @scroll
                moveDrawY = MOVE_LIST_SUMMARY_MOVE_NAMES_Y_INIT + 32 * displayIndex
                drawFormattedTextEx(overlay, MOVE_LIST_X_LEFT, moveDrawY, 450, moveName, base, moveShadow)
                if listIndex == @scroll
                    @sprites["selectionarrow"].y = moveDrawY - 4
                    @sprites["selectionarrow"].visible = true
                end
                displayIndex += 1
                break if displayIndex > MAX_LENGTH_MOVE_LIST
            end
		end

        drawMoveInfo(@selected_move) if @selected_move
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
        @moveInfoDisplayBitmap.dispose
        @searchCursorbitmap.dispose
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

	def drawMoveInfo(selected_move)
        writeMoveInfoToInfoOverlayBackwardsL(@extraInfoOverlay.bitmap,selected_move) unless selected_move.nil?
    end

    def getFormattedMoveName(move_data, maxWidth = 99_999)
        move_data = GameData::Move.get(move_data) if move_data.is_a?(Symbol)
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
        if move_data.is_signature?
            moveName = "<outln>" + moveName + "</outln>"
            shadow = SIGNATURE_COLOR
        else
            shadow = MessageConfig.pbDefaultTextShadowColor
        end
        return moveName, shadow
    end

    def navigateMoveDex
        @scroll = 0

        linesShown = 7

        loop do
            Graphics.update
            Input.update
            pbUpdate
            doRefresh = false
            if Input.trigger?(Input::UP) && Input.press?(Input::CTRL)
                if @scroll > 0
                    pbPlayCursorSE
                    @scroll = 0
                    doRefresh = true
                else
                    pbPlayCursorSE
                end
            elsif Input.trigger?(Input::DOWN) && Input.press?(Input::CTRL)
                if @scroll < @moveList.length - 1
                    pbPlayCursorSE
                    @scroll = @moveList.length - 1
                    doRefresh = true
                else
                    pbPlayCursorSE
                end
            elsif Input.repeat?(Input::UP)
                if @scroll > 0
                    pbPlayCursorSE
                    @scroll -= 1
                    doRefresh = true
                elsif Input.trigger?(Input::UP)
                    pbPlayCursorSE
                    @scroll = @moveList.length - 1
                    doRefresh = true
                end
            elsif Input.repeat?(Input::DOWN)
                if @scroll < @moveList.length - 1
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
                offsetMax = @moveList.length - 1
                if @scroll < offsetMax
                    pbPlayCursorSE
                    @scroll += MAX_LENGTH_MOVE_LIST
                    @scroll = offsetMax if @scroll > offsetMax
                    doRefresh = true
                else
                    pbPlayBuzzerSE
                end
            elsif Input.trigger?(Input::USE)
                if @selected_move
                    pbFadeOutIn do
                        moveDexEntryScene = MoveDex_Entry_Scene.new
                        screen = MoveDex_Entry_Screen.new(moveDexEntryScene)
                        @scroll = screen.pbStartScreen(@moveList,@scroll)
                        pbRefresh
                    end
                else
                    pbPlayBuzzerSE
                end
            elsif Input.trigger?(Input::BACK)
                if @searchResults
                    pbPlayCancelSE
                    pbCloseSearch
                else
                    pbPlayCancelSE
                    @scroll = -1
                    pbRefresh
                    break
                end
            elsif Input.trigger?(Input::ACTION)
                pbPlayDecisionSE
                pbDexSearch
            else
                for key_index in 1..6 do
                    if Input.pressex?("NUMBER_#{key_index}".to_sym)
                        searchIndex = key_index - 1
                        searchIndex += 6 if Input.press?(Input::CTRL)
                        acceptSearchResults do
                            send SEARCH_METHODS_INDEX[searchIndex]
                        end
                    end
                end
            end
            pbRefresh if doRefresh
        end
    end

    SEARCH_METHODS_INDEX = [
		:searchByMoveName,
		:searchByMoveType,
		:searchByMoveCategory,
		:searchByMoveDescription,
        :searchByMoveMisc,
        :sortByMoveMisc,
	]

    def pbDexSearch
        # Prepare to start the search screen
        oldsprites = pbFadeOutAndHide(@sprites)
        @sprites["searchbg"].visible = true
        @sprites["searchoverlay"].visible = true
        @sprites["searchCursor"].visible = true
        overlay = @sprites["searchoverlay"].bitmap
        overlay.clear
        index = 0
        updateSearchCursor(index)
        oldindex = index

        # Write the button names onto the overlay
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor
        title_base   = MessageConfig::LIGHT_TEXT_MAIN_COLOR
        title_shadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
        xLeft = 92
        xLeft2 = 316
        text_pos = [
            [_INTL("Choose a Search"), Graphics.width / 2, -2, 2, title_base, title_shadow],
            [_INTL("Name"), xLeft, 68, 0, base, shadow],
            [_INTL("Type"), xLeft2, 68, 0, base, shadow],
            [_INTL("Category"), xLeft, 164, 0, base, shadow],
            [_INTL("Text"), xLeft2, 164, 0, base, shadow],
            [_INTL("Filters"), xLeft, 260, 0, base, shadow],
            [_INTL("Sorts"), xLeft2, 260, 0, base, shadow],
        ]
        pbDrawTextPositions(overlay, text_pos)

        # Begin the search screen
        pbFadeInAndShow(@sprites)
        oldIndex = 0
        loop do
            if index != oldIndex
                pbPlayCursorSE
                updateSearchCursor(index)
                oldIndex = index
            end

            Graphics.update
            Input.update
            pbUpdate

            if Input.trigger?(Input::UP)
                index -= 2 unless [0, 1].include?(index)
            elsif Input.trigger?(Input::DOWN)
                index += 2 unless [4, 5].include?(index)
            elsif Input.trigger?(Input::LEFT)
                index -= 1 if index.odd?
            elsif Input.trigger?(Input::RIGHT)
                index += 1 if index.even?
            elsif Input.trigger?(Input::BACK)
                pbPlayCloseMenuSE
                break
            elsif Input.trigger?(Input::USE)
				searchChanged = acceptSearchResults2 do
					send SEARCH_METHODS_INDEX[index]
				end
                if searchChanged
                    break
                else
                    pbPlayCloseMenuSE
                end
            end
        end
        overlay.clear
        pbFadeOutAndHide(@sprites)
        pbRefresh
        pbFadeInAndShow(@sprites, oldsprites)
        Input.update
    end

    def acceptSearchResults(&searchingBlock)
        pbPlayDecisionSE
        begin
            dexlist = searchingBlock.call
            if !dexlist
                # Do nothing
            elsif dexlist.length == 0
                if @searchResults
                    pbMessage(_INTL("Attempted to do a combined search, but no matching moves were found."))
                else
                    pbMessage(_INTL("No matching moves were found."))
                end
            else
                @moveList = dexlist
                self.searchResults = true
                @scroll = 0
                # path = "Graphics/Pictures/Pokedex/bg_listsearch"
                # path += "_dark" if darkMode?
                # @sprites["background"].setBitmap(path)
            end
        rescue StandardError
            pbMessage(_INTL("An unknown error has occured."))
        end
        pbRefresh
    end

    def acceptSearchResults2(&searchingBlock)
        pbPlayDecisionSE
        begin
            dexlist = searchingBlock.call
            if !dexlist
                # Do nothing
            elsif dexlist.length == 0
                if @searchResults
                    pbMessage(_INTL("Attempted to do a combined search, but no matching moves were found."))
                else
                    pbMessage(_INTL("No matching moves were found."))
                end
            else
                @moveList = dexlist
                @scroll = 0
                self.searchResults = true
                return true
            end
        rescue StandardError
            pbMessage(_INTL("An unknown error has occured."))
        end
        return false
    end

    def pbCloseSearch
        oldsprites = pbFadeOutAndHide(@sprites)
        self.searchResults = false
        @moveList = generateMoveList
        for i in 0...@moveList.length
            next if @moveList[i][:move] != @selected_move
            @scroll = i
            pbRefresh
            break
        end
        pbFadeInAndShow(@sprites, oldsprites)
    end

    def updateSearchCursor(index)
        @sprites["searchCursor"].x = index.even? ? 72 : 296
        @sprites["searchCursor"].y = 62 + index / 2 * 96
    end
end