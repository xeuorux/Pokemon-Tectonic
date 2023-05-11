def canTeleport?(showMessage = false)
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if showMessage
    return false
  end
  if GameData::MapMetadata.try_get($game_map.map_id)&.teleport_blocked
    pbMessage(_INTL("You are prevented from teleporting due to an unknown force.")) if showMessage
    return false
  end
  return true
end

ItemHandlers::UseFromBag.add(:ABRAPORTER,proc { |item|
  next 0 unless canTeleport?(true)
  healing = $PokemonGlobal.healingSpot
  healing = GameData::Metadata.get.home if !healing   # Home
  unless healing
    pbMessage(_INTL("You have nowhere to teleport to!"))
    next 0
  end
  next 2
})

ItemHandlers::ConfirmUseInField.add(:ABRAPORTER,proc { |item|
  next false unless canTeleport?(true)
  healing = $PokemonGlobal.healingSpot
  healing = GameData::Metadata.get.home if !healing   # Home
  unless healing
    pbMessage(_INTL("You have nowhere to teleport to!"))
    next false
  end
  
  mapname = pbGetMapNameFromId(healing[0])
  next pbConfirmMessage(_INTL("Want to teleport from here and return to {1}?",mapname))
})

ItemHandlers::UseInField.add(:ABRAPORTER,proc { |item|
  healing = $PokemonGlobal.healingSpot
  healing = GameData::Metadata.get.home if !healing   # Home
  unless healing
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
  pbUseItemMessage(item)
  pbFadeOutIn {
    $game_temp.player_new_map_id    = healing[0]
    $game_temp.player_new_x         = healing[1]
    $game_temp.player_new_y         = healing[2]
    $game_temp.player_new_direction = 2
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  }
  pbEraseEscapePoint
  next 1
})