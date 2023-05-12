# Category has the following effects:
#   - Determines the in-battle weather.
#   - Some abilities reduce the encounter rate in certain categories of weather.
#   - Some evolution methods check the current weather's category.
#   - The :Rain category treats the last listed particle graphic as a water splash rather
#     than a raindrop, which behaves differently.
#   - :Rain auto-waters berry plants.
# Delta values are per second.
# For the tone_proc, strength goes from 0 to RPG::Weather::MAX_SPRITES (60) and
# will typically be the maximum.
module GameData
    class Weather
      attr_reader :id
      attr_reader :id_number
      attr_reader :real_name
      attr_reader :category   # :None, :Rain, :Hail, :Sandstorm, :Sun, :Fog
      attr_reader :graphics   # [[particle file names], [tile file names]]
      attr_reader :particle_delta_x
      attr_reader :particle_delta_y
      attr_reader :particle_delta_opacity
      attr_reader :tile_delta_x
      attr_reader :tile_delta_y
      attr_reader :tone_proc
      attr_reader :particle_names
    attr_reader :tile_name
    attr_reader :clouds_proc
    attr_reader :default_strength
  
      DATA = {}
  
      extend ClassMethods
      include InstanceMethods
  
      def self.load; end
      def self.save; end
  
      def initialize(hash)
        @id                     = hash[:id]
        @id_number              = hash[:id_number]
        @real_name              = hash[:id].to_s                || "Unnamed"
        @category               = hash[:category]               || :None
        @particle_delta_x       = hash[:particle_delta_x]       || 0
        @particle_delta_y       = hash[:particle_delta_y]       || 0
        @particle_delta_opacity = hash[:particle_delta_opacity] || 0
        @tile_delta_x           = hash[:tile_delta_x]           || 0
        @tile_delta_y           = hash[:tile_delta_y]           || 0
        @particle_names         = hash[:particle_names]         || []
        @tile_name              = hash[:tile_name]
        @tone_proc              = hash[:tone_proc]
        @clouds_proc            = hash[:clouds_proc]
        @default_strength       = hash[:default_strength] || 2
    end
  
      def has_particles?
        return @graphics[0] && @graphics[0].length > 0
      end
  
      def has_tiles?
        return @graphics[1] && @graphics[1].length > 0
      end
  
      def tone(strength)
        return (@tone_proc) ? @tone_proc.call(strength) : Tone.new(0, 0, 0, 0)
      end
        def setsTone?
            return !@tone_proc.nil?
        end

        def cloud_cover_opacity(strength)
            return (@clouds_proc) ? @clouds_proc.call(strength) : 0
        end
    end
  end

  GameData::Weather.register({
    :id               => :None,
    :id_number        => 0,   # Must be 0 (preset RMXP weather)
    :clouds_proc        => proc { |strength|
      next 0
    },
  })
  
  GameData::Weather.register({
    :id               => :Rain,
    :id_number        => 1,   # Must be 1 (preset RMXP weather)
    :category         => :Rain,
    :particle_names   => ["storm_1", "storm_2", "storm_3", "storm_4"], # Last is splash
    :particle_delta_x => -3200,
    :particle_delta_y => 3200,
    :tone_proc        => proc { |strength|
      next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 10)
    },
    :clouds_proc      => proc { |strength|
      next strength * -6
    },
  })
  
  # NOTE: This randomly flashes the screen in RPG::Weather#update.
  GameData::Weather.register({
    :id               => :Storm,
    :id_number        => 2,   # Must be 2 (preset RMXP weather)
    :category         => :Rain,
    :particle_names   => ["storm_1", "storm_2", "storm_3", "storm_4"], # Last is splash
    :particle_delta_x => -4800,
    :particle_delta_y => 4800,
    :tone_proc        => proc { |strength|
      next Tone.new(-strength * 3, -strength * 3, -strength * 3, 20)
    },
    :clouds_proc        => proc { |strength|
      next strength * -8
    },
  })
  
  # NOTE: This alters the movement of snow particles in RPG::Weather#update_sprite_position.
  GameData::Weather.register({
    :id               => :Snow,
    :id_number        => 3,   # Must be 3 (preset RMXP weather)
    :category         => :Hail,
    :particle_names   => ["blizzard_1", "blizzard_2", "blizzard_3", "blizzard_4"],
    :particle_delta_x => -240,
    :particle_delta_y => 240,
    :tone_proc        => proc { |strength|
      next Tone.new(strength / 2, strength / 2, strength / 2, 0)
    },
    :clouds_proc        => proc { |strength|
      next strength * -4
    },
  })
  
  GameData::Weather.register({
    :id               => :Blizzard,
    :id_number        => 4,
    :category         => :Hail,
    :particle_names   => ["blizzard_1", "blizzard_2", "blizzard_3", "blizzard_4"],
    :particle_delta_x => -960,
    :particle_delta_y => 480,
    :tile_name        => "blizzard_tile",
    :tile_delta_x     => -1440,
    :tile_delta_y     => 720,
    :tone_proc        => proc { |strength|
      next Tone.new(strength * 3 / 4, strength * 3 / 4, strength * 3 / 4, 0)
    },
    :clouds_proc        => proc { |strength|
      next strength * -8
    },
  })
  
  GameData::Weather.register({
    :id               => :Sandstorm,
    :id_number        => 5,
    :category         => :Sandstorm,
    :particle_names   => ["sandstorm_1", "sandstorm_2", "sandstorm_3", "sandstorm_4"],
    :particle_delta_x => -1200,
    :particle_delta_y => 640,
    :tile_name        => "sandstorm_tile",
    :tile_delta_x     => -720,
    :tile_delta_y     => 360,
    :tone_proc        => proc { |strength|
      next Tone.new(strength / 2, 0, -strength / 2, 0)
    },
    :clouds_proc        => proc { |strength|
      next strength * -10
    },
  })
  
  GameData::Weather.register({
    :id               => :HeavyRain,
    :id_number        => 6,
    :category         => :Rain,
    :particle_names   => ["storm_1", "storm_2", "storm_3", "storm_4"], # Last is splash
    :particle_delta_x => -4800,
    :particle_delta_y => 4800,
    :tone_proc        => proc { |strength|
      next Tone.new(-strength * 3 / 2, -strength * 3 / 2, -strength * 3 / 2, 20)
    },
    :clouds_proc      => proc { |strength|
      next strength * -8
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
    :clouds_proc      => proc { |strength|
      next strength * -10
    },
  })
  
  GameData::Weather.register({
    :id               => :Fog,
    :category         => :Fog,
    :id_number        => 8,
    :tile_delta_x     => -32,
    :tile_delta_y     => 0,
    :tile_name        => "fog_tile",
    :clouds_proc      => proc { |strength|
      next strength * -10
    },
  })
  
  GameData::Weather.register({
    :id               => :Dusty,
    :id_number        => 9,
    :category         => :Sandstorm,
    :tile_name        => "dust_tile",
    :tile_delta_x     => -60,
    :tile_delta_y     => 0,
    :tone_proc        => proc { |strength|
      next Tone.new(strength / 4, 0, -strength / 4, 0)
    },
    :clouds_proc        => proc { |strength|
      next strength * -8
    },
  })
  
  GameData::Weather.register({
    :id               => :Overcast,
    :id_number        => 10,   # Must be 1 (preset RMXP weather)
    :category         => :Rain,
    :tone_proc        => proc { |strength|
      next Tone.new(-strength * 2 / 3, -strength * 2 / 3, -strength * 2 / 3, 10)
    },
    :clouds_proc        => proc { |strength|
      next strength * -2
    },
  })
  
  GameData::Weather.register({
    :id               => :ToxicFog,
    :category         => :ToxicFog,
    :id_number        => 11,
    :tile_delta_x     => 0,
    :tile_delta_y     => 8,
    :tile_name        => "toxic_fog_tile",
    :default_strength => 1,
    :clouds_proc        => proc { |strength|
      next strength * -4
    },
  })
  
  GameData::Weather.register({
    :id               => :Windy,
    :category         => :Windy,
    :id_number        => 12,
    :particle_delta_x => 0,
    :particle_delta_y => 400,
    :particle_names   => ["wind_1","wind_2"],
    :clouds_proc        => proc { |strength|
      next strength * -4
    },
  })
  
  GameData::Weather.register({
    :id               => :StrongWinds,
    :category         => :Windy,
    :id_number        => 13,
    :particle_delta_x => 0,
    :particle_delta_y => 400,
    :particle_names   => ["wind_1","wind_2"],
    :clouds_proc        => proc { |strength|
      next strength * -4
    },
    :tone_proc        => proc { |strength|
      next Tone.new(-strength, -strength, -strength)
    },
  })
  
  GameData::Weather.register({
    :id               => :TimeSandstorm,
    :id_number        => 5,
    :category         => :Sandstorm,
    :particle_names   => ["sandstorm_1", "sandstorm_2", "sandstorm_3", "sandstorm_4"],
    :particle_delta_x => -1200,
    :particle_delta_y => 640,
    :tile_name        => "sandstorm_tile",
    :tile_delta_x     => -720,
    :tile_delta_y     => 360,
    :clouds_proc        => proc { |strength|
      next strength * -10
    },
  })