def pbRespawnTrainers
  if !$game_variables[76].is_a?(Array)
    $game_variables[76] = []
    echo("Creating respawn table.\n")
    return
  end
  for i in 0...200
    $game_variables[76][i] = true
  end
end

Events.onMapChange += proc { |_sender,e|
  if !$game_variables[76].is_a?(Array)
    $game_variables[76] = []
    echo("Recreating respawn table.\n")
    next
  end
  oldid = e[0] # previous map ID, 0 if no map ID
  
  if oldid==0 || oldid==$game_map.map_id
    echo("Skipping this map because of some unknown error.\n")
    next
  end
    
  if !$game_variables[76][$game_map.map_id] && $game_variables[75].is_a?(Array) && !$game_variables[75].any?{|id| id == $game_map.map_id}
    echo("Skipping this map because its already been reset and it's not an always reset map.\n")
    next
  end
    
  $game_variables[76][$game_map.map_id] = false
  echo("Resetting events on this map\n")
  for event in $game_map.events.values
    if event.name.downcase.include?("trainer") or ($game_switches[78] && event.name.downcase.include?("berryplant"))
      $game_self_switches[[$game_map.map_id,event.id,"A"]] = false
    end
  end
}

def pbTrainerDropsItem()
  pbMessage("The fleeing trainer dropped an item!")
  items = [:RARECANDY] # [:POTION,:RARECANDY,:ETHER,:STATUSHEAL,:POKEBALL,:REPEL,:ESCAPEROPE,:PRETTYFEATHER,:POKEDOLL]
  chances =  [100] # [15,30,35,50,65,70,75,95,100]
  number = rand(100)
  echo("#{number}\n")
  itemGiven = :PRETTYFEATHER
  items.each_with_index do |item,index|
    echo("#{item},")
    if number < chances[index]
      itemGiven = item
      break
    end
  end
  echo("\n")
  pbReceiveItem(itemGiven)
end

#===============================================================================
# Standard methods that start a trainer battle of various sizes
#===============================================================================
# Used by most trainer events, which can be positioned in such a way that
# multiple trainer events spot the player at once. The extra code in this method
# deals with that case and can cause a double trainer battle instead.
def pbTrainerBattle(trainerID, trainerName, endSpeech=nil,
                    doubleBattle=false, trainerPartyID=0, canLose=false, outcomeVar=1, random=false)
  # If there is another NPC trainer who spotted the player at the same time, and
  # it is possible to have a double battle (the player has 2+ able Pokémon or
  # has a partner trainer), then record this first NPC trainer into
  # $PokemonTemp.waitingTrainer and end this method. That second NPC event will
  # then trigger and cause the battle to happen against this first trainer and
  # themselves.
  if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning? &&
     ($Trainer.able_pokemon_count > 1 ||
     ($Trainer.able_pokemon_count > 0 && $PokemonGlobal.partner))
    thisEvent = pbMapInterpreter.get_character(0)
    # Find all other triggered trainer events
    triggeredEvents = $game_player.pbTriggeredTrainerEvents([2],false)
    otherEvent = []
    for i in triggeredEvents
      next if i.id==thisEvent.id
      next if $game_self_switches[[$game_map.map_id,i.id,"A"]]
      otherEvent.push(i)
    end
    # Load the trainer's data, and call an event which might modify it
    trainer = pbLoadTrainer(trainerID,trainerName,trainerPartyID)
    pbMissingTrainer(trainerID,trainerName,trainerPartyID) if !trainer
    return false if !trainer
    Events.onTrainerPartyLoad.trigger(nil,trainer)
    # If there is exactly 1 other triggered trainer event, and this trainer has
    # 6 or fewer Pokémon, record this trainer for a double battle caused by the
    # other triggered trainer event
    if otherEvent.length == 1 && trainer.party.length <= Settings::MAX_PARTY_SIZE
      trainer.lose_text = endSpeech if endSpeech && !endSpeech.empty?
      $PokemonTemp.waitingTrainer = [trainer, thisEvent.id]
      return false
    end
  end
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule("double") if doubleBattle || $PokemonTemp.waitingTrainer
  setBattleRule("randomOrder") if random
  # Perform the battle
  if $PokemonTemp.waitingTrainer
    waitingTrainer = $PokemonTemp.waitingTrainer
    decision = pbTrainerBattleCore($PokemonTemp.waitingTrainer,
       [trainerID,trainerName,trainerPartyID,endSpeech]
    )
  else
    decision = pbTrainerBattleCore([trainerID,trainerName,trainerPartyID,endSpeech])
  end
  # Finish off the recorded waiting trainer, because they have now been battled
  if decision==1 && $PokemonTemp.waitingTrainer   # Win
    pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "A", true)
  end
  $PokemonTemp.waitingTrainer = nil
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end

def pbTrainerBattleRandom(trainerID, trainerName, partyID=0)
  pbTrainerBattle(trainerID, trainerName, nil, false, partyID, false, 1, true)
end

