#===============================================================================
# Abstraction layer for Pokemon Essentials
#===============================================================================
class PokemonMartAdapter
    def getMoney
      return $Trainer.money
    end
  
    def getMoneyString
      return pbGetGoldString
    end

    def getMoneyDisplay(currencyAmount = nil)
      currencyAmount = getMoney unless currencyAmount
      return "$#{currencyAmount.to_s_formatted}"
    end

    def getMoneyName(upperCase = false)
      return upperCase ? "Money" : "money"
    end
  
    def setMoney(value)
      $Trainer.money=value
    end

    def moneyOnNewLine?; return true; end
  
    def getInventory
      return $PokemonBag
    end
  
    def getName(item)
      return GameData::Item.get(item).name
    end
  
    def getDisplayName(item)
      return getName(item)
    end
  
    def getDescription(item)
      return GameData::Item.get(item).description
    end
  
    def getItemIcon(item)
      return (item) ? GameData::Item.icon_filename(item) : nil
    end
  
    # Unused
    def getItemIconRect(_item)
      return Rect.new(0, 0, 48, 48)
    end
  
    def getQuantity(item)
      return $PokemonBag.pbQuantity(item)
    end
  
    def showQuantity?(item)
      return !GameData::Item.get(item).is_single_purchase?
    end
  
    def getPrice(item, selling = false)
        price = getUnmodifiedPrice(item, selling)
        if vipCardActive? && !selling
            price = (price * 0.9).ceil
        end
        return price
    end

    def getUnmodifiedPrice(item, selling = false)
        if $game_temp.mart_prices && $game_temp.mart_prices[item]
            if selling
              return $game_temp.mart_prices[item][1] if $game_temp.mart_prices[item][1] >= 0
            else
              return $game_temp.mart_prices[item][0] if $game_temp.mart_prices[item][0] > 0
            end
        end
        return GameData::Item.get(item).price
    end
  
    def getDisplayPrice(item, selling = false)
      return getMoneyDisplay(getPrice(item, selling))
    end
  
    def canSell?(item)
      return getPrice(item, true) > 0 && !GameData::Item.get(item).is_important?
    end
  
    def addItem(item)
      return $PokemonBag.pbStoreItem(item)
    end
  
    def removeItem(item)
      return $PokemonBag.pbDeleteItem(item)
    end
  end
  
  #===============================================================================
  # Buy and Sell adapters
  #===============================================================================
  class BuyAdapter
    def initialize(adapter)
      @adapter = adapter
    end
  
    def getDisplayName(item)
      @adapter.getDisplayName(item)
    end
  
    def getDisplayPrice(item)
      @adapter.getDisplayPrice(item, false)
    end
  
    def isSelling?
      return false
    end
  end
  
  #===============================================================================
  #
  #===============================================================================
  class SellAdapter
    def initialize(adapter)
      @adapter = adapter
    end
  
    def getDisplayName(item)
      @adapter.getDisplayName(item)
    end
  
    def getDisplayPrice(item)
      if @adapter.showQuantity?(item)
        return sprintf("x%d", @adapter.getQuantity(item))
      else
        return ""
      end
    end
  
    def isSelling?
      return true
    end
  end