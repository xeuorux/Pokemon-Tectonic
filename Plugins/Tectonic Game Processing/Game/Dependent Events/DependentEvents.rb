def pbRemoveDependencies
    $PokemonTemp.dependentEvents.removeAllEvents
    begin
        pbDeregisterPartner
    rescue StandardError
        nil
    end
end

def pbAddDependency(event)
    $PokemonTemp.dependentEvents.addEvent(event)
end

def pbRemoveDependency(event)
    $PokemonTemp.dependentEvents.removeEvent(event)
end

def pbAddDependency2(eventID, eventName, commonEvent)
    $PokemonTemp.dependentEvents.addEvent($game_map.events[eventID], eventName, commonEvent)
end

# Gets the Game_Character object associated with a dependent event.
def pbGetDependency(eventName)
    return $PokemonTemp.dependentEvents.getEventByName(eventName)
end

def pbRemoveDependency2(eventName)
    $PokemonTemp.dependentEvents.removeEventByName(eventName)
end

class PokemonGlobalMetadata
    attr_writer :dependentEvents

    def dependentEvents
        @dependentEvents ||= []
        return @dependentEvents
    end
end

def pbTestPass(follower, x, y, _direction = nil)
    return $MapFactory.isPassableStrict?(follower.map.map_id, x, y, follower)
end

# Same map only
def moveThrough(follower, direction)
    oldThrough = follower.through
    follower.through = true
    case direction
    when 2 then follower.move_down
    when 4 then follower.move_left
    when 6 then follower.move_right
    when 8 then follower.move_up
    end
    follower.through = oldThrough
end

# Same map only
def moveFancy(follower, direction)
    deltaX = (if direction == 6
                  1
              else
                  (direction == 4 ? -1 : 0)
              end)
    deltaY = (if direction == 2
                  1
              else
                  (direction == 8 ? -1 : 0)
              end)
    newX = follower.x + deltaX
    newY = follower.y + deltaY
    # Move if new position is the player's, or the new position is passable,
    # or the current position is not passable
    if ($game_player.x == newX && $game_player.y == newY) ||
       pbTestPass(follower, newX, newY, 0) ||
       !pbTestPass(follower, follower.x, follower.y, 0)
        oldThrough = follower.through
        follower.through = true
        case direction
        when 2 then follower.move_down
        when 4 then follower.move_left
        when 6 then follower.move_right
        when 8 then follower.move_up
        end
        follower.through = oldThrough
    end
end

# Same map only
def jumpFancy(follower, direction, leader)
    deltaX = (if direction == 6
                  2
              else
                  (direction == 4 ? -2 : 0)
              end)
    deltaY = (if direction == 2
                  2
              else
                  (direction == 8 ? -2 : 0)
              end)
    halfDeltaX = (if direction == 6
                      1
                  else
                      (direction == 4 ? -1 : 0)
                  end)
    halfDeltaY = (if direction == 2
                      1
                  else
                      (direction == 8 ? -1 : 0)
                  end)
    middle = pbTestPass(follower, follower.x + halfDeltaX, follower.y + halfDeltaY, 0)
    ending = pbTestPass(follower, follower.x + deltaX, follower.y + deltaY, 0)
    if middle
        moveFancy(follower, direction)
        moveFancy(follower, direction)
    elsif ending
        if pbTestPass(follower, follower.x, follower.y, 0)
            if leader.jumping?
                follower.jump_speed_real = leader.jump_speed_real * Graphics.frame_rate / 40.0
            else
                follower.jump_speed_real = leader.move_speed_real * Graphics.frame_rate / 20.0
            end
            follower.jump(deltaX, deltaY)
        else
            moveThrough(follower, direction)
            moveThrough(follower, direction)
        end
    end
end

def pbFancyMoveTo(follower, newX, newY, leader)
    if follower.x - newX == -1 && follower.y == newY
        moveFancy(follower, 6)
    elsif follower.x - newX == 1 && follower.y == newY
        moveFancy(follower, 4)
    elsif follower.y - newY == -1 && follower.x == newX
        moveFancy(follower, 2)
    elsif follower.y - newY == 1 && follower.x == newX
        moveFancy(follower, 8)
    elsif follower.x - newX == -2 && follower.y == newY
        jumpFancy(follower, 6, leader)
    elsif follower.x - newX == 2 && follower.y == newY
        jumpFancy(follower, 4, leader)
    elsif follower.y - newY == -2 && follower.x == newX
        jumpFancy(follower, 2, leader)
    elsif follower.y - newY == 2 && follower.x == newX
        jumpFancy(follower, 8, leader)
    elsif follower.x != newX || follower.y != newY
        follower.moveto(newX, newY)
    end
