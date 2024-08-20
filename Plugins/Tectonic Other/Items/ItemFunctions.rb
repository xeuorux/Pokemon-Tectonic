#===============================================================================
# ItemHandlers
#===============================================================================
module ItemHandlers
  UseText            = ItemHandlerHash.new
  UseFromBag         = ItemHandlerHash.new
  ConfirmUseInField  = ItemHandlerHash.new
  UseInField         = ItemHandlerHash.new
  UseOnPokemon       = ItemHandlerHash.new
  CanUseInBattle     = ItemHandlerHash.new
  UseInBattle        = ItemHandlerHash.new
  BattleUseOnBattler = ItemHandlerHash.new
  BattleUseOnPokemon = ItemHandlerHash.new

  def self.hasUseText(item)
    return UseText[item]!=nil
  end

  def self.hasOutHandler(item)                       # Shows "Use" option in Bag
    return UseFromBag[item]!=nil || UseInField[item]!=nil || UseOnPokemon[item]!=nil
  end

  def self.hasUseInFieldHandler(item)           # Shows "Register" option in Bag
    return UseInField[item]!=nil
  end

  def self.hasUseOnPokemon(item)
    return UseOnPokemon[item]!=nil
  end

  def self.hasUseInBattle(item)
    return UseInBattle[item]!=nil
  end

  def self.hasBattleUseOnBattler(item)
    return BattleUseOnBattler[item]!=nil
  end

  def self.hasBattleUseOnPokemon(item)
    return BattleUseOnPokemon[item]!=nil
  end

  # Returns text to display instead of "Use"
  def self.getUseText(item)
    return UseText.trigger(item)
  end

  # Return value:
  # 0 - Item not used
  # 1 - Item used, don't end screen
  # 2 - Item used, end screen
  # 3 - Item used, don't end screen, consume item
  # 4 - Item used, end screen, consume item
  def self.triggerUseFromBag(item)
    return UseFromBag.trigger(item) if UseFromBag[item]
    # No UseFromBag handler exists; check the UseInField handler if present
    return UseInField.trigger(item) if UseInField[item]
    return 0
  end

  # Returns whether item can be used
  def self.triggerConfirmUseInField(item)
    return true if !ConfirmUseInField[item]
    return ConfirmUseInField.trigger(item)
  end

  # Return value:
  # -1 - Item effect not found
  # 0  - Item not used
  # 1  - Item used
  # 3  - Item used, consume item
  def self.triggerUseInField(item)
    return -1 if !UseInField[item]
    return UseInField.trigger(item)
  end

  # Returns whether item was used
  def self.triggerUseOnPokemon(item,pkmn,scene)
    return false if !UseOnPokemon[item]
    return UseOnPokemon.trigger(item,pkmn,scene)
  end

  def self.triggerCanUseInBattle(item,pkmn,battler,move,firstAction,battle,scene,showMessages=true)
    return true if !CanUseInBattle[item]   # Can use the item by default
    return CanUseInBattle.trigger(item,pkmn,battler,move,firstAction,battle,scene,showMessages)
  end

  # Returns whether item was used
  def self.triggerUseInBattle(item,battler,battle)
    return false if !UseInBattle[item]
    return UseInBattle.trigger(item,battler,battle)
  end

  # Returns whether item was used
  def self.triggerBattleUseOnBattler(item,battler,scene)
    return false if !BattleUseOnBattler[item]
    return BattleUseOnBattler.trigger(item,battler,scene)
  end

  # Returns whether item was used
  def self.triggerBattleUseOnPokemon(item,pkmn,battler,choices,scene)
    return false if !BattleUseOnPokemon[item]
    return BattleUseOnPokemon.trigger(item,pkmn,battler,choices,scene)
  end
end



def pbCanRegisterItem?(item)
  return ItemHandlers.hasUseInFieldHandler(item)
end

def pbCanUseOnPokemon?(item)
  return ItemHandlers.hasUseOnPokemon(item) || GameData::Item.get(item).is_machine?
end



