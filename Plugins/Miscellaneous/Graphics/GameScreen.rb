class Game_Screen
    attr_reader :weather_strength
    attr_reader :transition_time
    attr_reader :weather_in_battle
    attr_reader :weather_sprites_enabled

    #-----------------------------------------------------------------------------
    # * Object Initialization
    #-----------------------------------------------------------------------------
    def initialize
        @brightness       = 255
        @fadeout_duration = 0
        @fadein_duration  = 0
        @tone             = Tone.new(0, 0, 0, 0)
        @tone_target      = Tone.new(0, 0, 0, 0)
        @tone_duration    = 0
        @flash_color      = Color.new(0, 0, 0, 0)
        @flash_duration   = 0
        @shake_power      = 0
        @shake_speed      = 0
        @shake_duration   = 0
        @shake_direction  = 1
        @shake            = 0
        @pictures         = [nil]
        for i in 1..100
            @pictures.push(Game_Picture.new(i))
        end
        @weather_type     = 0
        @weather_strength = 0
        @weather_duration = 0
        @weather_in_battle = true
    end

    def start_shake(power, speed, duration)
        return if $PokemonSystem.screenshake != 0
        @shake_power    = power
        @shake_speed    = speed
        @shake_duration = duration
    end

    def resetWeather
        @weather_type       = :None
        @weather_strength   = 0
        @transition_time   = 0
        @weather_in_battle  = true
        @weather_sprites_enabled = true
    end

    def weather(type, strength, transition_time = 0, weather_in_battle = true, sprites_enabled = true)
        weatherData = GameData::Weather.get(type)
        @weather_type       = weatherData.id
        @weather_strength   = strength || weatherData.default_strength
        @transition_time    = transition_time   # In 1/20ths of a seconds
        @weather_in_battle  = weather_in_battle
        @weather_sprites_enabled = sprites_enabled
    end
end