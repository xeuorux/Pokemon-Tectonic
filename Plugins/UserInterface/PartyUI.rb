class PokemonPartyPanel < SpriteWrapper

  def initialize(pokemon,index,viewport=nil)
    super(viewport)
    @pokemon = pokemon
    @active = (index==0)   # true = rounded panel, false = rectangular panel
    @refreshing = true
    self.x = (index % 2) * Graphics.width / 2
    self.y = 16 * (index % 2) + 96 * (index / 2)
    @panelbgsprite = ChangelingSprite.new(0,0,viewport)
    @panelbgsprite.z = self.z
    if @active   # Rounded panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_round")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_round_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_round_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_round_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_round_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_round_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_round_swap_sel2")
    else   # Rectangular panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_rect")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_rect_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_rect_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_rect_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_rect_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_rect_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_rect_swap_sel2")
    end
    @hpbgsprite = ChangelingSprite.new(0,0,viewport)
    @hpbgsprite.z = self.z+1
    @hpbgsprite.addBitmap("able","Graphics/Pictures/Party/overlay_hp_back")
    @hpbgsprite.addBitmap("fainted","Graphics/Pictures/Party/overlay_hp_back_faint")
    @hpbgsprite.addBitmap("swap","Graphics/Pictures/Party/overlay_hp_back_swap")
    @ballsprite = ChangelingSprite.new(0,0,viewport)
    @ballsprite.z = self.z+1
    @ballsprite.addBitmap("desel","Graphics/Pictures/Party/icon_ball")
    @ballsprite.addBitmap("sel","Graphics/Pictures/Party/icon_ball_sel")
    @pkmnsprite = PokemonIconSprite.new(pokemon,viewport)
    @pkmnsprite.setOffset(PictureOrigin::Center)
    @pkmnsprite.active = @active
    @pkmnsprite.z      = self.z+2
    @helditemsprite = HeldItemIconSprite.new(0,0,@pokemon,viewport)
    @helditemsprite.z = self.z+3
    @overlaysprite = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
    @overlaysprite.z = self.z+4
    @hpbar    = AnimatedBitmap.new("Graphics/Pictures/Party/overlay_hp")
    @statuses = AnimatedBitmap.new(_INTL("Graphics/Pictures/Rework/statuses"))
    @selected      = false
    @preselected   = false
    @switching     = false
    @text          = nil
    @refreshBitmap = true
    @refreshing    = false
    refresh
  end
  
  def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    if @panelbgsprite && !@panelbgsprite.disposed?
      if self.selected
        if self.preselected;     @panelbgsprite.changeBitmap("swapsel2")
        elsif @switching;        @panelbgsprite.changeBitmap("swapsel")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("faintedsel")
        else;                    @panelbgsprite.changeBitmap("ablesel")
        end
      else
        if self.preselected;     @panelbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("fainted")
        else;                    @panelbgsprite.changeBitmap("able")
        end
      end
      @panelbgsprite.x     = self.x
      @panelbgsprite.y     = self.y
      @panelbgsprite.color = self.color
    end
    if @hpbgsprite && !@hpbgsprite.disposed?
      @hpbgsprite.visible = (!@pokemon.egg? && !(@text && @text.length>0))
      if @hpbgsprite.visible
        if self.preselected || (self.selected && @switching); @hpbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?;                              @hpbgsprite.changeBitmap("fainted")
        else;                                                 @hpbgsprite.changeBitmap("able")
        end
        @hpbgsprite.x     = self.x+96
        @hpbgsprite.y     = self.y+50
        @hpbgsprite.color = self.color
      end
    end
    if @ballsprite && !@ballsprite.disposed?
      @ballsprite.changeBitmap((self.selected) ? "sel" : "desel")
      @ballsprite.x     = self.x+10
      @ballsprite.y     = self.y
      @ballsprite.color = self.color
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x        = self.x+60
      @pkmnsprite.y        = self.y+40
      @pkmnsprite.color    = self.color
      @pkmnsprite.selected = self.selected
    end
    if @helditemsprite && !@helditemsprite.disposed?
      if @helditemsprite.visible
        @helditemsprite.x     = self.x+62
        @helditemsprite.y     = self.y+48
        @helditemsprite.color = self.color
      end
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
    if @refreshBitmap
      @refreshBitmap = false
      @overlaysprite.bitmap.clear if @overlaysprite.bitmap
      basecolor   = Color.new(248,248,248)
      shadowcolor = Color.new(40,40,40)
      pbSetSystemFont(@overlaysprite.bitmap)
      textpos = []
      # Draw Pokémon name
      textpos.push([@pokemon.name,96,10,0,basecolor,shadowcolor])
      if !@pokemon.egg?
        if !@text || @text.length==0
          # Draw HP numbers
          textpos.push([sprintf("% 3d /% 3d",@pokemon.hp,@pokemon.totalhp),224,54,1,basecolor,shadowcolor])
          # Draw HP bar
          if @pokemon.hp>0
            w = @pokemon.hp*96*1.0/@pokemon.totalhp
            w = 1 if w<1
            w = ((w/2).round)*2
            hpzone = 0
            hpzone = 1 if @pokemon.hp<=(@pokemon.totalhp/2).floor
            hpzone = 2 if @pokemon.hp<=(@pokemon.totalhp/4).floor
            hprect = Rect.new(0,hpzone*8,w,8)
            @overlaysprite.bitmap.blt(128,52,@hpbar.bitmap,hprect)
          end
          # Draw status
          status = 0
          if @pokemon.fainted?
            status = GameData::Status::DATA.keys.length / 2
          elsif @pokemon.status != :NONE
            status = GameData::Status.get(@pokemon.status).id_number
          end
          if status >= 1
            statusrect = Rect.new(0,16*(status-1),44,16)
            @overlaysprite.bitmap.blt(78,68,@statuses.bitmap,statusrect)
          end
        end
        # Draw gender symbol
        if @pokemon.male?
          textpos.push([_INTL("♂"),224,10,0,Color.new(0,112,248),Color.new(120,184,232)])
        elsif @pokemon.female?
          textpos.push([_INTL("♀"),224,10,0,Color.new(232,32,16),Color.new(248,168,184)])
        end
        # Draw shiny icon
        if @pokemon.shiny?
          shinyIconFileName = @pokemon.shiny_variant? ? "Graphics/Pictures/shiny_variant" : "Graphics/Pictures/shiny"
          pbDrawImagePositions(@overlaysprite.bitmap,[[
             shinyIconFileName,80,48,0,0,16,16]])
        end
      end
      pbDrawTextPositions(@overlaysprite.bitmap,textpos)
      # Draw level text
      if !@pokemon.egg?
        pbDrawImagePositions(@overlaysprite.bitmap,[[
           "Graphics/Pictures/Party/overlay_lv",20,70,0,0,22,14]])
        pbSetSmallFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,[
           [@pokemon.level.to_s,42,57,0,basecolor,shadowcolor]
        ])
      end
      # Draw annotation text
      if @text && @text.length>0
        pbSetSystemFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,[
           [@text,96,52,0,basecolor,shadowcolor]
        ])
      end
    end
    @refreshing = false
  end