#===============================================================================
# Change a Pokémon's level
#===============================================================================
def pbChangeLevel(pkmn, newlevel, scene = nil)
  oldLevel = pkmn.level
  newlevel = newlevel.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level == newlevel
      pbMessage(_INTL("{1}'s level remained unchanged.", pkmn.name))
  elsif pkmn.level > newlevel
      attackdiff  = pkmn.attack
      defensediff = pkmn.defense
      speeddiff   = pkmn.speed
      spatkdiff   = pkmn.spatk
      spdefdiff   = pkmn.spdef
      totalhpdiff = pkmn.totalhp
      pkmn.level = newlevel
      pkmn.calc_stats
      scene&.pbRefresh
      pbMessage(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
      attackdiff  = pkmn.attack - attackdiff
      defensediff = pkmn.defense - defensediff
      speeddiff   = pkmn.speed - speeddiff
      spatkdiff   = pkmn.spatk - spatkdiff
      spdefdiff   = pkmn.spdef - spdefdiff
      totalhpdiff = pkmn.totalhp - totalhpdiff
      pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
         totalhpdiff, attackdiff, defensediff, spatkdiff, spdefdiff, speeddiff))
      pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
         pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed))
  else
      attackdiff  = pkmn.attack
      defensediff = pkmn.defense
      speeddiff   = pkmn.speed
      spatkdiff   = pkmn.spatk
      spdefdiff   = pkmn.spdef
      totalhpdiff = pkmn.totalhp
      pkmn.level = newlevel
      pkmn.calc_stats
      scene&.pbRefresh
      pbSceneDefaultDisplay(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level),scene)
      attackdiff  = pkmn.attack - attackdiff
      defensediff = pkmn.defense - defensediff
      speeddiff   = pkmn.speed - speeddiff
      spatkdiff   = pkmn.spatk - spatkdiff
      spdefdiff   = pkmn.spdef - spdefdiff
      totalhpdiff = pkmn.totalhp - totalhpdiff
      pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
         totalhpdiff, attackdiff, defensediff, spatkdiff, spdefdiff, speeddiff), scene)
      pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
         pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)

      (newlevel - oldLevel).times do
          pkmn.changeHappiness("candylevelup")
      end
      
      # Learn new moves upon level up
      unless $PokemonSystem.prompt_level_moves == 1
          movelist = pkmn.getMoveList
          for i in movelist
              next unless i[0] > oldLevel
              next unless i[0] <= pkmn.level
              pbLearnMove(pkmn, i[1], true)
          end
      end
      
      # Check for evolution
      while true
        newspecies = pkmn.check_evolution_on_level_up
        break unless newspecies
        evolutionSuccess = false
        pbFadeOutInWithMusic do
            evo = PokemonEvolutionScene.new
            evo.pbStartScreen(pkmn, newspecies)
            evolutionSuccess = true if evo.pbEvolution
            evo.pbEndScreen
            scene&.pbRefresh
        end
        break unless evolutionSuccess
      end
  end
end

#===============================================================================
# Restore HP
#===============================================================================
def pbItemRestoreHP(pkmn,restoreHP)
  newHP = pkmn.hp+restoreHP
  newHP = pkmn.totalhp if newHP>pkmn.totalhp
  hpGain = newHP-pkmn.hp
  pkmn.hp = newHP
  return hpGain
end

def pbHPItem(pkmn,restoreHP,scene = nil,revive = false)
  if pkmn.fainted? && !revive
    pbSceneDefaultDisplay(_INTL("It won't have any effect."),scene)
    return false
  end
  if pkmn.hp == pkmn.totalhp
    pbSceneDefaultDisplay(_INTL("It won't have any effect."),scene)
    return false
  end
  hpGain = pbItemRestoreHP(pkmn,restoreHP)
  scene&.pbRefresh
  pbSceneDefaultDisplay(_INTL("{1}'s HP was restored by {2} points.",pkmn.name,hpGain),scene)
  return true
end

def pbBattleHPItem(pkmn,battler,restoreHP,scene = nil)
  if battler
    if battler.pbRecoverHP(restoreHP)>0
      pbSceneDefaultDisplay(_INTL("{1}'s HP was restored.",battler.pbThis),scene)
    end
  else
    if pbItemRestoreHP(pkmn,restoreHP)>0
      pbSceneDefaultDisplay(_INTL("{1}'s HP was restored.",pkmn.name),scene)
    end
  end
  return true
end

#===============================================================================
# Restore PP
#===============================================================================
def pbRestorePP(pkmn,idxMove,pp)
  return 0 if !pkmn.moves[idxMove] || !pkmn.moves[idxMove].id
  return 0 if pkmn.moves[idxMove].total_pp<=0
  oldpp = pkmn.moves[idxMove].pp
  newpp = pkmn.moves[idxMove].pp+pp
  newpp = pkmn.moves[idxMove].total_pp if newpp>pkmn.moves[idxMove].total_pp
  pkmn.moves[idxMove].pp = newpp
  return newpp-oldpp
