DOCK_LOCATIONS = {
    :CASABA_VILLA_DOCK => {
        :map_name => "Casaba Villa",
        :map_id => 136,
        :event_id => 39,
    },
    :FEEBAS_FIN => {
        :map_name => "Feebas' Fin",
        :map_id => 59,
        :event_id => 24,
    },
    :ELEIG_BOATING_DOCK => {
        :map_name => "Eleig Boating Dock",
        :map_id => 185,
        :event_id => 5,
        :unlock_switch => 301,
    },
    :SWEETROCK_DOCK => {
        :map_name => "Sweetrock Harbor",
        :map_id => 217,
        :event_id => 57,
        :unlock_switch => 302,
    },
    :TAPU_ISLAND => {
        :map_name => "Guardian Island",
        :map_id => 377,
        :event_id => 93,
        :unlock_switch => 303,
    },
    :EVENTIDE_ISLE => {
        :map_name =>  "Eventide Isle",
        :map_id => 413,
        :event_id => 13,
        :unlock_switch => 304,
    },
    :DRAGON_ISLAND => {
        :map_name => "Isle of Dragons",
        :map_id => 356,
        :event_id => 38,
        :unlock_switch => 86,
    },
    :TRI_ISLAND => {
        :map_name => "Tri Island",
        :map_id => 411,
        :event_id => 23,
        :unlock_switch => 97,
    },
    :MONUMENT_ISLAND => {
        :map_name => "Battle Monument",
        :map_id => 357,
        :event_id => 4,
        :unlock_switch => 99,
    },
    :SPIRIT_ATOLL => {
        :map_name => "Spirit Atoll",
        :map_id => 182,
        :event_id => 19,
        :unlock_switch => 151,
    },
}

def unlockBoatingSpot(dockID,ignoreAlreadyActive=false)
    dockInfo = DOCK_LOCATIONS[dockID]
    raise _INTL("Dock ID {1} has no unlock_switch defined. Cannot unlock!",dockID) if dockInfo[:unlock_switch].nil?
    return if getGlobalSwitch(dockInfo[:unlock_switch]) && !ignoreAlreadyActive
    mapName = _INTL(dockInfo[:map_name])
    text = _INTL("You can now travel to <imp>{1}</imp> on your boat!",mapName)
    pbMessage(_INTL("\\wm#{text}\\me[Slots win]\\wtnp[80]\1"))
    pbSetGlobalSwitch(dockInfo[:unlock_switch])
end

def unlockAllBoatingSpots
    DOCK_LOCATIONS.each do |dockID, dockInfo|
        next unless dockInfo[:unlock_switch]
        pbSetGlobalSwitch(dockInfo[:unlock_switch])
    end
    pbMessage(_INTL("All boating spots were unlocked."))
end

def boatTravel(currentDock = nil)
    commands = []
    validDockIDs = []

    DOCK_LOCATIONS.each do |dockID, dockInfo|
        next if dockID == currentDock
        next if dockInfo[:unlock_switch] && !getGlobalSwitch(dockInfo[:unlock_switch])
        commands.push(_INTL(dockInfo[:map_name]))
        validDockIDs.push(dockID)
    end

    if commands.empty?
        pbMessage(_INTL("There are no other places you can travel to."))
        return
    end

    commands.push(_INTL("Cancel"))

    choiceNumber = pbMessage(_INTL("Where would you like to go?"),commands,commands.length)

    return if choiceNumber == commands.length - 1 # Cancel

    chosenDockID = validDockIDs[choiceNumber]

    warpToBoatWaypoint(chosenDockID)
end

def boatWaypointUnlocked?(dockID)
    dockInfo = DOCK_LOCATIONS[dockID]
    if dockInfo[:unlock_switch]
        return getGlobalSwitch(dockInfo[:unlock_switch])
    else
        return true
    end
end

def warpToBoatWaypoint(dockID)
    dockInfo = DOCK_LOCATIONS[dockID]
    direction = dockInfo[:direction] || Up
    transferPlayerToEvent(dockInfo[:event_id],direction,dockInfo[:map_id])
end