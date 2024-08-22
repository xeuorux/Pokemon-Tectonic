#===============================================================================
# Increases the user's Defense and Special Defense by 2 steps each. Ups the
# user's stockpile by 1 (max. 2). (Stockpile)
#===============================================================================
class PokeBattle_Move_UserAddStockpileRaiseDefSpDef2 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.effectAtMax?(:Stockpile)
            @battle.pbDisplay(_INTL("{1} can't stockpile any more!", user.pbThis)) if show_message
            return true
        end
        return super
    end

    def pbEffectGeneral(user)
        user.incrementEffect(:Stockpile)
        super
    end

    def getEffectScore(user, target)
        score = super
        score += 20 if user.pbHasMoveFunction?("PowerDependsOnUserStockpile") # Spit Up
        score += 20 if user.pbHasMoveFunction?("HealUserDependingOnUserStockpile") # Swallow
        return score
    end
end

#===============================================================================
# Power is 150 multiplied by the user's stockpile (X). Resets the stockpile to
# 0. Decreases the user's Defense and Special Defense by X steps each. (Spit Up)
#===============================================================================
class PokeBattle_Move_PowerDependsOnUserStockpile < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.effectActive?(:Stockpile)
            @battle.pbDisplay(_INTL("But it failed to spit up a thing!")) if show_message
            return true
        end
        return false
    end

    def pbBaseDamage(_baseDmg, user, _target)
        return 150 * user.countEffect(:Stockpile)
    end

    def pbEffectAfterAllHits(user, target)
        return if user.fainted? || !user.effectActive?(:Stockpile)
        return if target.damageState.unaffected
        @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!", user.pbThis))
        return if @battle.pbAllFainted?(target.idxOwnSide)
        user.disableEffect(:Stockpile)
    end

    def getEffectScore(user, _target)
        return -20 * user.countEffect(:Stockpile)
    end

    def shouldHighlight?(user, _target)
        return user.effectAtMax?(:Stockpile)
    end
end

#===============================================================================
# Heals user depending on the user's stockpile (X). Resets the stockpile to 0.
# Decreases the user's Defense and Special Defense by X steps each. (Swallow)
#===============================================================================
class PokeBattle_Move_HealUserDependingOnUserStockpile < PokeBattle_HealingMove
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