class AchievementsListScene
    def pbStartScene
        # Set up the two viewports to hold UI elements
        @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport1.z = 99999
        @sprites = {}

        # Set up all the sprites
        @sprites["background"] = IconSprite.new(0,0,@viewport1)
        bg_path = "Graphics/Pictures/bg_achievements"
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

        @displayText = ["TEST","TEST2","TEST3","TEST4","TEST5","TEST6","TEST7","TEST8","TEST9","TEST10"]
        
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

        drawFormattedTextEx(overlay, 50, 4, Graphics.width, _INTL("<outln2>Achievements</outln2>"), @titlebase, @titleshadow, 18)

        @sprites["scroll_arrow_up"].visible = @offset > 0
        @sprites["scroll_arrow_down"].visible = @offset < @displayText.length - @linesToShow
        
        overlay = @sprites["overlay"].bitmap
        xLeft = 36
        coordinateY = 32

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
            # Scroll up on the page if not already at the top
            if @offset > 0
                @offset = @offset - 1
                dorefresh = true
            elsif Input.trigger?(Input::UP)
                @offset = offsetMax
                dorefresh = true
            end
        elsif Input.repeat?(Input::DOWN)
            # Scroll down on the page if not already at the bottom
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
