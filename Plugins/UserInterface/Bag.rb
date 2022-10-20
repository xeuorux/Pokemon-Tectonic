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