class TribalBonusScene
    def initialize()
        @tribalBonus = TribalBonus.new 

        # Set up the two viewports to hold UI elements
        @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport1.z = 99999
        @viewport2 = Viewport.new(30, 120, Graphics.width, Graphics.height)
        @viewport2.z = 99999
        @viewport3 = Viewport.new(0, 120, Graphics.width, Graphics.height)
        @viewport3.z = 999999
        $viewport = nil
        @sprites = {}

        # Set up all the sprites
        @sprites["background"] = IconSprite.new(0,0,@viewport1)
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/dexnav"))

        @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport1)
        @sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport2)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["name_overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport1)

        @sprites["nav_arrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport3)
        @sprites["nav_arrow"].visible = false
        @sprites["nav_arrow"].play
	
        pbFadeInAndShow(@sprites)

        displayTribalBonuses()
    end

    def dispose
        pbFadeOutAndHide(@sprites) {pbUpdate}
        pbDisposeSpriteHash(@sprites)
        @viewport1.dispose
        @viewport2.dispose
        @viewport3.dispose
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
end