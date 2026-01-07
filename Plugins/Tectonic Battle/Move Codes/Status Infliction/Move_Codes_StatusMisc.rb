#===============================================================================
# Burns, frostbites, or numbs the target. (Tri Attack, Triple Threat)
#===============================================================================
class PokeBattle_Move_NumbBurnOrFrostbiteTarget < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        case @battle.pbRandom(3)
        when 0 then target.applyBurn(user)      if target.canBurn?(user, false, self)
        when 1 then target.applyFrostbite(user) if target.canFrostbite?(user, false, self)
        when 2 then target.applyNumb(user)      if target.canNumb?(user, false, self)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        burnScore = getBurnEffectScore(user, target)
        frostBiteScore = getFrostbiteEffectScore(user, target)
        numbScore = getNumbEffectScore(user, target)
        return (burnScore + frostBiteScore + numbScore) / 3
    end
end

#===============================================================================
# Poisons, leeches, or waterlogs the target. (Chaos Wheel, Rolling Arsenal)
#===============================================================================
class PokeBattle_Move_PoisonWaterlogOrLeechTarget < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        case @battle.pbRandom(3)
        when 0 then target.applyPoison(user)	if target.canPoison?(user, true, self)
        when 1 then target.applyWaterlog(user)  if target.canWaterlog?(user, true, self)
        when 2 then target.applyLeeched(user)	if target.canLeech?(user, true, self)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        poisonScore = getPoisonEffectScore(user, target)
        waterlogScore = getWaterlogEffectScore(user, target)
        leechScore = getLeechEffectScore(user, target)
        return (poisonScore + waterlogScore + leechScore) / 3
    end
end

#===============================================================================
# Burns or frostbites the target, whichever hits the target's better base stat.
# (Diametric Breath)
#===============================================================================
class PokeBattle_Move_BurnOrFrostbiteTargetBasedOnHigherStat < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if !target.canBurn?(user, show_message, self) && !target.canFrostbite?(user, show_message, self)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} can neither be burned or frostbitten!", target.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        burnOrFrostbite(user, target)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        burnOrFrostbite(user, target)
    end

    def burnOrFrostbite(user, target)
        real_attack = target.pbAttack
        real_special_attack = target.pbSpAtk

        if target.canBurn?(user, false, self) && real_attack >= real_special_attack
            target.applyBurn(user)
        elsif target.canFrostbite?(user, false, self) && real_special_attack >= real_attack
            target.applyFrostbite(user)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        real_attack = target.pbAttack
        real_special_attack = target.pbSpAtk
        if target.canBurn?(user, false, self) && real_attack >= real_special_attack
            score += getBurnEffectScore(user, target)
        elsif target.canFrostbite?(user, false, self) && real_special_attack >= real_attack
            score += getFrostbiteEffectScore(user, target)
        end
        return score
    end
end

#===============================================================================
# Leeches or numbs the target, depending on how its speed compares to the user.
# (Mystery Seed)
#===============================================================================
class PokeBattle_Move_LeechTargetIfSlowerNumbTargetIfFaster < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if !target.canLeech?(user, false, self) && !target.canNumb?(user, false, self)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} can neither be leeched or numbed!", target.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        leechOrNumb(user, target)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        leechOrNumb(user, target)
    end

    def leechOrNumb(user, target)
        target_speed = target.pbSpeed
        user_speed = user.pbSpeed

        if target.canNumb?(user, false, self) && target_speed >= user_speed
            target.applyNumb(user)
        elsif target.canLeech?(user, false, self) && user_speed >= target_speed
            target.applyLeeched(user)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        target_speed = target.pbSpeed
        user_speed = user.pbSpeed

        if target.canNumb?(user, false, self) && target_speed >= user_speed
            return getNumbEffectScore(user, target)
        elsif target.canLeech?(user, false, self) && user_speed >= target_speed
            return getLeechEffectScore(user, target)
        end
        return 0
    end
end