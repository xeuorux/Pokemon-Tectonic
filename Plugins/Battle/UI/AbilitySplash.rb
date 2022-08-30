class AbilitySplashBar < SpriteWrapper
    SPECIES_ICON_SRC_Y = 8
    SPECIES_ICON_SRC_HEIGHT = 76
    SPECIES_ICON_X_POS_OWN = 180
    SPECIES_ICON_X_POS_ENEMY = 12
    SPECIES_ICON_Y_POS = 0
    SPECIES_IRON_OPACITY_MULT = 0.6 # Between 0 and 1, 1 meaning fully opaque

    def initialize(side,viewport=nil)
        super(viewport)
        @side    = side
        @battler = nil
        # Create sprite wrapper that displays background graphic
        @bgBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/ability_bar"))
        @bgSprite = SpriteWrapper.new(viewport)
        @bgSprite.bitmap = @bgBitmap.bitmap
        @bgSprite.src_rect.y      = (side==0) ? 0 : @bgBitmap.height/2
        @bgSprite.src_rect.height = @bgBitmap.height/2
        # Create bitmap that displays the text
        @contents = BitmapWrapper.new(@bgBitmap.width,@bgBitmap.height/2)
        self.bitmap = @contents
        pbSetSystemFont(self.bitmap)
        # Cretae bitmap that displays the icon
        @speciesIcon = IconSprite.new(0,0,viewport)
        # Position the bar
        self.x       = (side==0) ? -Graphics.width/2 : Graphics.width
        self.y       = (side==0) ? 180 : 80
        self.z       = 120
        self.visible = false
      end
    
    def dispose
        @bgSprite.dispose
        @bgBitmap.dispose
        @contents.dispose
        @speciesIcon.dispose
        super
    end

    def battler=(value)
        @battler = value
        @speciesIcon.setBitmap(GameData::Species.icon_filename_from_pokemon(@battler.pokemon))
        @speciesIcon.src_rect.y = SPECIES_ICON_SRC_Y
        @speciesIcon.src_rect.height = SPECIES_ICON_SRC_HEIGHT
        @speciesIcon.src_rect.width = @speciesIcon.bitmap.width / 2
        refresh
    end

    def x=(value)
        super
        @bgSprite.x = value
        offset = 0
        if !@battler.nil?
            offset = @battler.opposes? ? SPECIES_ICON_X_POS_ENEMY : SPECIES_ICON_X_POS_OWN
        end
        @speciesIcon.x = value + offset
    end

    def y=(value)
        super
        @bgSprite.y = value
        @speciesIcon.y = value + SPECIES_ICON_Y_POS
    end

    def z=(value)
        super
        @bgSprite.z = value-1
        @speciesIcon.z = value-1
    end

    def opacity=(value)
        super
        @bgSprite.opacity = value
        @speciesIcon.opacity = value * SPECIES_IRON_OPACITY_MULT
    end

    def visible=(value)
        super
        @bgSprite.visible = value
        @speciesIcon.visible = value
    end

    def color=(value)
        super
        @bgSprite.color = value
        @speciesIcon.color = value
    end
end