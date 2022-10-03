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