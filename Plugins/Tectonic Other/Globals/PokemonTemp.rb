#===============================================================================
# Temporary data which is not saved and which is erased when a game restarts.
#===============================================================================
class PokemonTemp
    attr_accessor :menuLastChoice
    attr_accessor :keyItemCalling
    attr_accessor :hiddenMoveEventCalling
    attr_accessor :bicycleCalling 
    attr_accessor :begunNewGame
    attr_accessor :miniupdate
    attr_accessor :waitingTrainer
    attr_accessor :darknessSprite
    attr_accessor :lastbattle
    attr_accessor :flydata
    attr_accessor :surfJump
    attr_accessor :endSurf
    attr_accessor :forceSingleBattle
    attr_accessor :encounterTriggered
    attr_accessor :encounterType
    attr_accessor :evolutionLevels
    attr_writer   :dependentEvents

    # Overworld trackers
    attr_accessor :batterywarning
    attr_accessor :cueBGM
    attr_accessor :cueFrames

    # GameData caches
    attr_accessor :townMapData
    attr_accessor :phoneData
    attr_accessor :speciesShadowMovesets
    attr_accessor :regionalDexes
    attr_accessor :battleAnims
    attr_accessor :moveToAnim
    attr_accessor :mapInfos
    
    # Dexnav
    attr_accessor :navigationRow
    attr_accessor :navigationColumn
    attr_accessor :currentDexSearch
  
    def initialize
      @menuLastChoice         = 0
      @keyItemCalling         = false
      @hiddenMoveEventCalling = false
      @begunNewGame           = false
      @miniupdate             = false
      @forceSingleBattle      = false
    end

    def dependentEvents
        @dependentEvents ||= DependentEvents.new
        return @dependentEvents
    end

    def battleRules
      @battleRules = {} if !@battleRules
      return @battleRules
    end

    def clearBattleRules
      self.battleRules.clear
    end

    def recordBattleRule(rule,var=nil)
      rules = self.battleRules
      case rule.to_s.downcase
      when "single", "1v1", "1v2", "2v1", "1v3", "3v1",
          "double", "2v2", "2v3", "3v2", "triple", "3v3"
        rules["size"] = rule.to_s.downcase
      when "canlose"                then rules["canLose"]        = true
      when "cannotlose"             then rules["canLose"]        = false
      when "canrun"                 then rules["canRun"]         = true
      when "cannotrun"              then rules["canRun"]         = false
      when "roamerflees"            then rules["roamerFlees"]    = true
      when "noexp"                  then rules["expGain"]        = false
      when "nomoney"                then rules["moneyGain"]      = false
      when "switchstyle"            then rules["switchStyle"]    = true
      when "setstyle"               then rules["switchStyle"]    = false
      when "anims"                  then rules["battleAnims"]    = true
      when "noanims"                then rules["battleAnims"]    = false
      when "terrain"
        terrain_data = GameData::BattleTerrain.try_get(var)
        rules["defaultTerrain"] = (terrain_data) ? terrain_data.id : nil
      when "weather"
        weather_data = GameData::BattleWeather.try_get(var)
        rules["defaultWeather"] = (weather_data) ? weather_data.id : nil
      when "environment", "environ"
        environment_data = GameData::Environment.try_get(var)
        rules["environment"] = (environment_data) ? environment_data.id : nil
      when "backdrop", "battleback" then rules["backdrop"]       = var
      when "base"                   then rules["base"]           = var
      when "outcome", "outcomevar"  then rules["outcomeVar"]     = var
      when "nopartner"              then rules["noPartner"]      = true
      when "randomorder";           then rules["randomOrder"]    = true
      when "turnstosurvive";        then rules["turnsToSurvive"] = var
      when "autotesting"            then rules["autotesting"]    = true
      when "playerambush"           then rules["playerambush"]   = true
      when "foeambush"              then rules["foeambush"]      = true
      when "lanetargeting"          then rules["lanetargeting"]   = true
      when "doubleshift"           then rules["doubleshift"]   = true
      else
        raise _INTL("Battle rule \"{1}\" does not exist.", rule)
      end
    end

    def dragonFlames
      @dragonFlames = [] if @dragonFlames.nil?
      return @dragonFlames
  end
end
  