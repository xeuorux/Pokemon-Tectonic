SaveData.register(:waypoints_tracker) do
	ensure_class :WaypointsTracker
	save_value { $waypoints_tracker }
	load_value { |value| $waypoints_tracker = value }
	new_game_value { WaypointsTracker.new }
end

class WaypointsTracker
	attr_reader :activeWayPoints
	
	def initialize()
		@activeWayPoints = {}
	end

	def overwriteWaypoint(waypointName,mapID,wayPointLoc)
		if @activeWayPoints.has_key?(waypointName)
			@activeWayPoints[waypointName] = [mapID,wayPointLoc]
		end
	end
	
	def accessWaypoint(waypointName,event)
		@activeWayPoints = {} if @activeWayPoints.nil?
		
		pbMessage(_INTL("#{WAYPOINT_ACCESS_MESSAGE}"))
		if !@activeWayPoints.has_key?(waypointName)
			pbMessage(_INTL("#{WAYPOINT_REGISTER_MESSAGE}"))
			wayPointLoc = [event.event.x,event.event.y+1]
			@activeWayPoints[waypointName] = [$game_map.map_id,wayPointLoc]
		end
		
		if @activeWayPoints.length <= 1
			pbMessage(_INTL("#{WAYPOINT_UNABLE_MESSAGE}"))
		else
			commands = [_INTL("Cancel")]
			names = @activeWayPoints.sort_by {|key,value| value[0]}.map {|value| value[0]}
			names.delete_if{|name| name == waypointName}
			names.each do |name|
				commands.push(_INTL(name))
			end
			chosen = pbMessage(_INTL("#{WAYPOINT_CHOOSE_MESSAGE}"),commands,0)
			if chosen != 0
				chosenLocationName = names[chosen-1]
				chosenLocation = @activeWayPoints[chosenLocationName]
				$game_temp.player_new_map_id = chosenLocation[0]
				$game_temp.player_new_x = chosenLocation[1][0]
				$game_temp.player_new_y = chosenLocation[1][1]
				$game_temp.player_new_direction = 2
				$game_temp.transition_processing = true
				$game_temp.transition_name       = ""
				$scene.transfer_player
				$game_map.autoplay
				$game_map.refresh
			end
		end
	end
end