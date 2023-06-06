def setBattleRule(*args)
  r = nil
  for arg in args
    if r
      $PokemonTemp.recordBattleRule(r,arg)
      r = nil
    else
      case arg.downcase
      when "terrain", "weather", "environment", "environ", "backdrop",
           "battleback", "base", "outcome", "outcomevar", "turnstosurvive"
        r = arg
        next
      end
      $PokemonTemp.recordBattleRule(arg)
    end
  end
  raise _INTL("Argument {1} expected a variable after it but didn't have one.",r) if r
end

# Sets up various battle parameters and applies special rules.
def pbPrepareBattle(battle)
  battleRules = $PokemonTemp.battleRules
  # The size of the battle, i.e. how many Pokémon on each side (default: "single")
  battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
  # Whether the game won't black out even if the player loses (default: false)
  battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
  # Whether the player can choose to run from the battle (default: true)
  battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
  # Whether wild Pokémon always try to run from battle (default: nil)
  battle.rules["alwaysflee"] = battleRules["roamerFlees"]
  # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
  battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
  # Whether the player gains/loses money at the end of the battle (default: true)
  battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
  # Whether the player is able to switch when an opponent's Pokémon faints
  battle.switchStyle = false
  # How long the player can merely survive to draw the battle
  battle.turnsToSurvive = battleRules["turnsToSurvive"] if !battleRules["turnsToSurvive"].nil?
  # Whether battle animations are shown
  battle.showAnims = $PokemonSystem.battlescene != 2
  battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
  # Terrain
  battle.defaultTerrain = battleRules["defaultTerrain"] if !battleRules["defaultTerrain"].nil?
  # Weather
  if !battleRules["defaultWeather"].nil?
    battle.defaultWeather = battleRules["defaultWeather"]
  elsif $game_screen.weather_in_battle
    case GameData::Weather.get($game_screen.weather_type).category
    when :Rain
      battle.defaultWeather = :Rain
    when :Hail
      battle.defaultWeather = :Hail
    when :Sandstorm
      battle.defaultWeather = :Sandstorm
    when :Sun
      battle.defaultWeather = :Sun
    when :Eclipse
      battle.defaultWeather = :Eclipse
    when :Moonglow
      battle.defaultWeather = :Moonglow
    when :Windy
      battle.defaultWeather = :StrongWinds
    end
  else
    battle.defaultWeather = :None
  end
  # Environment
  if battleRules["environment"].nil?
    battle.environment = pbGetEnvironment
  else
    battle.environment = battleRules["environment"]
  end
  # Backdrop graphic filename
  if !battleRules["backdrop"].nil?
    backdrop = battleRules["backdrop"]
  elsif $PokemonGlobal.nextBattleBack
    backdrop = $PokemonGlobal.nextBattleBack
  #elsif $PokemonGlobal.surfing
  #  backdrop = "water"   # This applies wherever you are, including in caves
  elsif GameData::MapMetadata.exists?($game_map.map_id)
    back = GameData::MapMetadata.get($game_map.map_id).battle_background
    backdrop = back if back && back != ""
  end
  backdrop = "indoor1" if !backdrop
  battle.backdrop = backdrop
  # Choose a name for bases depending on environment
  if battleRules["base"].nil?
    environment_data = GameData::Environment.try_get(battle.environment)
    base = environment_data.battle_base if environment_data
  else
    base = battleRules["base"]
  end
  battle.backdropBase = base if base
  # Time of day
  if GameData::MapMetadata.exists?($game_map.map_id) &&
     GameData::MapMetadata.get($game_map.map_id).battle_environment == :Cave
    battle.time = 2   # This makes Dusk Balls work properly in caves
  elsif Settings::TIME_SHADING
    timeNow = pbGetTimeNow
    if PBDayNight.isNight?(timeNow);      battle.time = 2
    elsif PBDayNight.isEvening?(timeNow); battle.time = 1
    else;                                 battle.time = 0
    end
  end
  # Ambush
  battle.playerAmbushing = true if battleRules["playerambush"]
  battle.foeAmbushing = true if battleRules["foeambush"]
  # Auto testing
  battle.autoTesting = battleRules["autotesting"]
end

