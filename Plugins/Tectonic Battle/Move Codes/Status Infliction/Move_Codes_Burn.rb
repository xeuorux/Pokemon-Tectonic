#===============================================================================
# Burns the target.
#===============================================================================
class PokeBattle_Move_Burn < PokeBattle_BurnMove
end

#===============================================================================
# Burns the target. May cause the target to flinch. (Fire Fang)
#===============================================================================
class PokeBattle_Move_BurnFlinchTarget < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType, 10)
        return if chance == 0
        if @battle.pbRandom(100) < chance && target.canBurn?(user, false, self) && canApplyRandomAddedEffects?(user,target,true)
            target.applyBurn(user)
        end 
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 0.1 * getBurnEffectScore(user, target)
        score += 0.1 * getFlinchingEffectScore(60, user, target, self)
        return score
    end
end

#===============================================================================
# Burns target if target is a foe, or raises target's Speed by 4 steps an ally. (Destrier's Whim)
#===============================================================================
class PokeBattle_Move_RaiseAllySpd4OrBurnFoe < PokeBattle_Move
    def pbOnStartUse(user, targets)
        @buffing = false
        @buffing = !user.opposes?(targets[0]) if targets.length > 0
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if @buffing
            if target.substituted? && !ignoresSubstitute?(user)
                @battle.pbDisplay(_INTL("#{target.pbThis} is protected behind its substitute!")) if show_message
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