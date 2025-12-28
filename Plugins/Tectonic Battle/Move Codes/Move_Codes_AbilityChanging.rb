#===============================================================================
# Target's ability becomes Simple. (Simple Beam)
#===============================================================================
class PokeBattle_Move_SetTargetAbilityToSimple < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        unless GameData::Ability.exists?(:SIMPLE)
            @battle.pbDisplay(_INTL("But it failed, since the ability Simple doesn't exist!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.immutableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1}'s ability can't be supressed!", target.pbThis(true)))
            end
            return true
        end
        if target.hasAbility?(:SIMPLE)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} already has the ability {2}!", target.pbThis(true), getAbilityName(:SIMPLE)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.replaceAbility(:SIMPLE)
    end

    def getEffectScore(user, target)
        score = getSuppressAbilityEffectScore(user, target)
        score += user.opposes?(target) ? -20 : 20
        return score
    end
end

#===============================================================================
# Target's ability becomes Insomnia.
#===============================================================================
class PokeBattle_Move_SetTargetAbilityToInsomnia < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        unless GameData::Ability.exists?(:INSOMNIA)
            @battle.pbDisplay(_INTL("But it failed, since the ability Insomnia doesn't exist!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.immutableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1}'s ability can't be supressed!", target.pbThis(true)))
            end
            return true
        end
        if target.hasAbility?(:INSOMNIA)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1}'s ability is already {2}!", target.pbThis(true), getAbilityName(:INSOMNIA)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.replaceAbility(:INSOMNIA)
    end

    def getEffectScore(user, target)
        return getSuppressAbilityEffectScore(user, target)
    end
end

#===============================================================================
# User copies target's ability. (Role Play)
#===============================================================================
class PokeBattle_Move_SetUserAbilityToTargetAbility < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.immutableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1}'s ability can't be changed!", user.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.firstAbility
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} doesn't have an ability!", target.pbThis(true)))
            end
            return true
        end
        if user.hasAbility?(target.firstAbility)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the {1} and {2} have the same ability!", target.pbThis(true), user.pbThis(true)))
            end
            return true
        end
        if GameData::Ability.get(target.firstAbility).is_uncopyable_ability?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1}'s ability can't be copied!", target.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        replacementMsg = _INTL("{1} copied {2}'s {3}!",
            user.pbThis, target.pbThis(true), getAbilityName(target.firstAbility))
        user.replaceAbility(target.firstAbility, replacementMsg: replacementMsg)
    end

    def getEffectScore(user, target)
        return 0 if target.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        return 100 if user.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        return 50
    end
end

class PokeBattle_Move_EmpoweredRolePlay < PokeBattle_Move
    include EmpoweredMove
    
    def ignoresSubstitute?(_user); return true; end

    def pbEffectGeneral(user)
        super
        user.eachOpposing do |b|
            next unless b.firstAbility
            next if GameData::Ability.get(b.firstAbility).is_uncopyable_ability?
            @battle.pbDisplay(_INTL("{1} copies {2}'s ability!",user.pbThis,b.pbThis(true)))
            user.addAbility(b.firstAbility)
        end
    end  
end

#===============================================================================
# Target copies user's ability. (Entrainment)
#===============================================================================
class PokeBattle_Move_SetTargetAbilityToUserAbility < PokeBattle_Move
    def pbMoveFailed?(user, _targets, _show_message)
        unless user.firstAbility
            @battle.pbDisplay(_INTL("But it failed, since {1} doesn't have an ability!", user.pbThis(true)))
            return true
        end
        if GameData::Ability.get(user.firstAbility).is_uncopyable_ability?
            @battle.pbDisplay(_INTL("But it failed, since {1}'s ability cannot be copied!", user.pbThis(true)))
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.immutableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1}'s ability can't be supressed!", target.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        replacementMsg = _INTL("{1} acquired {2}!", target.pbThis, getAbilityName(user.firstAbility))
        target.replaceAbility(user.firstAbility, replacementMsg: replacementMsg)
    end

    def getEffectScore(user, target)
        score = 60
        if user.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
            if user.opposes?(target)
                score += 60
            else
                return 0
            end
        end
        return score
    end
end

#===============================================================================
# User and target swap abilities. (Skill Swap)
#===============================================================================
class PokeBattle_Move_UserTargetSwapAbilities < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, _show_message)
        unless user.firstAbility
            @battle.pbDisplay(_INTL("But it failed, since {1} doesn't have an ability!", user.pbThis(true)))
            return true
        end
        if GameData::Ability.get(user.firstAbility).is_immutable_ability?
            @battle.pbDisplay(_INTL("But it failed, since {1}'s ability cannot be changed!", user.pbThis(true)))
            return true
        end
        if GameData::Ability.get(user.firstAbility).is_uncopyable_ability?
            @battle.pbDisplay(_INTL("But it failed, since {1}'s ability cannot be copied!", user.pbThis(true)))
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.firstAbility
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} doesn't have an ability!", target.pbThis(true)))
            end
            return true
        end
        if GameData::Ability.get(target.firstAbility).is_immutable_ability?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1}'s ability can't be supressed!", target.pbThis(true)))
            end
            return true
        end
        if GameData::Ability.get(target.firstAbility).is_uncopyable_ability?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1}'s ability can't be copied!", target.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        showSplashes = user.opposes?(target)
        oldUserAbil   = user.firstAbility
        oldTargetAbil = target.firstAbility
        replacementMsg = _INTL("{1} swapped Abilities with its target!", user.pbThis)
        target.replaceAbility(oldUserAbil, showSplashes, user, replacementMsg: replacementMsg)
        user.replaceAbility(oldTargetAbil, showSplashes, target, replacementMsg: replacementMsg)
    end

    def getEffectScore(user, target)
        return 0 if target.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        score = 60
        score += 100 if user.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        return score
    end
end