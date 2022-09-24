Events.onMapChange += proc { |_sender,*args|
    applyOutdoorFog()
}

def applyOutdoorFog()
    return if !playerIsOutdoors?
    if $game_screen.weather_type == :None
        currentClockHour = pbGetTimeNow.hour
        currentDay = pbGetTimeNow.day % 6
        velX = (Math.sin(currentClockHour / 12.0 * Math::PI) * 5).round
        velY = (Math.sin((currentClockHour + 2 + currentDay) / 12.0 * Math::PI) * 6).round
        applyFog('clouds_fog_texture_high_contrast',0,40,velX,velY,2)
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