class MoveDex_Entry_Scene
    attr_reader :sprites
    attr_reader :viewport

    MAX_LENGTH_SPECIES_LIST = 10
	SPECIES_LIST_Y_INIT = 52
    SPECIES_LIST_COLUMN_1_X_LEFT = 20
    SPECIES_LIST_COLUMN_X_OFFSET = 260

    def pageTitles
        return [_INTL("BY LEVEL"), _INTL("BY OTHER"), _INTL("MATCHUPS"), _INTL("DETAILS"), _INTL("ANIMATION")]
    end

    def pbStartScene(movedexlist, index)
        @movedexlist = movedexlist
        @index = index
        @page = 1

        updateMove

        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @scroll   = -1
        @columnSelected = 0
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)

        @speciesLinesToShow = 9
        @sprites["selectionarrow"] = IconSprite.new(0, 0, @viewport)
        @sprites["selectionarrow"].setBitmap("Graphics/Pictures/selarrow")
        @sprites["selectionarrow"].visible = false
        @sprites["selectionarrow"].x = SPECIES_LIST_COLUMN_1_X_LEFT - 16

        @typebitmap = AnimatedBitmap.new(addLanguageSuffix(("Graphics/Pictures/Pokedex/icon_types")))

        @detailLinesToShow = 9
        @sprites["scroll_arrow_up"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
        @sprites["scroll_arrow_up"].x = (Graphics.width - 28) / 2
        @sprites["scroll_arrow_up"].y = 38
        @sprites["scroll_arrow_up"].visible = false
        @sprites["scroll_arrow_up"].play
        @sprites["scroll_arrow_down"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
        @sprites["scroll_arrow_down"].x = (Graphics.width - 28) / 2
        @sprites["scroll_arrow_down"].y = (Graphics.height - 44)
        @sprites["scroll_arrow_down"].visible = false
        @sprites["scroll_arrow_down"].play

        @animations = pbLoadBattleAnimations
        @sprites["pokemon_0"] = Sprite.new(@viewport)
        @sprites["pokemon_0"].z = 21
        @sprites["pokemon_1"] = Sprite.new(@viewport)
        @sprites["pokemon_1"].z = 16
        @sprites["animation_black_bars"] = IconSprite.new(0, 32, @viewport)
        @sprites["animation_black_bars"].setBitmap("Graphics/Pictures/Movedex/bg_move_animation_black_bars")
        @sprites["animation_black_bars"].z = 999_999

        drawPage

        navigateMoveEntry

        return @index
    end

    def updateMove
        @move = @movedexlist[@index][:move]
        @moveData = @movedexlist[@index][:data]
        @battleMoveObject = PokeBattle_Move.from_pokemon_move(nil, Pokemon::Move.new(@move))

        # Generate and set species lists
        generateLevelUpLearnablesSpeciesList
        generateOtherLearnablesSpeciesList
        setCurrentPageSpeciesList

        # Get move details, split into manageable lines
        baseMoveDetails = []
        @battleMoveObject.getDetailsForMoveDex(baseMoveDetails)
        @moveDetailsText = []
        baseMoveDetails.each do |baseMoveDetailLine|
            break_string(baseMoveDetailLine, 40).each {|line|
                @moveDetailsText << line
            }
        end

        # Gather data for the animation
        @defaultMoveUser = @moveData.signature_of || getRandomNonLegendaryLearner
        @defaultMoveTarget = getRandomNonLegendaryLearner
        @targetingData = GameData::Target.get(@moveData.target)
    end

    def getRandomNonLegendaryLearner
        return :PIKACHU if @otherLearnables.empty?
        speciesData = nil
        loop do
            speciesData = GameData::Species.get(@otherLearnables.sample)
            break if speciesData.form == 0
        end
        return speciesData.id
    end

    def generateLevelUpLearnablesSpeciesList
        @levelUpLearnables = @moveData.level_up_learners.clone
        @levelUpLearnables.sort_by! { |learningEntry|
            learningEntry[1]
        }
        @levelUpLearnables.reject! { |learningEntry|
            !speciesInfoViewable?(learningEntry[1])
        }
    end

    def generateOtherLearnablesSpeciesList
        @otherLearnables = @moveData.other_learners.clone
        @otherLearnables.sort_by! { |speciesID|
            GameData::Species.get(speciesID).name
        }
        @otherLearnables.reject! { |speciesID|
            !speciesInfoViewable?(speciesID)
        }
    end

    def setCurrentPageSpeciesList
        case @page
        when 1
            newSpeciesList = @levelUpLearnables
        when 2
            newSpeciesList = @otherLearnables
        end

        @currentSpeciesList = [[],[]]
        if newSpeciesList
            columnCutoff = (newSpeciesList.length / 2.0).ceil
            newSpeciesList.each_with_index do |listEntry, index|
                if index < columnCutoff
                    columnIndex = 0
                else
                    columnIndex = 1
                end
                @currentSpeciesList[columnIndex].push(listEntry)
            end
        end
    end

    def drawPage
        overlay = @sprites["overlay"].bitmap
        base = Color.new(219, 240, 240)
        shadow = Color.new(88, 88, 80)

        overlay.clear

        # Draw page title
        pageTitle = pageTitles[@page-1]
        drawFormattedTextEx(overlay, 50, 4, Graphics.width, "<outln2>#{pageTitle}</outln2>", base, shadow, 18)

        drawFormattedTextEx(overlay, 212, 2, Graphics.width, "<outln2>[#{@page}/#{pageTitles.length}]</outln2>", base, shadow, 18)

        # Draw move name on top right	
        moveName = getFormattedMoveName(@moveData.name,148)
        drawFormattedTextEx(overlay, 316, 4, Graphics.width, "<outln2>#{moveName}</outln2>", base, shadow, 18)

        @sprites["scroll_arrow_up"].visible = false
        @sprites["scroll_arrow_down"].visible = false
        @sprites["pokemon_0"].visible = @page == 5
        @sprites["pokemon_1"].visible = @page == 5
        @sprites["animation_black_bars"].visible = @page == 5
        
        case @page
        when 1
            drawLevelUpLearnablesPage
        when 2
            drawOtherLearnablesPage
        when 3
            drawTypeMatchupsPage
        when 4
            drawOtherDetailsPage
        when 5
            drawMoveAnimationPage
        end
    end

    # Chop letters off of excessively long names to make them fit into the maximum width
    def getFormattedMoveName(moveName, maxWidth = 99_999)
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
        return moveName
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

        updateSpeciesPageScrollArrows
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

        updateSpeciesPageScrollArrows
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

    def updateSpeciesPageScrollArrows
        @sprites["scroll_arrow_up"].visible = @scroll > 0
        @sprites["scroll_arrow_down"].visible = canScrollSpeciesList? && @scroll <= @currentSpeciesList[0].length - @speciesLinesToShow
    end
    
    def drawTypeMatchupsPage
        bg_path = "Graphics/Pictures/Movedex/bg_move_matchups"
        bg_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(_INTL(bg_path))
        overlay = @sprites["overlay"].bitmap
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor

        xLeft = 36
        yBase = 60

        if @moveData.status?
            statusLabel = _INTL("Status")
            statusLabelWidth = @sprites["overlay"].bitmap.text_size(statusLabel).width
            drawTextEx(overlay, Graphics.width / 2 - statusLabelWidth / 2, 80, 450, 1, statusLabel, base, shadow)
        else
            immuneTypes = []
            resistentTypes = []
            weakTypes = []

            GameData::Type.each do |t|
                next if t.pseudo_type

                effect = @battleMoveObject.pbCalcTypeModSingle(@moveData.type, t.id) ** 3

                if Effectiveness.ineffective?(effect)
                    immuneTypes.push(t)
                elsif Effectiveness.not_very_effective?(effect)
                    resistentTypes.push(t)
                elsif Effectiveness.super_effective?(effect)
                    weakTypes.push(t)
                end
            end

            # Draw the types the move is super effective against
            drawTextEx(overlay, xLeft, yBase, 450, 1, _INTL("Super:"), base, shadow)
            if weakTypes.length == 0
                drawTextEx(overlay, xLeft, yBase + 30, 450, 1, _INTL("None"), base, shadow)
            else
                weakTypes.each_with_index do |t, index|
                    type_number = GameData::Type.get(t).id_number
                    typerect = Rect.new(0, type_number * 32, 96, 32)
                    overlay.blt(xLeft + (index >= 7 ? 100 : 0), yBase + 30 + 36 * (index % 7), @typebitmap.bitmap,
                typerect)
                end
            end

            # Draw the types the move deals NVE damage to
            resistOffset = 212
            drawTextEx(overlay, xLeft + resistOffset, yBase, 450, 1, _INTL("Not Very:"), base, shadow)
            if resistentTypes.length == 0
                drawTextEx(overlay, xLeft + resistOffset, yBase + 30, 450, 1, _INTL("None"), base, shadow)
            else
                resistentTypes.each_with_index do |t, index|
                    type_number = GameData::Type.get(t).id_number
                    typerect = Rect.new(0, type_number * 32, 96, 32)
                    overlay.blt(xLeft + resistOffset, yBase + 30 + 36 * index, @typebitmap.bitmap, typerect)
                end
            end

            # Draw the types the move deals immune damage to
            immuneOffset = 324
            drawTextEx(overlay, xLeft + immuneOffset, yBase, 450, 1, _INTL("No Effect:"), base, shadow)
            if immuneTypes.length == 0
                drawTextEx(overlay, xLeft + immuneOffset, yBase + 30, 450, 1, _INTL("None"), base, shadow)
            else
                immuneTypes.each_with_index do |t, index|
                    type_number = GameData::Type.get(t).id_number
                    typerect = Rect.new(0, type_number * 32, 96, 32)
                    overlay.blt(xLeft + immuneOffset, yBase + 30 + 36 * index, @typebitmap.bitmap, typerect)
                end
            end
        end
    end

    def drawOtherDetailsPage
        bg_path = "Graphics/Pictures/Movedex/bg_move_other_details"
        bg_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(_INTL(bg_path))

        overlay = @sprites["overlay"].bitmap
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor

        @sprites["scroll_arrow_up"].visible = @scroll > 0
        @sprites["scroll_arrow_down"].visible = @scroll < @moveDetailsText.length - @detailLinesToShow - 1

        if @moveDetailsText.empty?
            statusLabel = _INTL("None")
            statusLabelWidth = @sprites["overlay"].bitmap.text_size(statusLabel).width
            drawTextEx(overlay, Graphics.width / 2 - statusLabelWidth / 2, 80, 450, 1, statusLabel, base, shadow)
        else
            xLeft = 36
            yBase = 60
            displayIndex = 0
            @moveDetailsText[@scroll..@scroll+@detailLinesToShow].each do |moveDetailLine|
                drawFormattedTextEx(overlay, xLeft, yBase + 30 * displayIndex, 800, moveDetailLine, base, shadow, 30)
                displayIndex += 1
            end
        end
    end

    def drawMoveAnimationPage
        bg_path = "Graphics/Pictures/Movedex/bg_move_animation"
        @sprites["background"].setBitmap(_INTL(bg_path))

        overlay = @sprites["overlay"].bitmap
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor

        animID = PokeBattle_Scene.pbFindMoveAnimation(@move,0,0)
        @animation = @animations[animID[0]]

        @player = nil
        @battle = MiniBattle.new
        @user = GameData::Species.back_sprite_bitmap(@defaultMoveUser).deanimate
        @target = GameData::Species.front_sprite_bitmap(@defaultMoveTarget).deanimate

        battlerSpriteYOffset = 48

        @sprites["pokemon_0"].bitmap = @user
        @sprites["pokemon_1"].bitmap = @target
        userSpriteMetrics = GameData::SpeciesMetrics.get_species_form(@defaultMoveUser,0)
        userSpriteX = PokeBattle_SceneConstants::FOCUSUSER_X
        userSpriteY = PokeBattle_SceneConstants::FOCUSUSER_Y + battlerSpriteYOffset
        pbSpriteSetAnimFrame(@sprites["pokemon_0"],
            pbCreateCel(userSpriteX,userSpriteY,-1,2),
            @sprites["pokemon_0"],@sprites["pokemon_1"])
        userSpriteMetrics.apply_metrics_to_sprite(@sprites["pokemon_0"],0)

        targetSpeciesMetrics = GameData::SpeciesMetrics.get_species_form(@defaultMoveTarget,0)
        targetSpriteX = PokeBattle_SceneConstants::FOCUSTARGET_X
        targetSpriteY = PokeBattle_SceneConstants::FOCUSTARGET_Y + battlerSpriteYOffset
        pbSpriteSetAnimFrame(@sprites["pokemon_1"],
            pbCreateCel(targetSpriteX,targetSpriteY,-2,1),
            @sprites["pokemon_0"],@sprites["pokemon_1"])
        targetSpeciesMetrics.apply_metrics_to_sprite(@sprites["pokemon_1"],1)
    end

    def playAnimation(oppmove = false,speedMult = 1.0)
        userSprite = @sprites["pokemon_#{oppmove ? 1 : 0}"]
        targetSprite = @sprites["pokemon_#{oppmove ? 0 : 1}"]
        oldUserX = userSprite ? userSprite.x : 0
        oldUserY = userSprite ? userSprite.y : 0
        oldTargetX = targetSprite ? targetSprite.x : 0
        oldTargetY = targetSprite ? targetSprite.y : 0
        user = @battle.battlers[oppmove ? 1 : 0]
        target = @battle.battlers[oppmove ? 0 : 1]
        target = nil unless @targetingData.targets_foe
        target = user if @targetingData.targets_user
        @player = PBAnimationPlayerX.new(@animation,user,target,self,oppmove,false,speedMult)
        @player.setLineTransform(
           PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
           PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
           oldUserX,oldUserY,
           oldTargetX,oldTargetY)
        @player.start
        loop do
            Graphics.update
            break if @player.animDone?
            @player.update
        end
        @player.dispose
        # Return Pokémon sprites to their original positions
        if userSprite
            userSprite.x = oldUserX
            userSprite.y = oldUserY
            userSprite.visible = true
            userSprite.opacity = 255
        end
        if targetSprite
            targetSprite.x = oldTargetX
            targetSprite.y = oldTargetY
            targetSprite.visible = true
            targetSprite.opacity = 255
            targetSprite.tone
        end
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
        @typebitmap.dispose
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbScrollSpeciesList
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
                @scroll = 0
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

    def pbScrollDetailsList
        @scroll = 0

        length = @moveDetailsText.length
        offsetMax = length - @detailLinesToShow - 1

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
                if @scroll < offsetMax
                    pbPlayCursorSE
                    @scroll = offsetMax
                    doRefresh = true
                else
                    pbPlayCursorSE
                end
            elsif Input.repeat?(Input::UP)
                if @scroll > 0
                    pbPlayCursorSE
                    @scroll -= 1
                    doRefresh = true
                end
            elsif Input.repeat?(Input::DOWN)
                if @scroll < offsetMax
                    pbPlayCursorSE
                    @scroll += 1
                    doRefresh = true
                end
            elsif Input.repeat?(Input::JUMPUP) # Jump multiple lines
                if @scroll > 0
                    pbPlayCursorSE
                    @scroll -= @detailLinesToShow
                    @scroll = 0 if @scroll < 0
                    doRefresh = true
                else
                    pbPlayBuzzerSE
                end
            elsif Input.repeat?(Input::JUMPDOWN)
                if @scroll < offsetMax
                    pbPlayCursorSE
                    @scroll += @detailLinesToShow
                    @scroll = offsetMax if @scroll > offsetMax
                    doRefresh = true
                else
                    pbPlayBuzzerSE
                end
            elsif Input.trigger?(Input::BACK)
                pbPlayCancelSE
                @scroll = 0
                drawPage
                break
            end
            drawPage if doRefresh
        end
    end

    def updateSelectionArrow
        speciesDrawX, speciesDrawY = getSpeciesDisplayCoordinates(0,@columnSelected)
        @sprites["selectionarrow"].x = speciesDrawX - 16
        @sprites["selectionarrow"].y = speciesDrawY - 4
    end

    def fixScrollOnColumnChance
        @scroll = [@scroll,@currentSpeciesList[@columnSelected].length-1].min
    end

    def canScrollSpeciesList?
        @currentSpeciesList[0].length > @speciesLinesToShow + 1
    end

    def canScrollDetailsList?
        return @moveDetailsText.length > @detailLinesToShow + 1
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
                if @page == 1 || @page == 2 && canScrollSpeciesList?
                    pbPlayDecisionSE
                    pbScrollSpeciesList
                elsif @page == 4 && canScrollDetailsList?
                    pbPlayDecisionSE
                    pbScrollDetailsList
                elsif @page == 5
                    pbPlayDecisionSE
                    oppMove = Input.press?(Input::CTRL)
                    playAnimation(oppMove,getBattleAnimationSpeedMult)
                end
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
                    @page = pageTitles.length if @page < 1 # Wrap around

                    setCurrentPageSpeciesList
                    @scroll = 0
                    @columnSelected = 0
                    pbPlayCursorSE
                    dorefresh = true
                end
            elsif Input.repeat?(Input::RIGHT)
                highestLeftRepeat = 0
                repeats = 1 + Input.time?(Input::RIGHT) / 100_000
                if repeats > highestRightRepeat
                    highestRightRepeat = repeats
                    oldpage = @page
                    @page += 1
                    @page = 1 if @page > pageTitles.length # Wrap around

                    setCurrentPageSpeciesList
                    @scroll = 0
                    @columnSelected = 0
                    pbPlayCursorSE
                    dorefresh = true
                end
            elsif Input.pressex?(:NUMBER_1)
                dorefresh = true if moveToPage(1)
            elsif Input.pressex?(:NUMBER_2)
                dorefresh = true if moveToPage(2)
            elsif Input.pressex?(:NUMBER_3)
                dorefresh = true if moveToPage(3)
            elsif Input.pressex?(:NUMBER_4)
                dorefresh = true if moveToPage(4)
            elsif Input.pressex?(:NUMBER_5)
                dorefresh = true if moveToPage(5)
            elsif Input.repeat?(Input::UP)
				oldindex = @index
                pbGoToPrevious
                if @index != oldindex
                    @scroll = 0
                    @columnSelected = 0
                    pbSEStop
                    updateMove
                    dorefresh = true
                end
            elsif Input.repeat?(Input::DOWN)
				oldindex = @index
                pbGoToNext
                if @index != oldindex
                    @scroll = 0
                    @columnSelected = 0
                    pbSEStop
                    updateMove
                    dorefresh = true
                end
            else
                highestLeftRepeat = 0
                highestRightRepeat = 0
            end

            drawPage if dorefresh
        end
    end

    def moveToPage(pageNum)
        oldpage = @page
        @page = pageNum
        @page = 1 if @page < 1
        @page = pageTitles.length if @page > pageTitles.length
        if @page != oldpage
            @scroll = 0
            pbPlayCursorSE
            setCurrentPageSpeciesList
            return true
        end
        return false
    end

    def pbGoToPrevious
        newindex = @index
        while newindex > 0
            newindex -= 1
            newMove = @movedexlist[newindex][:move]
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
            newMove = @movedexlist[newindex][:move]
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
    return false if moveData.testMove?
    return true unless moveData.is_signature?
    signatureSpecies = moveData.signature_of
    return true unless GameData::Species.get(signatureSpecies).isLegendary?
    return true if $Trainer.seen?(signatureSpecies)
    return false
end