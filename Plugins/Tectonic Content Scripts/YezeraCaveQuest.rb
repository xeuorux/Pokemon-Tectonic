def registerYezera(id = nil)
    stowFollowerIfActive
    pbToggleFollowingPokemon("off", false)
    $PokemonTemp.dependentEvents.removeEventByName("FollowerPkmn")
    pbRegisterPartner(:POKEMONTRAINER_Yezera, "Yezera", 2)
    pbAddDependency2(id || @event_id, "Yezera", 3)
end

def showThinkingOverFollower(followerName = "Yezera")
    event = pbGetDependency(followerName)
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal, event.x, event.y)
end

def teleportYezera
    get_character(1).moveto($game_player.x - 1, $game_player.y)
end

def helenaAskedForPackage?
    return pbGetSelfSwitch(37,'A',78) # Helena off to the side in LuxTech Main
end