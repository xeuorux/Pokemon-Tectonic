SaveData.register_conversion(:waypoints_data_add) do
  game_version '1.7.2'
  display_title 'Fixing WayPoints in pre 1.7.2 saves.'
  to_all do |save_data|
    if save_data.has_key?(:waypoints_tracker)
      tracker = save_data[:waypoints_tracker]
      tracker.overwriteWaypoint("Catacombs Entryway",189,[24,37])
      tracker.overwriteWaypoint("Prizca Property",236,[14,11])
     end
  end
end