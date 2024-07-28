class AchievementsListScene
    def pbStartScene
        # Set up the two viewports to hold UI elements
        @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport1.z = 99999
        @sprites = {}

        # Set up all the sprites
        @sprites["background"] = IconSprite.new(0,0,@viewport1)
        bg_path = "Graphics/Pictures/bg_achievements"
        bg_path += "_dark" if darkMode?
        @sprites["background"].setBitmap(_INTL(bg_path))

        @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport1)
        pbSetSystemFont(@sprites["overlay"].bitmap)

        # Used for Tribal Info page
        @offset = 0
        @linesToShow = 9
        @sprites["scroll_arrow_up"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport1)
        @sprites["scroll_arrow_up"].x = (Graphics.width - 28) / 2
        @sprites["scroll_arrow_up"].y = 34
        @sprites["scroll_arrow_up"].visible = false
        @sprites["scroll_arrow_up"].play
        @sprites["scroll_arrow_down"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport1)
        @sprites["scroll_arrow_down"].x = (Graphics.width - 28) / 2
        @sprites["scroll_arrow_down"].y = (Graphics.height - 40)
        @sprites["scroll_arrow_down"].visible = false
        @sprites["scroll_arrow_down"].play
        @sprites["scroll_bar"] = IconSprite.new(0,0,@viewport1)
        @sprites["scroll_bar"].setBitmap("Graphics/Pictures/scroll_bar")
        @sprites["scroll_bar"].x = Graphics.width - 32
        @sprites["scroll_bar"].y = 48
        @sprites["scroll_bar"].visible = true

        @page = 1
        @maxPage = 1
        GameData::Achievement.each do |achievementData|
            @maxPage = achievementData.page if achievementData.page > @maxPage
        end

        calculateDisplayText
        
        pbFadeInAndShow(@sprites) { pbUpdate }

        @base   = MessageConfig.pbDefaultTextMainColor
        @shadow = MessageConfig.pbDefaultTextShadowColor

        @titlebase = MessageConfig::LIGHT_TEXT_MAIN_COLOR
        @titleshadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
        
        drawPage()
    end

    def visualHeightOffset
        return -[(@offset - 3),0].max * 32
    end

    def calculateDisplayText
        @displayText = []
        @checkboxesHeights = []

        index = 0
        GameData::Achievement.each do |achievementData|
            next unless @page == achievementData.page
            unlocked = $AchievementsTracker.isAchievementUnlocked?(achievementData.id)

            @displayText << "\n" unless index == 0

            # Place the checkbox
            if unlocked
                checkBoxFileName = "Graphics/Pictures/checkbox_active"
            else
                checkBoxFileName = "Graphics/Pictures/checkbox_inactive"
            end

            checkboxY = @displayText.size * 32 + 56
		    @checkboxesHeights.push([checkBoxFileName,checkboxY])

            if achievementData.hidden && !unlocked && !isAchievementUnlocked?(:BECOME_CHAMPION)
                @displayText << _INTL("<u>???</u>")
                @displayText << _INTL("Achievement hidden.")
            else
                # Add the achievement text
                @displayText << "<u>#{achievementData.name}</u>"

                break_string(achievementData.description, 38).each {|line|
                    @displayText << line
                }
            end
        
            index += 1
        end

        @displayText << _INTL("None") if @displayText.empty?
    end

    def break_string(str, n)
        arr = []
        pos = 0     
        loop do
            break arr if pos == str.size
            if str[pos] == ' '
                pos += 1
            end
            m = str.match(/.{1,#{n}}(?=[ ]|\z)|.{,#{n-1}}[ ]/, pos)
            return nil if m.nil?
            arr << m[0]
            pos += m[0].size
        end
    end

    def drawPage()
        # Draw page title
        overlay = @sprites["overlay"].bitmap
        overlay.clear

        pageName = Settings.achievement_page_names[@page] || _INTL("Unknown")
        drawFormattedTextEx(overlay, 32, 4, Graphics.width, _INTL("<outln2>Achievements: {1}</outln2>",pageName), @titlebase, @titleshadow, 18)
        drawFormattedTextEx(overlay, Graphics.width - 90, 4, Graphics.width, _INTL("[{1}/{2}]",@page,@maxPage), @titlebase, @titleshadow, 18)

        @sprites["scroll_arrow_up"].visible = @offset > 0
        @sprites["scroll_arrow_down"].visible = @offset < @displayText.length - @linesToShow
        
        xLeft = 36
        coordinateY = 28

        rangeStart = @offset
        rangeEnd = [@offset+@linesToShow,@displayText.length].min
        @displayText[rangeStart..rangeEnd].each {|line|
            drawFormattedTextEx(overlay, xLeft, coordinateY += 30, 450, line, @base, @shadow)
        }

        @sprites["scroll_bar"].y = 48 + (Graphics.width - 192) * (@offset / @displayText.length.to_f)

        offsetCheckboxImagePositions = []
        @checkboxesHeights.each do |checkBoxInfo|
            checkboxY = checkBoxInfo[1] - (@offset * 32)
            next unless checkboxY > 40 && checkboxY < 320
            offsetCheckboxImagePositions.push([checkBoxInfo[0],Graphics.width - 72,checkboxY])
        end
        pbDrawImagePositions(overlay,offsetCheckboxImagePositions)
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

        offsetMax = [@displayText.length - @linesToShow,0].max
        
        if Input.repeat?(Input::UP)
            # Scroll up on the page if not already at the top
            if @offset > 0
                @offset -= 1
                dorefresh = true
            elsif Input.trigger?(Input::UP)
                pbPlayBuzzerSE
            end
        elsif Input.repeat?(Input::DOWN)
            # Scroll down on the page if not already at the bottom
            if @offset < offsetMax
                @offset += 1
                dorefresh = true
            elsif Input.trigger?(Input::DOWN)
                pbPlayBuzzerSE
            end
        elsif Input.repeat?(Input::JUMPUP) # Jump multiple lines
            if @offset > 0
                @offset = @offset - @linesToShow
                @offset = 0 if @offset < 0
                dorefresh = true
            elsif Input.trigger?(Input::JUMPUP)
                pbPlayBuzzerSE
            end
        elsif Input.repeat?(Input::JUMPDOWN)
            if @offset < offsetMax
                @offset = @offset + @linesToShow
                @offset = offsetMax if @offset > offsetMax
                dorefresh = true
            elsif Input.trigger?(Input::JUMPDOWN)
                pbPlayBuzzerSE
            end
        elsif Input.trigger?(Input::BACK)
            returnIndex = -1
        elsif Input.trigger?(Input::LEFT)
            if @page > 1
                @page -= 1
                @offset = 0
                calculateDisplayText
                dorefresh = true
            else
                pbPlayBuzzerSE
            end
        elsif Input.trigger?(Input::RIGHT)
            if @page < @maxPage
                @page += 1
                @offset = 0
                calculateDisplayText
                dorefresh = true
            else
                pbPlayBuzzerSE
            end
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
class AchievementsListScreen
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
