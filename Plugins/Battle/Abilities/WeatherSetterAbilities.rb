def pbBattleWeatherAbility(weather,battler,battle,ignorePrimal=false)
    return if !ignorePrimal && [:HarshSun, :HeavyRain, :StrongWinds].include?(battle.field.weather)
    battle.pbShowAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
    end
    fixedDuration = ![:HarshSun, :HeavyRain, :StrongWinds].include?(weather)
    battle.pbStartWeather(battler,weather,4)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
end

#########################################
# ON SWITCH IN WEAHER ABILITIES
#########################################

BattleHandlers::AbilityOnSwitchIn.add(:SWARMCALL,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Swarm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:POLLUTION,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:AcidRain, battler, battle)
  }
)

#########################################
# ON HIT WEAHER ABILITIES
#########################################

BattleHandlers::TargetAbilityOnHit.add(:SANDBURST,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Sandstorm,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:INNERLIGHT,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Sun,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:STORMBRINGER,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Rain,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:FROSTSCATTER,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Hail,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:SWARMMOUTH,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Swarm,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:ACIDBODY,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:AcidRain,battler,battle)
	}
)