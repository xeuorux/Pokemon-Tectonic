Events.onMapChange += proc { |_sender,*args|
    applyOutdoorEffects()
}

WEATHER_TRANSITION_DELAY = 80

# Don't put a map in both hot and cold
HOT_MAPS = [
    130, # Canal Desert
    316, # Sandstone Estuary
    59, # Mainland Dock
    136, # Casaba Villa
    38, # Bluepoint Beach
    53, # Jungle Path
]

COLD_MAPS = [
    217, # Sweetrock Harbor
    266, # Berry GreenHouse
    258, # Whitebloom Town
    216, # Highland Lake
    37, # Svait
    186, # Frostflow Farms
    211, # Split Peaks
    121, # Skyward Ascent
]

# Don't put a map in both wet and dry
WET_MAPS = [
    59, # Mainland Dock
    136, # Casaba Villa
    38, # Bluepoint Beach
    217, # Sweetrock Harbor
    266, # Berry GreenHouse
    258, # Whitebloom Town
    216, # Highland Lake
    53, # Jungle Path
]

DRY_MAPS = [
    130, # Canal Desert
    37, # Svait
    211, # Split Peaks
    121, # Skyward Ascent
    129, # Barren Crater
]

FOG_MAPS = [
    7, # Wet Walkways
    8, # Velenz
]

DARK_MAPS = [
    8, # Velenz
]

GLASS_CEILING_MAPS = [
    266, # Berry Greenhouse
]

# Every other map is assumed to be temperate, with potential for both hot days, cold days, wet days, and dry days in equal measure

def getWeatherForTimeAndMap(time,map_id)
    clockHour = time.hour
    hours = (time - UnrealTime.initial_date).to_i / (60 * 60)

    # Both of these go from -3 to +3
    hotnessThisHour = (3 * Math.sin(hours / 31.0) * Math.sin(hours / 87.0))
    hotnessThisHour += 0.45 # The game takes place in summer
    hotnessThisHour = hotnessThisHour.round

    wetnessThisHour = (3 * Math.cos(hours / 31.0) * Math.cos(hours / 87.0))
    wetnessThisHour = wetnessThisHour.round

    #echoln("Hour #{hours} hotness/wetness: #{hotnessThisHour}, #{wetnessThisHour}")

    # Hotter near noon, colder near midnight
    # Up to + 1 and down to -1
    hotness = hotnessThisHour
    hotness += (1 - (clockHour - 11).abs / 6).round

    # Wetter near 6 AM and 6 PM, dryer neat midnight and noon
    # Up to + 1 and down to -1
    wetness = wetnessThisHour
    wetness += (1 - 2 * [(clockHour - 5).abs / 6,(clockHour - 17).abs / 6].min).round

    #echoln("Hotness/wetness after time of day mod: #{hotness}, #{wetness}")

    if HOT_MAPS.include?(map_id)
        hotness += 1
    elsif COLD_MAPS.include?(map_id)
        hotness -= 1
    end

    if WET_MAPS.include?(map_id)
        wetness += 1
    elsif DRY_MAPS.include?(map_id)
        wetness -= 1
    end

    #echoln("Hotness/wetness after map mod: #{hotness}, #{wetness}")

    weatherSym = :None

    # Within this section, strength is treated as between 1-5
    strength = 1
    if FOG_MAPS.include?(map_id)
        weatherSym = :Fog
    else
        hotWetness = hotness + wetness
        hotDryness = hotness - wetness
        coldWetness = -hotness + wetness
        coldDryness = -hotness - wetness
        
        if hotness > 0 && wetness > 0 && hotWetness >= 4
            weatherSym, strength = getHotWetWeather(hotWetness - 3)
            strength *= 2
        elsif hotness > 0 && wetness < 0 && hotDryness >= 4
            weatherSym, strength = getHotDryWeather(hotDryness - 3)
            strength *= 2
        elsif hotness < 0 && wetness > 0 && coldWetness >= 4
            weatherSym, strength = getColdWetWeather(coldWetness - 3)
            strength *= 2
        elsif hotness < 0 && wetness < 0 && coldDryness >= 4
            weatherSym, strength = getColdDryWeather(coldDryness - 3)
            strength *= 2
        elsif hotness >= 3
            weatherSym, strength = getHotWeather(hotness - 2)
        elsif hotness <= -3
            weatherSym, strength = getColdWeather(-hotness - 2)
        elsif wetness >= 3
            weatherSym, strength = getWetWeather(wetness - 2)
        elsif wetness <= -3
            weatherSym, strength = getDryWeather(-wetness - 2)
        end
    end
    return weatherSym, strength
end

def weatherRNGByHour(totalHours)
    return (Math.sin(day * 2.0) * Math.sin(day * 4.0) * Math.sin(day * 8.0)).abs
end