end

def pbBattleRestorePP(pkmn, battler, idxMove, pp)
  return if pbRestorePP(pkmn,idxMove,pp) == 0
  if battler && !battler.effects[PBEffects::Transform] &&
     battler.moves[idxMove] && battler.moves[idxMove].id == pkmn.moves[idxMove].id
    battler.pbSetPP(battler.moves[idxMove], pkmn.moves[idxMove].pp)
  end
end


#===============================================================================
# Decide whether the player is able to ride/dismount their Bicycle
#===============================================================================
def pbBikeCheck
  if $PokemonGlobal.surfing || $PokemonGlobal.diving
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  if !$PokemonGlobal.bicycle && !$game_player.canBikeOnTerrain?
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    return false
  end
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if $PokemonGlobal.bicycle
    if map_metadata && map_metadata.always_bicycle
      pbMessage(_INTL("You can't dismount your Bike here."))
      return false
    end
    return true
  end
  if !map_metadata || (!map_metadata.can_bicycle && !map_metadata.outdoor_map)
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  return true
end

#===============================================================================
# Find the closest hidden item (for Itemfinder)
#===============================================================================
def pbClosestHiddenItem
  result = []
  playerX = $game_player.x
  playerY = $game_player.y
  for event in $game_map.events.values
    next if !event.name[/hiddenitem/i]
    next if (playerX-event.x).abs>=8
    next if (playerY-event.y).abs>=6
    next if $game_self_switches[[$game_map.map_id,event.id,"A"]]
    result.push(event)
  end
  return nil if result.length==0
  ret = nil
  retmin = 0
  for event in result
    dist = (playerX-event.x).abs+(playerY-event.y).abs
    next if ret && retmin<=dist
    ret = event
    retmin = dist
  end
  return ret
end

#===============================================================================
# Teach and forget a move
#===============================================================================
def pbLearnMove(pkmn,move,ignoreifknown=false,bymachine=false,addfirstmove=false,&block)
  return false if !pkmn
  move = GameData::Move.get(move).id
  if pkmn.egg? && !$DEBUG
    pbMessage(_INTL("Eggs can't be taught any moves."),&block)
    return false
  end
  pkmnname = pkmn.name
  movename = GameData::Move.get(move).name
  if pkmn.hasMove?(move)
    pbMessage(_INTL("{1} already knows {2}.",pkmnname,movename),&block) if !ignoreifknown
    return false
  end
  if pkmn.numMoves < Pokemon::MAX_MOVES
    pkmn.learn_move(move)
    pkmn.add_first_move(move) if addfirstmove
    pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",pkmnname,movename),&block)
    return true
  end
  loop do
    pbMessage(_INTL("{1} wants to learn {2}, but it already knows {3} moves.\1",
      pkmnname, movename, pkmn.numMoves.to_word), &block) if !bymachine
    pbMessage(_INTL("Please choose a move that will be replaced with {1}.",movename),&block)
    forgetmove = pbForgetMove(pkmn,move)
    if forgetmove>=0
      oldmovename = pkmn.moves[forgetmove].name
      oldmovepp   = pkmn.moves[forgetmove].pp
      pkmn.moves[forgetmove] = Pokemon::Move.new(move)   # Replaces current/total PP
      if bymachine && Settings::TAUGHT_MACHINES_KEEP_OLD_PP
        pkmn.moves[forgetmove].pp = [oldmovepp,pkmn.moves[forgetmove].total_pp].min
      end
      pbMessage(_INTL("1, 2, and...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"),&block)
      pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1",pkmnname,oldmovename),&block)
      pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",pkmnname,movename),&block)
      pkmn.add_first_move(move) if addfirstmove
      return true
  else
      pbMessage(_INTL("{1} did not learn {2}.",pkmnname,movename),&block)
      return false
    end
  end
end

def pbForgetMove(pkmn,moveToLearn)
  ret = -1
  pbFadeOutIn {
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    ret = screen.pbStartForgetScreen([pkmn],0,moveToLearn)
  }
  return ret
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
    return 0 unless machine
    if pbMoveTutorChoose(machine,nil,true,itm.is_TR?)
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
          ret = ItemHandlers.triggerUseOnPokemon(item,pkmn,screen)
          if ret && itm.consumed_after_use?   # Usable on Pokémon, consumed
            bag.pbDeleteItem(item)
            if !bag.pbHasItem?(item)
              pbMessage(_INTL("You used your last {1}.",itm.name)) { screen.pbUpdate }
              break
            end
          end
        end
      end
      screen.pbEndScene
      bagscene&.pbRefresh if bagscene
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

