# Map ID, Shard Event ID, TP Location Event ID
SPACE_TIME_SHARD_LOCATIONS = [
    [136,0,17]
]

def collectedShard?(locationDetails)
    return pbGetSelfSwitch(locationDetails[1],'A',locationDetails[0])
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
    mapID, shardEventID, warpEventID = getRandomSpaceTimeShardLocation
    pbSEPlay("Anim/PRSFX- Roar of Time2")
    pbWait(30)
    teleportLeaveAnimation(false)
    pbWait(20)
    pbSEPlay("Anim/PRSFX- Spacial Rend")
    pbWait(10)
    blackFadeOutIn(5) {
        transferPlayerToEvent(warpEventID,$game_player.direction,mapID)
        hours = rand(10,14)
        UnrealTime.add_seconds(hours * 60 * 60)
    }
    pbWait(10)
    pbSEPlay("Anim/PRSFX- Roar of Time3")
    teleportArriveAnimation(false)
    pbWait(20)
end

def TTRSTS
    teleportToRandomSpaceTimeShard
end