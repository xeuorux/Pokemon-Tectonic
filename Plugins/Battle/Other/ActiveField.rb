class PokeBattle_ActiveField
    class PokeBattle_ActiveField
    attr_accessor :effects
    attr_accessor :defaultWeather
    attr_accessor :weatherDuration
    attr_accessor :defaultTerrain
    attr_accessor :terrain
    attr_accessor :terrainDuration

    def initialize
      @effects = []
      @effects[PBEffects::AmuletCoin]      = false
      @effects[PBEffects::FairyLock]       = 0
      @effects[PBEffects::FusionBolt]      = false
      @effects[PBEffects::FusionFlare]     = false
      @effects[PBEffects::Gravity]         = 0
      @effects[PBEffects::HappyHour]       = false
      @effects[PBEffects::IonDeluge]       = false
      @effects[PBEffects::MagicRoom]       = 0
      @effects[PBEffects::MudSportField]   = 0
      @effects[PBEffects::PayDay]          = 0
      @effects[PBEffects::TrickRoom]       = 0
      @effects[PBEffects::WaterSportField] = 0
      @effects[PBEffects::WonderRoom]      = 0
	  @effects[PBEffects::Fortune]      = 0
      @defaultWeather  = :None
      @weather         = :None
      @weatherDuration = 0
      @defaultTerrain  = :None
      @terrain         = :None
      @terrainDuration = 0
    end
  end
  
  def terrain()
	eachBattler { |b| return :None if b.hasActiveAbility?([:EARTHLOCK]) }
	return @terrain
  end
end