def applyOutdoorEffects()
    return if !playerIsOutdoors?

    map_id = $game_map.map_id
    weather_metadata = GameData::MapMetadata.try_get(map_id).weather

    glassCeiling = GLASS_CEILING_MAPS.include?(map_id)

    if weather_metadata.nil?
        weatherSym,strength = getWeatherForTimeAndMap(pbGetTimeNow,map_id)

        weatherData = GameData::Weather.get(weatherSym)
        cloudCoverOpacity = weatherData.cloud_cover_opacity(strength)

        if cloudCoverOpacity > 0
            speed = 6
            if [:Rain,:Overcast,:Snow].include?(weatherSym)
                speed -= strength * 2
            end
            speed = [speed,0].max
            velX = (Math.sin(pbGetTimeNow.hour / 12.0 * Math::PI) * speed).round
            velY = (Math.sin((pbGetTimeNow.hour + 2 + pbGetTimeNow.day) / 12.0 * Math::PI) * speed).round

            if glassCeiling
                cloudCoverOpacity /= 2
            end
            applyFog('clouds_fog_texture_high_contrast',0,cloudCoverOpacity,velX,velY,2)
        else
            applyDefaultFog(map_id)
        end

        if speedingUpTime?
            if weatherSym != $game_screen.weather_type
                print("Weather type changed to #{weatherSym}!")
            elsif strength != $game_screen.weather_strength
                print("Weather strength changed to #{strength}!")
            end
        end
        $game_screen.weather(weatherSym, strength, WEATHER_TRANSITION_DELAY, false, !glassCeiling)
    else
        applyDefaultFog(map_id)
    end
end

def getHotWeather(strength)
    return :Sun,strength
end

def getColdWeather(strength)
    return :Snow,strength
end

def getWetWeather(strength)
    return :Rain,strength
end

def getDryWeather(strength)
    return :Dusty,strength
end

def getHotWetWeather(strength)
    weatherSym = :Overcast

    if strength >= 4
        weatherSym = :Storm
        strength -= 3
    end

    return weatherSym,strength
end

def getHotDryWeather(strength)
    weatherSym = :Sun

    if strength >= 4
        weatherSym = :Sandstorm
        strength -= 3
    end

    return weatherSym,strength
end

def getColdWetWeather(strength)
    weatherSym = :Fog

    if strength >= 4
        weatherSym = :Rain
        strength -= 3
    end

    return weatherSym,strength
end

def getColdDryWeather(strength)
    weatherSym = :Snow

    if strength >= 4
        weatherSym = :Blizzard
        strength -= 3
    end

    return weatherSym,strength
end

def applyDefaultFog(mapID)
    darknessOpacity = 0
    darknessOpacity = 100 if DARK_MAPS.include?(mapID)
    applyFog('darkness', 0, darknessOpacity)
end

def applyFog(name, hue = 0, opacity = 100, velX = 0, velY = 0, blend_type = 0, zoom = 100)
    $game_map.fog_name       = name
    $game_map.fog_hue        = hue
    $game_map.fog_opacity    = opacity
    $game_map.fog_blend_type = blend_type
    $game_map.fog_zoom       = zoom
    $game_map.fog_sx         = velX
    $game_map.fog_sy         = velY
end

def debugIncrementWeather(weatherSym)
    newPower = Input.press?(Input::CTRL) ? -2 : 2
    if $game_screen.weather_type == GameData::Weather.get(weatherSym).id
        newPower += $game_screen.weather_strength
    end
    newPower = [newPower,10].min
    $game_screen.weather(weatherSym, newPower, WEATHER_TRANSITION_DELAY, false)
    pbMessage("Setting weather to #{weatherSym} at power #{newPower}")
end

def getWeatherOverNextDay(map_id = -1)
    mapName = ""
    if map_id == -1
        map_id = WEATHER_REPORT_MAPS.keys.sample
        mapName = WEATHER_REPORT_MAPS[map_id]
    else
        mapName = pbGetMapNameFromId(map_id)
    end

    secondsInAMinute = 60
    secondsInAnHour = secondsInAMinute * 60
    secondsInADay = secondsInAnHour * 24

    # Add 24 hours, then round down to latest 24 hour start
    tomorrowStart = ((pbGetTimeNow.to_i + secondsInADay) / secondsInADay).floor * secondsInADay

    tomorrowMorning = Time.at(tomorrowStart + secondsInAnHour * 8) # 8 AM
    tomorrowAfternoon = Time.at(tomorrowStart + secondsInAnHour * 14) # 2 PM
    tomorrowEvening = Time.at(tomorrowStart + secondsInAnHour * 20) # 8 PM

    morningWeather, morningStrength = getWeatherForTimeAndMap(tomorrowMorning,map_id)
    morningDescriptor = getWeatherDescriptor(morningWeather, morningStrength)
    
    afternoonWeather, afternoonStrength = getWeatherForTimeAndMap(tomorrowAfternoon,map_id)
    afternoonDescriptor = getWeatherDescriptor(afternoonWeather, afternoonStrength)
    
    eveningWeather, eveningStrength = getWeatherForTimeAndMap(tomorrowEvening,map_id)
    eveningDescriptor = getWeatherDescriptor(eveningWeather, eveningStrength)

    return [[morningWeather, morningStrength],[afternoonWeather, afternoonStrength],[eveningWeather, eveningStrength]]
end