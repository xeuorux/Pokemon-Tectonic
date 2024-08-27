Events.onMapChange += proc { |_sender,*args|
    applyOutdoorEffects
}

WEATHER_TRANSITION_DELAY = 80

# Tectonic takes place during the summer
BASE_HOTNESS_OFFSET = 0.1
BASE_HUMIDITY_OFFSET = -0.1

GLASS_CEILING_MAPS = [
    266, # Berry Greenhouse
]

# Every other map is assumed to be temperate, with potential for both hot days, cold days, wet days, and dry days in equal measure

def getWeatherForTimeAndMap(time,map_id)
    clockHour = time.hour
    hours = (time - UnrealTime.initial_date).to_i / (60 * 60)

    # Both of these go from -3 to +3
    hotnessThisHour = (3 * Math.sin(hours / 31.0) * Math.sin(hours / 87.0))
    hotnessThisHour += BASE_HOTNESS_OFFSET

    wetnessThisHour = (3 * Math.cos(hours / 31.0) * Math.cos(hours / 87.0))
    wetnessThisHour += BASE_HUMIDITY_OFFSET

    # Hotter near noon, colder near midnight
    # Up to + 1 and down to -1
    hotness = hotnessThisHour
    hotness += (1 - (clockHour - 11).abs / 6)

    # Wetter near 6 AM and 6 PM, dryer neat midnight and noon
    # Up to + 1 and down to -1
    wetness = wetnessThisHour
    wetness += (1 - 2 * [(clockHour - 5).abs / 6,(clockHour - 17).abs / 6].min)

    if GameData::MapMetadata.exists?(map_id)
        metaData = GameData::MapMetadata.get(map_id)

        case metaData.temperature
        when 0 # Hot
            hotness += 1
        when 1 # Cold
            hotness -= 1
        when 2 # Stable
            hotness *= 0.7
        end
    
        case metaData.humidity
        when 0 # Wet
            wetness += 1
        when 1 # Dry
            wetness -= 1
        when 2 # Stable
            wetness *= 0.7
        end
    end

    weatherSym = :None

    # Within this section, strength is treated as between 1-5
    strength = 1

    hotWetness = hotness + wetness
    hotDryness = hotness - wetness
    coldWetness = -hotness + wetness
    coldDryness = -hotness - wetness
    
    if hotness > 0 && wetness > 0 && hotWetness >= 4
        weatherSym, strength = getHotWetWeather(hotWetness - 3)
    elsif hotness > 0 && wetness < 0 && hotDryness >= 4
        weatherSym, strength = getHotDryWeather(hotDryness - 3)
    elsif hotness < 0 && wetness > 0 && coldWetness >= 4
        weatherSym, strength = getColdWetWeather(coldWetness - 3)
    elsif hotness < 0 && wetness < 0 && coldDryness >= 4
        weatherSym, strength = getColdDryWeather(coldDryness - 3)
    elsif hotness >= 2
        weatherSym, strength = getHotWeather(hotness - 1)
    elsif hotness <= -2
        weatherSym, strength = getColdWeather(-hotness - 1)
    elsif wetness >= 2
        weatherSym, strength = getWetWeather(wetness - 1)
    elsif wetness <= -2
        weatherSym, strength = getDryWeather(-wetness - 1)
    end

    strength = strength.round
    return weatherSym, strength
end

def weatherRNGByHour(totalHours)
    return (Math.sin(day * 2.0) * Math.sin(day * 4.0) * Math.sin(day * 8.0)).abs
end

def applyOutdoorEffects(delay = -1)
    return unless $PokemonSystem.overworld_weather == 0
    return unless playerIsOutdoors?

    map_id = $game_map.map_id
    weather_metadata = GameData::MapMetadata.try_get(map_id).weather

    if weather_metadata.nil?
        weatherSym,strength = getWeatherForTimeAndMap(pbGetTimeNow,map_id)
        if speedingUpTime? && Input.press?(Input::ACTION)
            if weatherSym != $game_screen.weather_type
                print("Weather type changed to #{weatherSym}!")
            elsif strength != $game_screen.weather_strength
                print("Weather strength changed to #{strength}!")
            end
        end
        delay = WEATHER_TRANSITION_DELAY if delay < 0
        $game_screen.weather(weatherSym, strength, delay, false, !GLASS_CEILING_MAPS.include?(map_id))
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

    if strength >= 3
        weatherSym = :Storm
        strength = (strength - 2) * 2
    end

    return weatherSym,strength
