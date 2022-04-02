class PokemonGlobalMetadata
	attr_accessor :respawnPoint
end

#===============================================================================
# Blacking out animation
#===============================================================================
def pbStartOver(gameover=false)
  if pbInBugContest?
    pbBugContestStartOver
    return
  end
  $Trainer.heal_party
  if !$PokemonGlobal.respawnPoint.nil? &&
		pbConfirmMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You feel the pull of the nearby Avatar Totem. Would you like it to revive you?"))
	pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]By the power of the Avatar Totem, your team is revived."))
    pbCancelVehicles
    pbRemoveDependenciesExceptFollower
	$game_temp.player_new_map_id    = $game_map.map_id
    $game_temp.player_new_x         = $PokemonGlobal.respawnPoint[0]
    $game_temp.player_new_y         = $PokemonGlobal.respawnPoint[1]
    $game_temp.player_new_direction = $PokemonGlobal.respawnPoint[2] || Down
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    $game_map.refresh
	$PokemonGlobal.respawnPoint = nil
  elsif $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId>=0
	mapName = pbGetMessage(MessageTypes::MapNames,$PokemonGlobal.pokecenterMapId)
    mapName.gsub!(/\\PN/,$Trainer.name) if $Trainer
    pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back to {1}, protecting your exhausted Pokémon from any further harm...",mapName))
    pbCancelVehicles
    pbRemoveDependenciesExceptFollower
	pbToggleFollowingPokemon("off",false)
    $game_switches[Settings::STARTING_OVER_SWITCH] = true
    $game_temp.player_new_map_id    = $PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x         = $PokemonGlobal.pokecenterX
    $game_temp.player_new_y         = $PokemonGlobal.pokecenterY
    $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    $game_map.refresh
  end
  pbEraseEscapePoint
end