class PokemonGlobalMetadata
    attr_accessor :respawnPoint
end

#===============================================================================
# Blacking out animation
#===============================================================================
def pbStartOver(_gameover = false)
    $Trainer.heal_party
    respawnedYet = false
    unless $PokemonGlobal.respawnPoint.nil?
        if pbConfirmMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You feel the pull of the nearby Avatar Totem. Would you like it to revive you?"))
            pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]By the power of the Avatar Totem, your team is revived."))
            pbCancelVehicles
            pbRemoveDependenciesExceptFollower
            $game_temp.player_new_map_id = $game_map.map_id

            actualPoint = nil
            if $PokemonGlobal.respawnPoint.is_a?(Integer)
                respawnEvent = pbMapInterpreter.get_event($PokemonGlobal.respawnPoint)
                actualPoint = [respawnEvent.x, respawnEvent.y + 1, Down]
            elsif $PokemonGlobal.respawnPoint.is_a?(Array)
                actualPoint = $PokemonGlobal.respawnPoint
            end
            if !actualPoint.nil?
                $game_temp.player_new_x = actualPoint[0]
                $game_temp.player_new_y         = actualPoint[1]
                $game_temp.player_new_direction = actualPoint[2] || Down
                $scene.transfer_player if $scene.is_a?(Scene_Map)
                $game_map.refresh
                pbMapInterpreter.get_self.clear_starting
                respawnedYet = true
            else
                pbMessage(_INTL("An error has occured. Unable to spawn player at Avatar Totem. Attempting backup spawn at healing spot."))
            end
        end
        $PokemonGlobal.respawnPoint = nil
    end
    if !respawnedYet && $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId >= 0
        $PokemonGlobal.respawnPoint = nil
        mapName = pbGetMessage(MessageTypes::MapNames, $PokemonGlobal.pokecenterMapId)
        mapName.gsub!(/\\PN/, $Trainer.name) if $Trainer
        pbMessage(_INTL(
                      "\\w[]\\wm\\c[8]\\l[3]You scurry back to {1}, protecting your exhausted Pokémon from any further harm...", mapName))
        pbCancelVehicles
        pbRemoveDependenciesExceptFollower
        pbToggleFollowingPokemon("off", false)
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
