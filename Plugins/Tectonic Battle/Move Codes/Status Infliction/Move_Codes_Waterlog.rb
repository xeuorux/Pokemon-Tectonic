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
# May cause the target to be waterlogged or to lower their Defense by two steps. (Hydro Fang, Aquatic Crunch)
#===============================================================================
class PokeBattle_Move_WaterlogTargetLowerTargetDef2 < PokeBattle_Move_StatusTargetLowerTargetDef2
    def initialize(battle, move)
        super
        @statusToApply = :WATERLOG
    end
end

#===============================================================================
# Waterlogs the target and applies Aqua Ring to the user. (Seaborne Sacrament)
#===============================================================================
class PokeBattle_Move_WaterlogTargetStartHealUserEachTurn < PokeBattle_WaterlogMove
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if !target.canWaterlog?(user, false, self) && user.effectActive?(:AquaRing)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} can't be waterlogged and {2} already has an Aqua Ring!", target.pbThis(true), user.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.applyWaterlog if target.canWaterlog?(user, false, self)
    end

    def pbEffectGeneral(user)
        return if damagingMove? && !spreadMove?
        user.applyEffect(:AquaRing) unless user.effectActive?(:AquaRing)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        targets.each do |b|
            @battle.pbAnimation(:SOAK, user, [b]) if b.canWaterlog?(user, false, self)
        end
        @battle.pbAnimation(:AQUARING, user, nil) unless user.effectActive?(:AquaRing)
    end

    def pbAdditionalEffect(user, _target)
        super
        return if spreadMove?
        user.applyEffect(:AquaRing) unless user.effectActive?(:AquaRing)
    end

    def getEffectScore(user, target)
        return getAquaRingEffectScore(user) 
    end
end