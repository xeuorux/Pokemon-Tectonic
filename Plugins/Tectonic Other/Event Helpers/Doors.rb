def slidingDoorTransfer(map_id, x, y, dir = nil)
    slidingDoor
    blackFadeOutIn {
        block.call if block_given?
        $game_player.transparent = false
        teleportPlayer(map_id,x,y,true,dir)
    }
end

def swingingDoorTransfer(map_id, x, y, dir = nil, &block)
    swingingDoor
    blackFadeOutIn {
        block.call if block_given?
        $game_player.transparent = false
        teleportPlayer(map_id,x,y,true,dir)
    }
end

def openDoorTransfer(map_id, x, y, dir = nil, &block)
    pbSEPlay('Door exit')
    playerEntersDoorMoveRoute
    blackFadeOutIn {
        block.call if block_given?
        $game_player.transparent = false
        teleportPlayer(map_id,x,y,true,dir)
    }
end

def ajarDoorTransfer(map_id, x, y, dir = nil, &block)
    ajarDoor
    blackFadeOutIn {
        block.call if block_given?
        $game_player.transparent = false
        teleportPlayer(map_id,x,y,true,dir)
    }
end

def avatarChamberDoor(itemID, map_id, x, y, dir = nil, &block)
    if pbHasItem?(itemID)
        stoneDoorTransfer(map_id, x, y) {
            block.call if block_given?
        }
    else
        pbMessage(_INTL("The door resists your attempts to open it with a mystic force."))
        if pbHasItem?(:TAROTAMULET)
            pbWait(20)
            pbMessage(_INTL("...oh?"))
            pbWait(20)
            pbMessage(_INTL("\\i[TAROTAMULET]The Tarot Amulet begins vibrating inside of your bag."))
            pbMessage(_INTL("Not a moment later, it stops vibrating, just as suddenly as it started."))
            pbMessage(_INTL("How strange."))
        end
    end
end

def stoneDoorTransfer(map_id, x, y, dir = nil, &block)
    stoneDoor
    blackFadeOutIn {
        block.call if block_given?
        $game_player.transparent = false
        pbCaveEntrance
        teleportPlayer(map_id,x,y,true,dir)
    }
end

def slidingDoor(doorEvent: nil)
    doorMoveRoute('Door enter sliding',doorEvent: doorEvent)
end

def swingingDoor(doorEvent: nil)
    doorMoveRoute('Door enter',doorEvent: doorEvent)
end

def ajarDoor(doorEvent: nil)
    ajarDoorMoveRoute('Door enter',doorEvent: doorEvent)
end

def stoneDoor(doorEvent: nil)
    doorMoveRoute('Anim/PRSFX- Splintered Stormshards1',100,70,doorEvent: doorEvent)
end

def doorMoveRoute(soundEffectName, volume = nil, pitch = nil, doorEvent: nil)
    pbSEPlay(soundEffectName, volume, pitch) if soundEffectName
    doorEvent = get_self if doorEvent.nil?
    doorEvent = get_character(doorEvent) if doorEvent.is_a?(Integer)
    pbMoveRoute(doorEvent,  [
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait,2,
    ])
    pbWait(16)
    playerEntersDoorMoveRoute
    pbMoveRoute(doorEvent,  [
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

def ajarDoorMoveRoute(soundEffectName, doorEvent: nil)
    pbSEPlay(soundEffectName) if soundEffectName
    doorEvent = get_self if doorEvent.nil?
    doorEvent = get_character(doorEvent) if doorEvent.is_a?(Integer)
    pbMoveRoute(doorEvent,  [
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait,2,
    ])
    pbWait(6)
    playerEntersDoorMoveRoute
    pbMoveRoute(doorEvent,  [
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnRight,
    ])
    pbWait(6)
end

def playerEntersDoorMoveRoute
    pbMoveRoute(get_player, [
        PBMoveRoute::ThroughOn,
        PBMoveRoute::Forward,
        PBMoveRoute::ThroughOff,
    ])
    pbWait(12)
    $game_player.transparent = true
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
            next unless ["Lab door", "Research Center door", "Poké Center door", "Poké Mart door", "Mart door", "door"].include?(event.name)
            begin
                pagesMaintained = []
                event.pages.each do |page|
                    # just dispose of the tsOff? page
                    next if page.condition.switch1_id == 22

                    # Main door page
                    if !page.list.empty? && page.list[0].code == 209
                        mainPage = page.clone
                        pagesMaintained.push(mainPage)
                        changed = true

                        raise _INTL("Map #{mapName} (#{id}), event #{event.id}: Page has more or less commands than expected: #{mainPage.list.length}") unless mainPage.list.length == 31

                        transferParameters = mainPage.list[28].parameters
                        new_map_id    = transferParameters[1]
                        new_x         = transferParameters[2]
                        new_y         = transferParameters[3]
                        new_direction = transferParameters[4]

                        slidingDoor = page.list[0].parameters[1].list[0].parameters[0].name == 'Door enter sliding'

                        echoln("Map #{mapName} (#{id}), event #{event.id} params: #{new_map_id},#{new_x},#{new_y},#{new_direction}, #{slidingDoor}")

                        mainPage.list = []
                        if slidingDoor
                            push_script(mainPage.list,"slidingDoorTransfer(#{new_map_id},#{new_x},#{new_y})")
                        else
                            push_script(mainPage.list,"swingingDoorTransfer(#{new_map_id},#{new_x},#{new_y})")
                        end
                        push_end(mainPage.list)

                        event.name = "door to #{mapData.mapinfos[new_map_id].name}"
                    else
                        pagesMaintained.push(page)
                    end
                end
                
                event.pages = pagesMaintained
                
                customDoor = event.pages.length != 1
                if customDoor
                    echoln "CUSTOM: Map #{mapName} (#{id}), event #{event.id}\r\n"
                else
                    echoln "modified: Map #{mapName} (#{id}), event #{event.id}\r\n"
                end
            rescue Exception
                p $!.message, $!.backtrace
            end
        end
        mapData.saveMap(id) if changed
    end
end