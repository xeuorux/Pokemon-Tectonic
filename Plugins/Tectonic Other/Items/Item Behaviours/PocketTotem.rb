ItemHandlers::UseFromBag.add(:POCKETTOTEM,proc { |item|
  next 2 if canTeleport?(true)
  next 0
})

ItemHandlers::ConfirmUseInField.add(:POCKETTOTEM,proc { |item|
  next canTeleport?(true)
})

ItemHandlers::UseInField.add(:POCKETTOTEM,proc { |item|
  $waypoints_tracker.warpByWaypoints(true)
  next 1
})