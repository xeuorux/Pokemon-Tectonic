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
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be supressed!"))
            end
            return true
        end
        if target.hasAbility?(:SIMPLE)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} already has the ability #{getAbilityName(:SIMPLE)}!"))
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
# Target's ability becomes Insomnia. (Worry Seed)
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
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be supressed!"))
            end
            return true
        end
        if target.hasAbility?(:INSOMNIA)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability is already #{getAbilityName(:INSOMNIA)}!"))
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
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s ability can't be changed!"))
            end
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.firstAbility
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have an ability!"))
            end
            return true
        end
        if user.hasAbility?(target.firstAbility)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the #{target.pbThis(true)} and #{user.pbThis(true)} have the same ability!"))
            end
            return true
        end
        if GameData::Ability.get(target.firstAbility).is_uncopyable_ability?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be copied!"))
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

#===============================================================================
# Target copies user's ability. (Entrainment)
#===============================================================================
class PokeBattle_Move_SetTargetAbilityToUserAbility < PokeBattle_Move
    def pbMoveFailed?(user, _targets, _show_message)
        unless user.firstAbility
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have an ability!"))
            return true
        end
        if GameData::Ability.get(user.firstAbility).is_uncopyable_ability?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s ability cannot be copied!"))
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.immutableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be supressed!"))
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
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have an ability!"))
            return true
        end
        if GameData::Ability.get(user.firstAbility).is_immutable_ability?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s ability cannot be changed!"))
            return true
        end
        if GameData::Ability.get(user.firstAbility).is_uncopyable_ability?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s ability cannot be copied!"))
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.firstAbility
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have an ability!"))
            end
            return true
        end
        if GameData::Ability.get(target.firstAbility).is_immutable_ability?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be supressed!"))
            end
            return true
        end
        if GameData::Ability.get(target.firstAbility).is_uncopyable_ability?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be copied!"))
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