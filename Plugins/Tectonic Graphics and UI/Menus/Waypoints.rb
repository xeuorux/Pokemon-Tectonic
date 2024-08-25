SaveData.register(:waypoints_tracker) do
	ensure_class :WaypointsTracker
	save_value { $waypoints_tracker }
	load_value { |value| $waypoints_tracker = value }
	new_game_value { WaypointsTracker.new }
end

class WaypointsTracker
	attr_reader :activeWayPoints
	attr_reader :legendsMaterialized
	
	def initialize()
		@activeWayPoints = {}
		@legendsMaterialized = []
	end

	def overwriteWaypoint(waypointName,event)
		if @activeWayPoints.has_key?(waypointName) || debugControl
			addWaypoint(waypointName,event)
		end
	end

	def setWaypoint(waypointName,mapID,wayPointInfo)
		@activeWayPoints[waypointName] = [mapID,wayPointInfo]
	end

	def deleteWaypoint(waypointName)
		@activeWayPoints.delete(waypointName)
	end

	def deleteAllWaypoints
		@activeWayPoints = {}
	end

	def mapPositionHash
		return generateMapPositionHash
	end

	def generateMapPositionHash
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

	def addWaypoint(waypointName,event)
		if event.is_a?(Array)
			@activeWayPoints[waypointName] = event
		else
			@activeWayPoints[waypointName] = [event.map_id,event.id]
		end
	end

	def summonPokemonFromWaypoint(avatarSpecies,waypointEvent)
		$PokemonGlobal.respawnPoint = waypointEvent.id
		speciesDisplayName = GameData::Species.get(avatarSpecies).name
		pbMessage(_INTL("By the power of the Primal Clay, a #{speciesDisplayName} was created!"))
		level = [50,getLevelCap].min
		if pbWildBattleCore(avatarSpecies, level) == 4 # Caught
			$PokemonGlobal.respawnPoint = nil
			return true
		end
		return false
	end
	
	def accessWaypoint(waypointName,waypointEvent,alternateMessage=false)
		@activeWayPoints = {} if @activeWayPoints.nil?
		
		if alternateMessage
			pbMessage(_INTL("#{waypointAccessMessageAlternative}"))
		else
			pbMessage(_INTL("#{waypointAccessMessage}"))
		end
		
		unless @activeWayPoints.has_key?(waypointName)
			pbMessage(_INTL("#{waypointRegisterMessage}"))
			addWaypoint(waypointName,waypointEvent)

            checkForWaypointsAchievement
		end
		
		if @activeWayPoints.length <= 1
			pbMessage(_INTL("#{waypointUnableMessage}"))
		else
			warpByWaypoints
		end
	end

	def warpByWaypoints(skipMessage = false)
		if @activeWayPoints.empty?
			pbMessage(_INTL("#{noWaypointsMessage}"))
			return
		end

		chosenLocation = nil
		chosenKey = nil
		if CHOOSE_BY_LIST
			commands = [_INTL("Cancel")]
			names = @activeWayPoints.sort_by {|key,value| value[0]}.map {|value| value[0]}
			names.delete_if{|name| name == waypointName}
			names.each do |name|
				commands.push(_INTL(name))
			end
			chosen = pbMessage(_INTL("#{waypointChooseMessage}"),commands,0)
			if chosen != 0
				chosenKey = names[chosen-1]
				chosenLocation = @activeWayPoints[chosenKey]
			end
		else
			pbMessage(_INTL("#{waypointChooseMessage}")) unless skipMessage
			chosenKey = nil
			pbFadeOutIn {
				scene = PokemonRegionMap_Scene.new(-1,false)
				screen = PokemonRegionMapScreen.new(scene)
				chosenKey = screen.pbStartWaypointScreen
			}
			chosenLocation = @activeWayPoints[chosenKey] if !chosenKey.nil?
		end

		unless chosenLocation.nil?
			mapID = chosenLocation[0]
			waypointInfo = chosenLocation[1]

			# Old system of storing the specific location
			if waypointInfo.is_a?(Array)
				$game_temp.player_new_map_id = mapID
				$game_temp.player_new_x = waypointInfo[0]
				$game_temp.player_new_y = waypointInfo[1]
				$game_temp.player_new_direction = 2
				$game_temp.transition_processing = true
				$game_temp.transition_name       = ""
			else
				event = getEventByID(waypointInfo,mapID)
				if event.nil? || !event.name.include?("AvatarTotem")
					pbMessage(_INTL("The chosen waypoint is somehow invalid."))
					pbMessage(_INTL("Removing access."))
					@activeWayPoints.delete(chosenKey)
					return
				end
				transferPlayerToEvent(waypointInfo,Up,mapID,[0,1])
			end
			$scene.transfer_player
			$game_map.autoplay
			$game_map.refresh
		end
	end

    def checkForWaypointsAchievement
        unlockedAll = true
        $waypoints_tracker.eachWaypoint do |event, mapID, waypointName|
            next if @activeWayPoints.has_key?(waypointName)
            unlockedAll = false
            break
        end
        return unless unlockedAll
        unlockAchievement(:UNLOCK_ALL_WAYPOINTS)
    end

    def eachWaypoint
        mapData = Compiler::MapData.new
        for map_id in mapData.mapinfos.keys.sort
            map = mapData.getMap(map_id)
            next if !map || !mapData.mapinfos[map_id]
            mapName = mapData.mapinfos[map_id].name
            for key in map.events.keys
                event = map.events[key]
                next if !event || event.pages.length == 0
                next if event.name != "AvatarTotem"
                event.pages.each do |page|
                    page.list.each do |eventCommand|
                        eventCommand.parameters.each do |parameter|
                            next unless parameter.is_a?(String)
                            match = parameter.match(/accessWaypoint\("([a-zA-Z0-9 ']+)"/)
                            if match
                                waypointName = match[1]
                                yield event, map_id, waypointName
                            else
                                echoln("No match: #{parameter}")
                            end
                        end
                    end
                end
            end
        end
    end
end

# Should only be called by the waypoint events themselves
def accessWaypoint(waypointName,avatarSpecies=nil)
	waypointEvent = get_self

	alternate = false

	if avatarSpecies
		alternate = true
		if pbHasItem?(:PRIMALCLAY)
			speciesName = GameData::Species.get(avatarSpecies).name

			pbMessage(_INTL("The totem pulses with the frequency of #{speciesName}."))
			if pbConfirmMessage(_INTL("Use the Primal Clay to summon #{speciesName}?"))
				# No longer allow summoning the pokemon once its been caught once
				if $waypoints_tracker.summonPokemonFromWaypoint(avatarSpecies,waypointEvent)
					pbMessage(_INTL("The totem returns to its original state."))
					pbSetSelfSwitch(waypointEvent.id,'A',false)
					return true
				end
				return false
			end
		end
	end
	
	$waypoints_tracker.accessWaypoint(waypointName,waypointEvent,alternate)
end

def setWaypointSummonable(waypointEventID)
	pbSetSelfSwitch(waypointEventID,'A',true)
end

def totemAuraSummon(species)
	unless pbHasItem?(:PRIMALCLAY)
		pbMessage(_INTL("You sense an powerful presence trying to manifest on this spot."))
		pbMessage(_INTL("However, you seem to lack a way to interact with it."))
		return
	end
	speciesName = GameData::Species.get(species).name
	pbMessage(_INTL("An Avatar Totem is partially manifested on this spot."))
	pbMessage(_INTL("It pulses with the frequency of #{speciesName}."))
	return unless pbConfirmMessage(_INTL("Use the Primal Clay to summon #{speciesName}?"))
	if $waypoints_tracker.summonPokemonFromWaypoint(species,get_character(0))
		pbMessage(_INTL("The summoning spot exhausted its energy."))
		setMySwitch('A')
		return true
	end
end

def waypointAccessMessage
    return _INTL("A mystical Avatar Totem. It pulses with ancient vital energy.")
end

def waypointAccessMessageAlternative
    return _INTL("A mystical Avatar Totem. It pulses with an unusual frequency.")
end

def waypointRegisterMessage
    return _INTL("You see it glow with extra intensity, and sense somehow that a connection has been created.")
end

def waypointUnableMessage
    return _INTL("However, it does not react further. Perhaps you must find more like it?")
end

def waypointChooseMessage
    return _INTL("You sense the connection to the other totems. Choose your warp location.")
end

def noWaypointsMessage
    return _INTL("There are no active totems to warp to.")
end

CHOOSE_BY_LIST = false