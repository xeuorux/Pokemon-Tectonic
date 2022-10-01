class Game_Screen
    attr_reader :weather_in_battle

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
        @weather_max      = 0.0
        @weather_duration = 0
        @weather_in_battle = true
    end

    def start_shake(power, speed, duration)
        return if $PokemonSystem.screenshake != 0
        @shake_power    = power
        @shake_speed    = speed
        @shake_duration = duration
    end

    def weather(type, power, duration, weather_in_battle = true)
        @weather_type     = GameData::Weather.get(type).id
        @weather_max      = (power + 1) * RPG::Weather::MAX_SPRITES / 10
        @weather_duration = duration   # In 1/20ths of a seconds
        @weather_in_battle = weather_in_battle
    end
end