PRESENT_TONE = Tone.new(0,0,0,0)
PAST_TONE = Tone.new(40,30,10,130)

def getTimeTone
    if $game_switches[78] # Time Traveling
        return PAST_TONE
    else
        return PRESENT_TONE
    end
end

def toggleTimeTravel
    $game_switches[78] = !$game_switches[78]
    modifyTimeLinkedEvents unless $game_switches[78] # If now in the present
end

def leaveTimeTravelIfNeeded
    return if timeTravelMap?
    echoln("Disabling time travel since this is not a time travel map") if $game_switches[78]
    $game_switches[78] = false
    $game_screen.start_tone_change(getTimeTone, 0)
end

def timeTravelToEvent(eventID)
    goingForwards = $game_switches[78]
    pbSEPlay("Anim/Sand",70,80)
    pbSEPlay("Anim/Sand",40,65)
    pbWait(10)
    if goingForwards
        pbSEPlay("Anim/PRSFX- Roar of Time2",20,200)
    else
        pbSEPlay("Anim/PRSFX- Roar of Time2",20,200)
    end
    $game_screen.start_tone_change(Tone.new(230,230,230,255), 20)
	pbWait(20)
    toggleTimeTravel
    transferPlayerToEvent(eventID)
    $game_screen.start_tone_change(getTimeTone, 20)
	pbWait(10)
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
        otherEventID = -1
        match = /timelinked\(([0-9]+)\)/.match(eventName)
        captureGroup1 = match.captures[0]
        begin
            otherEventID = captureGroup1.to_i
            otherEvent = map.events[otherEventID]

            # Match all self switches
            ['A','B','C','D'].each do |switchName|
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
        eroding = true if GameData::MapMetadata.get(mapID).weather[0] == :TimeSandstorm
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

# def disableCatacombs(mapID = -1)
#     mapID = $game_map.map_id if mapID == -1
#     map = $MapFactory.getMapNoAdd(mapID)
#     count = 0
#     map.events.each_value do |event|
#         eventName = event.name.downcase
#         if eventName.include?("darkblock") || eventName.include?("dragoncandlelit")
#             pbSetSelfSwitch(event.id,"A",true,mapID)
#             count += 1
#         elsif eventName.include?("dragoncandleunlit")
#             pbSetSelfSwitch(event.id,"A",false,mapID)
#             count += 1
#         end
#     end
#     echoln("Disabled map #{mapID}'s #{count} dragon flame puzzle events")
# end