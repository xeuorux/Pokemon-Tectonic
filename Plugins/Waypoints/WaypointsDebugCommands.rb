DebugMenuCommands.register("waypoints", {
    "parent"      => "main",
    "name"        => _INTL("Waypoints..."),
    "description" => _INTL("Edit information about waypoints."),
    "always_show" => true
  })
  
  DebugMenuCommands.register("unlockallwaypoints", {
    "parent"      => "waypoints",
    "name"        => _INTL("Unlock all waypoints."),
    "description" => _INTL("Unlock all waypoints."),
    "effect"      => proc { |sprites, viewport|
      mapData = Compiler::MapData.new
      for id in mapData.mapinfos.keys.sort
          map = mapData.getMap(id)
          next if !map || !mapData.mapinfos[id]
          mapName = mapData.mapinfos[id].name
          for key in map.events.keys
              event = map.events[key]
              next if !event || event.pages.length==0
              next if event.name != "AvatarTotem"
              event.pages.each do |page|
                  page.list.each do |eventCommand|
                      eventCommand.parameters.each do |parameter|
                          next unless parameter.is_a?(String)
                          match = parameter.match(/accessWaypoint\("([a-zA-Z0-9 ']+)"/)
                          if match
                              waypointName = match[1]
                              begin
                                  echoln("Unlocking: #{waypointName}")
                                  $waypoints_tracker.addWaypoint(waypointName,[id,event.id],false)
                              rescue => exception
                                  pbMessage(_INTL("Unable to unlock waypoint: #{waypointName}"))
                              end
                          else
                              echoln("No match: #{parameter}")
                          end
                      end
                  end
              end
          end
      end
      pbMessage(_INTL("All waypoints unlocked!"))
  
    }}
  )
  
  DebugMenuCommands.register("warptowaypoint", {
    "parent"      => "waypoints",
    "name"        => _INTL("Warp to waypoint."),
    "description" => _INTL("Choose a waypoint to warp to."),
    "effect"      => proc { |sprites, viewport|
      $waypoints_tracker.warpByWaypoints()
    }}
  )