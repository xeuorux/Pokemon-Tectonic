def pbNewBattleScene
  return PokeBattle_Scene.new
end

# Used to determine the environment in battle, and also the form of Burmy/
# Wormadam.
def pbGetEnvironment
  ret = :None
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  ret = map_metadata.battle_environment if map_metadata && map_metadata.battle_environment
  if $PokemonTemp.encounterType &&
     GameData::EncounterType.get($PokemonTemp.encounterType).type == :fishing
    terrainTag = $game_player.pbFacingTerrainTag
  else
    terrainTag = $game_player.terrain_tag
  end
  tile_environment = terrainTag.battle_environment
  if ret == :Forest && [:Grass, :TallGrass].include?(tile_environment)
    ret = :ForestGrass
  else
    ret = tile_environment if tile_environment
  end
  return ret
end

Events.onStartBattle += proc { |_sender|
  # Record current levels of Pokémon in party, to see if they gain a level
  # during battle and may need to evolve afterwards
  $PokemonTemp.evolutionLevels = []
  for i in 0...$Trainer.party.length
    $PokemonTemp.evolutionLevels[i] = $Trainer.party[i].level
  end
}

def pbCanDoubleBattle?
  return $PokemonGlobal.partner || $Trainer.able_pokemon_count >= 2
end

def pbCanTripleBattle?
  return true if $Trainer.able_pokemon_count >= 3
  return $PokemonGlobal.partner && $Trainer.able_pokemon_count >= 2
end

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
  # Weather
  if !battleRules["defaultWeather"].nil?
    battle.defaultWeather = battleRules["defaultWeather"]
  elsif $game_screen.weather_in_battle
    case GameData::Weather.get($game_screen.weather_type).category
    when :Rain
      battle.defaultWeather = :Rainstorm
    when :Hail
      battle.defaultWeather = :Hail
    when :Sandstorm
      battle.defaultWeather = :Sandstorm
    when :Sun
      battle.defaultWeather = :Sunshine
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
  # Lane battles
  battle.laneTargeting = battleRules["lanetargeting"]
  battle.doubleShift = battleRules["doubleshift"]
  battle.shiftEnabled = true if battleRules["doubleshift"]
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
    $Trainer.heal_party
    break if debugControl
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