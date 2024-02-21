#===============================================================================
# Pokémon Mart
#===============================================================================
class Window_PokemonMart < Window_DrawableCommand
    def initialize(stock, adapter, x, y, width, height, viewport = nil)
      @stock       = stock
      @adapter     = adapter
      super(x, y, width, height, viewport)
      @selarrow    = AnimatedBitmap.new("Graphics/Pictures/martSel")
      @baseColor   = darkMode? ? Color.new(248,248,248) : Color.new(88,88,80)
      @shadowColor = darkMode? ? Color.new(104,104,104) : Color.new(168,184,184)
      self.windowskin = nil
    end
  
    def itemCount
      return @stock.length + 1
    end
  
    def item
      return (self.index >= @stock.length) ? nil : @stock[self.index]
    end
  
    def drawItem(index, count, rect)
      textpos = []
      rect = drawCursor(index, rect)
      ypos = rect.y
      if index == count-1
        textpos.push([_INTL("CANCEL"), rect.x, ypos - 4, false, self.baseColor, self.shadowColor])
      else
        item = @stock[index]
        itemname = @adapter.getDisplayName(item)
        qty = @adapter.getDisplayPrice(item)
        sizeQty = self.contents.text_size(qty).width
        xQty = rect.x + rect.width - sizeQty - 2 - 16
        textpos.push([itemname, rect.x, ypos - 4, false, self.baseColor, self.shadowColor])
        textpos.push([qty, xQty, ypos - 4, false, self.baseColor, self.shadowColor])
      end
      pbDrawTextPositions(self.contents, textpos)
    end
  end