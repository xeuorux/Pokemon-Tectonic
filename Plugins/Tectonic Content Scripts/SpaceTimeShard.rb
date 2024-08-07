# Map ID, TP Location Event ID, Shard Event ID
SPACE_TIME_SHARD_LOCATIONS = [
    [38,35,31], # Bluepoint Beach
    [56,90,76], # Novo Town
    [6,47,46], # LuxTech
    [430,48,47], # Amber Hills
    [55,40,39], # Lingering Delta
    [78,41,7], # LuxTech Main
    [301,56,44], # County Park
    [7,47,45], # Repora Forest
    [114,11,9], # Velenz Underground East
    [396,10,9], # Crater-Shelf Gatehouse
    [299,14,13], # Fin Center
    [124,11,10], # Clearwater Cave
    [37,31,30], # Svait
    [185,65,64], # Eleig Stretch
    [426,76,75], # Prizca Black Market
    [212,60,59], # Ruins Digsite
    [144,6,5], # Artist's House
    [155,50,42], # Prizca West
    [173,11,10], # Full Blast Records
    [422,5,3], # Leo's Elite Items
    [367,25,24], # Prizca Great Hall
    [186,69,68], # Frostflow Farms
    [187,111,110], # Prizca East
    [288,15,9], # Underground River
    [193,27,26], # Volcanic Shore
    [183,8,4], # Circuit Cave
    [313,5,4], # Wren's House
    [333,23,22], # Floral Maze
    [216,52,31], # Highland Lake
    [211,51,49], # Split Peaks
    [418,5,3], # M. Munna Den 3
    [264,7,6], # Sweetrock Harbor Mart
]

DIALGA_PALKIA_MAP_ID = 143

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
    setMySwitch("A")
    if collectedAllShards?
        # Teleport to Dialga/Palkia dimmension
        spaceTimeWarpToEvent(28,Left,143)
    else
        teleportToRandomSpaceTimeShard
    end
end

def teleportToRandomSpaceTimeShard
    raise _INTL("Can't warp to any shards because they're all collected already!") if collectedAllShards?
    mapID, warpEventID, shardEventID = getRandomSpaceTimeShardLocation
    dir = [2,4,6,8].sample
    spaceTimeWarpToEvent(warpEventID,dir,mapID)
end

def spaceTimeWarpToEvent(warpEventID,dir,mapID)
    pbSEPlay("Anim/PRSFX- Roar of Time2")
    pbWait(30)
    teleportLeaveAnimation(false)
    pbWait(20)
    pbSEPlay("Anim/PRSFX- Spacial Rend")
    pbWait(10)
    blackFadeOutIn(5) {
        transferPlayerToEvent(warpEventID,dir,mapID)
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