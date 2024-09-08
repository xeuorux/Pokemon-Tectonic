class PokeBattle_Battler
    def affectedByWeatherDownsides?(checkingForAI = false)
        return false if inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground", "TwoTurnAttackInvulnerableUnderwater")   # Dig, Dive
        return false if shouldAbilityApply?(GameData::Ability.getByFlag("AllWeatherSynergy"), checkingForAI)
        return false if hasActiveItem?(:UTILITYUMBRELLA)
        return false if @battle.pbCheckAlliedAbility(:HIGHRISE, @index)
        return true
    end

    def debuffedBySun?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:FIRE, checkingForAI) || shouldTypeApply?(:GRASS, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability.getByFlag("SunshineSynergy"), checkingForAI)
        return true
    end

    def debuffedByRain?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:WATER, checkingForAI) || shouldTypeApply?(:ELECTRIC, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability.getByFlag("RainstormSynergy"), checkingForAI)
        return true
    end  

    def takesSandstormDamage?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false unless takesIndirectDamage?
        return false if shouldTypeApply?(:GROUND,checkingForAI) || shouldTypeApply?(:ROCK,checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability.getByFlag("SandstormSynergy"), checkingForAI)
        return true
    end

    def takesHailDamage?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false unless takesIndirectDamage?
        return false if shouldTypeApply?(:ICE,checkingForAI) || shouldTypeApply?(:GHOST,checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability.getByFlag("HailSynergy"), checkingForAI)
        return true
    end

    def debuffedByEclipse?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:PSYCHIC, checkingForAI) || shouldTypeApply?(:DRAGON, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability.getByFlag("EclipseSynergy"), checkingForAI)
        return true
    end

    def flinchedByMoonglow?(checkingForAI = false)
        return false if flinchImmuneByAbility?(checkingForAI)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:FAIRY, checkingForAI) || shouldTypeApply?(:DARK, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability.getByFlag("MoonglowSynergy"), checkingForAI)
        return true
    end
end