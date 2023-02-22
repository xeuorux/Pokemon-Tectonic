BattleHandlers::StatusImmunityAbility.add(:FLOWERVEIL,
  proc { |_ability, battler, _status|
      next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:IMMUNITY,
  proc { |_ability, _battler, status|
      next true if status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:INSOMNIA,
  proc { |_ability, _battler, status|
      next true if status == :SLEEP
  }
)

BattleHandlers::StatusImmunityAbility.add(:ONEDGE,
  proc { |_ability, battler, status|
      next true if status == :SLEEP && battler.battle.pbWeather == :Moonglow
  }
)

BattleHandlers::StatusImmunityAbility.copy(:INSOMNIA, :SWEETVEIL, :VITALSPIRIT)

BattleHandlers::StatusImmunityAbility.add(:LEAFGUARD,
  proc { |_ability, battler, _status|
      next true if battler.battle.sunny?
  }
)

BattleHandlers::StatusImmunityAbility.add(:LIMBER,
  proc { |_ability, _battler, status|
      next true if status == :NUMB
  }
)

BattleHandlers::StatusImmunityAbility.add(:MAGMAARMOR,
  proc { |_ability, _battler, status|
      next true if status == :FROZEN
  }
)

BattleHandlers::StatusImmunityAbility.add(:WATERVEIL,
  proc { |_ability, _battler, status|
      next true if status == :BURN
  }
)

BattleHandlers::StatusImmunityAbility.add(:ENERGETIC,
  proc { |_ability, _battler, status|
      next true if %i[FROZEN NUMB POISON].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:STABILITY,
  proc { |_ability, _battler, status|
      next true if %i[BURN FROSTBITE POISON].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:FAEVEIL,
  proc { |_ability, _battler, status|
      next true if %i[BURN FROSTBITE NUMB].include?(status)
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:FAEVEIL,
  proc { |_ability, _battler, status|
      next true if %i[BURN FROSTBITE NUMB].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:CANDYVEIL,
  proc { |_ability, _battler, status|
      next true if %i[SLEEP DIZZY].include?(status)
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:CANDYVEIL,
  proc { |_ability, _battler, status|
      next true if %i[SLEEP DIZZY].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:SLICKSURFACE,
  proc { |_ability, _battler, status|
      next true if status == :LEECHED
  }
)

BattleHandlers::StatusImmunityAbility.add(:STABILITY,
  proc { |_ability, battler, status|
      next true if battler.battle.pbWeather == :Eclipse
  }
)