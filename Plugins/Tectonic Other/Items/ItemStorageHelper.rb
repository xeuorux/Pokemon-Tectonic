module ItemStorageHelper
    # Returns the quantity of check_item in item_array
    def self.pbQuantity(item_array, check_item)
      ret = 0
      item_array.each { |i| ret += i[1] if i && i[0] == check_item }
      return ret
    end
  
    # Deletes an item (items array, max. size per slot, item, no. of items to delete)
    def self.pbDeleteItem(items, item, qty)
      raise "Invalid value for qty: #{qty}" if qty < 0
      return true if qty == 0
      ret = false
      for i in 0...items.length
        itemslot = items[i]
        next if !itemslot || itemslot[0] != item
        amount = [qty, itemslot[1]].min
        itemslot[1] -= amount
        qty -= amount
        items[i] = nil if itemslot[1] == 0
        next if qty > 0
        ret = true
        break
      end
      items.compact!
      return ret
    end
  
    def self.pbCanStore?(items, maxsize, maxPerSlot, item, qty)
      raise "Invalid value for qty: #{qty}" if qty < 0
      return true if qty == 0
      for i in 0...maxsize
        itemslot = items[i]
        if !itemslot
          qty -= [qty, maxPerSlot].min
          return true if qty == 0
        elsif itemslot[0] == item && itemslot[1] < maxPerSlot
          newamt = itemslot[1]
          newamt = [newamt + qty, maxPerSlot].min
          qty -= (newamt - itemslot[1])
          return true if qty == 0
        end
      end
      return false
    end
  
    def self.pbStoreItem(items, maxsize, maxPerSlot, item, qty, sorting = false)
      raise "Invalid value for qty: #{qty}" if qty < 0
      return true if qty == 0
      itm = GameData::Item.try_get(item)
      itemPocket = (itm) ? itm.pocket : 0
      for i in 0...maxsize
        itemslot = items[i]
        if !itemslot
          items[i] = [item, [qty, maxPerSlot].min]
          qty -= items[i][1]
          sortItems(items) if sorting
          return true if qty == 0
        elsif itemslot[0] == item && itemslot[1] < maxPerSlot
          newamt = itemslot[1]
          newamt = [newamt + qty, maxPerSlot].min
          qty -= (newamt - itemslot[1])
          itemslot[1] = newamt
          return true if qty == 0
        end
      end
      return false
    end
  
    def self.sortItems(items)
      if $PokemonSystem.bag_sorting == 2
        items.sort! { |a, b|
          itemDataA = GameData::Item.get(a[0])
          itemDataB = GameData::Item.get(b[0])
          if itemDataA.is_machine? && itemDataB.is_machine?
            next itemDataA.machine_index <=> itemDataB.machine_index
          else
            next itemDataA.id_number <=> itemDataB.id_number
          end
        }
      elsif $PokemonSystem.bag_sorting == 1
        items.sort! { |a, b| GameData::Item.get(a[0]).name <=> GameData::Item.get(b[0]).name }
      end
    end
  end