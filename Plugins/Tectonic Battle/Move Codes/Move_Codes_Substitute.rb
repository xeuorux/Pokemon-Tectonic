#===============================================================================
# User turns 1/4 of max HP into a substitute. (Substitute)
#===============================================================================
class PokeBattle_Move_UserMakeSubstitute < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.substituted?
            @battle.pbDisplay(_INTL("{1} already has a substitute!", user.pbThis)) if show_message
            return true
        end

        if user.hp <= user.getSubLife
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} does not have enough HP left to make a substitute!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.createSubstitute
    end

    def getEffectScore(user, _target)
        score = getSubstituteEffectScore(user)
        score += getHPLossEffectScore(user, 0.25)
        return score
    end
end

#===============================================================================
# Forces the target to use a substitute (Doll Stitch)
#===============================================================================
class PokeBattle_Move_UserOrTargetMakesSubstitute < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        @battle.forceUseMove(target, :SUBSTITUTE)
    end
end