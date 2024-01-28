#===============================================================================
# Resets all target's stat steps to 0. (Clear Smog)
#===============================================================================
class PokeBattle_Move_050 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        if target.damageState.calcDamage > 0 && !target.damageState.substitute && target.hasAlteredStatSteps?
            target.pbResetStatSteps
            @battle.pbDisplay(_INTL("{1}'s stat changes were removed!", target.pbThis))
        end
    end

    def getTargetAffectingEffectScore(_user, target)
        score = 0
        if !target.substituted? && target.hasAlteredStatSteps?
            GameData::Stat.each_battle do |s|
                score += target.steps[s.id] * 10
            end
        end
        return score
    end
end

#===============================================================================
# User and target swap all their stat steps. (Heart Swap)
#===============================================================================
class PokeBattle_Move_054 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbEffectAgainstTarget(user, target)
        GameData::Stat.each_battle do |s|
            user.steps[s.id], target.steps[s.id] = target.steps[s.id], user.steps[s.id]
        end
        @battle.pbDisplay(_INTL("{1} switched stat changes with the target!", user.pbThis))
    end

    def getEffectScore(user, target)
        score = 0
        userSteps = 0
        targetSteps = 0
        GameData::Stat.each_battle do |s|
            userSteps += user.steps[s.id]
            targetSteps += target.steps[s.id]
        end
        score += (targetSteps - userSteps) * 10
        return score
    end
end

#===============================================================================
# User copies the target's stat steps. (Psych Up)
#===============================================================================
class PokeBattle_Move_055 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbEffectAgainstTarget(user, target)
        GameData::Stat.each_battle { |s| user.steps[s.id] = target.steps[s.id] }
        # Copy critical hit chance raising effects
        target.eachEffect do |effect, value, data|
            user.effects[effect] = value if data.critical_rate_buff?
        end
        @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!", user.pbThis, target.pbThis(true)))
    end

    def getEffectScore(user, target)
        score = 0
        GameData::Stat.each_battle do |s|
            stepdiff = target.steps[s.id] - user.steps[s.id]
            score += stepdiff * 10
        end
        return score
    end
end

#===============================================================================
# User gains stat steps equal to each of the target's positive stat steps,
# and target's positive stat steps become 0, before damage calculation.
# (Spectral Thief, Scam)
#===============================================================================
class PokeBattle_Move_15D < PokeBattle_Move
    def statStepStealingMove?; return true; end
    
    def ignoresSubstitute?(_user); return true; end

    def pbCalcDamage(user, target, numTargets = 1)
        if target.hasRaisedStatSteps?
            pbShowAnimation(@id, user, target, 1) # Stat step-draining animation
            @battle.pbDisplay(_INTL("{1} stole the target's boosted stats!", user.pbThis))
            showAnim = true
            GameData::Stat.each_battle do |s|
                next if target.steps[s.id] <= 0
                if user.pbCanRaiseStatStep?(s.id, user,
self) && user.pbRaiseStatStep(s.id, target.steps[s.id], user, showAnim)
                    showAnim = false
                end
                target.steps[s.id] = 0
            end
        end
        super
    end

    def getEffectScore(_user, target)
        score = 0
        GameData::Stat.each_battle do |s|
            next if target.steps[s.id] <= 0
            score += target.steps[s.id] * 20
        end
        return score
    end

    def shouldHighlight?(_user, target)
        return target.hasRaisedStatSteps?
    end
end

#===============================================================================
# Swaps the user's Sp Attack and Sp Def stats. (Energy Trick)
#===============================================================================
class PokeBattle_Move_056 < PokeBattle_Move
    def pbEffectGeneral(user)
        baseSpAtk = user.base_special_attack
        baseSpDef = user.base_special_defense
        user.effects[:BaseSpecialAttack] = baseSpDef
        user.effects[:BaseSpecialDefense] = baseSpAtk
        user.effects[:EnergyTrick] = !user.effects[:EnergyTrick]
        @battle.pbDisplay(_INTL("{1} switched its base Sp. Atk and Sp. Def!", user.pbThis))
    end

    def getEffectScore(user, _target)
        return 0 if user.effectActive?(:EnergyTrick) # No flip-flopping
        baseSpAtk = user.base_special_attack
        baseSpDef = user.base_special_defense
        return 100 if baseSpDef > baseSpAtk # Prefer a higher Attack
        return 0
    end
end

#===============================================================================
# Swaps the user's Attack and Defense stats. (Power Trick)
#===============================================================================
class PokeBattle_Move_057 < PokeBattle_Move
    def pbEffectGeneral(user)
        baseAttack = user.base_attack
        baseDefense = user.base_defense
        user.effects[:BaseAttack] = baseDefense
        user.effects[:BaseDefense] = baseAttack
        user.effects[:PowerTrick] = !user.effects[:PowerTrick]
        @battle.pbDisplay(_INTL("{1} switched its base Attack and Defense!", user.pbThis))
    end

    def getEffectScore(user, _target)
        return 0 if user.effectActive?(:PowerTrick) # No flip-flopping
        baseAttack = user.base_attack
        baseDefense = user.base_defense
        return 100 if baseDefense > baseAttack # Prefer a higher Attack
        return 0
    end
end

