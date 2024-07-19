DebugMenuCommands.register("unlockallwaypoints", {
    "parent"      => "waypoints",
    "name"        => _INTL("Unlock all waypoints."),
    "description" => _INTL("Unlock all waypoints."),
    "effect"      => proc { |_sprites, _viewport|
        $waypoints_tracker.eachWaypoint do |event, mapID, waypointName|
            begin
                echoln("Unlocking: #{waypointName}")
                $waypoints_tracker.addWaypoint(waypointName, [mapID, event.id])
            rescue StandardError => exception
                pbMessage(_INTL("Unable to unlock waypoint: #{waypointName}"))
            end
        end
        pbMessage(_INTL("All waypoints unlocked!"))
    },
}
)

DebugMenuCommands.register("warptowaypoint", {
  "parent"      => "waypoints",
  "name"        => _INTL("Warp to waypoint."),
  "description" => _INTL("Choose a waypoint to warp to."),
  "effect"      => proc { |_sprites, _viewport|
      $waypoints_tracker.warpByWaypoints
  },
}
)

DebugMenuCommands.register("wipeallwaypoints", {
  "parent"      => "waypoints",
  "name"        => _INTL("Wipe all waypoints."),
  "description" => _INTL("Unregister all waypoints."),
  "effect"      => proc { |_sprites, _viewport|
      $waypoints_tracker.deleteAllWaypoints
      pbMessage(_INTL("All waypoints deregistered."))
  },
}
)
