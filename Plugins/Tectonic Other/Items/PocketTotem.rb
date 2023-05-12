ItemHandlers::UseFromBag.add(:POCKETTOTEM,proc { |item|
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next 0
  end
  if !GameData::MapMetadata.exists?($game_map.map_id)
    next 0
  end
  if GameData::MapMetadata.get($game_map.map_id).teleport_blocked
	  pbMessage(_INTL("You are prevented from teleporting due to an unknown force."))
    next 0
  end
  next 2
})

ItemHandlers::ConfirmUseInField.add(:POCKETTOTEM,proc { |item|
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next false
  end
  if !GameData::MapMetadata.exists?($game_map.map_id)
    next false
  end
  if GameData::MapMetadata.get($game_map.map_id).teleport_blocked
	  pbMessage(_INTL("You are prevented from teleporting due to an unknown force."))
    next false
  end
  next true
})

ItemHandlers::UseInField.add(:POCKETTOTEM,proc { |item|
  $waypoints_tracker.warpByWaypoints(true)
  next 1
})