BattleHandlers::SpeedCalcAbility.add(:CHLOROPHYLL,
  proc { |ability, battler, mult|
      next mult * 2 if battler.battle.sunny?
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKFEET,
  proc { |ability, battler, mult|
      next mult * 2.0 if battler.pbHasAnyStatus?
  }
)

BattleHandlers::SpeedCalcAbility.add(:HYPERSPEED,
  proc { |ability, battler, mult|
      next mult * 2.0
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDRUSH,
  proc { |ability, battler, mult|
      next mult * 2 if [:Sandstorm].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLOWSTART,
  proc { |ability, battler, mult|
      next mult / 2 if battler.effectActive?(:SlowStart)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLUSHRUSH,
  proc { |ability, battler, mult|
      next mult * 2 if [:Hail].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SURGESURFER,
  proc { |ability, battler, mult|
      next mult * 2 if battler.battle.field.terrain == :Electric
  }
)

BattleHandlers::SpeedCalcAbility.add(:SWIFTSWIM,
  proc { |ability, battler, mult|
      next mult * 2 if battler.battle.rainy?
  }
)

BattleHandlers::SpeedCalcAbility.add(:AQUAPROPULSION,
  proc { |ability, battler, mult|
      next mult * 1.25 if battler.battle.rainy?
  }
)

BattleHandlers::SpeedCalcAbility.add(:UNBURDEN,
  proc { |ability, battler, mult|
      next mult * 2 if battler.effectActive?(:ItemLost) && !battler.hasAnyItem?
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKTHINKING,
  proc { |ability, battler, mult|
      next mult * 2 if battler.battle.field.terrain == :Psychic
  }
)

BattleHandlers::SpeedCalcAbility.add(:BROODING,
  proc { |ability, battler, mult|
      dragonCount = 0
      battler.battle.eachInTeamFromBattlerIndex(battler.index) do |pkmn, _i|
          dragonCount += 1 if pkmn.hasType?(:DRAGON)
      end
      next mult * (1.0 + dragonCount * 0.05)
  }
)

BattleHandlers::SpeedCalcAbility.add(:ARCANEFINALE,
  proc { |ability, battler, mult|
      next mult *= 2 if battler.isLastAlive?
  }
)

BattleHandlers::SpeedCalcAbility.add(:HEROICFINALE,
  proc { |ability, battler, mult|
      next mult *= 2 if battler.isLastAlive?
  }
)

BattleHandlers::SpeedCalcAbility.add(:FEROCIOUS,
  proc { |ability, battler, mult|
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
  proc { |ability, _battler, mult|
      next mult / 2
  }
)

BattleHandlers::SpeedCalcAbility.add(:LOCOMOTION,
  proc { |ability, _battler, mult|
      next mult * 1.5
  }
)

BattleHandlers::SpeedCalcAbility.add(:LIGHTTRICK,
  proc { |ability, battler, mult|
      active = false
      battler.eachOpposing do |b|
          next unless b.pbHasAnyStatus?
          active = true
          break
      end
      mult *= 2 if active
      next mult
  }
)

BattleHandlers::SpeedCalcAbility.add(:ANARCHIC,
  proc { |ability, battler, mult|
      next mult * 2 if battler.battle.pbWeather == :Eclipse
  }
)

BattleHandlers::SpeedCalcAbility.add(:NIGHTLIFE,
  proc { |ability, battler, mult|
      next mult * 2 if battler.battle.pbWeather == :Moonglow
  }
)

BattleHandlers::SpeedCalcAbility.add(:NIGHTVISION,
  proc { |ability, battler, mult|
      next mult * 1.5 if battler.battle.pbWeather == :Moonglow
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDDRILLING,
  proc { |ability, battler, mult|
      next mult * 1.5 if battler.battle.pbWeather == :Sandstorm
  }
)

BattleHandlers::SpeedCalcAbility.add(:NIGHTOWL,
  proc { |ability, battler, mult|
      next mult * 1.5 if battler.battle.pbWeather == :Moonglow
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDSNIPER,
  proc { |ability, battler, mult|
      next mult * 1.5 if battler.battle.pbWeather == :Sandstorm
  }
)

BattleHandlers::SpeedCalcAbility.add(:TAIGATRECKER,
  proc { |ability, battler, mult|
      next mult * 1.5 if battler.battle.pbWeather == :Hail
  }
)

BattleHandlers::SpeedCalcAbility.add(:POLARHUNTER,
  proc { |ability, battler, mult|
      next mult * 1.25 if battler.battle.pbWeather == :Hail
  }
)

BattleHandlers::SpeedCalcAbility.add(:LIGHTNINGRIDE,
  proc { |ability, battler, mult|
      next mult * 2.0 if battler.effectActive?(:Charge)
  }
)

BattleHandlers::SpeedCalcAbility.add(:METEORIC,
  proc { |ability, battler, mult|
      next mult * 1.5 if %i[Sandstorm Hail].include?(battler.battle.pbWeather)
  }
)