#===============================================================================
# Global variables used by the overworld triggers.
#===============================================================================
class PokemonTemp
  attr_accessor :batterywarning
  attr_accessor :cueBGM
  attr_accessor :cueFrames
end

#===============================================================================
# Checks per step
#===============================================================================
# Party Pokémon gain happiness from walking
Events.onStepTaken += proc {
  $PokemonGlobal.happinessSteps = 0 if !$PokemonGlobal.happinessSteps
  $PokemonGlobal.happinessSteps += 1
  threshold = (20 * 6) / $Trainer.able_pokemon_count # The more pokemon, the more often gains happiness
  if $PokemonGlobal.happinessSteps >= threshold
    if $Trainer.able_pokemon_count > 0
      chosenPokemon = nil
      # If player has a follower pokemon, be more likely to choose them
      if rand(3) == 0 && $PokemonSystem.followers == 0
        chosenPokemon = $Trainer.first_able_pokemon
      else
        chosenPokemon = $Trainer.able_party.sample
      end
      chosenPokemon.changeHappiness("walking")
    end
    $PokemonGlobal.happinessSteps = 0
  end
}

def pbOnStepTaken(eventTriggered)
  if $game_player.move_route_forcing || pbMapInterpreterRunning?
    Events.onStepTakenFieldMovement.trigger(nil,$game_player)
    return
  end
  $PokemonGlobal.stepcount = 0 if !$PokemonGlobal.stepcount
  $PokemonGlobal.stepcount += 1
  $PokemonGlobal.stepcount &= 0x7FFFFFFF
  repel_active = ($PokemonGlobal.repel > 0)
  Events.onStepTaken.trigger(nil)
#  Events.onStepTakenFieldMovement.trigger(nil,$game_player)
  handled = [nil]
  Events.onStepTakenTransferPossible.trigger(nil,handled)
  return if handled[0]
  pbBattleOnStepTaken(repel_active) if !eventTriggered && !$game_temp.in_menu
  $PokemonTemp.encounterTriggered = false   # This info isn't needed here
end

def pbBattleOnStepTaken(repel_active)
  return if $Trainer.able_pokemon_count == 0
  return if !$PokemonEncounters.encounter_possible_here?
  encounter_type = $PokemonEncounters.encounter_type
  return if !encounter_type
  return if !$PokemonEncounters.encounter_triggered?(encounter_type, repel_active)
  $PokemonTemp.encounterType = encounter_type
  encounter = $PokemonEncounters.choose_wild_pokemon(encounter_type)
  encounter = EncounterModifier.trigger(encounter)
  if $PokemonEncounters.allow_encounter?(encounter, repel_active)
    if $PokemonEncounters.have_double_wild_battle?
      encounter2 = $PokemonEncounters.choose_wild_pokemon(encounter_type)
      encounter2 = EncounterModifier.trigger(encounter2)
      pbDoubleWildBattle(encounter[0], encounter[1], encounter2[0], encounter2[1])
    else
      pbWildBattle(encounter[0], encounter[1])
    end
    $PokemonTemp.encounterType = nil
    $PokemonTemp.encounterTriggered = true
  end
  $PokemonTemp.forceSingleBattle = false
  EncounterModifier.triggerEncounterEnd
end

# Set up various data related to the new map
Events.onMapChange += proc { |_sender, e|
  old_map_ID = e[0]   # previous map ID, is 0 if no map ID
  new_map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if new_map_metadata && new_map_metadata.teleport_destination
    $PokemonGlobal.healingSpot = new_map_metadata.teleport_destination
  end
  $PokemonMap.clear if $PokemonMap
  $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  $PokemonGlobal.visitedMaps[$game_map.map_id] = true
}

Events.onMapSceneChange += proc { |_sender, e|
  scene      = e[0]
  mapChanged = e[1]
  next if !scene || !scene.spriteset
  # Update map trail
  if $game_map
    $PokemonGlobal.mapTrail = [] if !$PokemonGlobal.mapTrail
    if $PokemonGlobal.mapTrail[0] != $game_map.map_id
      $PokemonGlobal.mapTrail.pop if $PokemonGlobal.mapTrail.length >= 4
    end
    $PokemonGlobal.mapTrail = [$game_map.map_id] + $PokemonGlobal.mapTrail
  end
  # Display darkness circle on dark maps
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if map_metadata && map_metadata.dark_map
    $PokemonTemp.darknessSprite = DarknessSprite.new
    scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
    if $PokemonGlobal.flashUsed
      $PokemonTemp.darknessSprite.radius = $PokemonTemp.darknessSprite.radiusMax
    end
  else
    $PokemonGlobal.flashUsed = false
    $PokemonTemp.darknessSprite.dispose if $PokemonTemp.darknessSprite
    $PokemonTemp.darknessSprite = nil
  end
  # Show location signpost
  if mapChanged && map_metadata && map_metadata.announce_location
    nosignpost = false
    if $PokemonGlobal.mapTrail[1]
      for i in 0...Settings::NO_SIGNPOSTS.length / 2
        nosignpost = true if Settings::NO_SIGNPOSTS[2 * i] == $PokemonGlobal.mapTrail[1] &&
                             Settings::NO_SIGNPOSTS[2 * i + 1] == $game_map.map_id
        nosignpost = true if Settings::NO_SIGNPOSTS[2 * i + 1] == $PokemonGlobal.mapTrail[1] &&
                             Settings::NO_SIGNPOSTS[2 * i] == $game_map.map_id
        break if nosignpost
      end
      mapinfos = pbLoadMapInfos
      oldmapname = mapinfos[$PokemonGlobal.mapTrail[1]].name
      nosignpost = true if $game_map.name == oldmapname
    end
    scene.spriteset.addUserSprite(LocationWindow.new($game_map.name)) if !nosignpost
  end
  # Force cycling/walking
  if map_metadata && map_metadata.always_bicycle
    pbMountBike
  elsif !pbCanUseBike?($game_map.map_id)
    pbDismountBike
  end
}