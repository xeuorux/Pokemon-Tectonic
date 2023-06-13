class PokeBattle_Battler
    def affectedByTerrain?(checkingForAI = false)
        return false if airborne?(checkingForAI)
        return false if semiInvulnerable?
        return true
    end

    def affectedByWeatherDownsides?(checkingForAI = false)
        return false if inTwoTurnAttack?("0CA", "0CB")   # Dig, Dive
        return false if shouldAbilityApply?(%i[ACCLIMATIZE TERRITORIAL METALCOVER NESTING HIGHRISE], checkingForAI)
        return false if hasActiveItem?(:UTILITYUMBRELLA)
        return false if @battle.pbCheckAlliedAbility(:HIGHRISE, @index)
        return true
    end

    def debuffedBySun?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:FIRE, checkingForAI) || shouldTypeApply?(:GRASS, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::SUN_ABILITIES, checkingForAI)
        return true
    end

    def debuffedByRain?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:WATER, checkingForAI) || shouldTypeApply?(:ELECTRIC, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::RAIN_ABILITIES, checkingForAI)
        return true
    end  

    def takesSandstormDamage?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false unless takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:GROUND,checkingForAI) || shouldTypeApply?(:ROCK,checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::SAND_ABILITIES, checkingForAI)
        return true
    end

    def takesHailDamage?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false unless takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:ICE,checkingForAI) || shouldTypeApply?(:GHOST,checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::HAIL_ABILITIES, checkingForAI)
        return true
    end

    def debuffedByEclipse?(checkingForAI = false)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:PSYCHIC, checkingForAI) || shouldTypeApply?(:DRAGON, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::ECLIPSE_ABILITIES, checkingForAI)
        return true
    end

    def flinchedByMoonglow?(checkingForAI = false)
        return false if flinchImmuneByAbility?(checkingForAI)
        return false unless affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:FAIRY, checkingForAI) || shouldTypeApply?(:DARK, checkingForAI)
        return false if shouldAbilityApply?(GameData::Ability::MOONGLOW_ABILITIES, checkingForAI)
        return true
    end
end