# Only called when in the party screen and having chosen an item to be used on
# the selected Pokémon
def pbUseItemOnPokemon(item,pkmn,scene = nil)
  itm = GameData::Item.get(item)
  # TM or HM
  if itm.is_machine?
    machine = itm.move
    return false if !machine
    movename = GameData::Move.get(machine).name
    if !pkmn.compatible_with_move?(machine)
      pbMessage(_INTL("{1} can't learn {2}.",pkmn.name,movename)) { scene&.pbUpdate }
    else
      if pbLearnMove(pkmn,machine,false,true,true) { scene&.pbUpdate }
        $PokemonBag.pbDeleteItem(item) if itm.is_TR?
        return true
      end
    end
    return false
  end
  # Other item
  ret = ItemHandlers.triggerUseOnPokemon(item,pkmn,scene)
  scene&.pbClearAnnotations
  scene&.pbHardRefresh
  if ret && itm.consumed_after_use?   # Usable on Pokémon, consumed
    $PokemonBag.pbDeleteItem(item)
    if !$PokemonBag.pbHasItem?(item)
      pbMessage(_INTL("You used your last {1}.",itm.name)) { scene&.pbUpdate }
    end
  end
  return ret
end

def pbUseKeyItemInField(item)
  ret = ItemHandlers.triggerUseInField(item)
  if ret==-1   # Item effect not found
    pbMessage(_INTL("Can't use that here."))
  elsif ret==3   # Item was used and consumed
    $PokemonBag.pbDeleteItem(item)
  end
  return ret!=-1 && ret!=0
end

def pbUseItemMessage(item)
  itemname = GameData::Item.get(item).name
  if itemname.starts_with_vowel?
    pbMessage(_INTL("You used an {1}.",itemname))
  else
    pbMessage(_INTL("You used a {1}.",itemname))
  end
end

def pbCheckUseOnPokemon(_item,pkmn,_screen)
  return pkmn && !pkmn.egg?
end

#===============================================================================
# Choose an item from the Bag
#===============================================================================
def pbChooseItem(var = 0, *args)
  ret = nil
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ret = screen.pbChooseItemScreen
  }
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

def pbChooseApricorn(var = 0)
  ret = nil
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_apricorn? })
  }
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

def pbChooseFossil(var = 0)
  ret = nil
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_fossil? })
  }
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

def pbChooseEvolutionStone(var = 0)
  ret = nil
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_evolution_stone? })
  }
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

# Shows a list of items to choose from, with the chosen item's ID being stored
# in the given Global Variable. Only items which the player has are listed.
def pbChooseItemFromList(message, variable, *args)
  commands = []
  itemid   = []
  for item in args
    next if !GameData::Item.exists?(item)
    itm = GameData::Item.get(item)
    next if !$PokemonBag.pbHasItem?(itm)
    commands.push(itm.name)
    itemid.push(itm.id)
  end
  if commands.length == 0
    $game_variables[variable] = 0
    return nil
  end
  commands.push(_INTL("Cancel"))
  itemid.push(nil)
  ret = pbMessage(message, commands, -1)
  if ret < 0 || ret >= commands.length-1
    $game_variables[variable] = nil
    return nil
  end
  $game_variables[variable] = itemid[ret]
  return itemid[ret]
end


#===============================================================================
# Add EXP
#===============================================================================
def pbAddEXP(pkmn, exp)
    new_exp = pkmn.growth_rate.add_exp(pkmn.exp, exp)
    new_level = pkmn.growth_rate.level_from_exp(new_exp)
    pkmn.setExp(new_exp)
    pkmn.calc_stats
    return new_level
end