class PokemonTemp
  def recordBattleRule(rule,var=nil)
    rules = self.battleRules
    case rule.to_s.downcase
    when "single", "1v1", "1v2", "2v1", "1v3", "3v1",
         "double", "2v2", "2v3", "3v2", "triple", "3v3"
      rules["size"] = rule.to_s.downcase
    when "canlose"                then rules["canLose"]        = true
    when "cannotlose"             then rules["canLose"]        = false
    when "canrun"                 then rules["canRun"]         = true
    when "cannotrun"              then rules["canRun"]         = false
    when "roamerflees"            then rules["roamerFlees"]    = true
    when "noexp"                  then rules["expGain"]        = false
    when "nomoney"                then rules["moneyGain"]      = false
    when "switchstyle"            then rules["switchStyle"]    = true
    when "setstyle"               then rules["switchStyle"]    = false
    when "anims"                  then rules["battleAnims"]    = true
    when "noanims"                then rules["battleAnims"]    = false
    when "terrain"
      terrain_data = GameData::BattleTerrain.try_get(var)
      rules["defaultTerrain"] = (terrain_data) ? terrain_data.id : nil
    when "weather"
      weather_data = GameData::BattleWeather.try_get(var)
      rules["defaultWeather"] = (weather_data) ? weather_data.id : nil
    when "environment", "environ"
      environment_data = GameData::Environment.try_get(var)
      rules["environment"] = (environment_data) ? environment_data.id : nil
    when "backdrop", "battleback" then rules["backdrop"]       = var
    when "base"                   then rules["base"]           = var
    when "outcome", "outcomevar"  then rules["outcomeVar"]     = var
    when "nopartner"              then rules["noPartner"]      = true
	when "randomorder";            rules["randomOrder"]    = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.", rule)
    end
  end
end

#===============================================================================
# Start a trainer battle
#===============================================================================
def pbTrainerBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  randomOrder = $PokemonTemp.battleRules["randomOrder"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $Trainer.able_pokemon_count > 0
    pbSet(outcomeVar,($Trainer.able_pokemon_count == 0) ? 0 : 1)   # Treat it as undecided/a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    return ($Trainer.able_pokemon_count == 0) ? 0 : 1   # Treat it as undecided/a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate trainers and their parties based on the arguments given
  foeTrainers    = []
  foeItems       = []
  foeEndSpeeches = []
  foeParty       = []
  foePartyStarts = []
  for arg in args
    raise _INTL("Expected an array of trainer data, got {1}.",arg) if !arg.is_a?(Array)
    if arg.is_a?(NPCTrainer)
      foeTrainers.push(arg)
      foePartyStarts.push(foeParty.length)
	  if randomOrder
        arg.party = arg.party.shuffle
      end
      arg.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg.lose_text)
      foeItems.push(arg.items)
    else
      # [trainer type, trainer name, ID, speech (optional)]
      trainer = pbLoadTrainer(arg[0],arg[1],arg[2])
      pbMissingTrainer(arg[0],arg[1],arg[2]) if !trainer
      return 0 if !trainer
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      foeTrainers.push(trainer)
      foePartyStarts.push(foeParty.length)
	  if randomOrder
        trainer.party = trainer.party.shuffle
      end
      trainer.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg[3] || trainer.lose_text)
      foeItems.push(trainer.items)
    end
  end
  # Calculate who the player trainer(s) and their party are
  playerTrainers    = [$Trainer]
  playerParty       = $Trainer.party
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $PokemonTemp.battleRules["size"] &&
     !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
    room_for_partner = true
  end
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$PokemonTemp.battleRules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,foeTrainers)
  battle.party1starts = playerPartyStarts
  battle.party2starts = foePartyStarts
  battle.items        = foeItems
  battle.endSpeeches  = foeEndSpeeches
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # End the trainer intro music
  Audio.me_stop
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers),(battle.singleBattle?) ? 1 : 3,foeTrainers) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end

class PokeBattle_Battle
#=============================================================================
  # Start a battle
  #=============================================================================
  def pbStartBattle
    PBDebug.log("")
    PBDebug.log("******************************************")
    logMsg = "[Started battle] "
    if @sideSizes[0]==1 && @sideSizes[1]==1
      logMsg += "Single "
    elsif @sideSizes[0]==2 && @sideSizes[1]==2
      logMsg += "Double "
    elsif @sideSizes[0]==3 && @sideSizes[1]==3
      logMsg += "Triple "
    else
      logMsg += "#{@sideSizes[0]}v#{@sideSizes[1]} "
    end
    logMsg += "wild " if wildBattle?
    logMsg += "trainer " if trainerBattle?
    logMsg += "battle (#{@player.length} trainer(s) vs. "
    logMsg += "#{pbParty(1).length} wild Pokémon)" if wildBattle?
    logMsg += "#{@opponent.length} trainer(s))" if trainerBattle?
    PBDebug.log(logMsg)
	$game_switches[94] = false
    faintedBefore = $Trainer.able_pokemon_count # Record the number of fainted
    pbEnsureParticipants
    begin
      pbStartBattleCore
    rescue BattleAbortedException
      @decision = 0
      @scene.pbEndBattle(@decision)
    end
	$game_switches[94] = true if $Trainer.able_pokemon_count == faintedBefore # Record if the fight was perfected
    return @decision
  end
end


def pbTrainerNotScared(event, trainerID, trainerName, trainerPartyID=0)
	return true
end