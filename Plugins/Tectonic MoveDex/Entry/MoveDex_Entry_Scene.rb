class MoveDex_Entry_Scene
    MAX_LENGTH_SPECIES_LIST = 10
	SPECIES_LIST_Y_INIT = 52
    SPECIES_LIST_COLUMN_1_X_LEFT = 20
    SPECIES_LIST_COLUMN_X_OFFSET = 260

    def pageTitles
        return [_INTL("LEVEL LEARNERS"), _INTL("OTHER LEARNERS")]
    end

    def pbStartScene(movedexlist, index)
        @movedexlist = movedexlist
        @index = index
        @page = 0

        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @scroll   = -1
        @columnSelected = 0
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["selectionarrow"] = IconSprite.new(0, 0, @viewport)
        @sprites["selectionarrow"].setBitmap("Graphics/Pictures/selarrow")
        @sprites["selectionarrow"].visible = false
        @sprites["selectionarrow"].x = SPECIES_LIST_COLUMN_1_X_LEFT - 16

        updateMove

        drawPage

        navigateMoveEntry

        return @index
    end

    def updateMove
        @move = @movedexlist[@index][:id]
        @moveData = @movedexlist[@index][:data]
        generateCurrentPageSpeciesList
    end

    def generateLevelUpLearnablesSpeciesList
        @currentSpeciesList = [[],[]]
        levelUpLearners = @moveData.level_up_learners.clone
        levelUpLearners.sort_by! { |learningEntry|
            learningEntry[1]
        }
        levelUpLearners.reject! { |learningEntry|
            !speciesInfoViewable?(learningEntry[1])
        }
        columnCutoff = (levelUpLearners.length / 2.0).ceil
        levelUpLearners.each_with_index do |learningEntry, index|
            if index < columnCutoff
                columnIndex = 0
            else
                columnIndex = 1
            end
            @currentSpeciesList[columnIndex].push(learningEntry)
        end
    end

    def generateOtherLearnablesSpeciesList
        @currentSpeciesList = [[],[]]
        otherLearners = @moveData.other_learners.clone
        otherLearners.sort_by! { |speciesID|
            GameData::Species.get(speciesID).name
        }
        otherLearners.reject! { |speciesID|
            !speciesInfoViewable?(speciesID)
        }
        columnCutoff = (otherLearners.length / 2.0).ceil
        otherLearners.each_with_index do |speciesID,index|
            if index < columnCutoff
                columnIndex = 0
            else
                columnIndex = 1
            end
            @currentSpeciesList[columnIndex].push(speciesID)
        end
    end

    def generateCurrentPageSpeciesList
        case @page
        when 0
            generateLevelUpLearnablesSpeciesList
        when 1
            generateOtherLearnablesSpeciesList
        end
    end

    def drawPage
        overlay = @sprites["overlay"].bitmap
        base = Color.new(219, 240, 240)
        shadow = Color.new(88, 88, 80)

        overlay.clear

        # Draw page title
        pageTitle = pageTitles[@page]
        drawFormattedTextEx(overlay, 50, 4, Graphics.width, "<outln2>#{pageTitle}</outln2>", base, shadow, 18)

        # Draw species name on top right	
        drawFormattedTextEx(overlay, 300, 4, Graphics.width, "<outln2>#{@moveData.name}</outln2>", base, shadow, 18)

        case @page
        when 0
            drawLevelUpLearnablesPage
        when 1
            drawOtherLearnablesPage
        end
    end

    def drawLevelUpLearnablesPage
        bg_path = "Graphics/Pictures/Movedex/bg_move_level_learners"
        bg_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(_INTL(bg_path))

        overlay = @sprites["overlay"].bitmap
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor

		# render the moves lists
        @selected_species = nil
        if @currentSpeciesList[0].empty?
            drawSpeciesColumn(overlay,[_INTL("None")], [], 0)
		else
            [0,1].each do |columnIndex|
                speciesColumn = @currentSpeciesList[columnIndex]
                next if speciesColumn.empty?
                speciesLabelList = []
                levelLabelList = []
                listIndex = -1
                speciesColumn.each do |learnableEntry|

                    speciesID = learnableEntry[0]
                    speciesLabelList.push(GameData::Species.get(speciesID).name)

                    level = learnableEntry[1]
                    level = level == 0 ? _INTL("E") : level.to_s
                    levelLabelList.push(level)

                    listIndex += 1
                    if listIndex == @scroll && columnIndex == @columnSelected
                        @selected_species = speciesID
                    end
                end
                drawSpeciesColumn(overlay,speciesLabelList,levelLabelList,columnIndex)
            end
		end
    end

    def drawOtherLearnablesPage
        bg_path = "Graphics/Pictures/Movedex/bg_move_all_learners"
        bg_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(_INTL(bg_path))

        overlay = @sprites["overlay"].bitmap
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor

		# render the moves lists
        @selected_species = nil
        if @currentSpeciesList[0].empty?
            drawSpeciesColumn(overlay,[_INTL("None")], [], 0)
		else
            [0,1].each do |columnIndex|
                speciesColumn = @currentSpeciesList[columnIndex]
                next if speciesColumn.empty?
                speciesLabelList = []
                listIndex = -1
                speciesColumn.each do |speciesID|
                    speciesLabelList.push(GameData::Species.get(speciesID).name)

                    listIndex += 1
                    if listIndex == @scroll && columnIndex == @columnSelected
                        @selected_species = speciesID
                    end
                end
                drawSpeciesColumn(overlay,speciesLabelList, [], columnIndex)
            end
		end
    end

    def drawSpeciesColumn(overlay,speciesLabelList,levelLabelsList,columnIndex)
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor

        displayIndex = 0
		listIndex = -1
        speciesLabelList.each_with_index do |speciesLabel, index|
            listIndex += 1
            next if listIndex < @scroll
            speciesDrawX, speciesDrawY = getSpeciesDisplayCoordinates(displayIndex,columnIndex)
            drawFormattedTextEx(overlay, speciesDrawX , speciesDrawY, 450, speciesLabel, base, shadow)
            if levelLabelsList[index]
                levelDrawX = 212 + (columnIndex * 260)
                levelLabel = levelLabelsList[index]
                drawFormattedTextEx(overlay, levelDrawX, speciesDrawY, 42, levelLabel, base, shadow)
            end
            displayIndex += 1
            break if displayIndex > MAX_LENGTH_SPECIES_LIST
        end
    end

    def getSpeciesDisplayCoordinates(displayIndex,columnIndex)
        speciesDrawX = SPECIES_LIST_COLUMN_1_X_LEFT + SPECIES_LIST_COLUMN_X_OFFSET * columnIndex
        speciesDrawY = SPECIES_LIST_Y_INIT + 32 * displayIndex
        return speciesDrawX, speciesDrawY
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbScroll
        @scroll = 0
        @columnSelected = 0

        linesShown = 7

        updateSelectionArrow
        @sprites["selectionarrow"].visible = true

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
                if @scroll < @currentSpeciesList[@columnSelected].length - 1
                    pbPlayCursorSE
                    @scroll = @currentSpeciesList[@columnSelected].length - 1
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
                    @scroll = @currentSpeciesList[@columnSelected].length - 1
                    doRefresh = true
                end
            elsif Input.repeat?(Input::DOWN)
                if @scroll < @currentSpeciesList[@columnSelected].length - 1
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
                    @scroll -= MAX_LENGTH_SPECIES_LIST
                    @scroll = 0 if @scroll < 0
                    doRefresh = true
                else
                    pbPlayBuzzerSE
                end
            elsif Input.repeat?(Input::JUMPDOWN)
                offsetMax = @currentSpeciesList[@columnSelected].length - 1
                if @scroll < offsetMax
                    pbPlayCursorSE
                    @scroll += MAX_LENGTH_SPECIES_LIST
                    @scroll = offsetMax if @scroll > offsetMax
                    doRefresh = true
                else
                    pbPlayBuzzerSE
                end
            elsif Input.repeat?(Input::LEFT)
                if @columnSelected > 0
                    pbPlayCursorSE
                    @columnSelected -= 1
                    fixScrollOnColumnChance
                    doRefresh = true
                elsif Input.trigger?(Input::LEFT)
                    pbPlayCursorSE
                    @columnSelected = @currentSpeciesList.length - 1
                    fixScrollOnColumnChance
                    doRefresh = true
                end
            elsif Input.repeat?(Input::RIGHT)
                if @columnSelected < @currentSpeciesList.length - 1
                    pbPlayCursorSE
                    @columnSelected += 1
                    fixScrollOnColumnChance
                    doRefresh = true
                elsif Input.trigger?(Input::RIGHT)
                    pbPlayCursorSE
                    @columnSelected = 0
                    fixScrollOnColumnChance
                    doRefresh = true
                end
            elsif Input.trigger?(Input::BACK)
                pbPlayCancelSE
                @scroll = -1
                drawPage
                break
            end
            if doRefresh
                updateSelectionArrow
                drawPage
            end
        end

        @sprites["selectionarrow"].visible = false
    end

    def updateSelectionArrow
        speciesDrawX, speciesDrawY = getSpeciesDisplayCoordinates(0,@columnSelected)
        @sprites["selectionarrow"].x = speciesDrawX - 16
        @sprites["selectionarrow"].y = speciesDrawY - 4
    end

    def fixScrollOnColumnChance
        @scroll = [@scroll,@currentSpeciesList[@columnSelected].length-1].min
    end

    def navigateMoveEntry
        highestLeftRepeat = 0
        highestRightRepeat = 0
        loop do
            Graphics.update
            Input.update
            pbUpdate
            dorefresh = false

            if Input.trigger?(Input::USE)
                pbPlayDecisionSE
                pbScroll
            elsif Input.trigger?(Input::BACK)
                pbPlayCloseMenuSE
                break
            elsif Input.repeat?(Input::LEFT)
                highestRightRepeat = 0
                repeats = 1 + Input.time?(Input::LEFT) / 100_000
                if repeats > highestLeftRepeat
                    highestLeftRepeat = repeats
                    oldpage = @page
                    @page -= 1
                    @page = pageTitles.length - 1 if @page < 0 # Wrap around
                    if @page != oldpage
                        generateCurrentPageSpeciesList
                        @scroll = -1
                        @columnSelected = 0
                        pbPlayCursorSE
                        dorefresh = true
                    end
                end
            elsif Input.repeat?(Input::RIGHT)
                highestLeftRepeat = 0
                repeats = 1 + Input.time?(Input::RIGHT) / 100_000
                if repeats > highestRightRepeat
                    highestRightRepeat = repeats
                    oldpage = @page
                    @page += 1
                    @page = 0 if @page > pageTitles.length - 1 # Wrap around
                    if @page != oldpage
                        generateCurrentPageSpeciesList
                        @scroll = -1
                        @columnSelected = 0
                        pbPlayCursorSE
                        dorefresh = true
                    end
                end
            elsif Input.pressex?(:NUMBER_1)
                dorefresh = true if moveToPage(1)
            elsif Input.pressex?(:NUMBER_2)
                dorefresh = true if moveToPage(2)
            elsif Input.repeat?(Input::UP)
				oldindex = @index
                pbGoToPrevious
                if @index != oldindex
                    @scroll = -1
                    @columnSelected = 0
                    pbSEStop
                    updateMove
                    dorefresh = true
                end
            elsif Input.repeat?(Input::DOWN)
				oldindex = @index
                pbGoToNext
                if @index != oldindex
                    @scroll = -1
                    @columnSelected = 0
                    pbSEStop
                    updateMove
                    dorefresh = true
                end
            end

            drawPage if dorefresh
        end
    end

    def moveToPage(pageNum)
        oldpage = @page
        @page = pageNum
        @page = 1 if @page < 1
        @page = 10 if @page > 10
        if @page != oldpage
            @scroll = -1
            pbPlayCursorSE
            return true
        end
        return false
    end

    def pbGoToPrevious
        newindex = @index
        while newindex > 0
            newindex -= 1
            newMove = @movedexlist[newindex][:id]
            if moveInfoViewable?(newMove)
                @index = newindex
                break
            end
        end
    end

    def pbGoToNext
        newindex = @index
        while newindex < @movedexlist.length - 1
            newindex += 1
            newMove = @movedexlist[newindex][:id]
            if moveInfoViewable?(newMove)
                @index = newindex
                break
            end
        end
    end
end

# The player cannot see the signature movess of legendary pokemon not yet discovered
def moveInfoViewable?(moveID)
    return true if $DEBUG
    moveData = GameData::Move.get(moveID)
    return true unless moveData.is_signature?
    signatureSpecies = moveData.signature_of
    return true unless GameData::Species.get(signatureSpecies).isLegendary?
    return true if $Trainer.seen?(signatureSpecies)
    return false
end