class TribalBonusScene
    def pbStartScene
        playerTribalBonus().updateTribeCount()

        # Set up the two viewports to hold UI elements
        @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport1.z = 99999
        @sprites = {}

        # Set up all the sprites
        @sprites["background"] = IconSprite.new(0,0,@viewport1)
        bg_path = "Graphics/Pictures/bg_tribes"
        bg_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(_INTL(bg_path))

        @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport1)
        pbSetSystemFont(@sprites["overlay"].bitmap)

        # Used for Tribal Info page
        @displayText = []
        @offset = 0
        @linesToShow = 9
        @sprites["scroll_arrow_up"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport1)
        @sprites["scroll_arrow_up"].x = (Graphics.width - 28) / 2
        @sprites["scroll_arrow_up"].y = 38
        @sprites["scroll_arrow_up"].visible = false
        @sprites["scroll_arrow_up"].play
        @sprites["scroll_arrow_down"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport1)
        @sprites["scroll_arrow_down"].x = (Graphics.width - 28) / 2
        @sprites["scroll_arrow_down"].y = (Graphics.height - 44)
        @sprites["scroll_arrow_down"].visible = false
        @sprites["scroll_arrow_down"].play
        @sprites["scroll_bar"] = IconSprite.new(0,0,@viewport1)
        @sprites["scroll_bar"].setBitmap("Graphics/Pictures/scroll_bar")
        @sprites["scroll_bar"].x = Graphics.width - 32
        @sprites["scroll_bar"].y = 48
        @sprites["scroll_bar"].visible = true
        @tribalMemberIcons = {}

        tribalTracker = playerTribalBonus()

        tribeCounts = tribalTracker.tribeCounts.clone
        tribeCounts = tribeCounts.sort_by { |k,v| -v}.to_h
        @memberIconLineIndexes = []
        lineIndex = 0
        tribeCounts.each {|tribeID, count, index|
            @memberIconLineIndexes.push([tribeID,lineIndex])

            tribeName = getTribeName(tribeID)
            tribeData = GameData::Tribe.get(tribeID)
            titleText = "<u>#{tribeName} (#{count}/#{tribeData.threshold})</u>"
            titleText = "<b>#{titleText}</b>" if count >= tribeData.threshold
            @displayText << titleText
            lineIndex += 1
            bonusDescription = tribeData.description

            # Put in the curren value for the scaling stat bonuses
            smallBonus = tribalTracker.getSingleStatBonusSmall(getLevelCap)
            bonusDescription.gsub!("{b}","<b>#{smallBonus.to_s}</b>")
            mediumBonus = tribalTracker.getSingleStatBonusMedium(getLevelCap)
            bonusDescription.gsub!("{b1}","<b>#{mediumBonus.to_s}</b>")
            largeBonus = tribalTracker.getSingleStatBonusLarge(getLevelCap)
            bonusDescription.gsub!("{b2}","<b>#{largeBonus.to_s}</b>")

            break_string(bonusDescription, 40).each {|line|
                @displayText << line
                lineIndex += 1
            }
            @displayText << "\n" unless index == tribeCounts.size - 1
            lineIndex += 1

            # Create the sprites
            memberIcons = []
            @tribalMemberIcons[tribeID] = memberIcons
            memberIndex = 0
            $Trainer.party.each do |partyMember|
                next unless partyMember.tribes.include?(tribeID)
                newPokemonSprite = PokemonIconSprite.new(partyMember,@viewport1)
                newPokemonSprite.visible = false
                memberIcons.push(newPokemonSprite)
                @sprites["member_icon_#{tribeID}_#{memberIndex}"] = newPokemonSprite
                memberIndex += 1
            end

            # Right align the icons
            iconsTotalWidth = memberIcons.length * 40
            memberIcons.each_with_index do |memberIcon,index|
                memberIcon.x = Graphics.width - 60 - iconsTotalWidth + index * 40
            end
        }

        pbFadeInAndShow(@sprites) { pbUpdate }

        @base   = MessageConfig.pbDefaultTextMainColor
        @shadow = MessageConfig.pbDefaultTextShadowColor

        @titlebase = MessageConfig::LIGHT_TEXT_MAIN_COLOR
        @titleshadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
        
        drawPage()
    end

    def drawPage()
        # Draw page title
        overlay = @sprites["overlay"].bitmap
        overlay.clear

        pbDrawImagePositions(overlay,[["Graphics/Pictures/icon_tribal_bonus",20,6]])

        drawFormattedTextEx(overlay, 50, 4, Graphics.width, _INTL("<outln2>Tribal Bonus Info</outln2>"), @titlebase, @titleshadow, 18)

        @sprites["scroll_arrow_up"].visible = @offset > 0
        @sprites["scroll_arrow_down"].visible = @offset < @displayText.length - @linesToShow
        
        overlay = @sprites["overlay"].bitmap
        xLeft = 36
        coordinateY = 32

        @memberIconLineIndexes.each do |entry|
            tribeID = entry[0]
            lineIndex = entry[1]
            if lineIndex >= @offset && lineIndex < @offset + @linesToShow
                @tribalMemberIcons[tribeID].each do |iconSprite|
                    iconSprite.visible = true
                    iconSprite.y = 32 + 30 * (lineIndex - @offset)
                end
            else
                @tribalMemberIcons[tribeID].each do |iconSprite|
                    iconSprite.visible = false
                end
            end
        end

        @displayText[@offset..@offset+@linesToShow].each {|line|
            drawFormattedTextEx(overlay, xLeft, coordinateY += 30, 450, line, @base, @shadow)
        }

        @sprites["scroll_bar"].y = 48 + (Graphics.width - 192) * (@offset / @displayText.length.to_f)
    end    

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport1.dispose
    end

    def pbScene
        returnIndex = 0

        Graphics.update
        Input.update
        pbUpdate
        dorefresh = false

        offsetMax = @displayText.length - @linesToShow
        
        if Input.repeat?(Input::UP)
            # Scroll up on the Tribal Info page if not already at the top
            if @offset > 0
                @offset = @offset - 1
                dorefresh = true
            elsif Input.trigger?(Input::UP)
                @offset = offsetMax
                dorefresh = true
            end
        elsif Input.repeat?(Input::DOWN)
            # Scroll down on the Tribal Info page if not already at the bottom
            if @offset < offsetMax
                @offset = @offset + 1
                dorefresh = true
            elsif Input.trigger?(Input::DOWN)
                @offset = 0
                dorefresh = true
            end
        elsif Input.repeat?(Input::JUMPUP) # Jump multiple lines
            if @offset > 0
                @offset = @offset - @linesToShow
                @offset = 0 if @offset < 0
                dorefresh = true
            end
        elsif Input.repeat?(Input::JUMPDOWN)
            if @offset < offsetMax
                @offset = @offset + @linesToShow
                @offset = offsetMax if @offset > offsetMax
                dorefresh = true
            end
        elsif Input.trigger?(Input::BACK)
            returnIndex = -1
        end
        
        # If the page has changed, redraw the page
        if dorefresh
            pbPlayCursorSE
            drawPage()
        end
        
        return returnIndex
    end
end

########################################################################################################################
########################################################################################################################
########################################################################################################################
class TribalBonusScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen
        @scene.pbStartScene()
        loop do
            cmd = @scene.pbScene
            break if cmd < 0   # Cancel/Exit
        end
        @scene.pbEndScene
    end
end
