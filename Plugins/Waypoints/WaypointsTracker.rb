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

	def overwriteWaypoint(waypointName,mapID,wayPointInfo)
		if @activeWayPoints.has_key?(waypointName)
			@activeWayPoints[waypointName] = [mapID,wayPointInfo]
		elsif $DEBUG && Input.press?(Input::CTRL)
			setWaypoint(waypointName,mapID,wayPointInfo)
		end
	end

	def setWaypoint(waypointName,mapID,wayPointInfo)
		@activeWayPoints[waypointName] = [mapID,wayPointInfo]
	end

	def deleteWaypoint(waypointName)
		@activeWayPoints.delete(waypointName)
	end

	def mapPositionHash
		return generateMapPositionHash
	end

	def generateMapPositionHash()
		mapPositionHash = {}
		activeWayPoints.each do |waypointName,waypointInfo|
			mapID = waypointInfo[0]
			displayedPosition = getDisplayedPositionOfGameMap(mapID)
			mapPositionHash[waypointName] = displayedPosition 
		end
		return mapPositionHash
	end
	
	def getWaypointAtMapPosition(x,y)
		mapPositionHash.each do |waypointName,displayedPosition|
			if displayedPosition[1] == x && displayedPosition[2] == y
				return waypointName
			end
		end
		return nil
	end
	
	def accessWaypoint(waypointName,event)
		@activeWayPoints = {} if @activeWayPoints.nil?
		
		pbMessage(_INTL("#{WAYPOINT_ACCESS_MESSAGE}"))
		if !@activeWayPoints.has_key?(waypointName)
			pbMessage(_INTL("#{WAYPOINT_REGISTER_MESSAGE}"))
			@activeWayPoints[waypointName] = [$game_map.map_id,event.id]
		end
		
		if @activeWayPoints.length <= 1
			pbMessage(_INTL("#{WAYPOINT_UNABLE_MESSAGE}"))
		else
			chosenLocation = nil
			if CHOOSE_BY_LIST
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
				end
			else
				pbMessage(_INTL("#{WAYPOINT_CHOOSE_MESSAGE}"))
				chosenTotem = nil
				pbFadeOutIn {
					scene = PokemonRegionMap_Scene.new(-1,false)
					screen = PokemonRegionMapScreen.new(scene)
					chosenTotem = screen.pbStartWaypointScreen
				}
				chosenLocation = @activeWayPoints[chosenTotem] if !chosenTotem.nil?
			end

			if !chosenLocation.nil?
				$game_temp.player_new_map_id = waypointMap = chosenLocation[0]
				waypointInfo = chosenLocation[1]
				if waypointInfo.is_a?(Array)
					$game_temp.player_new_x = waypointInfo[0]
					$game_temp.player_new_y = waypointInfo[1]
				else
					# TODO find location of event with that ID on the waypointMap
					mapData = Compiler::MapData.new
					map = mapData.getMap(waypointMap)
					event = map.events[waypointInfo]
					$game_temp.player_new_x = event.x
					$game_temp.player_new_y = event.y + 1
				end
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