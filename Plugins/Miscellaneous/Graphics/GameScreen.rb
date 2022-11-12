class Game_Screen
    attr_reader :weather_strength
    attr_reader :transition_time
    attr_reader :weather_in_battle
    attr_reader :weather_sprites_enabled
    attr_reader :weather_callback

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
        @transition_time  = DEFAULT_STRENGTH_CHANGE_FRAMES
        @weather_duration = 0
        @weather_in_battle = true
        @callback_block = nil
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
        @transition_time    = DEFAULT_STRENGTH_CHANGE_FRAMES
        @weather_in_battle  = true
        @weather_sprites_enabled = true
        @callback_block = nil
    end

    def weather(type, strength, transition_time = 0, weather_in_battle = true, sprites_enabled = true, callback_block = nil)
        weatherData = GameData::Weather.get(type)
        @weather_type       = weatherData.id
        @weather_strength   = strength || weatherData.default_strength || 0
        @transition_time    = transition_time || DEFAULT_STRENGTH_CHANGE_FRAMES   # In 1/20ths of a seconds
        @weather_in_battle  = weather_in_battle
        @weather_sprites_enabled = sprites_enabled
        @callback_block = callback_block if callback_block
    end

    def updateWeather(weather)
        resetWeather if !@weather_type
        weather.updateWeatherSettings($game_screen.weather_type, $game_screen.weather_strength,
            $game_screen.transition_time, $game_screen.weather_sprites_enabled, @callback_block)
    end
end