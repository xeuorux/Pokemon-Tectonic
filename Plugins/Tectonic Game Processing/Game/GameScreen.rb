#===============================================================================
# ** Game_Screen
#-------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as change in color tone,
#  flashing, etc. Refer to "$game_screen" for the instance of this class.
#===============================================================================
class Game_Screen
    #-----------------------------------------------------------------------------
    # * Public Instance Variables
    #-----------------------------------------------------------------------------
    attr_reader   :brightness         # brightness
    attr_reader   :tone               # color tone
    attr_reader   :flash_color        # flash color
    attr_reader   :shake              # shake positioning
    attr_reader   :pictures           # pictures
    attr_reader   :weather_type       # weather type
    attr_reader   :weather_max        # max number of weather sprites
    attr_accessor :weather_duration   # ticks in which the weather should fade in
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
        @transition_time  = OverworldWeather::DEFAULT_STRENGTH_CHANGE_FRAMES
        @weather_duration = 0
        @weather_in_battle = true
        @callback_block = nil
    end

    #-----------------------------------------------------------------------------
    # * Start Changing Color Tone
    #     tone : color tone
    #     duration : time
    #-----------------------------------------------------------------------------
    def start_tone_change(tone, duration)
        @tone_target   = tone.clone
        @tone_duration = duration
        @tone = @tone_target.clone if @tone_duration == 0
    end

    #-----------------------------------------------------------------------------
    # * Start Flashing
    #     color : color
    #     duration : time
    #-----------------------------------------------------------------------------
    def start_flash(color, duration)
        @flash_color    = color.clone
        @flash_duration = duration
    end

    #-----------------------------------------------------------------------------
    # * Start Shaking
    #     power : strength
    #     speed : speed
    #     duration : time
    #-----------------------------------------------------------------------------
    def start_shake(power, speed, duration)
        return if $PokemonSystem.screenshake != 0
        @shake_power    = power
        @shake_speed    = speed
        @shake_duration = duration
    end

    #-----------------------------------------------------------------------------
    # * Set Weather
    #     type : type
    #     power : strength
    #     duration : time
    #-----------------------------------------------------------------------------
    def weather(type, strength, transition_time = 0, weather_in_battle = true, sprites_enabled = true,
                callback_block = nil)
        weatherData = GameData::Weather.get(type)
        @weather_type       = weatherData.id
        @weather_strength   = strength || weatherData.default_strength || 0
        @transition_time    = transition_time || OverworldWeather::DEFAULT_STRENGTH_CHANGE_FRAMES # In 1/20ths of a seconds
        @weather_in_battle  = weather_in_battle
        @weather_sprites_enabled = sprites_enabled
        @callback_block = callback_block if callback_block
    end

    def resetWeather
        @weather_type       = :None
        @weather_strength   = 0
        @transition_time    = OverworldWeather::DEFAULT_STRENGTH_CHANGE_FRAMES
        @weather_in_battle  = true
        @weather_sprites_enabled = true
        @callback_block = nil
    end

    def updateWeather(weather)
        resetWeather unless @weather_type
        weather.updateWeatherSettings($game_screen.weather_type, $game_screen.weather_strength,
            $game_screen.transition_time, $game_screen.weather_sprites_enabled, @callback_block)
        weather.updateCloudCover unless $game_switches[82]
    end

    def resetWeatherCallback
        @callback_block = nil
    end

    #-----------------------------------------------------------------------------
    # * Frame Update
    #-----------------------------------------------------------------------------
    def update
        if @fadeout_duration && @fadeout_duration >= 1
            d = @fadeout_duration
            @brightness = (@brightness * (d - 1)) / d
            @fadeout_duration -= 1
        end
        if @fadein_duration && @fadein_duration >= 1
            d = @fadein_duration
            @brightness = (@brightness * (d - 1) + 255) / d
            @fadein_duration -= 1
        end
        if @tone_duration >= 1
            d = @tone_duration
            @tone.red   = (@tone.red * (d - 1) + @tone_target.red) / d
            @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
            @tone.blue  = (@tone.blue * (d - 1) + @tone_target.blue) / d
            @tone.gray  = (@tone.gray * (d - 1) + @tone_target.gray) / d
            @tone_duration -= 1
        end
        if @flash_duration >= 1
            d = @flash_duration
            @flash_color.alpha = @flash_color.alpha * (d - 1) / d
            @flash_duration -= 1
        end
        if @shake_duration >= 1 || @shake != 0
            delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
            if @shake_duration <= 1 && @shake * (@shake + delta) < 0
                @shake = 0
            else
                @shake += delta
            end
            @shake_direction = -1 if @shake > @shake_power * 2
            @shake_direction = 1 if @shake < -@shake_power * 2
            @shake_duration -= 1 if @shake_duration >= 1
        end
        if $game_temp.in_battle
            for i in 51..100
                @pictures[i].update
            end
        else
            for i in 1..50
                @pictures[i].update
            end
        end
    end
end

#===============================================================================
#
#===============================================================================
def pbToneChangeAll(tone, duration)
    $game_screen.start_tone_change(tone, duration * Graphics.frame_rate / 20)
    for picture in $game_screen.pictures
        picture.start_tone_change(tone, duration * Graphics.frame_rate / 20) if picture
    end
end

def pbShake(power, speed, frames)
    $game_screen.start_shake(power, speed, frames * Graphics.frame_rate / 20)
end

def pbFlash(color, frames)
    $game_screen.start_flash(color, frames * Graphics.frame_rate / 20)
end

SaveData.register(:game_screen) do
    ensure_class :Game_Screen
    save_value do
        $game_screen.resetWeatherCallback
        $game_screen
    end
    load_value { |value| $game_screen = value }
    new_game_value { Game_Screen.new }
    from_old_format { |old_format| old_format[8] }
end
