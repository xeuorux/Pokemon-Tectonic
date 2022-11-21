class PokeBattle_Battler
	def affectedByTerrain?(checkingForAI = false)
		return false if airborne?(checkingForAI)
		return false if semiInvulnerable?
		return true
	end

	def affectedByWeatherDownsides?(checkingForAI = false)
		return false if inTwoTurnAttack?('0CA', '0CB')   # Dig, Dive
		return false if shouldAbilityApply?(%i[STOUT WEATHERSENSES NORMALIZE], checkingForAI)
		return false if hasActiveItem?(:UTILITYUMBRELLA)
		return false if @battle.pbCheckAlliedAbility(:HIGHRISE, @index)
		return true
	end

	def debuffedBySun?(checkingForAI = false)
		return false unless affectedByWeatherDownsides?(checkingForAI)
		return false if shouldTypeApply?(:FIRE, checkingForAI) || shouldTypeApply?(:GRASS, checkingForAI)
		setterAbilities = %i[DROUGHT INNERLIGHT]
		synergyAbilities = %i[CHLOROPHYLL SOLARPOWER LEAFGUARD FLOWERGIFT MIDNIGHTSUN HARVEST SUNCHASER HEATSAVOR BLINDINGLIGHT SOLARCELL ROAST FINESUGAR REFRESHMENTS]
		return false if shouldAbilityApply?(setterAbilities, checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
		return true
	end

	def debuffedByRain?(checkingForAI = false)
		return false unless affectedByWeatherDownsides?(checkingForAI)
		return false if shouldTypeApply?(:WATER, checkingForAI) || shouldTypeApply?(:ELECTRIC, checkingForAI)
		setterAbilities = %i[DRIZZLE STORMBRINGER]
		synergyAbilities = %i[SWIFTSWIM RAINDISH HYDRATION TIDALFORCE STORMFRONTRAINPRISM DREARYCLOUDS DRYSKIN RAINPRISM]
		return false if shouldAbilityApply?(setterAbilities, checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
		return true
	end

	def takesSandstormDamage?(checkingForAI = false)
		return false unless affectedByWeatherDownsides?(checkingForAI)
		return false unless takesIndirectDamage?
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return false if shouldTypeApply?(:GROUND,	checkingForAI) || shouldTypeApply?(:ROCK,	checkingForAI) || shouldTypeApply?(:STEEL, checkingForAI)
		setterAbilities = %i[SANDSTREAM SANDBURST]
		synergyAbilities = %i[OVERCOAT SANDFORCE SANDRUSH SANDSHROUD DESERTSPIRITBURROWER SHRAPNELSTORM HARSHHUNTER]
		return false if shouldAbilityApply?(setterAbilities, checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
		return true
	end

	def takesHailDamage?(checkingForAI = false)
		return false unless affectedByWeatherDownsides?(checkingForAI)
		return false unless takesIndirectDamage?
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return false if shouldTypeApply?(:ICE,	checkingForAI) || shouldTypeApply?(:GHOST,	checkingForAI) || shouldTypeApply?(:STEEL, checkingForAI)
		setterAbilities = %i[SNOWWARNING FROSTSCATTER]
		synergyAbilities = %i[OVERCOAT ICEBODY SNOWSHROUD BLIZZBOXER SLUSHRUSH ICEFACEBITTERCOLD ECTOPARTICLES]
		return false if shouldAbilityApply?(setterAbilities, checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
		return true
	end

	def takesAcidRainDamage?(checkingForAI = false)
		return false unless affectedByWeatherDownsides?(checkingForAI)
		return false unless takesIndirectDamage?
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return false if shouldTypeApply?(:POISON,	checkingForAI) || shouldTypeApply?(:DARK, checkingForAI)
		setterAbilities = %i[POLLUTION ACIDBODY]
		synergyAbilities = [:OVERCOAT]
		return false if shouldAbilityApply?(setterAbilities, checkingForAI) || shouldAbilityApply?(synergyAbilities, checkingForAI)
		return true
	end

	def takesShadowSkyDamage?
		return false if fainted?
		return false if shadowPokemon?
		return true
	end
end
