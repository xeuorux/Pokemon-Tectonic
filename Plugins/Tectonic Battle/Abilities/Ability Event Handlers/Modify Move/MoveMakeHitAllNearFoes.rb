BattleHandlers::MoveMakeHitAllNearFoesAbility.add(:SPACIALDISTORTION,
  proc { |ability, user, move, type, battle|
      next true
  }
)

BattleHandlers::MoveMakeHitAllNearFoesAbility.add(:MULTITASKER,
  proc { |ability, user, move, type, battle|
      next type == :PSYCHIC
  }
)

BattleHandlers::MoveMakeHitAllNearFoesAbility.add(:EVENHANDED,
  proc { |ability, user, move, type, battle|
      next type == :FIGHTING
  }
)

BattleHandlers::MoveMakeHitAllNearFoesAbility.add(:VICIOUSCYCLE,
  proc { |ability, user, move, type, battle|
      next type == :DRAGON
  }
)

BattleHandlers::MoveMakeHitAllNearFoesAbility.add(:HORDETACTICS,
  proc { |ability, user, move, type, battle|
      next type == :NORMAL
  }
)