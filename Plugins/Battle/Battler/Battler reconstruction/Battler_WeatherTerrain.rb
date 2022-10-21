class PokeBattle_Battler
    def affectedByTerrain?(checkingForAI=false)
        return false if airborne?(checkingForAI)
        return false if semiInvulnerable?
        return true
    end

    def affectedByWeatherDownsides?(checkingForAI=false)
        return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
        return false if shouldAbilityApply?([:STOUT,:WEATHERSENSES,:NORMALIZE],checkingForAI)
        return false if hasActiveItem?(:UTILITYUMBRELLA)
        return false if @battle.pbCheckAlliedAbility(:HIGHRISE,@index)
        return true
    end

    def debuffedBySun?(checkingForAI=false)
        return false if !affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:FIRE,checkingForAI) || shouldTypeApply?(:GRASS,checkingForAI)
        setterAbilities = [:DROUGHT,:INNERLIGHT]
        synergyAbilities = [:CHLOROPHYLL,:SOLARPOWER,:LEAFGUARD,:FLOWERGIFT,:MIDNIGHTSUN,:HARVEST,:SUNCHASER,:HEATSAVOR,:BLINDINGLIGHT,:SOLARCELL,:ROAST]
        return false if shouldAbilityApply?(setterAbilities,checkingForAI) || shouldAbilityApply?(synergyAbilities,checkingForAI)
        return true
    end

    def debuffedByRain?(checkingForAI=false)
        return false if !affectedByWeatherDownsides?(checkingForAI)
        return false if shouldTypeApply?(:WATER,checkingForAI) || shouldTypeApply?(:ELECTRIC,checkingForAI)
        setterAbilities = [:DRIZZLE,:STORMBRINGER]
        synergyAbilities = [:SWIFTSWIM,:RAINDISH,:HYDRATION,:TIDALFORCE,:STORMFRONT,:RAINPRISM,:DREARYCLOUDS]
        return false if shouldAbilityApply?(setterAbilities,checkingForAI) || shouldAbilityApply?(synergyAbilities,checkingForAI)
        return true
    end
        
    def takesSandstormDamage?(checkingForAI=false)
        return false if !affectedByWeatherDownsides?(checkingForAI)
        return false if !takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:GROUND,checkingForAI) || shouldTypeApply?(:ROCK,checkingForAI) || shouldTypeApply?(:STEEL,checkingForAI)
        setterAbilities = [:SANDSTREAM,:SANDBURST]
        synergyAbilities = [:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDSHROUD,:DESERTSPIRIT,:BURROWER,:SHRAPNELSTORM,:HARSHHUNTER]
        return false if shouldAbilityApply?(setterAbilities,checkingForAI) || shouldAbilityApply?(synergyAbilities,checkingForAI)
        return true
    end

    def takesHailDamage?(checkingForAI=false)
        return false if !affectedByWeatherDownsides?(checkingForAI)
        return false if !takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:ICE,checkingForAI) || shouldTypeApply?(:GHOST,checkingForAI) || shouldTypeApply?(:STEEL,checkingForAI)
        setterAbilities = [:SNOWWARNING,:FROSTSCATTER]
        synergyAbilities = [:OVERCOAT,:ICEBODY,:SNOWSHROUD,:BLIZZBOXER,:SLUSHRUSH,:ICEFACE,:BITTERCOLD,:ECTOPARTICLES]
        return false if shouldAbilityApply?(setterAbilities,checkingForAI) || shouldAbilityApply?(synergyAbilities,checkingForAI)
        return true
    end

    def takesAcidRainDamage?(checkingForAI=false)
        return false if !affectedByWeatherDownsides?(checkingForAI)
        return false if !takesIndirectDamage?
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return false if shouldTypeApply?(:POISON,checkingForAI) || shouldTypeApply?(:DARK,checkingForAI)
        setterAbilities = [:POLLUTION,:ACIDBODY]
        synergyAbilities = [:OVERCOAT]
        return false if shouldAbilityApply?(setterAbilities,checkingForAI) || shouldAbilityApply?(synergyAbilities,checkingForAI)
        return true
    end

    def takesShadowSkyDamage?
        return false if fainted?
        return false if shadowPokemon?
        return true
    end
end