end

class DependentEvents
    attr_reader :lastUpdate

    def createEvent(eventData)
        rpgEvent = RPG::Event.new(eventData[3], eventData[4])
        rpgEvent.id = eventData[1]
        if eventData[9]
            # Must setup common event list here and now
            commonEvent = Game_CommonEvent.new(eventData[9])
            rpgEvent.pages[0].list = commonEvent.list
        end
        newEvent = Game_Event.new(eventData[0], rpgEvent, $MapFactory.getMap(eventData[2]))
        newEvent.character_name = eventData[6]
        newEvent.character_hue  = eventData[7]
        case eventData[5] # direction
        when 2 then newEvent.turn_down
        when 4 then newEvent.turn_left
        when 6 then newEvent.turn_right
        when 8 then newEvent.turn_up
        end
        newEvent.dependent_event = true
        return newEvent
    end

    def initialize
        # Original map, Event ID, Current map, X, Y, Direction
        events = $PokemonGlobal.dependentEvents
        @realEvents = []
        @lastUpdate = -1
        for event in events
            @realEvents.push(createEvent(event))
        end
    end

    def pbEnsureEvent(event, newMapID)
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            # Check original map ID and original event ID
            next unless events[i][0] == event.map_id && events[i][1] == event.id
            # Change current map ID
            events[i][2] = newMapID
            newEvent = createEvent(events[i])
            # Replace event
            @realEvents[i] = newEvent
            @lastUpdate += 1
            return i
        end
        return -1
    end

    def pbFollowEventAcrossMaps(leader, follower, instant = false, leaderIsTrueLeader = true)
        areConnectedOrSame = $MapFactory.areConnected?(leader.map.map_id, follower.map.map_id)
        # Get the rear facing tile of leader
        facingDirection = 10 - leader.direction
        if !leaderIsTrueLeader && areConnectedOrSame
            relativePos = $MapFactory.getThisAndOtherEventRelativePos(leader, follower)
            # Assumes leader and follower are both 1x1 tile in size
            if relativePos[1] == 0 && relativePos[0] == 2 # 2 spaces to the right of leader
                facingDirection = 6
            elsif relativePos[1] == 0 && relativePos[0] == -2 # 2 spaces to the left of leader
                facingDirection = 4
            elsif relativePos[1] == -2 && relativePos[0] == 0 # 2 spaces above leader
                facingDirection = 2
            elsif relativePos[1] == 2 && relativePos[0] == 0 # 2 spaces below leader
                facingDirection = 8
            end
        end
        facings = [facingDirection] # Get facing from behind
        unless leaderIsTrueLeader
            facings.push(leader.direction) # Get forward facing
        end

        mapTile = nil

        if areConnectedOrSame
            mapTile = findMapTilesForConnectedMaps(follower, leader, facings)
        else
            tile = $MapFactory.getFacingTile(facings[0], leader)
            # Assumes leader is 1x1 tile in size
            passable = tile && $MapFactory.isPassable?(tile[0], tile[1], tile[2], follower)
            mapTile = passable ? mapTile : nil
        end

        moveFollower(follower, leader, mapTile, instant)
    end

    def findMapTilesForConnectedMaps(follower, leader, facings)
        mapTile = nil
        bestRelativePos = -1
        oldthrough = follower.through
        follower.through = false
        for i in 0...facings.length
            facing = facings[i]
            tile = $MapFactory.getFacingTile(facing, leader)
            # Check for staircase shenanigans
            if GameData::TerrainTag.exists?(:StairLeft)
                currentTag = $game_player.pbTerrainTag
                if tile[1] > $game_player.x
                    tile[2] -= 1 if currentTag == :StairLeft
                elsif tile[1] < $game_player.x
                    tile[2] += 1 if currentTag == :StairLeft
                end
                if tile[1] > $game_player.x
                    tile[2] += 1 if currentTag == :StairRight
                elsif tile[1] < $game_player.x
                    tile[2] -= 1 if currentTag == :StairRight
                end
            end
            assumedTerrainTag = $MapFactory.getTerrainTag(tile[0], tile[1], tile[2])

            # Assumes leader is 1x1 tile in size
            passable = false
            if tile
                passable = true if $MapFactory.isPassable?(tile[0], tile[1], tile[2], follower)
                passable = true if assumedTerrainTag.ice
                passable = true if defined?(assumedTerrainTag.rock_climbable) && assumedTerrainTag.rock_climbable
            end
            passable = true if $PokemonGlobal.bridge > 0

            # If the tile isn't passable and the tile is a ledge,
            # get tile from further behind
            if i == 0 && !passable && tile && assumedTerrainTag.ledge
                tile = $MapFactory.getFacingTileFromPos(tile[0], tile[1], tile[2], facing)
                passable = tile && $MapFactory.isPassable?(tile[0], tile[1], tile[2], follower)
            end

            next unless passable
            relativePos = $MapFactory.getThisAndOtherPosRelativePos(follower, tile[0], tile[1], tile[2])
            # Assumes follower is 1x1 tile in size
            distance = Math.sqrt(relativePos[0] * relativePos[0] + relativePos[1] * relativePos[1])
            if bestRelativePos > distance || bestRelativePos == -1
                bestRelativePos = distance
                mapTile = tile
            end
            break if i == 0 && distance <= 1 # Prefer behind if tile can move up to 1 space
        end
        follower.through = oldthrough
        return mapTile
    end

    def moveFollower(follower, leader, mapTile, instant)
        if mapTile && follower.map.map_id == mapTile[0]
            moveFollowerToSameMap(follower, leader, mapTile, instant)
        else
            # Fall back on making current position into leader's position
            mapTile ||= [leader.map.map_id, leader.x, leader.y]
            follower = moveFollowerToDifferentMap(follower, leader, mapTile) if follower.map.map_id != mapTile[0]
            moveFollowerToNearbySpot(follower, leader, mapTile)
        end
    end

    def moveFollowerToSameMap(follower, leader, mapTile, instant)
        # Follower is on same map
        newX = mapTile[1]
        newY = mapTile[2]
        if defined?(leader.on_stair?) && leader.on_stair?
            newX = leader.x + -1 * xOffsetFromDir(leader.direction)
            if leader.on_middle_of_stair?
                newY = leader.y + -1 * yOffsetFromDir(leader.direction)
            elsif follower.on_middle_of_stair?
                newY = follower.stair_start_y - follower.stair_y_position
            else
                newY = leader.y + -1 * yOffsetFromDir(leader.direction)
            end
        end
        deltaX = -1 * xOffsetFromDir(leader.direction)
        deltaY = -1 * yOffsetFromDir(leader.direction)
        posX = newX + deltaX
        posY = newY + deltaY

        follower.move_speed = leader.move_speed # sync movespeed
        distance = maxDistanceBetween(follower.x, follower.y, newX, newY)

        if distance > 0
            if instant
                follower.moveto(newX, newY)
            elsif distance <= 2
                pbFancyMoveTo(follower, newX, newY, leader)
            else
                pbFancyMoveTo(follower, posX, posY, leader)
                pbFancyMoveTo(follower, newX, newY, leader)
            end
        end
    end

    def maxDistanceBetween(x1, y1, x2, y2)
        xDistance = (x1 - x2).abs
        yDistance = (y1 - y2).abs
        return [xDistance, yDistance].max
    end

    def moveFollowerToNearbySpot(follower, leader, _mapTile)
        # Follower is on same map as leader
        newPosX = leader.x
        newPosY = leader.y

        # Try to find a nearby spot to place the pokemon
        # Try behind the player, then to their left, then their right, then finally ahead
        nearbySpotOffsets = nil
        case leader.direction
        when Up
            nearbySpotOffsets = [[0, 1], [-1, 0], [1, 0], [0, -1]]
        when Left
            nearbySpotOffsets = [[1, 0], [0, 1], [0, -1], [0, -1]]
        when Down
            nearbySpotOffsets = [[0, -1], [1, 0], [-1, 0], [0, 1]]
        when Right
            nearbySpotOffsets = [[-1, 0], [0, -1], [0, 1], [0, 1]]
        end

        nearbySpotOffsets.each do |spot|
            passable = $MapFactory.isPassable?(leader.map.map_id, leader.x + spot[0], leader.y + spot[1], follower)
            next unless passable
            newPosX += spot[0]
            newPosY += spot[1]
            break
        end
        pbFancyMoveTo(follower, newPosX, newPosY, leader)
        pbTurnTowardEvent(follower, leader) unless follower.move_route_forcing
    end

    def moveFollowerToDifferentMap(follower, leader, mapTile)
        # Follower will move to different map
        events = $PokemonGlobal.dependentEvents
        eventIndex = pbEnsureEvent(follower, mapTile[0])
        if eventIndex >= 0
            follower = @realEvents[eventIndex]
            newEventData = events[eventIndex]
            follower.moveto(mapTile[1], mapTile[2])
            pbFancyMoveTo(follower, mapTile[1], mapTile[2], leader)
            newEventData[3] = mapTile[1]
            newEventData[4] = mapTile[2]
            # if mapTile[0] == leader.map.map_id
            #   pbTurnTowardEvent(follower,leader) if !follower.move_route_forcing
            # end
        end
        return follower
    end

    # Fix follower not being in the same spot upon save
    def pbMapChangeMoveDependentEvents
        return
    end

    def debugEcho
        eachEvent do |e, d|
            echoln d
            echoln [e.map_id, e.map.map_id, e.id]
        end
    end

    def pbMoveDependentEvents
        events = $PokemonGlobal.dependentEvents
        updateDependentEvents
        leader = $game_player
        for i in 0...events.length
            event = @realEvents[i]
            pbFollowEventAcrossMaps(leader, event, false, i == 0)
            # Update X and Y for this event
            events[i][3] = event.x
            events[i][4] = event.y
            events[i][5] = event.direction
            # Set leader to this event
            leader = event
        end
    end

    def pbTurnDependentEvents
        events = $PokemonGlobal.dependentEvents
        updateDependentEvents
        leader = $game_player
        for i in 0...events.length
            event = @realEvents[i]
            pbTurnTowardEvent(event, leader)
            # Update direction for this event
            events[i][5] = event.direction
            # Set leader to this event
            leader = event
        end
    end

    def eachEvent
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            yield @realEvents[i], events[i]
        end
    end

    def updateDependentEvents
        events = $PokemonGlobal.dependentEvents
        return if events.length == 0
        for i in 0...events.length
            event = @realEvents[i]
            next unless @realEvents[i]
            event.transparent = $game_player.transparent
            if event.jumping? || event.moving? ||
               !($game_player.jumping? || $game_player.moving?)
                event.update
            elsif !event.starting
                event.set_starting
                event.update
                event.clear_starting
            end
            events[i][3] = event.x
            events[i][4] = event.y
            events[i][5] = event.direction
        end
        # Check event triggers
        if Input.trigger?(Input::USE) && !$game_temp.in_menu && !$game_temp.in_battle &&
           !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
           !pbMapInterpreterRunning?
            # Get position of tile facing the player
            facingTile = $MapFactory.getFacingTile
            # Assumes player is 1x1 tile in size
            eachEvent do |e, d|
                next unless d[9]
                if e.at_coordinate?($game_player.x, $game_player.y)
                    # On same position
                    if !e.jumping? && (!e.respond_to?("over_trigger") || e.over_trigger?) && (e.list.size > 1)
                        # Start event
                        $game_map.refresh if $game_map.need_refresh
                        e.lock
                        pbMapInterpreter.setup(e.list, e.id, e.map.map_id)
                    end
                elsif facingTile && e.map.map_id == facingTile[0] &&
                      e.at_coordinate?(facingTile[1], facingTile[2])
                    # On facing tile
                    if !e.jumping? && (!e.respond_to?("over_trigger") || !e.over_trigger?) && (e.list.size > 1)
                        # Start event
                        $game_map.refresh if $game_map.need_refresh
                        e.lock
                        pbMapInterpreter.setup(e.list, e.id, e.map.map_id)
                    end
                end
            end
        end
    end

    def removeEvent(event)
        events = $PokemonGlobal.dependentEvents
        mapid = $game_map.map_id
        for i in 0...events.length
            if events[i][2] == mapid && # Refer to current map
               events[i][0] == event.map_id && # Event's map ID is original ID
               events[i][1] == event.id
                events[i] = nil
                @realEvents[i] = nil
                @lastUpdate += 1
            end
            events.compact!
            @realEvents.compact!
        end
    end

    def getEventByName(name)
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            return @realEvents[i] if events[i] && events[i][8] == name # Arbitrary name given to dependent event
        end
        return nil
    end

    def removeAllEvents
        events = $PokemonGlobal.dependentEvents
        events.clear
        @realEvents.clear
        @lastUpdate += 1
    end

    def removeEventByName(name)
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            if events[i] && events[i][8] == name # Arbitrary name given to dependent event
                events[i] = nil
                @realEvents[i] = nil
                @lastUpdate += 1
            end
            events.compact!
            @realEvents.compact!
        end
    end

    def addEvent(event, eventName = nil, commonEvent = nil)
        return unless event
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            if events[i] && events[i][0] == $game_map.map_id && events[i][1] == event.id
                # Already exists
                return
            end
        end
        # Original map ID, original event ID, current map ID,
        # event X, event Y, event direction,
        # event's filename,
        # event's hue, event's name, common event ID
        eventData = [
            $game_map.map_id, event.id, $game_map.map_id,
            event.x, event.y, event.direction,
            event.character_name.clone,
            event.character_hue, eventName, commonEvent,
        ]
        newEvent = createEvent(eventData)
        events.push(eventData)
        @realEvents.push(newEvent)
        @lastUpdate += 1
        event.erase
    end

    attr_accessor :realEvents

    #-------------------------------------------------------------------------------
    # Raises The Current Pokemon's Happiness level +1 per each time
    # 5000 frames (2 min 5s) have passed
    # follower_hold_item is the variable which decides when you are able
    # to talk to your pokemon to recieve an item. It becomes true after 15000 frames
    # (6mins and 15s) have passed
    #-------------------------------------------------------------------------------
    def add_following_time
        $PokemonGlobal.time_taken += 1
        $PokemonGlobal.follower_hold_item = true if $PokemonGlobal.time_taken > 15_000
    end

    # Dependent Event method to remove all events except following pokemon
    def remove_except_follower
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            if events[i] && !events[i][8][/FollowerPkmn/i]
                events[i] = nil
                @realEvents[i] = nil
                @lastUpdate += 1
            end
            events.compact!
            @realEvents.compact!
        end
    end

    # Dependent Event method to look for Following Pokemon Event
    def follower_dependent_event
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            return @realEvents[i] if events[i] && events[i][8][/FollowerPkmn/i]
        end
        return nil
    end

    # Checks if the follower needs a refresh
    def can_refresh?
        return false unless pbGetFollowerDependentEvent
        return false unless $PokemonGlobal.follower_toggled
        first_pkmn = $Trainer.first_able_pokemon
        return false unless first_pkmn
        refresh = Events.FollowerRefresh.trigger(first_pkmn)
        refresh = true if refresh == -1
        return refresh
    end

    # Change the sprite to the correct species and data
    def change_sprite(params)
        events = $PokemonGlobal.dependentEvents
        for k in 0...events.length
            if events[k] && events[k][8][/FollowerPkmn/i]
                fname = GameData::Species.ow_sprite_filename(params[0], params[1], params[2], params[3], params[4]).gsub!(
                    "Graphics/Characters/", "")
                events[k][6] = fname
                @realEvents[k].character_name = fname
                @realEvents[k].floats = floatingPokemon?(params[5])
            end
            return
        end
    end

    # Adds step animation for followers and update their speed
    def start_stepping
        follower_move_route([PBMoveRoute::StepAnimeOn])
    end

    # Stop the Stepping animation
    def stop_stepping
        follower_move_route([PBMoveRoute::StepAnimeOff])
    end

    # Removes the sprite of the follower. DOESN'T DISABLE IT
    def remove_sprite
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            next unless events[i]
            next unless events[i][8][/FollowerPkmn/i]
            events[i][6] = sprintf("")
            @realEvents[i].character_name = ""
            $PokemonGlobal.time_taken = 0
        end
    end

    # Command to update follower/ make it reappear
    def refresh_sprite(anim = false)
        first_pkmn = $Trainer.first_able_pokemon
        return unless first_pkmn
        remove_sprite
        ret = can_refresh?
        if anim
            events = $PokemonGlobal.dependentEvents
            for i in 0...events.length
                next unless events[i]
                next unless events[i][8][/FollowerPkmn/i]
                if ret
                    anim = FollowerSettings::Animation_Come_Out
                else
                    anim = FollowerSettings::Animation_Come_In
                end
                $scene.spriteset.addUserAnimation(anim, @realEvents[i].x, @realEvents[i].y)
                pbWait(Graphics.frame_rate / 10)
            end
        end
        if ret
            change_sprite([first_pkmn.species, first_pkmn.form,
                           first_pkmn.gender, first_pkmn.shiny?,
                           false,first_pkmn])
        end
        if ret
            $PokemonTemp.dependentEvents.start_stepping
        else
            $PokemonTemp.dependentEvents.stop_stepping
        end
        return ret
    end

    # Command to update follower/ make it reappear
    def set_move_route(commands, waitComplete = true)
        events = $PokemonGlobal.dependentEvents
        for i in 0...events.length
            pbMoveRoute(@realEvents[i], commands, waitComplete) if events[i] && events[i][8][/FollowerPkmn/i]
        end
    end
end