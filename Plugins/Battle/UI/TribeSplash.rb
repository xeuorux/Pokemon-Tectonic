#===============================================================================
# Splash bar to announce a triggered tribal bonus
#===============================================================================
class TribeSplashBar < SpriteWrapper
    attr_reader :battler
  
    TEXT_BASE_COLOR   = Color.new(0,0,0)
    TEXT_SHADOW_COLOR = Color.new(248,248,248)
  
    def initialize(side,viewport=nil)
      super(viewport)
      @side    = side
      @tribeName = nil
      @trainerName = nil
      # Create sprite wrapper that displays background graphic
      @bgBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/tribal_bar"))
      @bgSprite = SpriteWrapper.new(viewport)
      @bgSprite.bitmap = @bgBitmap.bitmap
      @bgSprite.src_rect.y      = (side==0) ? 0 : @bgBitmap.height/2
      @bgSprite.src_rect.height = @bgBitmap.height/2
      # Create bitmap that displays the text
      @contents = BitmapWrapper.new(@bgBitmap.width,@bgBitmap.height/2)
      self.bitmap = @contents
      pbSetSystemFont(self.bitmap)
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
      super
    end
  
    def x=(value)
      super
      @bgSprite.x = value
    end
  
    def y=(value)
      super
      @bgSprite.y = value
    end
  
    def z=(value)
      super
      @bgSprite.z = value-1
    end
  
    def opacity=(value)
      super
      @bgSprite.opacity = value
    end
  
    def visible=(value)
      super
      @bgSprite.visible = value
    end
  
    def color=(value)
      super
      @bgSprite.color = value
    end
  
    def tribeName=(value)
      @tribeName = value
      refresh
    end

    def trainerName=(value)
      @trainerName = value
      refresh
    end
  
    def refresh
      self.bitmap.clear
      textPos = []
      textX = (@side==0) ? 10 : self.bitmap.width-8
      # Draw Pokémon's name
      textPos.push([_INTL("{1}'s",@trainerName),textX,-4,@side==1,
        TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true])
      # Draw Pokémon's ability
      textPos.push([_INTL("#{@tribeName} Tribe Bonus"),textX,26,@side==1,
          TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true])
      pbDrawTextPositions(self.bitmap,textPos)
    end
  
    def update
      super
      @bgSprite.update
    end
  end