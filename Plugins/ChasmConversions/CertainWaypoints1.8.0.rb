SaveData.register_conversion(:waypoints_data_modify_180) do
  game_version '1.8.0'
  display_title 'Converting all waypoint locations in pre-1.8.0 saves to use the event id information.'
  to_all do |save_data|
     if save_data.has_key?(:waypoints_tracker)
      tracker = save_data[:waypoints_tracker]
      # Secret avatar chambers
      tracker.overwriteWaypoint("Casaba Villa Chamber",42,3)
      tracker.overwriteWaypoint("Mainland Dock Chamber",24,3)
      tracker.overwriteWaypoint("Chasm HQ Chamber",84,3)
      tracker.overwriteWaypoint("Velenz Chamber",106,2)
      tracker.overwriteWaypoint("Eleig Crossing Chamber",176,4)
      tracker.overwriteWaypoint("Prizca East Chamber",199,3)
      tracker.overwriteWaypoint("Sweetrock Harbor Chamber",291,3)

      # Beast caves
      tracker.overwriteWaypoint("Clearwater Cave",124,3)
      tracker.overwriteWaypoint("Volcanic Cave",125,4)
      tracker.overwriteWaypoint("Six Spire Cave",10,2)

      # Other
      tracker.overwriteWaypoint("Catacombs Entryway",189,17)
      tracker.overwriteWaypoint("Ancient Meteorite",135,19)
      tracker.overwriteWaypoint("Boiling Cave",196,6)
      tracker.overwriteWaypoint("County Park Secret",5,3)
      tracker.overwriteWaypoint("Under the Peaks",272,1)
     end
  end
end