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

class PokemonBagScreen
  def pbStartScreen
    @scene.pbStartScene(@bag)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      cmdRead     = -1
      cmdUse      = -1
      cmdRegister = -1
      cmdGive     = -1
      cmdToss     = -1
      cmdDebug    = -1
      commands = []
      # Generate command list
      commands[cmdRead = commands.length]       = _INTL("Read") if itm.is_mail?

      canUseAsTM = itm.is_machine? && $Trainer.party.length > 0
      if ItemHandlers.hasOutHandler(item) || canUseAsTM
        if ItemHandlers.hasUseText(item)
          commands[cmdUse = commands.length]    = ItemHandlers.getUseText(item)
        else
          commands[cmdUse = commands.length]    = _INTL("Use")
        end
      end
      commands[cmdGive = commands.length]       = _INTL("Give") if $Trainer.pokemon_party.length > 0 && itm.can_hold?
      commands[cmdToss = commands.length]       = _INTL("Toss") if !itm.is_important? || $DEBUG
      if @bag.pbIsRegistered?(item)
        commands[cmdRegister = commands.length] = _INTL("Deselect")
      elsif pbCanRegisterItem?(item)
        commands[cmdRegister = commands.length] = _INTL("Register")
      end
      commands[cmdDebug = commands.length]      = _INTL("Debug") if $DEBUG
      commands[commands.length]                 = _INTL("Cancel")
      # Show commands generated above
      itemname = itm.name
      command = @scene.pbShowCommands(_INTL("{1} is selected.",itemname),commands)
      if cmdRead>=0 && command==cmdRead   # Read mail
        pbFadeOutIn {
          pbDisplayMail(Mail.new(item, "", ""))
        }
      elsif cmdUse>=0 && command==cmdUse   # Use item
        if (ItemHandlers.hasUseOnPokemon(item) || canUseAsTM) && !teamEditingAllowed?()
          showNoTeamEditingMessage()
          next
        end
        ret = pbUseItem(@bag,item,@scene)
        # ret: 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
        break if ret==2   # End screen
        @scene.pbRefresh
        next
      elsif cmdGive>=0 && command==cmdGive   # Give item to Pokémon
        if !teamEditingAllowed?()
          showNoTeamEditingMessage()
          next
        end
        if $Trainer.pokemon_count == 0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
        elsif itm.is_important?
          @scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
        else
          pbFadeOutIn {
            sscene = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
            sscreen.pbPokemonGiveScreen(item)
            @scene.pbRefresh
          }
        end
      elsif cmdToss>=0 && command==cmdToss   # Toss item
        qty = @bag.pbQuantity(item)
        if qty>1
          helptext = _INTL("Toss out how many {1}?",itm.name_plural)
          qty = @scene.pbChooseNumber(helptext,qty)
        end
        if qty>0
          itemname = itm.name_plural if qty>1
          if pbConfirm(_INTL("Is it OK to throw away {1} {2}?",qty,itemname))
            pbDisplay(_INTL("Threw away {1} {2}.",qty,itemname))
            qty.times { @bag.pbDeleteItem(item) }
            @scene.pbRefresh
          end
        end
      elsif cmdRegister>=0 && command==cmdRegister   # Register item
        if @bag.pbIsRegistered?(item)
          @bag.pbUnregisterItem(item)
        else
          @bag.pbRegisterItem(item)
        end
        @scene.pbRefresh
      elsif cmdDebug>=0 && command==cmdDebug   # Debug
        command = 0
        loop do
          command = @scene.pbShowCommands(_INTL("Do what with {1}?",itemname),[
            _INTL("Change quantity"),
            _INTL("Make Mystery Gift"),
            _INTL("Cancel")
            ],command)
          case command
          ### Cancel ###
          when -1, 2
            break
          ### Change quantity ###
          when 0
            qty = @bag.pbQuantity(item)
            itemplural = itm.name_plural
            params = ChooseNumberParams.new
            params.setRange(0, Settings::BAG_MAX_PER_SLOT)
            params.setDefaultValue(qty)
            newqty = pbMessageChooseNumber(
               _INTL("Choose new quantity of {1} (max. #{Settings::BAG_MAX_PER_SLOT}).",itemplural),params) { @scene.pbUpdate }
            if newqty>qty
              @bag.pbStoreItem(item,newqty-qty)
            elsif newqty<qty
              @bag.pbDeleteItem(item,qty-newqty)
            end
            @scene.pbRefresh
            break if newqty==0
          ### Make Mystery Gift ###
          when 1
            pbCreateMysteryGift(1,item)
          end
        end
      end
    end
    @scene.pbEndScene
    return item
  end
