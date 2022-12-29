BattleHandlers::StatusImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:IMMUNITY,
  proc { |ability,battler,status|
    next true if status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:INSOMNIA,
  proc { |ability,battler,status|
    next true if status == :SLEEP
  }
)

BattleHandlers::StatusImmunityAbility.copy(:INSOMNIA,:SWEETVEIL,:VITALSPIRIT)

BattleHandlers::StatusImmunityAbility.add(:LEAFGUARD,
  proc { |ability,battler,status|
    next true if battler.battle.sunny?
  }
)

BattleHandlers::StatusImmunityAbility.add(:LIMBER,
  proc { |ability,battler,status|
    next true if status == :NUMB
  }
)

BattleHandlers::StatusImmunityAbility.add(:MAGMAARMOR,
  proc { |ability,battler,status|
    next true if status == :FROZEN
  }
)

BattleHandlers::StatusImmunityAbility.add(:WATERVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN
  }
)

BattleHandlers::StatusImmunityAbility.add(:ENERGETIC,
  proc { |ability,battler,status|
	next true if status == :FROZEN || status == :NUMB || status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:STABILITY,
  proc { |ability,battler,status|
	next true if status == :BURN || status == :FROSTBITE || status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:FAEVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN || status == :FROSTBITE || status == :NUMB 
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:FAEVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN || status == :FROSTBITE || status == :NUMB 
  }
)

BattleHandlers::StatusImmunityAbility.add(:CANDYVEIL,
  proc { |ability,battler,status|
    next true if status == :SLEEP || status == :DIZZY
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:CANDYVEIL,
  proc { |ability,battler,status|
    next true if status == :SLEEP || status == :DIZZY
  }
)

BattleHandlers::StatusImmunityAbility.add(:SLICKSURFACE,
  proc { |ability,battler,status|
    next true if status == :LEECHED
  }
)