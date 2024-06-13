ItemHandlers::UseFromBag.add(:RUSTEDCOMPASS,proc { |item|
    if getNearItemBalls.empty?
        pbMessage(_INTL("You shake the Rusted Compass, but it remains stagnant."))
        next 0
    end
    next 2
})

def getNearItemBalls
    nearItemBalls = []

    mapData = Compiler::MapData.new
    map = mapData.getMap($game_map.map_id)
    raise _INTL("Error loading data on the current map.") if !map || !mapData.mapinfos[$game_map.map_id]
    for key in map.events.keys
        event = map.events[key]
        next if !event || event.pages.length==0
        next if pbGetSelfSwitch(event.id,'A') # Must not already be collected
    
        itemID = nil
        hidden = false
        event.pages.each do |page|
            page.list.each do |eventCommand|
                eventCommand.parameters.each do |parameter|
                    next unless parameter.is_a?(String)
                    match = parameter.match(/pbItemBall\(:([0-9A-Za-z]+)[\),]/)
                    if match
                        itemID = match[1].to_sym
                        eventName = event.name.gsub(",","")
                        #echoln "Event \"#{eventName}\" (#{event.id}) is loot for item #{itemID}"
                    end
                    break if itemID
                end
                break if itemID
            end
            if itemID
                hidden = page.graphic.character_name.empty?
                break
            end
        end
        next unless itemID
        xDif = (event.x - $game_player.x).abs
        yDif = (event.y - $game_player.y).abs
        squareDistance = xDif ** 2 + yDif ** 2
        nearItemBalls.push([itemID,squareDistance,hidden])
    end

    nearItemBalls.sort_by! { |entry| entry[1] }

    return nearItemBalls
end

ItemHandlers::UseInField.add(:RUSTEDCOMPASS,proc { |item|
    nearItemBalls = getNearItemBalls
    next if nearItemBalls.empty?

    nearItemBalls.each do |itemBall|
        echoln(itemBall)
    end

    nearestBall = nearItemBalls[0]

    itemID = nearestBall[0]
    squareDistance = nearestBall[1]
    hidden = nearestBall[2]
    
    #echoln("Closest loot is a #{itemID} located #{squareDistance ** 0.5} distance away")

    if squareDistance > 2048
        pbMessage(_INTL("Loot is very far away!"))
    elsif squareDistance > 512
        pbMessage(_INTL("Loot is far away!"))
    elsif squareDistance > 128
        pbMessage(_INTL("Loot is at a medium distance!"))
    elsif squareDistance > 32
        pbMessage(_INTL("Loot is close by!"))
    elsif squareDistance > 8
        pbMessage(_INTL("Loot is very close by!"))
    else
        pbMessage(_INTL("Loot is EXTREMELY close! You're nearly on top of it!"))
    end
    next 1
})