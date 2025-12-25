VOLUME_FAKERY_MULT = 2.0

class Options
    attr_accessor :textspeed
    attr_accessor :battlescene
    attr_accessor :battlestyle
    attr_reader   :frame
    attr_reader   :textskin
    attr_accessor :screensize
    attr_accessor :language
    attr_accessor :runstyle
    attr_accessor :textinput
    attr_accessor :followers
    attr_accessor :autosave
    attr_accessor :particle_effects
    attr_accessor :overworld_weather
    attr_accessor :screenshake
    attr_accessor :damage_numbers
    attr_accessor :show_item_descriptions
    attr_accessor :show_trait_unlocks
    attr_accessor :effectiveness_messages
    attr_accessor :weather_messages
    attr_accessor :status_effect_messages
    attr_accessor :move_clarifying_messages
    attr_accessor :avatar_mechanics_messages
    attr_accessor :nicknaming_prompt
    attr_accessor :dex_shown_register
    attr_accessor :color_shifts
    attr_accessor :party_snapshots
    attr_accessor :prompt_level_moves
    attr_accessor :show_stat_changes
    attr_accessor :bag_sorting
    attr_accessor :battle_transitions
    attr_accessor :tutorial_popups
    attr_accessor :dark_mode
    attr_accessor :forced_time_tint
    attr_accessor :aid_kit_animation
    attr_accessor :quick_evolution
    attr_accessor :name_on_showcases
    attr_accessor :flashing_weather
    
    attr_accessor :bike_bgm

    def bgmvolume
        return @bgmvolume / VOLUME_FAKERY_MULT
    end

    attr_writer :bgmvolume

    def sevolume
        return @sevolume / VOLUME_FAKERY_MULT
    end

    attr_writer :sevolume

    def self.optionsFilePath
        return System.data_directory + "/Options.dat"
    end

    def storeOptions
        File.open(Options.optionsFilePath, 'wb') { |file| Marshal.dump($Options, file) }
        echoln("Wrote options data to file.")
    end

    def initialize
        @textspeed                      = $DEBUG ? 4 : 2 # Text speed (0=slow, 1=normal, 2=fast, 3=rapid, 4=instant)
        @battlescene                    = 1 # Battle effects (animations) (0=on, 1=fast, 2=off)
        @battle_transitions             = $DEBUG ? 1 : 0 # (0=standard, 1=fast)
        @battlestyle                    = 1 # Battle style (0=switch, 1=set)
        @frame                          = 0 # Default window frame (see also Settings::MENU_WINDOWSKINS)
        @textskin    		            = 0 # Speech frame
        @dark_mode                      = 1 # (0=true, 1=false)
        @font        		            = 0 # Font (see also Settings::FONT_OPTIONS)
        @screensize  		            = (Settings::SCREEN_SCALE * 2).floor - 1 # 0=half size, 1=full size, 2=full-and-a-half size, 3=double size
        @language    		            = 0 # Language (see also Settings::LANGUAGES in script Options)
        @runstyle    		            = 0 # Default movement speed (0=walk, 1=run)
        @bgmvolume                      = 50 # Volume of background music and ME
        @sevolume    		            = 50 # Volume of sound effects
        @bike_bgm                       = 0 # (0=true, 1=false)
        @textinput   		            = System.platform.downcase[/android/] ? 0 : 1 # Text input mode (0=cursor, 1=keyboard)
        @followers   		            = 0	# Follower Pokemon enabled (0=true, 1=false)
        @autosave	 		            = 0	# Autosave enabled (0=true, 1=false)
        @color_shifts                   = 0 # (0=true, 1=false)
        @particle_effects               = 0 # (0=true, 1=false)
        @overworld_weather              = 0 # (0=true, 1=false)
        @forced_time_tint               = 0 # (0=off,1=morning,2=mid-day,3=evening,4=night)
        @screenshake                    = 0 # (0=true, 1=false)
        @flashing_weather               = 0 # (0=true, 1=false)
        @damage_numbers                 = 0 # (0=true, 1=false)
        @show_item_descriptions         = $DEBUG ? 1 : 0 # (0=true, 1=false)
        @effectiveness_messages         = 0 # (0=true, 1=false)
        @weather_messages               = 0 # (0=true, 1=false)
        @status_effect_messages         = 0 # (0=true, 1=false)
        @move_clarifying_messages       = 0 # (0=true, 1=false)
        @avatar_mechanics_messages      = 0 # (0=true, 1=false)
        @nicknaming_prompt              = 0 # (0=true, 1=false)
        @dex_shown_register             = 0 # (0=true, 1=false)
        @prompt_level_moves             = 0 # (0=true, 1=false)
        @show_stat_changes              = 0 # (0=true, 1=false)
        @show_trait_unlocks             = $DEBUG ? 1 : 0 # (0=true, 1=false)
        @party_snapshots                = $DEBUG ? 1 : 0 # (0=true, 1=false)
        @tutorial_popups                = $DEBUG ? 1 : 0 # (0=true, 1=false)
        @bag_sorting                    = 0 # (0=none,1=alphabetical,2=ID)
        @aid_kit_animation              = 0 # (0=true, 1=false)
        @quick_evolution                = 1 # (0=true, 1=false)
        @name_on_showcases              = 0 # (0=true, 1=false)
    end

    def frame=(value)
        @frame = value
        setSystemFrame
    end

    def setSystemFrame
        windowSkinName = "Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[@frame]
        windowSkinName += "_dark" if darkMode?
        MessageConfig.pbSetSystemFrame(windowSkinName)
    end

    def textskin=(value)
        @textskin = value
        setSpeechFrame
    end

    def setSpeechFrame
        windowSkinName = "Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[@textskin]
        windowSkinName += "_dark" if darkMode?
        MessageConfig.pbSetSpeechFrame(windowSkinName)
    end
end

# Run on game start
if File.directory?(System.data_directory)
    if File.file?(Options.optionsFilePath)
        File.open(Options.optionsFilePath) do |file|
            $Options = Marshal.load(file)
        end
        echoln("Loaded the existing Options Tracker data file.")
    else
        $Options = Options.new
        $Options.storeOptions
        echoln("Creating a new Options Tracker.")
    end
else
    raise _INTL("Could not create game Options file.")
end

# STUB
class PokemonSystem; end;