end

def getHotDryWeather(strength)
    weatherSym = :Sun

    if strength >= 3
        weatherSym = :Sandstorm
        strength = (strength - 2) * 2
    end

    return weatherSym,strength
end

def getColdWetWeather(strength)
    weatherSym = :Fog

    if strength >= 3
        weatherSym = :Rain
        strength = (strength - 2) * 2
    end

    return weatherSym,strength
end

def getColdDryWeather(strength)
    weatherSym = :Snow

    if strength >= 3
        weatherSym = :Blizzard
        strength = (strength - 2) * 2
    end

    return weatherSym,strength
end

def debugIncrementWeather(weatherSym)
    newPower = Input.press?(Input::CTRL) ? -2 : 2
    if $game_screen.weather_type == GameData::Weather.get(weatherSym).id
        newPower += $game_screen.weather_strength
    end
    newPower = [newPower,10].min
    $game_screen.weather(weatherSym, newPower, WEATHER_TRANSITION_DELAY, false)
    pbMessage(_INTL("Setting weather to #{weatherSym} at power #{newPower}"))
end

def secondsInAMinute
    return 60
end

def secondsInAnHour
    return secondsInAMinute * 60
end

def secondsInADay
    return secondsInAnHour * 24
end

def getWeatherOverNextDay(map_id = -1)
    map_id = WEATHER_REPORT_MAPS.keys.sample if map_id == -1

    # Add 24 hours, then round down to latest 24 hour start
    tomorrowStart = ((pbGetTimeNow.to_i + secondsInADay) / secondsInADay).floor * secondsInADay

    tomorrowMorning = Time.at(tomorrowStart + secondsInAnHour * 8) # 8 AM
    tomorrowAfternoon = Time.at(tomorrowStart + secondsInAnHour * 14) # 2 PM
    tomorrowEvening = Time.at(tomorrowStart + secondsInAnHour * 20) # 8 PM

    morningWeather, morningStrength = getWeatherForTimeAndMap(tomorrowMorning,map_id)
    afternoonWeather, afternoonStrength = getWeatherForTimeAndMap(tomorrowAfternoon,map_id)
    eveningWeather, eveningStrength = getWeatherForTimeAndMap(tomorrowEvening,map_id)

    return [
        [morningWeather, morningStrength],
        [afternoonWeather, afternoonStrength],
        [eveningWeather, eveningStrength],
    ]
end

def weather(type, strength = -1, delay = -1)
    strength = GameData::Weather.get(type).default_strength if strength < 0
    delay = WEATHER_TRANSITION_DELAY if delay < 0
    $game_screen.weather(type, strength, delay)
end

def debugTestMap(mapID)
    weatherCounts = {}
    hourCount = 100_000

    for i in 0..hourCount
        weatherSym,strength = getWeatherForTimeAndMap(UnrealTime.initial_date + i * secondsInAnHour,mapID)
        if weatherCounts.has_key?(weatherSym)
            weatherCounts[weatherSym] += 1
        else
            weatherCounts[weatherSym] = 1
        end
    end

    echoln("Over the course of #{hourCount} hours, map #{mapID} had the following weathers each percentage of the time:")
    weatherCounts.each do |key, value|
        echoln("#{key}: #{(100 * value / hourCount.to_f).round(1)} percent")
    end
end

def weatherTestingArray
    echoln("Hot and Wet")
    debugTestMap(53)
    echoln("Hot and Dry")
    debugTestMap(130)
    echoln("Cold and Wet")
    debugTestMap(217)
    echoln("Cold and Dry")
    debugTestMap(37)
end