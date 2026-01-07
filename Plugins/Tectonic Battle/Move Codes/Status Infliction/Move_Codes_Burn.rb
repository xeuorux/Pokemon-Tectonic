#===============================================================================
# Burns the target.
#===============================================================================
class PokeBattle_Move_Burn < PokeBattle_BurnMove
end

#===============================================================================
# May cause the target to be burned or to lower their Defense by two steps. (Fire Fang, Searing Crunch)
#===============================================================================
class PokeBattle_Move_BurnTargetLowerTargetDef2 < PokeBattle_Move_StatusTargetLowerTargetDef2
    def initialize(battle, move)
        super
        @statusToApply = :BURN
    end
end

#===============================================================================
# Burns target if target is a foe, or raises target's Speed by 4 steps an ally.
#===============================================================================
class PokeBattle_Move_RaiseAllySpd4OrBurnFoe < PokeBattle_Move
    def pbOnStartUse(user, targets)
        @buffing = false
        @buffing = !user.opposes?(targets[0]) if targets.length > 0
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if @buffing
            if target.substituted? && !ignoresSubstitute?(user)
                @battle.pbDisplay(_INTL("{1} is protected behind its substitute!", target.pbThis)) if show_message
                return true
            end
        else
            return true unless target.canBurn?(user, show_message, self)
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        if @buffing
            target.tryRaiseStat(:SPEED, user, move: self)
        else
            target.applyBurn(user)
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @buffing
            id = :AGILITY
        end
        super
    end

    def getTargetAffectingEffectScore(user, target)
        if user.opposes?(target)
            return getBurnEffectScore(user, target)
        else
            return getMultiStatUpEffectScore([:SPEED,4])
        end
    end
end

#===============================================================================
# If a Pokémon attacks the user with a physical move before it uses this move, the
# attacker is burned. (Beak Blast)
#===============================================================================
class PokeBattle_Move_BurnAttackerBeforeUserActs < PokeBattle_Move
    def pbDisplayChargeMessage(user)
        user.applyEffect(:BeakBlast)
    end

    def getTargetAffectingEffectScore(user, target)
        if target.hasPhysicalAttack?
            return getBurnEffectScore(user, target) / 2
        else
            return 0
        end
    end
end

#===============================================================================
# Target is burned if in eclipse. (Calamitous Slash)
#===============================================================================
class PokeBattle_Move_BurnTargetIfInEclipse < PokeBattle_BurnMove
    def pbAdditionalEffect(user, target)
        return unless @battle.eclipsed?
        super
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless @battle.eclipsed?
        super
    end
end

# Empowered Ignite
class PokeBattle_Move_EmpoweredIgnite < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyBurn(user) if b.canBurn?(user, true, self)
        end
        transformType(user, :FIRE)
    end
end

#===============================================================================
# Multi-hit move that can burn.
#===============================================================================
class PokeBattle_Move_HitTwoToFiveTimesBurn < PokeBattle_BurnMove
    include RandomHitable
end

#===============================================================================
# Burns the target and add the Fire-type to it. (Evernal Flux)
#===============================================================================
class PokeBattle_Move_BurnAddFireType < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if !target.canBurn?(_user, false, self) && !target.canChangeTypeTo?(:FIRE)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} can't be burned or gain Fire-type!", target.pbThis(true)))
            end
        end 
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        if target.canBurn?(_user, false, self)
            target.applyBurn(_user)
        end
        if target.canChangeTypeTo?(:FIRE)
            target.applyEffect(:Type3, :FIRE)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = getBurnEffectScore(user, target)
        score += 60
        return score
    end
end