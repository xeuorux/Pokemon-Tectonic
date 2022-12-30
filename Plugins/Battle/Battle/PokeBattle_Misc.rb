class PokeBattle_Battle
    def pbRandom(x); return rand(x); end

    #=============================================================================
    # Information about the type and size of the battle
    #=============================================================================
    def wildBattle?;    return @opponent.nil?;  end
    def trainerBattle?; return !@opponent.nil?; end

    # Sets the number of battler slots on each side of the field independently.
    # For "1v2" names, the first number is for the player's side and the second
    # number is for the opposing side.
    def setBattleMode(mode)
        @sideSizes =
            case mode
            when "triple", "3v3" then [3, 3]
            when "3v2"           then [3, 2]
            when "3v1"           then [3, 1]
            when "2v3"           then [2, 3]
            when "double", "2v2" then [2, 2]
            when "2v1"           then [2, 1]
            when "1v3"           then [1, 3]
            when "1v2"           then [1, 2]
            else                      [1, 1] # Single, 1v1 (default)
            end
    end

    def singleBattle?
        return pbSideSize(0) == 1 && pbSideSize(1) == 1
    end

    def pbSideSize(index)
        return @sideSizes[index % 2]
    end

    def maxBattlerIndex
        return (pbSideSize(0) > pbSideSize(1)) ? (pbSideSize(0) - 1) * 2 : pbSideSize(1) * 2 - 1
    end

    def bossBattle?
        return bossBattle
    end

    def roomActive?
        @field.effects.each do |effect, _value|
            effectData = GameData::BattleEffect.get(effect)
            return true if effectData.is_room?
        end
        return false
    end

    def curseActive?(curseID)
        return @curses.include?(curseID)
    end

    def pbCheckNeutralizingGas(battler = nil)
        # Battler = the battler to switch out.
        # Should be specified when called from pbAttackPhaseSwitch
        # Should be nil when called from pbEndOfRoundPhase
        return unless @field.effectActive?(:NeutralizingGas)
        return if battler && !battler.hasActiveNeutralizingGas?
        gasActive = false
        eachBattler do |b|
            next if !b || b.fainted?
            next if battler && b.index == battler.index
            # if specified, the battler will switch out, so don't consider it.
            # neutralizing gas can be blocked with gastro acid, ending the effect.
            if b.hasActiveNeutralizingGas?
                gasActive = true
                break
            end
        end
        unless gasActive
            @field.disableEffect(:NeutralizingGas)
            pbPriority(true).each do |b|
                next if battler && b.index == battler.index
                b.pbEffectsOnSwitchIn
            end
        end
    end

    def pbCheckAlliedAbility(abil, idxBattler = 0, nearOnly = false)
        eachSameSideBattler(idxBattler) do |b|
            next if nearOnly && !b.near?(idxBattler)
            return b if b.hasActiveAbility?(abil)
        end
        return nil
    end

    def useEmpoweredStatusMoves
        # Have bosses use empowered moves if appropriate
        @battlers.each do |b|
            next unless b
            next unless b.boss?
            avatarData = GameData::Avatar.get(b.species.to_sym)
            next if b.avatarPhase == avatarData.num_phases
            hpFraction = 1 - (b.avatarPhase.to_f / avatarData.num_phases.to_f)
            next if b.hp > b.totalhp * hpFraction
            usedEmpoweredMove = false
            b.eachMoveWithIndex do |move, index|
                next if move.damagingMove?
                next unless move.empoweredMove?
                next if move.pp < 1
                pbDisplayPaused(_INTL("A great energy rises up from inside {1}!", b.pbThis(true)))
                b.lastRoundMoved = 0
                b.pbUseMove([:UseMove, index, move, -1, 0])
                usedEmpoweredMove = true
            end
            # Swap to post-empowerment moveset
            next unless usedEmpoweredMove
            b.avatarPhase += 1
            movesetToAssign = avatarData.arrayOfMoveSets[b.avatarPhase - 1]
            echoln("ERROR: Unable to change moveset.") if movesetToAssign.nil?
            b.assignMoveset(movesetToAssign)
            b.primevalTimer = 0
            b.indicesTargetedLastRound = []
            @scene.pbRefresh
        end
    end

    # moveIDOrIndex is either the index of the move on the user's move list (Integer)
    # or it's the ID of the move to be used (Symbol)
    def forceUseMove(forcedMoveUser, moveIDOrIndex, target = -1, specialUsage = true, usageMessage = nil, moveUsageEffect = nil, showAbilitySplash = false)
        oldLastRoundMoved = forcedMoveUser.lastRoundMoved
        if specialUsage
            # NOTE: Petal Dance being used shouldn't lock the
            #       battler into using that move, and shouldn't contribute to its
            #       turn counter if it's already locked into Petal Dance.
            oldCurrentMove = forcedMoveUser.currentMove
            oldOutrageTurns = forcedMoveUser.effects[:Outrage]
            forcedMoveUser.effects[:Outrage] += 1 if forcedMoveUser.effectActive?(:Outrage)
        end
        pbShowAbilitySplash(forcedMoveUser, true) if showAbilitySplash
        pbDisplay(usageMessage) unless usageMessage.nil?
        pbHideAbilitySplash(forcedMoveUser) if showAbilitySplash
        moveID = moveIDOrIndex.is_a?(Symbol) ? moveIDOrIndex : nil
        moveIndex = moveIDOrIndex.is_a?(Integer) ? moveIDOrIndex : -1
        PBDebug.logonerr do
            forcedMoveUser.effects[moveUsageEffect] = true unless moveUsageEffect.nil?
            forcedMoveUser.pbUseMoveSimple(moveID, target, moveIndex, specialUsage)
            forcedMoveUser.effects[moveUsageEffect] = false unless moveUsageEffect.nil?
        end
        forcedMoveUser.lastRoundMoved = oldLastRoundMoved
        if specialUsage
            forcedMoveUser.effects[:Outrage] = oldOutrageTurns
            forcedMoveUser.currentMove = oldCurrentMove
        end
        pbJudge
        return if @decision > 0
    end

    def getBattleMoveInstanceFromID(move_id)
        return PokeBattle_Move.from_pokemon_move(self, Pokemon::Move.new(move_id))
    end

    def allEffectHolders(&block)
        yield @field
        @sides.each(&block)
        @positions.each_with_index do |position, _index|
            yield position unless position.nil?
        end
        eachBattler do |b|
            yield b unless b.nil?
        end
    end

    def pbSetSeen(battler)
        return if !battler || !@internalBattle
        pbPlayer.pokedex.register(battler.displaySpecies, battler.displayGender, battler.displayForm)
    end

    def nextPickupUse
        @nextPickupUse += 1
        return @nextPickupUse
    end

    def firstTurnThisRound?
        return @commandPhasesThisRound.zero?
    end

    def aiKnowsAbility?(pokemon)
        return @knownAbilities[pokemon.personalID]
    end
end