end

class PokemonPartyScreen
	def pbPokemonScreen
    @scene.pbStartScene(@party,(@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),nil)
    loop do
      @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon(false,-1,1)
      break if (pkmnid.is_a?(Numeric) && pkmnid<0) || (pkmnid.is_a?(Array) && pkmnid[1]<0)
      if pkmnid.is_a?(Array) && pkmnid[0]==1   # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid[1]
        pkmnid = @scene.pbChoosePokemon(true,-1,2)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
        next
      end
      pkmn = @party[pkmnid]
      commands   = []
      cmdSummary = -1
      cmdDebug   = -1
      cmdSwitch  = -1
      cmdMail    = -1
      cmdItem    = -1
	    cmdRename  = -1
      cmdPokedex = -1
	    cmdSetDown = -1
      cmdSendPC  = -1
      # Build the commands
      commands[cmdSetDown = commands.length]	    = _INTL("Set Down") if defined?($PokEstate.setDownIntoEstate) && $PokEstate.isInEstate?()
	    commands[cmdSummary = commands.length]      = _INTL("Summary")
      commands[cmdDebug = commands.length]        = _INTL("Debug") if $DEBUG
      commands[cmdSwitch = commands.length]       = _INTL("Switch") if @party.length>1
      if !pkmn.egg?
		    if $Trainer.has_pokedex
          commands[cmdPokedex = commands.length]  = _INTL("Pokédex")
        end
		    if !pkmn.shadowPokemon?
          commands[cmdRename = commands.length]   = _INTL("Rename")
        end
        if pkmn.mail
          commands[cmdMail = commands.length]     = _INTL("Mail")
        else
          commands[cmdItem = commands.length]     = _INTL("Item")
        end
      end
      commands[cmdSendPC = commands.length]       = _INTL("Send to PC") if @party.length>1
      commands[commands.length]                   = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands)
      havecommand = false
      if cmdSummary >= 0 && command == cmdSummary
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        }
      elsif cmdDebug >= 0 && command == cmdDebug
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdSwitch >= 0 && command == cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid
        pkmnid = @scene.pbChoosePokemon(true)
        if pkmnid >= 0 && pkmnid != oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
      elsif cmdMail >= 0 && command==cmdMail
        command = @scene.pbShowCommands(_INTL("Do what with the mail?"),
           [_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail(pkmn.mail,pkmn)
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
        when 1   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        end
      elsif cmdRename >= 0 && command == cmdRename
        currentName = pkmn.name
        pbTextEntry("#{currentName}'s nickname?",0,10,5)
        if pbGet(5)=="" || pbGet(5)==currentName
          pkmn.name = currentName
        else
          pkmn.name = pbGet(5)
        end
      elsif cmdPokedex >=0 && command == cmdPokedex
        openSingleDexScreen(pkmn)
      elsif cmdSendPC >= 0 && command == cmdSendPC
        if $Trainer.able_pokemon_count == 1 && pkmn.able?
          pbDisplay(_INTL("You can't send back your only able Pokémon!"))
        elsif pbConfirm(_INTL("Are you sure you'd like to send back #{pkmn.name}?"))
          if pkmn.hasItem?
            itemName = GameData::Item.get(pkmn.item).real_name
            if pbConfirmMessageSerious(_INTL("{1} is holding an {2}. Would you like to take it before transferring?", pkmn.name, itemName))
              pbTakeItemFromPokemon(pkmn,self)
              @scene.pbRefresh
            end
          end
          pbStorePokemonInPC(pkmn)
          @party[pkmnid] = nil
          @party.compact!
          pbSEPlay("PC close")
          @scene.pbHardRefresh
        end
      elsif cmdSetDown >= 0 && command == cmdSetDown
        if $PokEstate.setDownIntoEstate(pkmn)
          @party[pkmnid] = nil
          @party.compact!
          @scene.pbHardRefresh
          break
        end
      elsif cmdItem >= 0 && command == cmdItem
        itemcommands = []
        cmdUseItem   = -1
        cmdGiveItem  = -1
        cmdTakeItem  = -1
        cmdMoveItem  = -1
        # Build the commands
        itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
        itemcommands[cmdGiveItem=itemcommands.length] = _INTL("Give")
        itemcommands[cmdTakeItem=itemcommands.length] = _INTL("Take") if pkmn.hasItem?
        itemcommands[cmdMoveItem=itemcommands.length] = _INTL("Move") if pkmn.hasItem? && !GameData::Item.get(pkmn.item).is_mail?
        itemcommands[itemcommands.length]             = _INTL("Cancel")
        command = @scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
        if cmdUseItem>=0 && command==cmdUseItem   # Use
          item = @scene.pbUseItem($PokemonBag,pkmn) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item
            pbUseItemOnPokemon(item,pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
          item = @scene.pbChooseItem($PokemonBag) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item
            if pbGiveItemToPokemon(item,pkmn,self,pkmnid)
              pbRefreshSingle(pkmnid)
            end
          end
        elsif cmdTakeItem>=0 && command==cmdTakeItem   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdMoveItem>=0 && command==cmdMoveItem   # Move
          item = pkmn.item
          itemname = item.name
          @scene.pbSetHelpText(_INTL("Move {1} to where?",itemname))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn = @party[pkmnid]
            break if pkmnid==oldpkmnid
            if newpkmn.egg?
              pbDisplay(_INTL("Eggs can't hold items."))
            elsif !newpkmn.hasItem?
              newpkmn.item = item
              pkmn.item = nil
              @scene.pbClearSwitching
              pbRefresh
              pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
              break
            elsif GameData::Item.get(newpkmn.item).is_mail?
              pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",newpkmn.name))
            else
              newitem = newpkmn.item
              newitemname = newitem.name
              if newitem == :LEFTOVERS
                pbDisplay(_INTL("{1} is already holding some {2}.\1",newpkmn.name,newitemname))
              elsif newitemname.starts_with_vowel?
                pbDisplay(_INTL("{1} is already holding an {2}.\1",newpkmn.name,newitemname))
              else
                pbDisplay(_INTL("{1} is already holding a {2}.\1",newpkmn.name,newitemname))
              end
              if pbConfirm(_INTL("Would you like to switch the two items?"))
                newpkmn.item = item
                pkmn.item = newitem
                @scene.pbClearSwitching
                pbRefresh
                pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                pbDisplay(_INTL("{1} was given the {2} to hold.",pkmn.name,newitemname))
                break
              end
            end
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end
end

class PokeBattle_Scene
  #=============================================================================
  # Opens the party screen to choose a Pokémon to switch in (or just view its
  # summary screens)
  #=============================================================================
  def pbPartyScreen(idxBattler,canCancel=false)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    scene = PokemonParty_Scene.new
    switchScreen = PokemonPartyScreen.new(scene,modParty)
    switchScreen.pbStartScene(_INTL("Choose a Pokémon."),@battle.pbNumPositions(0,0))
    # Loop while in party screen
    loop do
      # Select a Pokémon
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      idxParty = switchScreen.pbChoosePokemon
      if idxParty<0
        next if !canCancel
        break
      end
      # Choose a command for the selected Pokémon
      cmdSwitch  = -1
      cmdSummary = -1
	  cmdPokedex = -1
      commands = []
      commands[cmdSwitch  = commands.length] = _INTL("Switch In") if modParty[idxParty].able?
      commands[cmdSummary = commands.length] = _INTL("Summary")
	  commands[cmdPokedex = commands.length] = _INTL("Pokédex") if !modParty[idxParty].egg? && $Trainer.has_pokedex
      commands[commands.length]              = _INTL("Cancel")
      command = scene.pbShowCommands(_INTL("Do what with {1}?",modParty[idxParty].name),commands)
      if cmdSwitch>=0 && command==cmdSwitch        # Switch In
        idxPartyRet = -1
        partyPos.each_with_index do |pos,i|
          next if pos!=idxParty+partyStart
          idxPartyRet = i
          break
        end
        break if yield idxPartyRet, switchScreen
      elsif cmdSummary>=0 && command==cmdSummary   # Summary
        scene.pbSummary(idxParty,true)
	  elsif cmdPokedex && command==cmdPokedex
        openSingleDexScreen(modParty[idxParty])
      end
    end
    # Close party screen
    switchScreen.pbEndScene
    # Fade back into battle screen
    pbFadeInAndShow(@sprites,visibleSprites)
  end
end