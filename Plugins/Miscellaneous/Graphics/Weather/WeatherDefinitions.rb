GameData::Weather.register({
  :id               => :None,
  :id_number        => 0,   # Must be 0 (preset RMXP weather)
  :clouds_proc        => proc { |strength|
    next 50
  },
})

GameData::Weather.register({
  :id               => :Rain,
  :id_number        => 1,   # Must be 1 (preset RMXP weather)
  :category         => :Rain,
  :graphics         => [["rain_1", "rain_2", "rain_3", "rain_4"]],   # Last is splash
  :particle_delta_x => -1200,
  :particle_delta_y => 4800,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 10)
  },
  :clouds_proc      => proc { |strength|
    next 50 - strength * 4
  },
})

# NOTE: This randomly flashes the screen in RPG::Weather#update.
GameData::Weather.register({
  :id               => :Storm,
  :id_number        => 2,   # Must be 2 (preset RMXP weather)
  :category         => :Rain,
  :graphics         => [["storm_1", "storm_2", "storm_3", "storm_4"]],   # Last is splash
  :particle_delta_x => -4800,
  :particle_delta_y => 4800,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3, -strength * 3, -strength * 3, 20)
  },
})

# NOTE: This alters the movement of snow particles in RPG::Weather#update_sprite_position.
GameData::Weather.register({
  :id               => :Snow,
  :id_number        => 3,   # Must be 3 (preset RMXP weather)
  :category         => :Hail,
  :graphics         => [["hail_1", "hail_2", "hail_3"]],
  :particle_delta_x => -240,
  :particle_delta_y => 240,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 2, strength / 2, strength / 2, 0)
  },
  :clouds_proc        => proc { |strength|
    next 40 - strength * 4
  },
})

GameData::Weather.register({
  :id               => :Blizzard,
  :id_number        => 4,
  :category         => :Hail,
  :graphics         => [["blizzard_1", "blizzard_2", "blizzard_3", "blizzard_4"], ["blizzard_tile"]],
  :particle_delta_x => -960,
  :particle_delta_y => 480,
  :tile_delta_x     => -1440,
  :tile_delta_y     => 720,
  :tone_proc        => proc { |strength|
    next Tone.new(strength * 3 / 4, strength * 3 / 4, strength * 3 / 4, 0)
  },
})

GameData::Weather.register({
  :id               => :Sandstorm,
  :id_number        => 5,
  :category         => :Sandstorm,
  :graphics         => [["sandstorm_1", "sandstorm_2", "sandstorm_3", "sandstorm_4"], ["sandstorm_tile"]],
  :particle_delta_x => -1200,
  :particle_delta_y => 640,
  :tile_delta_x     => -720,
  :tile_delta_y     => 360,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 2, 0, -strength / 2, 0)
  },
})

GameData::Weather.register({
  :id               => :HeavyRain,
  :id_number        => 6,
  :category         => :Rain,
  :graphics         => [["storm_1", "storm_2", "storm_3", "storm_4"]],   # Last is splash
  :particle_delta_x => -4800,
  :particle_delta_y => 4800,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 2, -strength * 3 / 2, -strength * 3 / 2, 20)
  },
})

# NOTE: This alters the screen tone in RPG::Weather#update_screen_tone.
GameData::Weather.register({
  :id               => :Sun,
  :id_number        => 7,
  :category         => :Sun,
  :tone_proc        => proc { |strength|
    next Tone.new(strength * 3/4, strength * 3/4, strength * 3/8, 0)
  },
})

GameData::Weather.register({
  :id               => :Fog,
  :category         => :Fog,
  :id_number        => 8,
  :tile_delta_x     => -32,
  :tile_delta_y     => 0,
  :graphics         => [nil, ["fog_tile"]],
})

GameData::Weather.register({
  :id               => :Dusty,
  :id_number        => 9,
  :category         => :Sandstorm,
  :graphics         => [nil, ["dust_tile"]],
  :tile_delta_x     => -60,
  :tile_delta_y     => 0,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 4, 0, -strength / 4, 0)
  },
})

GameData::Weather.register({
  :id               => :Overcast,
  :id_number        => 10,   # Must be 1 (preset RMXP weather)
  :category         => :Rain,
  :graphics         => [],   # Last is splash
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 2 / 3, -strength * 2 / 3, -strength * 2 / 3, 10)
  },
  :clouds_proc        => proc { |strength|
    next 50 - strength * 4
  },
})

GameData::Weather.register({
  :id               => :ToxicFog,
  :category         => :Fog,
  :id_number        => 11,
  :tile_delta_x     => 0,
  :tile_delta_y     => 8,
  :graphics         => [nil, ["toxic_fog_tile"]],
  :default_strength => 1,
})

GameData::Weather.register({
  :id               => :Windy,
  :category         => :Windy,
  :id_number        => 12,
  :particle_delta_x => 0,
  :particle_delta_y => 400,
  :graphics         => [["wind_1","wind_2"]],
  :clouds_proc        => proc { |strength|
    next 50 - strength * 4
  },
})

GameData::Weather.register({
  :id               => :StrongWinds,
  :category         => :Windy,
  :id_number        => 13,
  :particle_delta_x => 0,
  :particle_delta_y => 400,
  :graphics         => [["wind_1","wind_2"]],
  :clouds_proc        => proc { |strength|
    next 1
  },
  :tone_proc        => proc { |strength|
    next Tone.new(strength * 1/2, strength, strength * 3/4, 0)
  },
})