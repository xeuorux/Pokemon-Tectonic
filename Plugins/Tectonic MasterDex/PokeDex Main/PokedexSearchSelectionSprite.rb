#===============================================================================
#
#===============================================================================
class PokedexSearchSelectionSprite < SpriteWrapper
    attr_reader :index
    attr_accessor :cmds
    attr_accessor :minmax
  
    def initialize(viewport=nil)
      super(viewport)
      @selbitmap = AnimatedBitmap.new("Graphics/Pictures/Pokedex/cursor_search")
      self.bitmap = @selbitmap.bitmap
      self.mode = -1
      @index = 0
      refresh
    end
  
    def dispose
      @selbitmap.dispose
      super
    end
  
    def index=(value)
      @index = value
      refresh
    end
  
    def mode=(value)
      @mode = value
      case @mode
      when 0     # Order
        @xstart = 46; @ystart = 128
        @xgap = 236; @ygap = 64
        @cols = 2
      when 1     # Name
        @xstart = 78; @ystart = 114
        @xgap = 52; @ygap = 52
        @cols = 7
      when 2     # Type
        @xstart = 8; @ystart = 104
        @xgap = 124; @ygap = 44
        @cols = 4
      when 3,4   # Height, weight
        @xstart = 44; @ystart = 110
        @xgap = 8; @ygap = 112
      when 5     # Color
        @xstart = 62; @ystart = 114
        @xgap = 132; @ygap = 52
        @cols = 3
      when 6     # Shape
        @xstart = 82; @ystart = 116
        @xgap = 70; @ygap = 70
        @cols = 5
      end
    end
  
    def refresh
      # Size and position cursor
      if @mode==-1   # Main search screen
        case @index
        when 0     # Order
          self.src_rect.y = 0; self.src_rect.height = 44
        when 1,5   # Name, color
          self.src_rect.y = 44; self.src_rect.height = 44
        when 2     # Type
          self.src_rect.y = 88; self.src_rect.height = 44
        when 3,4   # Height, weight
          self.src_rect.y = 132; self.src_rect.height = 44
        when 6     # Form
          self.src_rect.y = 176; self.src_rect.height = 68
        else       # Reset/start/cancel
          self.src_rect.y = 244; self.src_rect.height = 40
        end
        case @index
        when 0         # Order
          self.x = 252; self.y = 52
        when 1,2,3,4   # Name, type, height, weight
          self.x = 114; self.y = 110+(@index-1)*52
        when 5         # Color
          self.x = 382; self.y = 110
        when 6         # Shape
          self.x = 420; self.y = 214
        when 7,8,9     # Reset, start, cancel
          self.x = 4+(@index-7)*176; self.y = 334
        end
      else   # Parameter screen
        case @index
        when -2,-3   # OK, Cancel
          self.src_rect.y = 244; self.src_rect.height = 40
        else
          case @mode
          when 0     # Order
            self.src_rect.y = 0; self.src_rect.height = 44
          when 1     # Name
            self.src_rect.y = 284; self.src_rect.height = 44
          when 2,5   # Type, color
            self.src_rect.y = 44; self.src_rect.height = 44
          when 3,4   # Height, weight
            self.src_rect.y = (@minmax==1) ? 328 : 424; self.src_rect.height = 96
          when 6     # Shape
            self.src_rect.y = 176; self.src_rect.height = 68
          end
        end
        case @index
        when -1   # Blank option
          if @mode==3 || @mode==4   # Height/weight range
            self.x = @xstart+(@cmds+1)*@xgap*(@minmax%2)
            self.y = @ystart+@ygap*((@minmax+1)%2)
          else
            self.x = @xstart+(@cols-1)*@xgap
            self.y = @ystart+(@cmds/@cols).floor*@ygap
          end
        when -2   # OK
          self.x = 4; self.y = 334
        when -3   # Cancel
          self.x = 356; self.y = 334
        else
          case @mode
          when 0,1,2,5,6   # Order, name, type, color, shape
            if @index>=@cmds
              self.x = @xstart+(@cols-1)*@xgap
              self.y = @ystart+(@cmds/@cols).floor*@ygap
            else
              self.x = @xstart+(@index%@cols)*@xgap
              self.y = @ystart+(@index/@cols).floor*@ygap
            end
          when 3,4         # Height, weight
            if @index>=@cmds
              self.x = @xstart+(@cmds+1)*@xgap*((@minmax+1)%2)
            else
              self.x = @xstart+(@index+1)*@xgap
            end
            self.y = @ystart+@ygap*((@minmax+1)%2)
          end
        end
      end
    end
  end