# Map ID, TP Location Event ID, Shard Event ID
SPACE_TIME_SHARD_LOCATIONS = [
    [38,0,31], # Bluepoint Beach
    [56,0,76], # Novo Town
    [6,0,46], # LuxTech
    [430,0,47], # Amber Hills
    [55,0,39], # Lingering Delta
    [78,0,7], # LuxTech Main
    [301,0,44], # County Park
    [7,0,45], # Repora Forest
    [114,0,9], # Velenz Underground East
    [396,0,9], # Crater-Shelf Gatehouse
    [299,0,13], # Fin Center
    [124,0,10], # Clearwater Cave
    [37,0,30], # Svait
    [185,0,64], # Eleig Stretch
    [426,0,75], # Prizca Black Market
    [212,0,59], # Ruins Digsite
    [144,0,5], # Artist's House
    [155,0,42], # Prizca West
    [173,0,10], # Full Blast Records
    [422,0,3], # Leo's Elite Items
    [367,0,24], # Prizca Great Hall
    [186,0,68], # Frostflow Farms
    [187,0,110], # Prizca East
    [288,0,9], # Underground River
    [193,0,26], # Volcanic Shore
    [183,0,4], # Circuit Cave
    [313,0,4], # Wren's House
    [333,0,22], # Floral Maze
    [216,0,31], # Highland Lake
    [211,0,49], # Split Peaks
    [418,0,3], # M. Munna Den 3
    [264,0,6], # Sweetrock Harbor Mart
]

def collectedShard?(locationDetails)
    return pbGetSelfSwitch(locationDetails[2],'A',locationDetails[0])
end

def collectedAllShards?
    collectedAll = true
    SPACE_TIME_SHARD_LOCATIONS.each do |locationDetails|
        next if collectedShard?(locationDetails)
        collectedAll = false
        break
    end
    return collectedAll
end

def getRandomSpaceTimeShardLocation
    return nil if collectedAllShards?
    while true
        locationDetails = SPACE_TIME_SHARD_LOCATIONS.sample
        break unless collectedShard?(locationDetails)
    end
    return locationDetails
end

def receiveSpaceTimeShard
    pbReceiveItem(:SPACETIMESHARD)
    if collectedAllShards?
        # TODO Teleport to Dialga/Palkia dimmension
    else
        teleportToRandomSpaceTimeShard
    end
end

def teleportToRandomSpaceTimeShard
    raise _INTL("Can't warp to any shards because they're all collected already!") if collectedAllShards?
    mapID, warpEventID, shardEventID = getRandomSpaceTimeShardLocation
    warpEventID = 1 # Until these events are actually created
    pbSEPlay("Anim/PRSFX- Roar of Time2")
    pbWait(30)
    teleportLeaveAnimation(false)
    pbWait(20)
    pbSEPlay("Anim/PRSFX- Spacial Rend")
    pbWait(10)
    blackFadeOutIn(5) {
        transferPlayerToEvent(warpEventID,$game_player.direction,mapID)
        hours = rand(10,14)
        UnrealTime.add_hours(hours)
    }
    pbWait(10)
    pbSEPlay("Anim/PRSFX- Roar of Time3")
    teleportArriveAnimation(false)
    pbWait(20)
end

def TTRSTS
    teleportToRandomSpaceTimeShard
end