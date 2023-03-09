class PokemonGlobalMetadata
    attr_writer :dragonFlamesCount
    attr_writer :puzzlesCompleted

    def dragonFlamesCount
        @dragonFlamesCount = 0 if @dragonFlamesCount.nil?
        return @dragonFlamesCount
    end

    def puzzlesCompleted
        @puzzlesCompleted = [] if @puzzlesCompleted.nil?
        return @puzzlesCompleted
    end
end

class PokemonTemp
    def dragonFlames
        @dragonFlames = [] if @dragonFlames.nil?
        return @dragonFlames
    end
end

def takeDragonFlame(triggerEventID = -1)
    if candlePuzzlesCompleted?
        pbMessage(_INTL("The flame refuses to budge!"))
        return
    end
    if $PokemonGlobal.dragonFlamesCount > 0
        pbMessage(_INTL("You are already holding a dragon flame!"))
        return
    end
    if triggerEventID > 0
        if get_event(triggerEventID).at_coordinate?($game_player.x, $game_player.y)
            pbMessage(_INTL("The shadow will envelop you if you remove the flame now!"))
            return
        end
    end
    pbSEPlay("Anim/PRSFX- Spirit Shackle3", 100, 150)
    invertMySwitch('A')
    createDragonFlameGraphic
    $PokemonGlobal.dragonFlamesCount += 1
    fadeInDarknessBlock(triggerEventID) if triggerEventID > 0
end

def giveDragonFlame(triggerEventID = -1, otherCandles = [])
    if $PokemonGlobal.dragonFlamesCount == 0
        pbMessage(_INTL("It looks like it could hold a magical flame."))
        return
    end
    pbSEPlay("Anim/PRSFX- Spirit Shackle3", 100, 120)
    invertMySwitch('A')
    removeDragonFlameGraphic
    $PokemonGlobal.dragonFlamesCount -= 1
    if triggerEventID > 0
        otherFlamesMatch = true
        otherCandles.each do |candleEventID|
            otherFlamesMatch = false if pbGetSelfSwitch(candleEventID,'A') != getMySwitch('A')
        end
        fadeOutDarknessBlock(triggerEventID, false) if otherFlamesMatch

        if candlePuzzlesCompleted?($game_map.map_id)
            lockInCatacombs
        end
    end
end

def createDragonFlameGraphic(spriteset = nil)
    newGraphic = LightEffect_DragonFlame.new($game_player,Spriteset_Map.viewport,$game_map)
    spriteset = $scene.spriteset if spriteset.nil?
    spriteset.addUserSprite(newGraphic)
    $PokemonTemp.dragonFlames.push(newGraphic)
end

def removeDragonFlameGraphic
    removedFlame = $PokemonTemp.dragonFlames.pop
    removedFlame.dispose
end

def candlePuzzlesCompleted?(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    case mapID
    when 282
        return pbGetSelfSwitch(14,"A",mapID) && pbGetSelfSwitch(12,"A",mapID)
    when 361
        return pbGetSelfSwitch(25,"A",mapID)
    when 362
        return pbGetSelfSwitch(42,"A",mapID)
    end
    return false
end

# Remove all dragon flames from player on map exit
Events.onMapChanging += proc { |_sender,e|
    newmapID = e[0]

    if !$game_map || newmapID == $game_map.map_id
        echoln("Skipping this map for dragon flame reset check, since its the same map as before")
        next
    end

    # Remove all the player's dragon flames
    $PokemonTemp.dragonFlames.each do |flame|
        flame.dispose
    end
    $PokemonTemp.dragonFlames.clear
    $PokemonGlobal.dragonFlamesCount = 0

    # If one of the catacombs maps
    if [282,361,362].include?(newmapID)
        unless candlePuzzlesCompleted?(newmapID)
            resetCatacombs(newmapID)
        else
            echoln("Not resetting this catacombs map #{newmapID}, its puzzle was completed")
        end
    end
}

def resetCatacombs(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    map = $MapFactory.getMapNoAdd(mapID)
    count = 0
    map.events.each_value do |event|
        eventName = event.name.downcase
        if eventName.include?("darkblock") || eventName.include?("dragoncandle")
            pbSetSelfSwitch(event.id,"A",false,mapID)
            count += 1
        end
    end
    echoln("Reset map #{mapID}'s #{count} dragon flame puzzle events")
end

def disableCatacombs(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    map = $MapFactory.getMapNoAdd(mapID)
    count = 0
    map.events.each_value do |event|
        eventName = event.name.downcase
        if eventName.include?("darkblock") || eventName.include?("dragoncandlelit")
            pbSetSelfSwitch(event.id,"A",true,mapID)
            count += 1
        elsif eventName.include?("dragoncandleunlit")
            pbSetSelfSwitch(event.id,"A",false,mapID)
            count += 1
        end
    end
    echoln("Disabled map #{mapID}'s #{count} dragon flame puzzle events")
end

def lockInCatacombs
    pbWait(20)
    pbSEPlay("Anim/PRSFX- Hypnosis", 120, 80)
    $game_screen.start_shake(5, 5, 2 * Graphics.frame_rate)
    pbWait(2 * Graphics.frame_rate)
    pbSEPlay("Anim/PRSFX- DiamondStorm6", 150, 80)
    disableCatacombs
    pbWait(20)
end

def hasDragonFlame?
    return $PokemonGlobal.dragonFlamesCount > 0
end