#===============================================================================
# Start a trainer battle
#===============================================================================
def pbTrainerBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  randomOrder = $PokemonTemp.battleRules["randomOrder"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count == 0 || debugControl
    if $DEBUG
      if pbConfirmMessageSerious(_INTL("Perfect battle?"))
        $game_switches[94] = true
        pbMessage(_INTL("SKIPPING BATTLE PERFECT..."))
      else
        $game_switches[94] = false
        pbMessage(_INTL("SKIPPING BATTLE..."))
      end
      pbMessage(_INTL("AFTER WINNING...")) if $Trainer.able_pokemon_count > 0
    end
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
  if battle.autoTesting
    decision = battle.pbStartBattle
  else
    pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers),(battle.singleBattle?) ? 1 : 3,foeTrainers) {
      pbSceneStandby {
        decision = battle.pbStartBattle
      }
      pbAfterBattle(decision,canLose)
    }
  end
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
  $game_switches[77] = decision == 6 # Mark if the battle was a time-out victory
  # Return true if the player won the battle, and false if any other result
  return (decision == 1 || decision == 6)
end

def pbDoubleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
  trainerID2, trainerName2, trainerPartyID2=0, endSpeech2=nil,
  canLose=false, outcomeVar=1)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbTrainerBattleCore(
  [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
  [trainerID2,trainerName2,trainerPartyID2,endSpeech2]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision == 1 || decision == 6)
end

def pbTripleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
    trainerID2, trainerName2, trainerPartyID2, endSpeech2,
    trainerID3, trainerName3, trainerPartyID3=0, endSpeech3=nil,
    canLose=false, outcomeVar=1)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule("triple")
  # Perform the battle
  decision = pbTrainerBattleCore(
  [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
  [trainerID2,trainerName2,trainerPartyID2,endSpeech2],
  [trainerID3,trainerName3,trainerPartyID3,endSpeech3]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision == 1 || decision == 6)
end

def pbTrainerBattleRandom(trainerID, trainerName, partyID=0)
  pbTrainerBattle(trainerID, trainerName, nil, false, partyID, false, 1, true)
end

# Vestigial
def pbTrainerNotScared(event, trainerID, trainerName, trainerPartyID=0)
	return true
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
	  when "randomorder";           then rules["randomOrder"]    = true
    when "turnstosurvive";        then rules["turnsToSurvive"] = var
    when "autotesting"            then rules["autotesting"]    = true
    when "playerambush"           then rules["playerambush"]   = true
    when "foeambush"              then rules["foeambush"]   = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.", rule)
    end
  end
end

#===============================================================================
# Start a trainer battle
#===============================================================================
def battleAutoTest(trainerID, trainerName)
  loop do
    setBattleRule("autotesting")
    side1Size = rand(3) + 1
    side2Size = rand(3) + 1
    sideSizeRuleDescriptor = "#{side1Size}v#{side2Size}"
    setBattleRule(sideSizeRuleDescriptor)
    $game_variables[LEVEL_CAP_VAR] = 70
    pbTrainerBattle(trainerID, trainerName)
    pbHealAll
  end
end

# A simpler variant which assumes that the cursed index is 1 higher than the base indexz
def cursedBattle(trainerType,trainerName,baseIndex = 0)
  baseIndex += 1 if $PokemonGlobal.tarot_amulet_active
  pbTrainerBattle(trainerType,trainerName,nil,false,baseIndex)
end

def pbTrainerBattleCursed(nonCursedInfoArray, cursedInfoArray)
	if $PokemonGlobal.tarot_amulet_active
		id = cursedInfoArray[2] || 0
		return pbTrainerBattle(cursedInfoArray[0], cursedInfoArray[1], nil, false, id)
	else
		id = nonCursedInfoArray[2] || 0
		return pbTrainerBattle(nonCursedInfoArray[0], nonCursedInfoArray[1], nil, false, id)
	end
end

def pbDoubleTrainerBattleCursed(nonCursedInfoArrayArray, cursedInfoArrayArray)
  arrayToPickFrom = $PokemonGlobal.tarot_amulet_active ? cursedInfoArrayArray : nonCursedInfoArrayArray
  firstTrainerArray = arrayToPickFrom[0]
  firstTrainerClass = firstTrainerArray[0]
  firstTrainerName = firstTrainerArray[1]
  firstTrainerId = firstTrainerArray[2] || 0
  secondTrainerArray = arrayToPickFrom[1]
  secondTrainerClass = secondTrainerArray[0]
  secondTrainerName = secondTrainerArray[1]
  secondTrainerId = secondTrainerArray[2] || 0
  return pbDoubleTrainerBattle(firstTrainerClass, firstTrainerName, firstTrainerId, nil, secondTrainerClass, secondTrainerName, secondTrainerId, nil)
end