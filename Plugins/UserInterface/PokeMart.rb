class PokemonMartScreen
  def pbBuyScreen
    @scene.pbStartBuyScene(@stock,@adapter)
    item=nil
    loop do
      item=@scene.pbChooseBuyItem
      break if !item
      quantity=0
      itemname=@adapter.getDisplayName(item)
      price=@adapter.getPrice(item)
      if @adapter.getMoney<price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      if GameData::Item.get(item).is_important?
        if !pbConfirm(_INTL("Certainly. You want {1}. That will be ${2}. OK?",
           itemname,price.to_s_formatted))
          next
        end
        quantity=1
      else
        maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getMoney / price
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        quantity=@scene.pbChooseNumber(
           _INTL("{1}? Certainly. How many would you like?",itemname),item,maxafford)
        next if quantity==0
        price*=quantity
        if !pbConfirm(_INTL("{1}, and you want {2}. That will be ${3}. OK?",
           itemname,quantity,price.to_s_formatted))
          next
        end
      end
      if @adapter.getMoney<price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      added=0
      quantity.times do
        break if !@adapter.addItem(item)
        added+=1
      end
      if added!=quantity
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbDisplayPaused(_INTL("You have no more room in the Bag."))
      else
        @adapter.setMoney(@adapter.getMoney-price)
        for i in 0...@stock.length
          if GameData::Item.get(@stock[i]).is_important? && $PokemonBag.pbHasItem?(@stock[i])
            @stock[i]=nil
          end
        end
        @stock.compact!
        pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
        if $PokemonBag
          if quantity>=10 && GameData::Item.get(item).is_poke_ball? && GameData::Item.exists?(:PREMIERBALL)
			premierCount = quantity / 10
			premier_data = GameData::Item.get(:PREMIERBALL)
            if premierCount == 1 && @adapter.addItem(premier_data)
              pbDisplayPaused(_INTL("I'll throw in a Premier Ball, too."))
			else
			  pbDisplayPaused(_INTL("I'll throw in some Premier Balls, too."))
			  premierCount.times do
				break if !@adapter.addItem(premier_data)
			  end
            end
          end
        end
      end
    end
    @scene.pbEndBuyScene
  end
end