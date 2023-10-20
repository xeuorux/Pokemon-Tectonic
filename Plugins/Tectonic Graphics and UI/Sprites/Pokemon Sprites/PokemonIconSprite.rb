#===============================================================================
# Pokémon icon (for defined Pokémon)
#===============================================================================
class PokemonIconSprite < SpriteWrapper
    attr_accessor :selected
    attr_accessor :active
    attr_reader   :pokemon
  
    def initialize(pokemon,viewport=nil)
      super(viewport)
      @selected     = false
      @active       = false
      @numFrames    = 0
      @currentFrame = 0
      @counter      = 0
      self.pokemon  = pokemon
      @logical_x    = 0   # Actual x coordinate
      @logical_y    = 0   # Actual y coordinate
      @adjusted_x   = 0   # Offset due to "jumping" animation in party screen
      @adjusted_y   = 0   # Offset due to "jumping" animation in party screen
    end
  
    def dispose
      @animBitmap.dispose if @animBitmap
      super
    end
  
    def x; return @logical_x; end
    def y; return @logical_y; end
  
    def x=(value)
      @logical_x = value
      super(@logical_x+@adjusted_x)
    end
  
    def y=(value)
      @logical_y = value
      super(@logical_y+@adjusted_y)
    end
  
    def pokemon=(value)
      @pokemon = value
      @animBitmap.dispose if @animBitmap
      @animBitmap = nil
      if !@pokemon
        self.bitmap = nil
        @currentFrame = 0
        @counter = 0
        return
      end
      @animBitmap = AnimatedBitmap.new(GameData::Species.icon_filename_from_pokemon(value))
      self.bitmap = @animBitmap.bitmap
      self.src_rect.width  = @animBitmap.height
      self.src_rect.height = @animBitmap.height
      @numFrames    = @animBitmap.width/@animBitmap.height
      @currentFrame = 0 if @currentFrame>=@numFrames
      changeOrigin
    end
  
    def setOffset(offset=PictureOrigin::Center)
      @offset = offset
      changeOrigin
    end
  
    def changeOrigin
      return if !self.bitmap
      @offset = PictureOrigin::TopLeft if !@offset
      case @offset
      when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
        self.ox = 0
      when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
        self.ox = self.src_rect.width/2
      when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
        self.ox = self.src_rect.width
      end
      case @offset
      when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
        self.oy = 0
      when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
        # NOTE: This assumes the top quarter of the icon is blank, so oy is placed
        #       in the middle of the lower three quarters of the image.
        self.oy = self.src_rect.height*5/8
      when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
        self.oy = self.src_rect.height
      end
    end
  
    # How long to show each frame of the icon for
    def counterLimit
      return 0 if @pokemon.fainted?    # Fainted - no animation
      # ret is initially the time a whole animation cycle lasts. It is divided by
      # the number of frames in that cycle at the end.
      ret = Graphics.frame_rate/4                       # Green HP - 0.25 seconds
      if @pokemon.hp<=@pokemon.totalhp/4;    ret *= 4   # Red HP - 1 second
      elsif @pokemon.hp<=@pokemon.totalhp/2; ret *= 2   # Yellow HP - 0.5 seconds
      end
      ret /= @numFrames
      ret = 1 if ret<1
      return ret
    end
  
    def update
      return if !@animBitmap
      super
      @animBitmap.update
      self.bitmap = @animBitmap.bitmap
      # Update animation
      cl = self.counterLimit
      if cl==0
        @currentFrame = 0
      else
        @counter += 1
        if @counter>=cl
          @currentFrame = (@currentFrame+1)%@numFrames
          @counter = 0
        end
      end
      self.src_rect.x = self.src_rect.width*@currentFrame
      # Update "jumping" animation (used in party screen)
      if @selected
        @adjusted_x = 4
        @adjusted_y = (@currentFrame>=@numFrames/2) ? -2 : 6
      else
        @adjusted_x = 0
        @adjusted_y = 0
      end
      self.x = self.x
      self.y = self.y
    end
end