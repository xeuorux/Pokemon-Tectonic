SaveData.register_conversion(:waypoints_data_modify_170) do
  game_version '1.7.0'
  display_title 'Fixing certain waypoint locations in pre-1.7.0 saves.'
  to_all do |save_data|
     if save_data.has_key?(:waypoints_tracker)
      tracker = save_data[:waypoints_tracker]
      tracker.overwriteWaypoint("Casaba Villa Chamber",[42,[18,16]])
      tracker.overwriteWaypoint("Clearwater Cave",[124,[22,28]])
      tracker.overwriteWaypoint("Volcanic Cave",[125,[24,13]])
      tracker.overwriteWaypoint("Six Spire Cave",[10,[29,38]])
     end
  end
end