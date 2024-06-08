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

def openDoorTransfer(map_id, x, y, &block)
    playerEntersDoorMoveRoute
    blackFadeOutIn {
        block.call if block_given?
        $game_player.transparent = false
        teleportPlayer(map_id,x,y,true)
    }
end

def ajarDoorTransfer(map_id, x, y, &block)
    ajarDoorMoveRoute
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
    doorMoveRoute('Door enter')
end

def doorMoveRoute(soundEffectName)
    pbSEPlay(soundEffectName) if soundEffectName
    pbMoveRoute(get_self,  [
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

def ajarDoorMoveRoute(soundEffectName)
    pbSEPlay(soundEffectName) if soundEffectName
    pbMoveRoute(get_self,  [
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait,2,
    ])
    pbWait(6)
    playerEntersDoorMoveRoute
    pbMoveRoute(get_self,  [
        PBMoveRoute::Wait,2,
        PBMoveRoute::TurnRight,
    ])
    pbWait(6)
end

def playerEntersDoorMoveRoute
    pbMoveRoute(get_player, [
        PBMoveRoute::ThroughOn,
        PBMoveRoute::Up,
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