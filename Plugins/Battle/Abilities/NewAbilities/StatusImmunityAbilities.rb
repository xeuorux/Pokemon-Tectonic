BattleHandlers::StatusImmunityAbility.add(:COLDPROOF,
  proc { |ability,battler,status|
    next true if status == :FROZEN
  }
)

BattleHandlers::StatusImmunityAbility.add(:ENERGETIC,
  proc { |ability,battler,status|
	next true if status == :FROZEN || status == :PARALYSIS
  }
)

BattleHandlers::StatusImmunityAbility.add(:FAEVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN || status == :POISON
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:FAEVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN || status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:CANDYVEIL,
  proc { |ability,battler,status|
    next true if status == :SLEEP || status == :CHILL
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:CANDYVEIL,
  proc { |ability,battler,status|
    next true if status == :SLEEP || status == :CHILL
  }
)