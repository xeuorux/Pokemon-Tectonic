#===============================================================================
# Pokémon icon (for species)
#===============================================================================
class PokemonSpeciesIconSprite < SpriteWrapper
    attr_reader :species
    attr_reader :gender
    attr_reader :form
    attr_reader :shiny
    attr_reader :silhouette
  
    def initialize(species,viewport=nil)
        super(viewport)
        @species      = species
        @gender       = 0
        @form         = 0
        @shiny        = false
        @numFrames    = 0
        @currentFrame = 0
        @counter      = 0
        @silhouette   = false
        refresh
      end
  
    def dispose
      @animBitmap.dispose if @animBitmap
      super
    end
  
    def species=(value)
      @species = value
      refresh
    end
  
    def gender=(value)
      @gender = value
      refresh
    end
  
    def form=(value)
      @form = value
      refresh
    end
  
    def shiny=(value)
      @shiny = value
      refresh
    end

    def silhouette=(value)
        @silhouette = value
        refresh
    end
  
    def pbSetParams(species,gender,form,shiny=false)
      @species = species
      @gender  = gender
      @form    = form
      @shiny   = shiny
      refresh
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
      # ret is initially the time a whole animation cycle lasts. It is divided by
      # the number of frames in that cycle at the end.
      ret = Graphics.frame_rate/4   # 0.25 seconds
      ret /= @numFrames
      ret = 1 if ret<1
      return ret
    end
  
    def refresh
        @animBitmap.dispose if @animBitmap
        @animBitmap = nil
        bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny)
        return if !bitmapFileName
        @animBitmap = AnimatedBitmap.new(bitmapFileName)
        self.bitmap = @animBitmap.bitmap
        if @silhouette
          self.bitmap = @animBitmap.bitmap.clone
          for x in 0..bitmap.width
              for y in 0..bitmap.height
                bitmap.set_pixel(x,y,Color.new(200,200,200,255)) if bitmap.get_pixel(x,y).alpha > 0
              end
          end
        end
        self.src_rect.width  = @animBitmap.height
        self.src_rect.height = @animBitmap.height
        @numFrames = @animBitmap.width / @animBitmap.height
        @currentFrame = 0 if @currentFrame>=@numFrames
        changeOrigin
      end
  
    def update
        return if !@animBitmap
        return if @silhouette
        super
        @animBitmap.update
        self.bitmap = @animBitmap.bitmap
        # Update animation
        @counter += 1
        if @counter>=self.counterLimit
          @currentFrame = (@currentFrame+1)%@numFrames
          @counter = 0
        end
        self.src_rect.x = self.src_rect.width*@currentFrame
      end 
  end
  