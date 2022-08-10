class Window_PokemonBag < Window_DrawableCommand
    def drawItem(index,_count,rect)
        textpos = []
        rect = Rect.new(rect.x+16,rect.y+16,rect.width-16,rect.height)
        thispocket = @bag.pockets[@pocket]
        if index==self.itemCount-1
          textpos.push([_INTL("CLOSE BAG"),rect.x,rect.y-2,false,self.baseColor,self.shadowColor])
        else
          item = (@filterlist) ? thispocket[@filterlist[@pocket][index]][0] : thispocket[index][0]
          baseColor   = self.baseColor
          shadowColor = self.shadowColor
          if @sorting && index==self.index
            baseColor   = Color.new(224,0,0)
            shadowColor = Color.new(248,144,144)
          end
          textpos.push(
             [@adapter.getDisplayName(item),rect.x,rect.y-2,false,baseColor,shadowColor]
          )
          itemData = GameData::Item.get(item)
          if itemData.is_important? && !itemData.is_consumable_key_item?
            if @bag.pbIsRegistered?(item)
              pbDrawImagePositions(self.contents,[
                 ["Graphics/Pictures/Bag/icon_register",rect.x+rect.width-72,rect.y+8,0,0,-1,24]
              ])
            elsif pbCanRegisterItem?(item)
              pbDrawImagePositions(self.contents,[
                 ["Graphics/Pictures/Bag/icon_register",rect.x+rect.width-72,rect.y+8,0,24,-1,24]
              ])
            end
          else
            qty = (@filterlist) ? thispocket[@filterlist[@pocket][index]][1] : thispocket[index][1]
            qtytext = _ISPRINTF("x{1: 3d}",qty)
            xQty    = rect.x+rect.width-self.contents.text_size(qtytext).width-16
            textpos.push([qtytext,xQty,rect.y-2,false,baseColor,shadowColor])
          end
        end
        pbDrawTextPositions(self.contents,textpos)
      end
end