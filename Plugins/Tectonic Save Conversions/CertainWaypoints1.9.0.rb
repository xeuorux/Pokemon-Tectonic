SaveData.register_conversion(:waypoints_data_modify_180) do
  game_version '1.8.0'
  display_title 'Converting all waypoint locations in pre-1.8.0 saves to use the event id information.'
  to_all do |save_data|
     if save_data.has_key?(:waypoints_tracker)
      tracker = save_data[:waypoints_tracker]
      # Secret avatar chambers
      tracker.deleteWaypoint("County Park Secret")
     end
  end
end