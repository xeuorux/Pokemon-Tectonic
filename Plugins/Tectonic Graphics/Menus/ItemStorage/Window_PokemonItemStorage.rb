#===============================================================================
#
#===============================================================================
class Window_PokemonItemStorage < Window_DrawableCommand
    attr_reader :bag
    attr_reader :pocket
    attr_reader :sortIndex
  
    def sortIndex=(value)
      @sortIndex = value
      refresh
    end
  
    def initialize(bag,x,y,width,height)
      @bag = bag
      @sortIndex = -1
      @adapter = PokemonMartAdapter.new
      super(x,y,width,height)
      self.windowskin = nil
    end
  
    def item
      item = @bag[self.index]
      return item ? item[0] : nil
    end
  
    def itemCount
      return @bag.length+1
    end
  
    def drawItem(index,_count,rect)
      rect = drawCursor(index,rect)
      textpos = []
      if index==@bag.length
        textpos.push([_INTL("CANCEL"),rect.x,rect.y-6,false,self.baseColor,self.shadowColor])
      else
        item     = @bag[index][0]
        itemname = @adapter.getDisplayName(item)
        baseColor = (index==@sortIndex) ? Color.new(248,24,24) : self.baseColor
        textpos.push([itemname,rect.x,rect.y-6,false,self.baseColor,self.shadowColor])
        if !GameData::Item.get(item).is_important?   # Not a Key item/HM/TM
          qty     = _ISPRINTF("x{1: 2d}",@bag[index][1])
          sizeQty = self.contents.text_size(qty).width
          xQty = rect.x+rect.width-sizeQty-2
          textpos.push([qty,xQty,rect.y-6,false,baseColor,self.shadowColor])
        end
      end
      pbDrawTextPositions(self.contents,textpos)
    end
  end