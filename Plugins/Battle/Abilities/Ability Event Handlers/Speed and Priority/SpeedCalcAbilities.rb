BattleHandlers::SpeedCalcAbility.add(:CHLOROPHYLL,
  proc { |_ability, battler, mult|
      next mult * 2 if battler.battle.sunny?
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKFEET,
  proc { |_ability, battler, mult|
      next mult * 1.5 if battler.pbHasAnyStatus?
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDRUSH,
  proc { |_ability, battler, mult|
      next mult * 2 if [:Sandstorm].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLOWSTART,
  proc { |_ability, battler, mult|
      next mult / 2 if battler.effectActive?(:SlowStart)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLUSHRUSH,
  proc { |_ability, battler, mult|
      next mult * 2 if [:Hail].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SURGESURFER,
  proc { |_ability, battler, mult|
      next mult * 2 if battler.battle.field.terrain == :Electric
  }
)

BattleHandlers::SpeedCalcAbility.add(:SWIFTSWIM,
  proc { |_ability, battler, mult|
      next mult * 2 if battler.battle.rainy?
  }
)

BattleHandlers::SpeedCalcAbility.add(:UNBURDEN,
  proc { |_ability, battler, mult|
      next mult * 2 if battler.effectActive?(:ItemLost) && !battler.item
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKTHINKING,
  proc { |_ability, battler, mult|
      next mult * 2 if battler.battle.field.terrain == :Psychic
  }
)

BattleHandlers::SpeedCalcAbility.add(:BROODING,
  proc { |_ability, battler, mult|
      dragonCount = 0
      battler.battle.eachInTeamFromBattlerIndex(battler.index) do |pkmn, _i|
          dragonCount += 1 if pkmn.hasType?(:DRAGON)
      end
      next mult * (1.0 + dragonCount * 0.05)
  }
)

BattleHandlers::SpeedCalcAbility.add(:ARCANEFINALE,
  proc { |_ability, battler, mult|
      next mult *= 2 if battler.isLastAlive?
  }
)

BattleHandlers::SpeedCalcAbility.add(:HEROICFINALE,
  proc { |_ability, battler, mult|
      next mult *= 2 if battler.isLastAlive?
  }
)

BattleHandlers::SpeedCalcAbility.add(:FEROCIOUS,
  proc { |_ability, battler, mult|
      active = false
      battler.eachOpposing do |b|
          next unless b.belowHalfHealth?
          active = true
          break
      end
      mult *= 2 if active
      next mult
  }
)

BattleHandlers::SpeedCalcAbility.add(:PRIMEVALSLOWSTART,
  proc { |_ability, _battler, mult|
      next mult / 2
  }
)

BattleHandlers::SpeedCalcAbility.add(:LOCOMOTION,
  proc { |_ability, _battler, mult|
      next mult * 1.5
  }
)
