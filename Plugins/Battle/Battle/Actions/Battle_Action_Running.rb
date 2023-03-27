class PokeBattle_Battle
    #=============================================================================
    # Running from battle
    #=============================================================================
    def pbCanRun?(idxBattler)
        return false if trainerBattle? || bossBattle? # Boss battle
        battler = @battlers[idxBattler]
        return false if !@canRun && !battler.opposes?
        return true if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
        battler.eachActiveAbility do |ability|
            return true if BattleHandlers.triggerRunFromBattleAbility(ability, battler)
        end   
        battler.eachActiveItem do |item|
            return true if BattleHandlers.triggerRunFromBattleItem(item, battler)
        end                       
        battler.eachEffectAllLocations(true) do |_effect, _value, data|
            return false if data.trapping?
        end
        return true
    end

    # Return values:
    # -1: Failed fleeing
    #  0: Wasn't possible to attempt fleeing, continue choosing action for the round
    #  1: Succeeded at fleeing, battle will end
    # duringBattle is true for replacing a fainted Pokémon during the End Of Round
    # phase, and false for choosing the Run command.
    def pbRun(idxBattler, duringBattle = false)
        battler = @battlers[idxBattler]
        if battler.opposes?
            return 0 if trainerBattle?
            @choices[idxBattler][0] = :Run
            @choices[idxBattler][1] = 0
            @choices[idxBattler][2] = nil
            return -1
        end
        # Fleeing from trainer battles or boss battles
        if trainerBattle? || bossBattle?
            if debugControl
                if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
                    @decision = 1
                    return 1
                elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
                    @decision = 2
                    return 1
                end
            elsif pbDisplayConfirmSerious(_INTL("Would you like to forfeit the match and quit now?"))
                pbSEPlay("Battle flee")
                if @internalBattle
                    @decision = 2
                else
                    @decision = 3
                end
                return 1
            end
            return 0
        end
        # Fleeing from wild battles
        if debugControl
            pbSEPlay("Battle flee")
            pbDisplayPaused(_INTL("You got away safely!"))
            @decision = 3
            return 1
        end
        unless @canRun
            pbDisplayPaused(_INTL("You can't escape!"))
            return 0
        end

        pbSEPlay("Battle flee")
        pbDisplayPaused(_INTL("You got away safely!"))
        @decision = 3
        return 1
    end
end
