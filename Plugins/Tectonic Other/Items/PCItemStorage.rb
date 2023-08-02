
#===============================================================================
# The PC item storage object, which actually contains all the items
#===============================================================================
class PCItemStorage
    attr_reader :items
  
    MAX_SIZE     = 999   # Number of different slots in storage
    MAX_PER_SLOT = 999   # Max. number of items per slot
  
    def initialize
      @items = []
      # Start storage with a Potion
      pbStoreItem(:POTION) if GameData::Item.exists?(:POTION)
    end
  
    def [](i)
      return @items[i]
    end
  
    def length
      return @items.length
    end
  
    def empty?
      return @items.length == 0
    end
  
    def clear
      @items.clear
    end
  
    def getItem(index)
      return (index < 0 || index >= @items.length) ? nil : @items[index][0]
    end
  
    def getCount(index)
      return (index < 0 || index >= @items.length) ? 0 : @items[index][1]
    end
  
    def pbQuantity(item)
      item = GameData::Item.get(item).id
      return ItemStorageHelper.pbQuantity(@items, item)
    end
  
    def pbCanStore?(item, qty = 1)
      item = GameData::Item.get(item).id
      return ItemStorageHelper.pbCanStore?(@items, MAX_SIZE, MAX_PER_SLOT, item, qty)
    end
  
    def pbStoreItem(item, qty = 1)
      item = GameData::Item.get(item).id
      return ItemStorageHelper.pbStoreItem(@items, MAX_SIZE, MAX_PER_SLOT, item, qty)
    end
  
    def pbDeleteItem(item, qty = 1)
      item = GameData::Item.get(item).id
      return ItemStorageHelper.pbDeleteItem(@items, item, qty)
    end
  end
  