#===============================================================================
# Averages the user's and target's base Attack.
# Averages the user's and target's base Special Attack. (Power Split)
#===============================================================================
class PokeBattle_Move_058 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        newAtk   = ((user.base_attack + target.base_attack) / 2).floor
        newSpAtk = ((user.base_special_attack + target.base_special_attack) / 2).floor
        user.applyEffect(:BaseAttack,newAtk)
        target.applyEffect(:BaseAttack,newAtk)
        user.applyEffect(:BaseSpecialAttack,newSpAtk)
        target.applyEffect(:BaseSpecialAttack,newSpAtk)
        @battle.pbDisplay(_INTL("{1} averaged its base attacking stats with the target!", user.pbThis))
    end

    def getEffectScore(user, target)
        userAttack = user.base_attack
        userSpAtk = user.base_special_attack
        targetAttack = target.base_attack
        targetSpAtk = target.base_special_attack
        if userAttack < targetAttack && userSpAtk < targetSpAtk
            return 120
        elsif userAttack + userSpAtk < targetAttack + targetSpAtk
            return 80
        else
            return 0
        end
    end
end

#===============================================================================
# Averages the user's and target's base Defense.
# Averages the user's and target's base Special Defense. (Guard Split)
#===============================================================================
class PokeBattle_Move_059 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        newDef   = ((user.base_defense + target.base_defense) / 2).floor
        newSpDef = ((user.base_special_defense + target.base_special_defense) / 2).floor
        user.applyEffect(:BaseDefense,newDef)
        target.applyEffect(:BaseDefense,newDef)
        user.applyEffect(:BaseSpecialDefense,newSpDef)
        target.applyEffect(:BaseSpecialDefense,newSpDef)
        @battle.pbDisplay(_INTL("{1} averaged its base defensive stats with the target!", user.pbThis))
    end

    def getEffectScore(user, target)
        userDefense = user.base_defense
        userSpDef = user.base_special_defense
        targetDefense = target.base_defense
        targetSpDef = target.base_special_defense
        if userDefense < targetDefense && userSpDef < targetSpDef
            return 120
        elsif userDefense + userSpDef < targetDefense + targetSpDef
            return 80
        else
            return 0
        end
    end
end

#===============================================================================
# Lower's the target's Attack by 1 step. If so, it raises the user's Attack by 1 step. (Blood Bite)
#===============================================================================
class PokeBattle_Move_0A7 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 1]
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        if target.tryLowerStat(@statDown[0], user, increment: @statDown[1], move: self)
            user.tryRaiseStat(@statDown[0], user, increment: @statDown[1], move: self)
        end
    end
end

#===============================================================================
# Lower's the target's Sp. Atk by 1 step. If so, it raises the user's Sp. Atk by 1 step.
#===============================================================================
class PokeBattle_Move_0A8 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 1]
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        if target.tryLowerStat(@statDown[0], user, increment: @statDown[1], move: self)
            user.tryRaiseStat(@statDown[0], user, increment: @statDown[1], move: self)
        end
    end
end

#===============================================================================
# User and the target copies eachothers highest stat steps. (Sharing Smiles)
#===============================================================================
class PokeBattle_Move_014 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        stepInfo = calculateStepInfo(user, target)
        if stepInfo[0].nil?
            @battle.pbDisplay(_INTL("But it failed, since {1} doesn't have any positive stat steps!", user.pbThis(true))) if show_message
            return true
        end
        if stepInfo[2].nil?
            @battle.pbDisplay(_INTL("But it failed, since {1} doesn't have any positive stat steps!", target.pbThis(true))) if show_message
            return true
        end
        if !user.pbCanRaiseStatStep?(stepInfo[2], user, self, false) && !target.pbCanRaiseStatStep?(stepInfo[0], user, self, false)
            @battle.pbDisplay(_INTL("But it failed, since {1} and {2} can't raise the other's highest stat step!", user.pbThis(true), target.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def calculateStepInfo(user,target)
        userHighestStat = nil
        userHighestStatStep = 0
        targetHighestStat = nil
        targetHighestStatStep = 0
        GameData::Stat.each_battle { |s|
            if user.steps[s.id] > userHighestStatStep
                userHighestStatStep = user.steps[s.id]
                userHighestStat = s.id
            end
            if target.steps[s.id] > targetHighestStatStep
                targetHighestStatStep = target.steps[s.id]
                targetHighestStat = s.id
            end
        }
        return [userHighestStat,userHighestStatStep,targetHighestStat,targetHighestStatStep]
    end

    def pbEffectAgainstTarget(user, target)
        stepInfo = calculateStepInfo(user, target)
        @battle.pbDisplay(_INTL("{1} and {2} shared their highest stat steps!", user.pbThis, target.pbThis(true)))
        user.tryRaiseStat(stepInfo[0], user, move: self, increment: stepInfo[1])
        target.tryRaiseStat(stepInfo[2], user, move: self, increment: stepInfo[3])
    end

    def getEffectScore(user, target)
        stepInfo = calculateStepInfo(user, target)
        score = 0
        score += getMultiStatUpEffectScore([stepInfo[0],stepInfo[1]], user, user)
        score += getMultiStatUpEffectScore([stepInfo[2],stepInfo[3]], user, target)
        return score
    end
end