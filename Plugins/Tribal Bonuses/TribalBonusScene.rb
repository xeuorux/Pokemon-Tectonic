class TribalBonusScene
	PAGE_TITLES = ["TRIBES", "TRIBE INFO"]

    def drawPage()
        # Draw page title
        overlay = @sprites["overlay"].bitmap
        overlay.clear

        base = Color.new(219, 240, 240)
        shadow   = Color.new(88, 88, 80)
        pageTitle = PAGE_TITLES[@page-1]
        drawFormattedTextEx(overlay, 50, 2, Graphics.width, "<outln2>#{pageTitle}</outln2>", base, shadow, 18)
        xPos = 240
        drawFormattedTextEx(overlay, xPos, 2, Graphics.width, "<outln2>[#{@page}/#{PAGE_TITLES.length()}]</outln2>", base, shadow, 18)

        # Draw page-specific information
        case @page
        when 1; displayTribalBonuses()
        when 2; displayTribalInfo()
        end
    end

    def displayTribalBonuses()
        overlay = @sprites["overlay"].bitmap
        base = Color.new(88,88,88)
        shadow = Color.new(168,184,184)
        xLeft = 36
    
        # Make sure arrows are hidden
        @sprites["scroll_arrow_up"].visible = false
        @sprites["scroll_arrow_down"].visible = false

        drewAny = false
        index = 0
        $Tribal_Bonuses.tribeCounts.each {|tribe, count|
            if count > 0
                tribeName = TribalBonus.getTribeName(tribe)
                coordinateY = 64 + (index % 9) * 32
                drawTextEx(overlay, xLeft + (index / 9) * 240, coordinateY, 450, 1, _INTL("{1}: {2}", tribeName, count), base, shadow)
                drewAny = true
                index += 1
            end
        }
        if !drewAny
            drawTextEx(overlay, xLeft, coordinateY + 30, 450, 1, _INTL("None"), base, shadow)
        end
    end

    def displayTribalInfo()
        @sprites["scroll_arrow_up"].visible = @offset > 0
        @sprites["scroll_arrow_down"].visible = @offset < @displayText.length - @linesToShow
        
        overlay = @sprites["overlay"].bitmap
        base = Color.new(88,88,88)
        shadow = Color.new(168,184,184)
        xLeft = 36
        coordinateY = 38

        @displayText[@offset..@offset+@linesToShow].each {|line|
            drawTextEx(overlay, xLeft, coordinateY += 30, 450, 1, line, base, shadow)
        }
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

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbStartScene
        $Tribal_Bonuses.updateTribeCount()
        @page = 1

        # Set up the two viewports to hold UI elements
        @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport1.z = 99999
        @sprites = {}

        # Set up all the sprites
        @sprites["background"] = IconSprite.new(0,0,@viewport1)
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_evolution"))

        @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport1)
        pbSetSystemFont(@sprites["overlay"].bitmap)

        # Used for Tribal Info page
        @displayText = []
        @offset = 0
        @linesToShow = 8
        @sprites["scroll_arrow_up"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport1)
        @sprites["scroll_arrow_up"].x = (Graphics.width - 28) / 2
        @sprites["scroll_arrow_up"].y = 38
        @sprites["scroll_arrow_up"].visible = false
        @sprites["scroll_arrow_up"].play
        @sprites["scroll_arrow_down"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport1)
        @sprites["scroll_arrow_down"].x = (Graphics.width - 28) / 2
        @sprites["scroll_arrow_down"].y = (Graphics.height - 60)
        @sprites["scroll_arrow_down"].visible = false
        @sprites["scroll_arrow_down"].play

        GameData::Tribe.each { |tribe|
            tribeName = TribalBonus.getTribeName(tribe.id)
            @displayText << tribeName + ":"
            bonusDescription = "5 battlers in this category will get a bonus to each main battle stat"
            break_string(bonusDescription, 40).each {|line|
                @displayText << line
            }
        }

        pbFadeInAndShow(@sprites) { pbUpdate }
        drawPage()
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport1.dispose
    end

    def pbScene
        returnIndex = -1

        Graphics.update
        Input.update
        pbUpdate
        dorefresh = false
        
        if Input.repeat?(Input::LEFT)
            # Go to previous page if not already on the first page
            if @page > 1
                @page -= 1
                dorefresh = true
            end
            returnIndex = @page
        elsif Input.repeat?(Input::RIGHT)
            # Go to next page if not already on the last page
            if @page < PAGE_TITLES.length()
                @page += 1
                dorefresh = true
            end
            returnIndex = @page
        elsif Input.repeat?(Input::UP)
            # Scroll up on the Tribal Info page if not already at the top
            if @offset > 0
                @offset = @offset - 1
                dorefresh = true
            end
            returnIndex = @page + @offset
        elsif Input.repeat?(Input::DOWN)
            # Scroll down on the Tribal Info page if not already at the bottom
            if @offset < @displayText.length - @linesToShow
                @offset = @offset + 1
                dorefresh = true
            end
            returnIndex = @page + @offset
        elsif Input.repeat?(Input::BACK)
            returnIndex = -1
        else
            returnIndex = @page
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
            break if cmd<0   # Cancel/Exit
        end
        @scene.pbEndScene
    end
  end
