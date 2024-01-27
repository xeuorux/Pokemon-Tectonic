#===============================================================================
# User flees from battle. Switches out, in trainer battles. (Teleport)
#===============================================================================
class PokeBattle_Move_0EA < PokeBattle_Move
    def switchOutMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if @battle.wildBattle? && !@battle.bossBattle?
            unless @battle.pbCanRun?(user.index)
                @battle.pbDisplay(_INTL("But it failed, since you can't run from this battle!")) if show_message
                return true
            end
        else
            unless @battle.pbCanChooseNonActive?(user.index)
                if show_message
                    @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no party members to replace it!"))
                end
                return true
            end
        end
        return false
    end

    def pbEffectGeneral(user)
        if @battle.wildBattle? && !@battle.bossBattle?
            @battle.pbDisplay(_INTL("{1} fled from battle!", user.pbThis))
            @battle.decision = 3 # Escaped
        else
            return if user.fainted?
            return unless @battle.pbCanChooseNonActive?(user.index)
            @battle.pbDisplay(_INTL("{1} teleported, and went back to {2}!", user.pbThis,
              @battle.pbGetOwnerName(user.index)))
            @battle.pbPursuit(user.index)
            return if user.fainted?
            newPkmn = @battle.pbGetReplacementPokemonIndex(user.index) # Owner chooses
            return if newPkmn < 0
            @battle.pbRecallAndReplace(user.index, newPkmn)
            @battle.pbClearChoice(user.index) # Replacement Pokémon does nothing this round
            @battle.moldBreaker = false
            user.pbEffectsOnSwitchIn(true)
        end
    end

    def getEffectScore(user, target)
        return getSwitchOutEffectScore(user)
    end
end

#===============================================================================
# User switches out. Various effects affecting the user are passed to the
# replacement. (Baton Pass)
#===============================================================================
class PokeBattle_Move_0ED < PokeBattle_Move
    def switchOutMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.pbCanChooseNonActive?(user.index)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no party allies to replace it!"))
            end
            return true
        end
        return false
    end

    def pbEndOfMoveUsageEffect(user, _targets, numHits, switchedBattlers)
        return if user.fainted? || numHits == 0
        return unless @battle.pbCanChooseNonActive?(user.index)
        @battle.pbPursuit(user.index)
        return if user.fainted?
        newPkmn = @battle.pbGetReplacementPokemonIndex(user.index) # Owner chooses
        return if newPkmn < 0
        @battle.pbRecallAndReplace(user.index, newPkmn, false, true)
        @battle.pbClearChoice(user.index) # Replacement Pokémon does nothing this round
        @battle.moldBreaker = false
        switchedBattlers.push(user.index)
        user.pbEffectsOnSwitchIn(true)
    end

    def getEffectScore(user, target)
        total = 0
        GameData::Stat.each_battle { |s| total += user.steps[s.id] }
        return 0 if total <= 0 || user.firstTurn?
        score = total * 10
        score += 30 unless user.hasDamagingAttack?
        score += getSwitchOutEffectScore(user, false)
        return score
    end
end

#===============================================================================
# After inflicting damage, user switches out. Ignores trapping moves.
# (U-turn, Volt Switch, Flip Turn)
#===============================================================================
class PokeBattle_Move_0EE < PokeBattle_Move
    def switchOutMove?; return true; end

    def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
        return if user.fainted? || numHits == 0
        switchOutUser(user,switchedBattlers)
    end

    def getEffectScore(user, target)
        return getSwitchOutEffectScore(user)
    end
end