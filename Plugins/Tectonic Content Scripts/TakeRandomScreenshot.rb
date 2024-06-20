def mapGuessingGame(screenshotCount = 9)
    locationNames = []
    loop do
        begin
            locationNames.push(takeRandomScreenshot(locationNames.length + 1))
        rescue Exception
            echoln $!.message
            echoln $!.backtrace
        end
        break if locationNames.length >= screenshotCount
    end
    echoln("Answers:")
    locationNames.each do |locationName|
        echoln(locationName)
    end
end

def takeRandomScreenshot(screenshotLabel = -1)
    get_player.opacity = 0

    mapData = Compiler::MapData.new
    map_id = -1
    loop do
        map_id = mapData.mapinfos.keys.sample
        break unless ESTATE_MAP_IDS.include?(map_id)
    end
    x, y = getRandomWarpPointOnMap(map_id, true)

    teleportPlayer(map_id, x, y, true)
    
    if screenshotLabel
        pbScreenCapture("MGG_#{screenshotLabel}")
    else
        pbScreenCapture("MGG_#{$game_map.name}")
    end

    get_player.opacity = 255
    
    pbWait(1)
end