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
