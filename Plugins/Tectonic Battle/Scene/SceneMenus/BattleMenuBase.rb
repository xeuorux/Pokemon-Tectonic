#===============================================================================
# Base class for all three menu classes below
#===============================================================================
class BattleMenuBase
    attr_accessor :x
    attr_accessor :y
    attr_reader   :z
    attr_reader   :visible
    attr_reader   :color
    attr_reader   :index
    attr_reader   :mode
    # NOTE: Button width is half the width of the graphic containing them all.
    BUTTON_HEIGHT = 46
    TEXT_BASE_COLOR   = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
    TEXT_SHADOW_COLOR = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR
  
    def initialize(viewport=nil)
      @x          = 0
      @y          = 0
      @z          = 0
      @visible    = false
      @color      = Color.new(0,0,0,0)
      @index      = 0
      @mode       = 0
      @disposed   = false
      @sprites    = {}
      @visibility = {}
    end
  
    def dispose
      return if disposed?
      pbDisposeSpriteHash(@sprites)
      @disposed = true
    end
  
    def disposed?; return @disposed; end
  
    def z=(value)
      @z = value
      for i in @sprites
        i[1].z = value if !i[1].disposed?
      end
    end
  
    def visible=(value)
      @visible = value
      for i in @sprites
        i[1].visible = (value && @visibility[i[0]]) if !i[1].disposed?
      end
    end
  
    def color=(value)
      @color = value
      for i in @sprites
        i[1].color = value if !i[1].disposed?
      end
    end
  
    def index=(value)
      oldValue = @index
      @index = value
      @cmdWindow.index = @index if @cmdWindow
      refresh if @index!=oldValue
    end
  
    def mode=(value)
      oldValue = @mode
      @mode = value
      refresh if @mode!=oldValue
    end
  
    def addSprite(key,sprite)
      @sprites[key]    = sprite
      @visibility[key] = true
    end
  
    def setIndexAndMode(index,mode)
      oldIndex = @index
      oldMode  = @mode
      @index = index
      @mode  = mode
      @cmdWindow.index = @index if @cmdWindow
      refresh if @index!=oldIndex || @mode!=oldMode
    end
  
    def refresh; end
  
    def update
      pbUpdateSpriteHash(@sprites)
    end
end