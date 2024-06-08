def slidingDoorTransfer(map_id, x, y)
    slidingDoor
    blackFadeOutIn {
        block.call if block_given?
        $game_player.transparent = false
        teleportPlayer(map_id,x,y,true)
    }
end

def swingingDoorTransfer(map_id, x, y, &block)
    swingingDoor
    blackFadeOutIn {
        block.call if block_given?
        $game_player.transparent = false
        teleportPlayer(map_id,x,y,true)
    }
end

def slidingDoor
    doorMoveRoute('Door enter sliding')
end

def swingingDoor
    doorMoveRoute
end

def doorMoveRoute(soundEffectName = 'Door enter')
    pbMoveRoute(get_self,  [
        PBMoveRoute::PlaySE,
        soundEffectName,
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait,2,
    ])
    pbWait(16)
    pbMoveRoute(get_player, [
        PBMoveRoute::ThroughOn,
        PBMoveRoute::Up,
        PBMoveRoute::ThroughOff,
    ])
    pbWait(12)
    $game_player.transparent = true
    pbMoveRoute(get_self,  [
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait,2,
    ])
    pbWait(16)
end

def fixDoors
    mapData = Compiler::MapData.new
    for id in mapData.mapinfos.keys.sort
        map = mapData.getMap(id)
        next if !map || !mapData.mapinfos[id]
        mapName = mapData.mapinfos[id].name
        changed = false
        for key in map.events.keys
            event = map.events[key]
            next unless event.name == "Lab door" || event.name == "Poké Center door" || event.name == "door"
            echoln "Map #{mapName} (#{id}), event #{event.name} (#{event.id})\r\n"
        end
        mapData.saveMap(id) if changed
    end
end