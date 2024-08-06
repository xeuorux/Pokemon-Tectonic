BattleHandlers::StatusImmunityAbility.add(:FLOWERVEIL,
  proc { |ability, battler, _status|
      next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:IMMUNITY,
  proc { |ability, _battler, status|
      next true if status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:INSOMNIA,
  proc { |ability, _battler, status|
      next true if status == :SLEEP
  }
)

BattleHandlers::StatusImmunityAbility.copy(:INSOMNIA, :SWEETVEIL, :VITALSPIRIT)

BattleHandlers::StatusImmunityAbility.add(:LEAFGUARD,
  proc { |ability, battler, _status|
      next true if battler.battle.sunny?
  }
)

BattleHandlers::StatusImmunityAbility.add(:LIMBER,
  proc { |ability, _battler, status|
      next true if status == :NUMB
  }
)

BattleHandlers::StatusImmunityAbility.add(:WATERVEIL,
  proc { |ability, _battler, status|
      next true if status == :BURN
  }
)

BattleHandlers::StatusImmunityAbility.add(:ENERGETIC,
  proc { |ability, _battler, status|
      next true if %i[FROZEN NUMB POISON].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:STABILITY,
  proc { |ability, _battler, status|
      next true if %i[BURN FROSTBITE POISON].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:LEVIATHAN,
  proc { |ability, _battler, status|
      next true if %i[BURN FROSTBITE].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:FAEVEIL,
  proc { |ability, _battler, status|
      next true if %i[BURN FROSTBITE NUMB].include?(status)
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:FAEVEIL,
  proc { |ability, _battler, status|
      next true if %i[BURN FROSTBITE NUMB].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:CANDYVEIL,
  proc { |ability, _battler, status|
      next true if %i[POISON LEECHED DIZZY].include?(status)
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:CANDYVEIL,
  proc { |ability, _battler, status|
      next true if %i[POISON LEECHED DIZZY].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:SLICKSURFACE,
  proc { |ability, _battler, status|
      next true if status == :LEECHED
  }
)

BattleHandlers::StatusImmunityAbility.add(:FIGHTINGVIGOR,
  proc { |ability, _battler, status|
      next true if status == :NUMB
  }
)

BattleHandlers::StatusImmunityAbility.add(:GROTESQUEVITALS,
  proc { |ability, _battler, status|
      next true if status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:SELFSUFFICIENT,
  proc { |ability, _battler, status|
      next true if %i[BURN FROSTBITE].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:DOMINEERING,
  proc { |ability, _battler, status|
      next true if status == :DIZZY
  }
)

BattleHandlers::StatusImmunityAbility.add(:RUNNINGFREE,
  proc { |ability, _battler, status|
      next true if %i[NUMB LEECHED].include?(status)
  }
)

BattleHandlers::StatusImmunityAbility.add(:MENTALBLOCK,
  proc { |ability, _battler, status|
      next true if status == :DIZZY
  }
)

BattleHandlers::StatusImmunityAbility.add(:PLOTARMOR,
  proc { |ability, battler, status|
      next true if battler.battle.eclipsed?
  }
)