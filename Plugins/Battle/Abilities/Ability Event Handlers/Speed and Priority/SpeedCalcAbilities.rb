BattleHandlers::SpeedCalcAbility.add(:CHLOROPHYLL,
  proc { |ability,battler,mult|
    next mult * 2 if [:Sun, :HarshSun].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKFEET,
  proc { |ability,battler,mult|
    next mult*1.5 if battler.pbHasAnyStatus?
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:Sandstorm].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLOWSTART,
  proc { |ability,battler,mult|
    next mult/2 if battler.effectActive?(:SlowStart)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLUSHRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:Hail].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SURGESURFER,
  proc { |ability,battler,mult|
    next mult*2 if battler.battle.field.terrain == :Electric
  }
)

BattleHandlers::SpeedCalcAbility.add(:SWIFTSWIM,
  proc { |ability,battler,mult|
    next mult * 2 if [:Rain, :HeavyRain].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:UNBURDEN,
  proc { |ability,battler,mult|
    next mult*2 if battler.effectActive?(:ItemLost) && !battler.item
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKTHINKING,
  proc { |ability,battler,mult|
    next mult*2 if battler.battle.field.terrain == :Psychic
  }
)

BattleHandlers::SpeedCalcAbility.add(:BROODING,
  proc { |ability,battler,mult|
	dragonCount = 0
	battler.battle.eachInTeamFromBattlerIndex(battler.index) do |pkmn,i|
		dragonCount += 1 if pkmn.hasType?(:DRAGON)
	end
	next mult * (1.0 + dragonCount * 0.05) 
  }
)

BattleHandlers::SpeedCalcAbility.add(:ARCANEFINALE,
  proc { |ability,battler,mult|
	  next mult *= 2 if battler.isLastAlive?
  }
)

BattleHandlers::SpeedCalcAbility.add(:HEROICFINALE,
  proc { |ability,battler,mult|
  next mult *= 2 if battler.isLastAlive?
  }
)

BattleHandlers::SpeedCalcAbility.add(:FEROCIOUS,
  proc { |ability,battler,mult|
  active = false
  battler.eachOpposing do |b|
    next if b.hp >= b.totalhp/2
    active = true
    break
  end
  mult *= 2 if active
  next mult
  }
)

BattleHandlers::SpeedCalcAbility.add(:PRIMEVALSLOWSTART,
  proc { |ability,battler,mult|
    next mult/2
  }
)