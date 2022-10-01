Events.onMapChange += proc { |_sender,*args|
    applyOutdoorEffects()
}

SNOW_MAPS = [
    37, # Svait
    186, # Frostflow Farms
    211 # Split Peaks
]

CONSTANT_FOG_MAPS = [
    7, # Wet Walkways
    8, # Velenz
    129, # Barren Crater
]

DAWN_DUSK_FOG_MAPS = [
    59, # Mainland Dock
    316, # Sandstone Estuary
    258, # Whitebloom Town
    216, # Highland Lake
]

def weatherIntensityByDay(day)
    return (Math.sin(day) * Math.sin(day / 2.0) * Math.sin(day / 4.0) * 5).abs
end

def applyOutdoorEffects()
    return if !playerIsOutdoors?

    map_id = $game_map.map_id
    weather_metadata = GameData::MapMetadata.try_get(map_id).weather

    if weather_metadata.nil?
        currentClockHour = pbGetTimeNow.hour
        currentDayOfWeek = pbGetTimeNow.day % 6

        weatherIntensityToday = weatherIntensityByDay(pbGetTimeNow.day)

        weatherSym = :None
        strength = 2

        if CONSTANT_FOG_MAPS.include?(map_id)
            weatherSym = :Fog
            strength = 2
        elsif DAWN_DUSK_FOG_MAPS.include?(map_id)
            if PBDayNight.isMorning? || PBDayNight.isEvening?
                weatherSym = :Fog
                strength = 3
            end
        elsif SNOW_MAPS.include?(map_id)
            if PBDayNight.isNight?
                difficulty = 1
            elsif PBDayNight.isMorning? || PBDayNight.isEvening?
                difficulty = 2
            else
                difficulty = 3
            end

            snowIntensity = weatherIntensityToday.ceil
            if snowIntensity > difficulty
                weatherSym = :Snow
                strength = snowIntensity - difficulty
            end
        else
            if PBDayNight.isNight? || PBDayNight.isEvening?
                nightWeatherNum = (weatherIntensityToday * 7).round % 9
                if nightWeatherNum == 2
                    weatherSym = :Storm
                elsif nightWeatherNum == 4 || nightWeatherNum == 7
                    weatherSym = :Rain
                end
            else
                nightWeatherNum = (weatherIntensityToday * 7).round % 9
                if nightWeatherNum == 4
                    weatherSym = :Sun
                    strength = 1
                elsif nightWeatherNum == 1 || nightWeatherNum == 6
                    weatherSym = :Rain
                end
            end
        end

        if [:None,:Rain].include?(weatherSym)
            velX = (Math.sin(currentClockHour / 12.0 * Math::PI) * 5).round
            velY = (Math.sin((currentClockHour + 2 + currentDayOfWeek) / 12.0 * Math::PI) * 6).round
            applyFog('clouds_fog_texture_high_contrast',0,40,velX,velY,2)
        else
            applyFog('')
        end

        $game_screen.weather(weatherSym, strength, 20, false)
    else
        applyFog('')
    end
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