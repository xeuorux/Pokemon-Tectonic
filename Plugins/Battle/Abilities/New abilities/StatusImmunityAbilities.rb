BattleHandlers::StatusImmunityAbility.add(:ENERGETIC,
  proc { |ability,battler,status|
	next true if status == :FROZEN || status == :PARALYSIS || status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:STABILITY,
  proc { |ability,battler,status|
	next true if status == :BURN || status == :FROSTBITE || status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:FAEVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN || status == :FROSTBITE || status == :PARALYSIS 
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:FAEVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN || status == :FROSTBITE || status == :PARALYSIS 
  }
)

BattleHandlers::StatusImmunityAbility.add(:CANDYVEIL,
  proc { |ability,battler,status|
    next true if status == :SLEEP || status == :FLUSTERED || status == :MYSTIFIED
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:CANDYVEIL,
  proc { |ability,battler,status|
    next true if status == :SLEEP || status == :FLUSTERED || status == :MYSTIFIED
  }
)