end

class PokemonBag_Scene
    # Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem
    @sprites["helpwindow"].visible = false
    itemwindow = @sprites["itemlist"]
    thispocket = @bag.pockets[itemwindow.pocket]
    swapinitialpos = -1
    pbActivateWindow(@sprites,"itemlist") {
      loop do
        oldindex = itemwindow.index
        Graphics.update
        Input.update
        pbUpdate
        if itemwindow.sorting && itemwindow.index>=thispocket.length
          itemwindow.index = (oldindex==thispocket.length-1) ? 0 : thispocket.length-1
        end
        if itemwindow.index!=oldindex
          # Move the item being switched
          if itemwindow.sorting
            thispocket.insert(itemwindow.index,thispocket.delete_at(oldindex))
          end
          # Update selected item for current pocket
          @bag.setChoice(itemwindow.pocket,itemwindow.index)
          pbRefresh
        end
        if itemwindow.sorting
          if Input.trigger?(Input::ACTION) ||
             Input.trigger?(Input::USE)
            itemwindow.sorting = false
            pbPlayDecisionSE
            pbRefresh
          elsif Input.trigger?(Input::BACK)
            thispocket.insert(swapinitialpos,thispocket.delete_at(itemwindow.index))
            itemwindow.index = swapinitialpos
            itemwindow.sorting = false
            pbPlayCancelSE
            pbRefresh
          end
        else
          # Change pockets
          if Input.trigger?(Input::LEFT)
            newpocket = itemwindow.pocket
            loop do
              newpocket = (newpocket==1) ? PokemonBag.numPockets : newpocket-1
              break if !@choosing || newpocket==itemwindow.pocket
              if @filterlist
                break if @filterlist[newpocket].length>0
              else
                break if @bag.pockets[newpocket].length>0
              end
            end
            if itemwindow.pocket!=newpocket
              itemwindow.pocket = newpocket
              @bag.lastpocket   = itemwindow.pocket
              thispocket = @bag.pockets[itemwindow.pocket]
              pbPlayCursorSE
              pbRefresh
            end
          elsif Input.trigger?(Input::RIGHT)
            newpocket = itemwindow.pocket
            loop do
              newpocket = (newpocket==PokemonBag.numPockets) ? 1 : newpocket+1
              break if !@choosing || newpocket==itemwindow.pocket
              if @filterlist
                break if @filterlist[newpocket].length>0
              else
                break if @bag.pockets[newpocket].length>0
              end
            end
            if itemwindow.pocket!=newpocket
              itemwindow.pocket = newpocket
              @bag.lastpocket   = itemwindow.pocket
              thispocket = @bag.pockets[itemwindow.pocket]
              pbPlayCursorSE
              pbRefresh
            end
          elsif Input.trigger?(Input::ACTION)   # Start switching the selected item
            if !@choosing
              if thispocket.length>1 && itemwindow.index<thispocket.length &&
                  $PokemonSystem.bag_sorting == 0
                itemwindow.sorting = true
                swapinitialpos = itemwindow.index
                pbPlayDecisionSE
                pbRefresh
              else
                pbPlayBuzzerSE
              end
            end
          elsif Input.trigger?(Input::BACK)   # Cancel the item screen
            pbPlayCloseMenuSE
            return nil
          elsif Input.trigger?(Input::USE)   # Choose selected item
            (itemwindow.item) ? pbPlayDecisionSE : pbPlayCloseMenuSE
            return itemwindow.item
          end
        end
      end
    }
  end
end

module ItemStorageHelper
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
      items.sort! { |a, b| b[1] <=> a[1] }
    elsif $PokemonSystem.bag_sorting == 1
      items.sort! { |a, b| GameData::Item.get(a[0]).real_name <=> GameData::Item.get(b[0]).real_name }
    end
  end
end

class PokemonBag
  def pbStoreItem(item, qty = 1, sort = true)
    item = GameData::Item.get(item)
    pocket = item.pocket
    maxsize = maxPocketSize(pocket)
    maxsize = @pockets[pocket].length + 1 if maxsize < 0
    return ItemStorageHelper.pbStoreItem(
       @pockets[pocket], maxsize, Settings::BAG_MAX_PER_SLOT, item.id, qty, sort)
  end

  def sortItems
    @pockets.each do |pocket|
      ItemStorageHelper.sortItems(pocket)
    end
  end
end