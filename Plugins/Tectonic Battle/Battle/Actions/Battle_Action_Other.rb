class PokeBattle_Battle
    #=============================================================================
    # Shifting a battler to another position in a battle larger than double
    #=============================================================================
    def pbCanShift?(idxBattler)
        return false if pbSideSize(0) <= 2 && pbSideSize(1) <= 2 # Double battle or smaller
        idxOther = -1
        case pbSideSize(idxBattler)
        when 1
            return false # Only one battler on that side
        when 2
            idxOther = (idxBattler + 2) % 4
        when 3
            return false if [2, 3].include?(idxBattler) # In middle spot already
            idxOther = idxBattler.even? ? 2 : 3
        end
        return false if pbGetOwnerIndexFromBattlerIndex(idxBattler) != pbGetOwnerIndexFromBattlerIndex(idxOther)
        return true
    end

    def pbRegisterShift(idxBattler)
        @choices[idxBattler][0] = :Shift
        @choices[idxBattler][1] = 0
        @choices[idxBattler][2] = nil
        return true
    end

    #=============================================================================
    # Choosing to Mega Evolve a battler
    #=============================================================================
    def pbCanMegaEvolve?(idxBattler)
        return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
        battler = @battlers[idxBattler]
        return false unless battler.hasMega?
        return false if wildBattle? && opposes?(idxBattler) && !battler.boss
        return true if debugControl
        return false if battler.effectActive?(:SkyDrop)
        side  = battler.idxOwnSide
        owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        return @megaEvolution[side][owner] == -1
    end

    def pbRegisterMegaEvolution(idxBattler)
        side  = @battlers[idxBattler].idxOwnSide
        owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        @megaEvolution[side][owner] = idxBattler
    end

    def pbUnregisterMegaEvolution(idxBattler)
        side  = @battlers[idxBattler].idxOwnSide
        owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        @megaEvolution[side][owner] = -1 if @megaEvolution[side][owner] == idxBattler
    end

    def pbToggleRegisteredMegaEvolution(idxBattler)
        side  = @battlers[idxBattler].idxOwnSide
        owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        if @megaEvolution[side][owner] == idxBattler
            @megaEvolution[side][owner] = -1
        else
            @megaEvolution[side][owner] = idxBattler
        end
    end

    def pbRegisteredMegaEvolution?(idxBattler)
        side  = @battlers[idxBattler].idxOwnSide
        owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        return @megaEvolution[side][owner] == idxBattler
    end

    #=============================================================================
    # Mega Evolving a battler
    #=============================================================================
    def pbMegaEvolve(idxBattler)
        battler = @battlers[idxBattler]
        return if !battler || !battler.pokemon
        return if !battler.hasMega? || battler.mega?
        # Break Illusion
        if battler.hasActiveAbility?(:ILLUSION)
            BattleHandlers.triggerTargetAbilityOnHit(:ILLUSION, nil, battler, nil, self)
        end
        # Mega Evolve
        if !battler.boss
            trainerName = pbGetOwnerName(idxBattler)
            pbDisplay(_INTL("{1}'s fervent wish has reached {2}!", trainerName, battler.pbThis))
        else
            case battler.pokemon.megaMessage
            when 1 # Rayquaza
                pbDisplay(_INTL("{1}'s is inspired by the echo of an ancient wish!", battler.pbThis))
            else
                pbDisplay(_INTL("{1}'s reacts to an unknown power!", battler.pbThis))
            end
        end
        pbCommonAnimation("MegaEvolution", battler)
        battler.pokemon.makeMega
        battler.form = battler.pokemon.form
        battler.pbUpdate(true)
        @scene.pbChangePokemon(battler, battler.pokemon)
        @scene.pbRefreshOne(idxBattler)
        pbCommonAnimation("MegaEvolution2", battler)
        megaName = battler.pokemon.megaName
        megaName = _INTL("Mega {1}", battler.pokemon.speciesName) if !megaName || megaName == ""
        pbDisplay(_INTL("{1} has Mega Evolved into {2}!", battler.pbThis, megaName))
        side  = battler.idxOwnSide
        owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
        @megaEvolution[side][owner] = -2
        battler.disableEffect(:Telekinesis) if battler.isSpecies?(:GENGAR) && battler.mega?
        pbCalculatePriority(false, [idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
        # Trigger ability
        battler.pbEffectsOnSwitchIn
    end

    #=============================================================================
    # Primal Reverting a battler
    #=============================================================================
    def pbPrimalReversion(idxBattler)
        battler = @battlers[idxBattler]
        return if !battler || !battler.pokemon
        return if !battler.hasPrimal? || battler.primal?
        if battler.isSpecies?(:KYOGRE)
            pbCommonAnimation("PrimalKyogre", battler)
        elsif battler.isSpecies?(:GROUDON)
            pbCommonAnimation("PrimalGroudon", battler)
        end
        battler.pokemon.makePrimal
        battler.form = battler.pokemon.form
        battler.pbUpdate(true)
        @scene.pbChangePokemon(battler, battler.pokemon)
        @scene.pbRefreshOne(idxBattler)
        if battler.isSpecies?(:KYOGRE)
            pbCommonAnimation("PrimalKyogre2", battler)
        elsif battler.isSpecies?(:GROUDON)
            pbCommonAnimation("PrimalGroudon2", battler)
        end
        pbDisplay(_INTL("{1}'s Primal Reversion!\nIt reverted to its primal form!", battler.pbThis))
        # Trigger ability
        battler.pbEffectsOnSwitchIn
    end
end
