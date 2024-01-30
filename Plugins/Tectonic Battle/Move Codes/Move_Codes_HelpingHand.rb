#===============================================================================
# Powers up the ally's attack this round by 1.5. (Helping Hand)
#===============================================================================
class PokeBattle_Move_PowerUpAllyMove < PokeBattle_HelpingMove
    def initialize(battle, move)
        super
        @helpingEffect = :HelpingHand
    end
end

#===============================================================================
# Powers up the ally's attack this round by making it crit. (Lucky Cheer)
#===============================================================================
class PokeBattle_Move_AllyAttackGuaranteedCrit < PokeBattle_HelpingMove
    def initialize(battle, move)
        super
        @helpingEffect = :LuckyCheer
    end

    def getEffectScore(user, target)
        score = super
        score *= 1.3
        return score
    end
end

#===============================================================================
# Gives an ally an extra move this turn. (Greater Glories)
#===============================================================================
class PokeBattle_Move_AllyGainsExtraMoveThisTurn < PokeBattle_HelpingMove
    def initialize(battle, move)
        super
        @helpingEffect = :GreaterGlories
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.fainted?
            @battle.pbDisplay(_INTL("But it failed, since the receiver of the help is gone!")) if show_message
            return true
        end
        if target.effectActive?(@helpingEffect)
            @battle.pbDisplay(_INTL("But it failed, since #{arget.pbThis(true)} is already being helped!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Powers up the ally's attack this round by boosting its damage and accuracy by 50%. (Spotting)
#===============================================================================
class PokeBattle_Move_PowerUpAndIncreaseAccOfAllyMove < PokeBattle_HelpingMove
    def initialize(battle, move)
        super
        @helpingEffect = :Spotting
    end

    def getEffectScore(user, target)
        score = super
    end
end