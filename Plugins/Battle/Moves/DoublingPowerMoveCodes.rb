class PokeBattle_DoublingMove < PokeBattle_Move
    def pbChangeUsageCounters(user,specialUsage)
        oldVal = user.effects[@usageCountEffect]
        super
        user.effects[@usageCountEffect] = [oldVal + 1,4].min
    end
  
    def pbBaseDamage(baseDmg,user,target)
        return baseDmg<<(user.effects[@usageCountEffect]-1)
    end
end

#===============================================================================
# Power doubles for each consecutive use. (FuryCutter)
#===============================================================================
class PokeBattle_Move_091 < PokeBattle_DoublingMove
    def initialize(battle, move)
        super
        @usageCountEffect = PBEffects::FuryCutter
    end
end

#===============================================================================
# Power doubles for each consecutive use. (Ice Ball)
#===============================================================================
class PokeBattle_Move_543 < PokeBattle_DoublingMove
    def initialize(battle, move)
        super
        @usageCountEffect = PBEffects::IceBall
    end
end
  
#===============================================================================
# Power doubles for each consecutive use. (Rollout)
#===============================================================================
class PokeBattle_Move_544 < PokeBattle_DoublingMove
    def initialize(battle, move)
        super
        @usageCountEffect = PBEffects::RollOut
    end
end