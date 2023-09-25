#===============================================================================
#
#===============================================================================
class PokemonMartScreen
  def initialize(scene,stock,human=true)
    @scene=scene
    @stock=stock
    @adapter=PokemonMartAdapter.new
    @human = human
  end

  def pbConfirm(msg)
    return @scene.pbConfirm(msg)
  end

  def pbDisplay(msg)
    return @scene.pbDisplay(msg)
  end

  def pbDisplayPaused(msg,&block)
    return @scene.pbDisplayPaused(msg,&block)
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock,@adapter)
    item=nil
    loop do
      item=@scene.pbChooseBuyItem
      break unless item
      quantity=0
      itemname=@adapter.getDisplayName(item)
      price=@adapter.getPrice(item)
      if @adapter.getMoney<price
        pbDisplayPaused(_INTL("You don't have enough {1}.",@adapter.getMoneyName))
        next
      end
      if GameData::Item.get(item).is_single_purchase?
        if @human
          confirmPurchaseMessage = _INTL("Certainly. You want {1}. That will be {2}. OK?",itemname,@adapter.getMoneyDisplay(price))
        else
          confirmPurchaseMessage = _INTL("{1} costs {2}. Confirm?",itemname,@adapter.getMoneyDisplay(price))
        end
        next unless pbConfirm(confirmPurchaseMessage)
        quantity=1
      else
        maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getMoney / price
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        if @human
          quantityChoiceMessage = _INTL("{1}? Certainly. How many would you like?",itemname)
        else
          quantityChoiceMessage = _INTL("You've selected {1}. Choose the amount.",itemname)
        end
        quantity=@scene.pbChooseNumber(quantityChoiceMessage,item,maxafford)
        next if quantity==0
        price*=quantity
        if @human
          quantityConfirmMessage = _INTL("{1}, and you want {2}. That will be {3}. OK?",itemname,quantity,@adapter.getMoneyDisplay(price))
        else
          quantityConfirmMessage = _INTL("Total cost: {3}. Confirm?",itemname,quantity,@adapter.getMoneyDisplay(price))
        end
        next unless pbConfirm(quantityConfirmMessage)
      end
      if @adapter.getMoney<price
        pbDisplayPaused(_INTL("You don't have enough {1}.", @adapter.getMoneyName))
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
          if GameData::Item.get(@stock[i]).is_single_purchase? && $PokemonBag.pbHasItem?(@stock[i])
            @stock[i]=nil
          end
        end
        @stock.compact!
        purchaseCompleteMessage = @human ? _INTL("Here you are! Thank you!") : _INTL("Purchase complete.")
        pbDisplayPaused(purchaseCompleteMessage) { pbSEPlay("Mart buy item") }

        # Free primier balls from pokeball purchases
        if $PokemonBag
          if quantity>=10 && GameData::Item.get(item).is_poke_ball? && GameData::Item.exists?(:PREMIERBALL)
            premierCount = quantity / 10
            premier_data = GameData::Item.get(:PREMIERBALL)
            if premierCount == 1 && @adapter.addItem(premier_data)
              if @human
                pbDisplayPaused(_INTL("I'll throw in a Premier Ball, too."))
              else
                pbDisplayPaused(_INTL("You got a free Premier Ball with your purchase!"))
              end
			      else
              if @human
                pbDisplayPaused(_INTL("I'll throw in some Premier Balls, too."))
              else
                pbDisplayPaused(_INTL("You got some free Premier Balls with your purchase!"))
              end
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

  def pbSellScreen
    item=@scene.pbStartSellScene(@adapter.getInventory,@adapter)
    loop do
      item=@scene.pbChooseSellItem
      break if !item
      itemname=@adapter.getDisplayName(item)
      price=@adapter.getPrice(item,true)
      if !@adapter.canSell?(item)
        pbDisplayPaused(_INTL("{1}? Oh, no. I can't buy that.",itemname))
        next
      end
      qty=@adapter.getQuantity(item)
      next if qty==0
      @scene.pbShowMoney
      if qty>1
        qty=@scene.pbChooseNumber(
           _INTL("{1}? How many would you like to sell?",itemname),item,qty)
      end
      if qty==0
        @scene.pbHideMoney
        next
      end
      price/=2
      price*=qty
      if pbConfirm(_INTL("I can pay {1}. Would that be OK?",@adapter.getMoneyDisplay(price)))
        @adapter.setMoney(@adapter.getMoney+price)
        qty.times do
          @adapter.removeItem(item)
        end
        pbDisplayPaused(_INTL("Turned over the {1} and received {2}.",itemname,@adapter.getMoneyDisplay(price))) { pbSEPlay("Mart buy item") }
        @scene.pbRefresh
      end
      @scene.pbHideMoney
    end
    @scene.pbEndSellScene
  end
end

