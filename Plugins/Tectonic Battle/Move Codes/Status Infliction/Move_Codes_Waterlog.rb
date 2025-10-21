#===============================================================================
# Waterlogs the target.
#===============================================================================
class PokeBattle_Move_Waterlog < PokeBattle_WaterlogMove
end

# Empowered Waterlog
class PokeBattle_Move_EmpoweredWaterlog < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyWaterlog(user) if b.canWaterlog?(user, true, self)
        end
        transformType(user, :WATER)
    end
end

#===============================================================================
# Power is doubled if the target is using Dive. Hits some semi-invulnerable
# targets. (Surf)
#===============================================================================
class PokeBattle_Move_WaterlogTargetHitsDivers < PokeBattle_WaterlogMove
    def hitsDivingTargets?; return true; end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater") # Dive
        return baseDmg
    end

    def pbEffectAfterAllHits(user, target)
        if !target.damageState.unaffected && !target.damageState.protected && !target.damageState.missed && user.canGulpMissile?
            user.form = 2
            user.form = 1 if user.hp > (user.totalhp / 2)
            @battle.scene.pbChangePokemon(user, user.pokemon)
        end
    end

    def getEffectScore(user, _target)
        score = super
        if user.canGulpMissile?
          score += 50
        end
        return score
    end
end

# Empowered Surf
class PokeBattle_Move_653 < PokeBattle_Move_WaterlogTargetHitsDivers
    include EmpoweredMove
end

#===============================================================================
# Multi-hit move that can waterlog.
#===============================================================================
class PokeBattle_Move_HitTwoToFiveTimesWaterlog < PokeBattle_WaterlogMove
    include RandomHitable
end

#===============================================================================
# May cause the target to be waterlogged or to lower their Defense by two steps. (Hydro Fang)
#===============================================================================
class PokeBattle_Move_WaterlogTargetLowerTargetDef2 < PokeBattle_Move_StatusTargetLowerTargetDef2
    def initialize(battle, move)
        super
        @statusToApply = :WATERLOG
    end
end