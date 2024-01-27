#===============================================================================
# Heals user depending on the user's stockpile (X). Resets the stockpile to 0.
# Decreases the user's Defense and Special Defense by X steps each. (Swallow)
#===============================================================================
class PokeBattle_Move_114 < PokeBattle_HealingMove
    def healingMove?; return true; end

    def pbMoveFailed?(user, targets, show_message)
        return true if super
        unless user.effectActive?(:Stockpile)
            @battle.pbDisplay(_INTL("But it failed to swallow a thing!")) if show_message
            return true
        end
        return false
    end

    def healRatio(user)
        case [user.countEffect(:Stockpile), 1].max
        when 1
            return 1.0 / 2.0
        when 2
            return 1.0
        end
        return 0.0
    end

    def pbEffectGeneral(user)
        super
        @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!", user.pbThis))
        user.disableEffect(:Stockpile)
    end

    def getEffectScore(user, target)
        score = super
        score -= 20 * user.countEffect(:Stockpile)
        return score
    end

    def shouldHighlight?(user, _target)
        return user.effectAtMax?(:Stockpile)
    end
end