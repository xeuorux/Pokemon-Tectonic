#===============================================================================
# Picking up an item found on the ground
#===============================================================================
def pbItemBall(item,quantity=1)
  item = GameData::Item.get(item)
  return false if !item || quantity<1
  itemname = (quantity>1) ? item.name_plural : item.name
  pocket = item.pocket
  move = item.move
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be picked up
    meName = (item.is_key_item?) ? "Key item get" : "Item get"
    if item == :LEFTOVERS
      pbMessage(_INTL("\\me[{1}]You found some \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    elsif item.is_machine?   # TM or HM
      pbMessage(_INTL("\\me[{1}]You found \\c[1]{2} {3}\\c[0]!\\wtnp[30]",meName,itemname,GameData::Move.get(move).name))
    elsif quantity>1
      pbMessage(_INTL("\\me[{1}]You found {2} \\c[1]{3}\\c[0]!\\wtnp[30]",meName,quantity,itemname))
    elsif itemname.starts_with_vowel?
      pbMessage(_INTL("\\me[{1}]You found an \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    else
      pbMessage(_INTL("\\me[{1}]You found a \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    end
	showItemDescription(item)
    pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
       itemname,pocket,PokemonBag.pocketNames()[pocket]))
    return true
  end
  # Can't add the item
  if item == :LEFTOVERS
    pbMessage(_INTL("You found some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  elsif item.is_machine?   # TM or HM
    pbMessage(_INTL("You found \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,GameData::Move.get(move).name))
  elsif quantity>1
    pbMessage(_INTL("You found {1} \\c[1]{2}\\c[0]!\\wtnp[30]",quantity,itemname))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("You found an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  else
    pbMessage(_INTL("You found a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  end
  pbMessage(_INTL("But your Bag is full..."))
  return false
end

#===============================================================================
# Being given an item
#===============================================================================
def pbReceiveItem(item,quantity=1)
  item = GameData::Item.get(item)
  return false if !item || quantity<1
  itemname = (quantity>1) ? item.name_plural : item.name
  pocket = item.pocket
  move = item.move
  meName = (item.is_key_item?) ? "Key item get" : "Item get"
  if item == :LEFTOVERS
    pbMessage(_INTL("\\me[{1}]You obtained some \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
  elsif item.is_machine?   # TM or HM
    pbMessage(_INTL("\\me[{1}]You obtained \\c[1]{2} {3}\\c[0]!\\wtnp[30]",meName,itemname,GameData::Move.get(move).name))
  elsif quantity>1
    pbMessage(_INTL("\\me[{1}]You obtained {2} \\c[1]{3}\\c[0]!\\wtnp[30]",meName,quantity,itemname))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("\\me[{1}]You obtained an \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
  else
    pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
  end
  showItemDescription(item)
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be added
    pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
       itemname,pocket,PokemonBag.pocketNames()[pocket]))
    return true
  end
  return false   # Can't add the item
end

class PokemonGlobalMetadata
	attr_accessor :hadItemYet
end

def showItemDescription(item)
	$PokemonGlobal.hadItemYet = {} if $PokemonGlobal.hadItemYet.nil?
	if !$PokemonGlobal.hadItemYet[item.id]
		pbMessage(_INTL("\\cl\\l[4]\\op\\wu\\i[{1}]\\or{2}\\wt[30]",item.id,item.real_description))
		$PokemonGlobal.hadItemYet[item.id] = true
	end
end

def pbPickBerry(berry, qty = 1)
  interp=pbMapInterpreter
  thisEvent=interp.get_character(0)
  berryData=interp.getVariable
  berry=GameData::Item.get(berry)
  itemname=(qty>1) ? berry.name_plural : berry.name

  if !$PokemonBag.pbCanStore?(berry,qty)
      pbMessage(_INTL("Too bad...\nThe Bag is full..."))
      return
    end
    $PokemonBag.pbStoreItem(berry,qty)
    if qty>1
      pbMessage(_INTL("You picked the {1} \\c[1]{2}\\c[0].\\wtnp[20]",qty,itemname))
    else
      pbMessage(_INTL("You picked the \\c[1]{1}\\c[0].\\wtnp[20]",itemname))
    end
	showItemDescription(berry)
    pocket = berry.pocket
    pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
       $Trainer.name,itemname,pocket,PokemonBag.pocketNames()[pocket]))
    if Settings::NEW_BERRY_PLANTS
      pbMessage(_INTL("The berry plant withered away."))
      berryData=[0,nil,0,0,0,0,0,0]
    else
      pbMessage(_INTL("The berry plant withered away."))
      berryData=[0,nil,false,0,0,0]
    end
    interp.setVariable(berryData)
    pbSetSelfSwitch(thisEvent.id,"A",true)
end

#===============================================================================
# Add EXP
#===============================================================================
def pbAddEXP(pkmn,exp)
  new_exp = pkmn.growth_rate.add_exp(pkmn.exp,exp)
  new_level = pkmn.growth_rate.level_from_exp(new_exp)
  pkmn.setExp(new_exp)
  pkmn.calc_stats
  return new_level
end

def pbEXPAdditionItem(pkmn,exp,item,scene)
	current_lvl = pkmn.level
	current_exp = pkmn.exp
	level_cap = LEVEL_CAPS_USED ? $game_variables[26] : growth_rate.max_level
	
	# Do nothing if the pokemon's already at the level cap
	if pkmn.level >= level_cap || pkmn.shadowPokemon?
		scene.pbDisplay(_INTL("It won't have any effect."))
		return false
	end
	
	# Ask the player how many they'd like to apply
	maxxp = pkmn.growth_rate.minimum_exp_for_level(level_cap)
    maxlv = ((maxxp - current_exp) / exp.to_f).ceil
    maximum = [maxlv,$PokemonBag.pbQuantity(item)].min # Max items which can be used
	if maximum > 1
		question = _INTL("How many {1} do you want to use?", GameData::Item.get(item).name_plural)
		qty = scene.pbChooseNumber(question, maximum, 1)
	else
		qty = 1
	end
    return false if qty < 1
    $PokemonBag.pbDeleteItem(item, qty - 1)
	scene.pbRefresh
	
	# Apply the new EXP, accounting for the level cap
    pkmn.exp += exp * qty
	pkmn.exp = [pkmn.exp,maxxp].min
    display_exp = pkmn.exp - current_exp
	new_level = pkmn.level
	if new_level == level_cap
		scene.pbDisplay(_INTL("{1} gained only {3} Exp. Points due to the level cap at level {2}.",pkmn.name,level_cap,display_exp))
    else
		scene.pbDisplay(_INTL("{1} gained {2} Exp. Points!",pkmn.name,display_exp))
    end
	pkmn.changeHappiness("vitamin")
	scene.pbRefresh
	
	# Leave if didn't level up
	if new_level == current_lvl
		return true
	end
	
	# Show messages surrounding leveling up
	attackdiff  = pkmn.attack
    defensediff = pkmn.defense
    speeddiff   = pkmn.speed
    spatkdiff   = pkmn.spatk
    spdefdiff   = pkmn.spdef
    totalhpdiff = pkmn.totalhp
    pkmn.calc_stats
    scene.pbRefresh
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!",pkmn.name,pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!",pkmn.name,pkmn.level))
    end
    attackdiff  = pkmn.attack-attackdiff
    defensediff = pkmn.defense-defensediff
    speeddiff   = pkmn.speed-speeddiff
    spatkdiff   = pkmn.spatk-spatkdiff
    spdefdiff   = pkmn.spdef-spdefdiff
    totalhpdiff = pkmn.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pkmn.totalhp,pkmn.attack,pkmn.defense,pkmn.spatk,pkmn.spdef,pkmn.speed))
	
	# Learn new moves upon level up
	movelist = pkmn.getMoveList
	for i in movelist
	  next if i[0] <= current_lvl
	  break if i[0] > new_level
	  pbLearnMove(pkmn,i[1],true) { scene.pbRefresh }
	end
	
	# Check for evolution
	newspecies = pkmn.check_evolution_on_level_up
	if newspecies
	  pbFadeOutInWithMusic {
		evo = PokemonEvolutionScene.new
		evo.pbStartScreen(pkmn,newspecies)
		evo.pbEvolution
		evo.pbEndScreen
		scene.pbRefresh
	  }
	end
	
    return true
end

class PokemonParty_Scene
  def pbChooseNumber(helptext,maximum,initnum=1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"],helptext,maximum,initnum) { pbUpdate }
  end
end

#===============================================================================
# Use an item from the Bag and/or on a Pokémon
#===============================================================================
# @return [Integer] 0 = item wasn't used; 1 = item used; 2 = close Bag to use in field
def pbUseItem(bag,item,bagscene=nil)
  itm = GameData::Item.get(item)
  useType = itm.field_use
  if itm.is_machine?    # TM or TR or HM
    if $Trainer.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    machine = itm.move
    return 0 if !machine
    movename = GameData::Move.get(machine).name
    pbMessage(_INTL("\\se[PC access]You booted up {1}.\1",itm.name))
    if !pbConfirmMessage(_INTL("Do you want to teach {1} to a Pokémon?",movename))
      return 0
    elsif pbMoveTutorChoose(machine,nil,true,itm.is_TR?)
      bag.pbDeleteItem(item) if itm.is_TR?
      return 1
    end
    return 0
  elsif useType==1 || useType==5   # Item is usable on a Pokémon
    if $Trainer.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret = false
    annot = nil
    if itm.is_evolution_stone?
      annot = []
      for pkmn in $Trainer.party
        elig = pkmn.check_evolution_on_use_item(item)
        annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    pbFadeOutIn {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Use on which Pokémon?"),false,annot)
      loop do
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        chosen = screen.pbChoosePokemon
        if chosen<0
          ret = false
          break
        end
        pkmn = $Trainer.party[chosen]
        if pbCheckUseOnPokemon(item,pkmn,screen)
          ret = ItemHandlers.triggerUseOnPokemon(item,pkmn,scene)
          if ret && useType==1   # Usable on Pokémon, consumed
            bag.pbDeleteItem(item)
            if !bag.pbHasItem?(item)
              pbMessage(_INTL("You used your last {1}.",itm.name)) { screen.pbUpdate }
              break
            end
          end
        end
      end
      screen.pbEndScene
      bagscene.pbRefresh if bagscene
    }
    return (ret) ? 1 : 0
  elsif useType==2   # Item is usable from Bag
    intret = ItemHandlers.triggerUseFromBag(item)
    case intret
    when 0 then return 0
    when 1 then return 1   # Item used
    when 2 then return 2   # Item used, end screen
    when 3                 # Item used, consume item
      bag.pbDeleteItem(item)
      return 1
    when 4                 # Item used, end screen and consume item
      bag.pbDeleteItem(item)
      return 2
    end
    pbMessage(_INTL("Can't use that here."))
    return 0
  end
  pbMessage(_INTL("Can't use that here."))
  return 0
end