def pbEXPAdditionItem(pkmn, exp, item, scene = nil, oneAtATime = false)
    current_lvl = pkmn.level
    current_exp = pkmn.exp
    level_cap = LEVEL_CAPS_USED ? getLevelCap : growth_rate.max_level

    # Do nothing if the pokemon's already at the level cap
    if pkmn.level >= level_cap
        pbSceneDefaultDisplay(_INTL("It won't have any effect."),scene)
        return false
    end

    # Max XP and level
    maxxp = pkmn.growth_rate.minimum_exp_for_level(level_cap)
    maxlv = ((maxxp - current_exp) / exp.to_f).ceil

    if oneAtATime
      quantity = 1
    else
      # Ask the player how many they'd like to apply
      maximum = [maxlv, $PokemonBag.pbQuantity(item)].min # Max items which can be used
      if maximum > 1
          params = ChooseNumberParams.new
          params.setRange(1, maximum)
          params.setInitialValue(1)
          params.setCancelValue(0)
          question = _INTL("How many {1} do you want to use?", GameData::Item.get(item).name_plural)
          quantity = pbMessageChooseNumber(question, params)
      else
          quantity = 1
      end
      return false if quantity < 1
    end
    $PokemonBag.pbDeleteItem(item, quantity - 1)
    scene&.pbRefresh

    # Apply the new EXP, accounting for the level cap
    expAmount = exp * quantity
    expAmount = (expAmount * 1.15).floor if pbHasItem?(:SWEETTOOTH)
    pkmn.exp += expAmount
    pkmn.exp = [pkmn.exp, maxxp].min
    display_exp = pkmn.exp - current_exp
    stored_exp = expAmount - display_exp
    new_level = pkmn.level
    if new_level == level_cap
        pbSceneDefaultDisplay(_INTL("{1} gained only {3} Exp. Points due to the level cap at level {2}.", pkmn.name, level_cap, separate_comma(display_exp)),scene)
        if pbHasItem?(:EXPEZDISPENSER) && stored_exp > 0
            pbSceneDefaultDisplay(_INTL("{1} Exp. Points were stored in the EXP-EZ Dispenser.", separate_comma(stored_exp)),scene)
            $PokemonGlobal.expJAR = 0 if $PokemonGlobal.expJAR.nil?
            $PokemonGlobal.expJAR += stored_exp
        end
    else
        if pbHasItem?(:SWEETTOOTH)
          pbSceneDefaultDisplay(_INTL("{1} gained a Sweet-Tooth boosted {2} Exp. Points!", pkmn.name, separate_comma(display_exp)),scene)
        else
          pbSceneDefaultDisplay(_INTL("{1} gained {2} Exp. Points!", pkmn.name, separate_comma(display_exp)),scene)
        end
    end
    scene&.pbRefresh

    # Leave if didn't level up
    return true if new_level == current_lvl

    # Show messages surrounding leveling up
    attackdiff = pkmn.attack
    defensediff = pkmn.defense
    speeddiff   = pkmn.speed
    spatkdiff   = pkmn.spatk
    spdefdiff   = pkmn.spdef
    totalhpdiff = pkmn.totalhp
    pkmn.calc_stats
    scene&.pbRefresh
    pbMessage(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    attackdiff  = pkmn.attack - attackdiff
    defensediff = pkmn.defense - defensediff
    speeddiff   = pkmn.speed - speeddiff
    spatkdiff   = pkmn.spatk - spatkdiff
    spdefdiff   = pkmn.spdef - spdefdiff
    totalhpdiff = pkmn.totalhp - totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
        totalhpdiff, attackdiff, defensediff, spatkdiff, spdefdiff, speeddiff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
        pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)

    (new_level - current_lvl).times do
        pkmn.changeHappiness("candylevelup")
    end
    
    # Learn new moves upon level up
    unless $PokemonSystem.prompt_level_moves == 1
        movelist = pkmn.getMoveList
        for i in movelist
            next if i[0] <= current_lvl
            break if i[0] > new_level
            pbLearnMove(pkmn, i[1], true)
        end
    end

    # Check for evolution
    while true
      newspecies = pkmn.check_evolution_on_level_up
      break unless newspecies
      evolutionSuccess = false
      pbFadeOutInWithMusic do
          evo = PokemonEvolutionScene.new
          evo.pbStartScreen(pkmn, newspecies)
          evolutionSuccess = true if evo.pbEvolution
          evo.pbEndScreen
          scene&.pbRefresh
      end
      break unless evolutionSuccess
    end

    return true
end

class PokemonParty_Scene
    def pbChooseNumber(helptext, maximum, initnum = 1)
        return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { pbUpdate }
    end
end

def pbSceneDefaultDisplay(message,scene = nil)
  if scene && scene.is_a?(PokemonPartyScreen)
    pbSceneDefaultDisplay(message)
  else
    pbMessage(message)
  end
end

def pbSceneDefaultConfirm(message,scene = nil)
  if scene && scene.is_a?(PokemonPartyScreen)
    return scene.pbConfirm(message)
  else
    return pbConfirmMessage(message)
  end
end