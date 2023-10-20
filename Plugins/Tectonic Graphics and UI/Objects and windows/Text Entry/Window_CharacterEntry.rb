#===============================================================================
#
#===============================================================================
class Window_CharacterEntry < Window_DrawableCommand
    XSIZE=13
    YSIZE=4
  
    def initialize(charset,viewport=nil)
      @viewport=viewport
      @charset=charset
      @othercharset=""
      super(0,96,480,192)
      colors=getDefaultTextColors(self.windowskin)
      self.baseColor=colors[0]
      self.shadowColor=colors[1]
      self.columns=XSIZE
      refresh
    end
  
    def setOtherCharset(value)
      @othercharset=value.clone
      refresh
    end
  
    def setCharset(value)
      @charset=value.clone
      refresh
    end
  
    def character
      if self.index<0 || self.index>=@charset.length
        return ""
      else
        return @charset[self.index]
      end
    end
  
    def command
      return -1 if self.index==@charset.length
      return -2 if self.index==@charset.length+1
      return -3 if self.index==@charset.length+2
      return self.index
    end
  
    def itemCount
      return @charset.length+3
    end
  
    def drawItem(index,_count,rect)
      rect=drawCursor(index,rect)
      if index==@charset.length # -1
        pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,"[ ]",
           self.baseColor,self.shadowColor)
      elsif index==@charset.length+1 # -2
        pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,@othercharset,
           self.baseColor,self.shadowColor)
      elsif index==@charset.length+2 # -3
        pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,_INTL("OK"),
           self.baseColor,self.shadowColor)
      else
        pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,@charset[index],
           self.baseColor,self.shadowColor)
      end
    end
  end