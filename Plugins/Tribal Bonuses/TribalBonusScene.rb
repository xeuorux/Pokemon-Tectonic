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
        coordinateY = 34
    
        @tribalBonus.tribes.each {|tribe, count|
            if count > 0
                tribeName = @tribalBonus.tribeNames[tribe]
                drawTextEx(overlay, xLeft, coordinateY += 30, 450, 1, _INTL("{1}: {2}", tribeName, count), base, shadow)
            end
        }
    end

    def displayTribalInfo()
        overlay = @sprites["overlay"].bitmap
        base = Color.new(88,88,88)
        shadow = Color.new(168,184,184)
        xLeft = 36
        coordinateY = 34
    
        @tribalBonus.bonusDescriptions.each {|tribe, bonusDescription|
            tribeName = @tribalBonus.tribeNames[tribe]
            drawTextEx(overlay, xLeft, coordinateY += 30, 450, 1, _INTL("{1}: {2}", tribeName, bonusDescription), base, shadow)
        }
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbStartScene
        @tribalBonus = TribalBonus.new
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
        highestLeftRepeat = 0
        highestRightRepeat = 0

        Graphics.update
        Input.update
        pbUpdate
        dorefresh = false
        
        if Input.repeat?(Input::LEFT)
            highestRightRepeat = 0
            repeats = 1 + Input.time?(Input::LEFT) / 100000
            if  repeats > highestLeftRepeat
                highestLeftRepeat = repeats
                oldpage = @page
                @page -= 1
                @page = 1 if @page<1
                if @page!=oldpage
                    @scroll = -1
                    @horizontalScroll = 0
                    pbPlayCursorSE
                    dorefresh = true
                end
            end
            returnIndex = @page
        elsif Input.repeat?(Input::RIGHT)
            highestLeftRepeat = 0
            repeats = 1 + Input.time?(Input::RIGHT) / 100000
            if repeats > highestRightRepeat
                highestRightRepeat = repeats
                oldpage = @page
                @page += 1
                @page = PAGE_TITLES.length() if @page>PAGE_TITLES.length()
                if @page!=oldpage
                    @scroll = -1
                    @horizontalScroll = 0
                    pbPlayCursorSE
                    dorefresh = true
                end
            end
            returnIndex = @page
        elsif Input.repeat?(Input::BACK)
            returnIndex = -1
        else
            highestLeftRepeat = 0
            highestRightRepeat = 0
            returnIndex = @page
        end
            
        if dorefresh
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
  