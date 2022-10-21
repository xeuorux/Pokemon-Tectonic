class PokeBattle_ActiveSide
    attr_accessor :effects

    def initialize
      @effects = {}
      @effects[PBEffects::AuroraVeil]         = 0
      @effects[PBEffects::CraftyShield]       = false
      @effects[PBEffects::EchoedVoiceCounter] = 0
      @effects[PBEffects::EchoedVoiceUsed]    = false
      @effects[PBEffects::LastRoundFainted]   = -1
      @effects[PBEffects::LightScreen]        = 0
      @effects[PBEffects::LuckyChant]         = 0
      @effects[PBEffects::MatBlock]           = false
      @effects[PBEffects::Mist]               = 0
      @effects[PBEffects::QuickGuard]         = false
      @effects[PBEffects::Rainbow]            = 0
      @effects[PBEffects::Reflect]            = 0
      @effects[PBEffects::Round]              = false
      @effects[PBEffects::Safeguard]          = 0
      @effects[PBEffects::SeaOfFire]          = 0
      @effects[PBEffects::Spikes]             = 0
      @effects[PBEffects::StealthRock]        = false
      @effects[PBEffects::StickyWeb]          = false
      @effects[PBEffects::Swamp]              = 0
      @effects[PBEffects::Tailwind]           = 0
      @effects[PBEffects::ToxicSpikes]        = 0
	  @effects[PBEffects::FlameSpikes]        = 0
      @effects[PBEffects::FrostSpikes]        = 0
      @effects[PBEffects::WideGuard]          = false
      @effects[PBEffects::EmpoweredEmbargo]   = false
      @effects[PBEffects::Bulwark]            = false
    end
end