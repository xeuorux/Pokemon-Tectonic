PRESENT_TONE = Tone.new(0,0,0,0)
PAST_TONE = Tone.new(40,30,10,130)
FUTURE_TONE = Tone.new(-9,18,18,9)

def getTimeTone
    if $game_switches[78] # Time Traveling
        return PAST_TONE
    else
        return PRESENT_TONE
    end
end

def inPast?
    return $game_switches[78]
end

def toggleTimeTravel
    $game_switches[78] = !$game_switches[78]
end

def processTimeTravel
    if timeTravelMap?
        modifyTimeLinkedEvents unless $game_switches[78] # If now in the present
    elsif $game_switches[78]
        echoln("Disabling time travel since this is not a time travel map")
        $game_switches[78] = false
        applyTimeTone
    end
end

def fakeTimeTravelToEvent(eventID, mapID = -1, toneID = -1)
    timeTravelTransition {
        transferPlayerToEvent(eventID,$game_player.direction,mapID)
        if toneID >= 0
            tone = [PAST_TONE,PRESENT_TONE,FUTURE_TONE][toneID]
            $game_screen.start_tone_change(tone, 20)
        else
            applyTimeTone(20)
        end
    }
end

def timeTravelToEvent(eventID)
    timeTravelTransition {
        bouldersTimeTravel($game_switches[78])
        toggleTimeTravel
        transferPlayerToEvent(eventID)
        applyTimeTone(20)
    }
end

def applyTimeTone(duration = 0)
    $game_screen.start_tone_change(getTimeTone, 0)
end

def timeTravelTransition
    pbSEPlay("Anim/Sand",70,80)
    pbSEPlay("Anim/Sand",40,65)
    pbWait(10)
    pbSEPlay("Anim/PRSFX- Roar of Time2",20,200)
    $game_screen.start_tone_change(Tone.new(230,230,230,255), 20)
	pbWait(20)
    yield if block_given?
	pbWait(10)
end

def bouldersTimeTravel(fromPast = false)
    boulders = []

    $game_map.events.each_value do |event|
        next unless event.name.downcase[/pushboulder/]
        boulders.push(event)
    end

    $game_map.events.each_value do |event|
        eventName = event.name.downcase
        next unless eventName[/timeteleporter/]
        if fromPast
            next unless eventName[/past/]
        else
            next unless eventName[/present/]
        end

        boulders.each do |boulder|
            next unless boulder.at_coordinate?(event.x, event.y)

            if boulder.name.downcase[/timelinked/]
                # If the boulder is moving from the past to the present, sever its time linking
                # Otherwise, re-enable its time-linking
                pbSetSelfSwitch(boulder.id,"D",fromPast)
            end

            otherEventID = parseTimeTeleporter(event)
            targetTimeTeleporter = $game_map.events[otherEventID]
            boulder.moveto(targetTimeTeleporter.x, targetTimeTeleporter.y)
        end
    end
end

def parseTimeTeleporter(event)
    list = event.list
    return nil unless list.is_a?(Array)
    list.each do |item|
        next unless item.code == 355 # Script
        item.parameters.each do |scriptLine|
            match = /timeTravelToEvent\(([0-9]+)\)/.match(scriptLine)
            next unless match
            return match.captures[0].to_i
        end
    end
    return nil
end

def matchPosition(eventToMove,eventToMatch)
    travelDistanceX = eventToMatch.x - eventToMatch.original_x
    travelDistanceY = eventToMatch.y - eventToMatch.original_y

    newX = eventToMove.original_x + travelDistanceX
    newY = eventToMove.original_y + travelDistanceY
    eventToMove.moveto(newX, newY)
end

def modifyTimeLinkedEvents
    map = $MapFactory.getMapNoAdd($game_map.map_id)
    eroding = mapErodes?
    map.events.each_value do |event|
        eventName = event.name.downcase
        next unless eventName.include?("timelinked")
        next if pbGetSelfSwitch(event.id,'D') # Timelinking disabled with D switch
        otherEventID = -1
        match = /timelinked\(([0-9]+)\)/.match(eventName)
        captureGroup1 = match.captures[0]
        begin
            otherEventID = captureGroup1.to_i
            otherEvent = map.events[otherEventID]

            next if pbGetSelfSwitch(otherEvent.id,'D') # Timelinking disabled with D switch

            # Match all self switches
            ['A','B','C'].each do |switchName|
                switchValue = pbGetSelfSwitch(event.id,switchName)
                pbSetSelfSwitch(otherEventID,switchName,switchValue)
            end

            matchPosition(otherEvent, event)

            # Erode events
            if eroding && otherEvent.name[/erodable/]
                pbSetSelfSwitch(otherEventID,'B',true)
            end
        rescue Error
            echoln("Unable to modify the state of events linked to event #{eventName} (#{event.id}) due to an unknown error")
        end
    end
    echoln("Modifying time linked events on this map")
end

def timeTravelMap?(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    map = $MapFactory.getMapNoAdd(mapID)
    map.events.each_value do |event|
        return true if event.name.downcase[/timeteleporter/]
    end
    return false
end

def mapErodes?(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    eroding = false
    begin
        weatherMetadata = GameData::MapMetadata.get(mapID).weather
        return false if !weatherMetadata
        eroding = true if weatherMetadata[0] == :TimeSandstorm
    rescue NoMethodError
        echoln("Map #{mapID} has no defined weather metadata, so assuming its not meant to be an eroding map.")
    end
    return eroding
end

def resetCanyon(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    map = $MapFactory.getMapNoAdd(mapID)
    eroding = mapErodes?(mapID)
    map.events.each_value do |event|
        eventName = event.name.downcase
        # If this is an eroding map, all erodables will be eroded in the starting present
        if eroding && eventName.include?("erodable")
            pbSetSelfSwitch(event.id,"B",true,mapID)
        end
        # All push boulders are moved back to their original positions, and are no longer down any holes
        if eventName.include?("pushboulder")
            event.moveto(event.original_x, event.original_y)
            pbSetSelfSwitch(event.id,"A",false,mapID)
        end
        # No boulder holes are filled
        if eventName.include?("boulderhole")
            pbSetSelfSwitch(event.id,"A",false,mapID)
        end
    end
end