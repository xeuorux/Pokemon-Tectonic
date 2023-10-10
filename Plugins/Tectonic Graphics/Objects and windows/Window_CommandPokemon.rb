class Window_CommandPokemon < Window_DrawableCommand
    attr_reader :commands
  
    def initialize(commands,width=nil)
      @starting=true
      @commands=[]
      dims=[]
      super(0,0,32,32)
      getAutoDims(commands,dims,width)
      self.width=dims[0]
      self.height=dims[1]
      commands.map! { |command|
        globalMessageReplacements(command)
      }
      @commands=commands
      self.active=true
      colors=getDefaultTextColors(self.windowskin)
      self.baseColor=colors[0]
      self.shadowColor=colors[1]
      refresh
      @starting=false
    end

    def self.newWithSize(commands,x,y,width,height,viewport=nil)
      ret=self.new(commands,width)
      ret.x=x
      ret.y=y
      ret.width=width
      ret.height=height
      ret.viewport=viewport
      return ret
    end
  
    def self.newEmpty(x,y,width,height,viewport=nil)
      ret=self.new([],width)
      ret.x=x
      ret.y=y
      ret.width=width
      ret.height=height
      ret.viewport=viewport
      return ret
    end
  
    def index=(value)
      super
      refresh if !@starting
    end
  
    def commands=(value)
      @commands=value
      @item_max=commands.length
      self.update_cursor_rect
      self.refresh
    end
  
    def width=(value)
      super
      if !@starting
        self.index=self.index
        self.update_cursor_rect
      end
    end
  
    def height=(value)
      super
      if !@starting
        self.index=self.index
        self.update_cursor_rect
      end
    end
  
    def resizeToFit(commands,width=nil)
      dims=[]
      getAutoDims(commands,dims,width)
      self.width=dims[0]
      self.height=dims[1]
    end
  
    def itemCount
      return @commands ? @commands.length : 0
    end
  
    def drawItem(index,_count,rect)
      pbSetSystemFont(self.contents) if @starting
      rect=drawCursor(index,rect)
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,
         _INTL(@commands[index]),self.baseColor,self.shadowColor)
    end
       
    def refreshSkin
      refreshSelArrow
      colors = getDefaultTextColors(self.windowskin)
      @baseColor   = colors[0]
      @shadowColor = colors[1]
      refresh
    end
end

#===============================================================================
#
#===============================================================================
class Window_CommandPokemonEx < Window_CommandPokemon
end