class PokeBattle_ActivePosition
    attr_accessor :effects
  
    def initialize
      @effects = {}
      @effects[PBEffects::FutureSightCounter]        = 0
      @effects[PBEffects::FutureSightMove]           = nil
      @effects[PBEffects::FutureSightUserIndex]      = -1
      @effects[PBEffects::FutureSightUserPartyIndex] = -1
      @effects[PBEffects::HealingWish]               = false
      @effects[PBEffects::LunarDance]                = false
      @effects[PBEffects::Wish]                      = 0
      @effects[PBEffects::WishAmount]                = 0
      @effects[PBEffects::WishMaker]                 = -1
      @effects[PBEffects::Refuge]                    = false
      @effects[PBEffects::RefugeMaker]               = -1
    end
  end