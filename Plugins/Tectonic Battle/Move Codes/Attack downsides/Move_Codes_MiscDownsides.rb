
#===============================================================================
# User loses their Fire type. Fails if user is not Fire-type. (Burn Up)
#===============================================================================
class PokeBattle_Move_162 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.pbHasType?(:FIRE)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} isn't Fire-type!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAfterAllHits(user, _target)
        user.applyEffect(:BurnUp)
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# User loses their Ice type. Fails if user is not Ice-type. (Sublimate)
#===============================================================================
class PokeBattle_Move_51B < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.pbHasType?(:ICE)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is not Ice-type!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAfterAllHits(user, _target)
        user.applyEffect(:Sublimate)
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# Poison's the user, even if normally immune to poison. (Grime Grapple)
#===============================================================================
class PokeBattle_Move_514 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        return if user.poisoned?
        user.applyPoison(nil, _INTL("{1} is poisoned by the grime! {2}",
           user.pbThis, POISONED_EXPLANATION), false)
    end

    def getEffectScore(user, _target)
        return 0 if user.poisoned?
        return -getPoisonEffectScore(user, user, ignoreCheck: true)
    end
end