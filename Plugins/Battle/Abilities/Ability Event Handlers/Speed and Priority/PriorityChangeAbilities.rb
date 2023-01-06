BattleHandlers::PriorityChangeAbility.add(:GALEWINGS,
  proc { |_ability, battler, move, _pri, _targets = nil|
      next 1 if battler.hp == battler.totalhp && move.type == :FLYING
  }
)

BattleHandlers::PriorityChangeAbility.add(:PRANKSTER,
  proc { |_ability, battler, move, _pri, _targets = nil|
      if move.statusMove?
          battler.applyEffect(:Prankster)
          next 1
      end
  }
)

BattleHandlers::PriorityChangeAbility.add(:TRIAGE,
  proc { |_ability, _battler, move, _pri, _targets = nil|
      next 3 if move.healingMove?
  }
)

BattleHandlers::PriorityChangeAbility.add(:MAESTRO,
  proc { |_ability, _battler, move, _pri, _targets = nil|
      next 1 if move.soundMove?
  }
)

BattleHandlers::PriorityChangeAbility.add(:FAUXLIAGE,
  proc { |_ability, battler, _move, _pri, _targets = nil|
      next 1 if battler.battle.field.terrain == :Grassy
  }
)

BattleHandlers::PriorityChangeAbility.add(:DECEPTIVE,
  proc { |_ability, battler, move, _pri|
      if move.statusMove? && battler.battle.field.terrain == :Fairy
          battler.applyEffect(:Prankster)
          next 1
      end
  }
)

BattleHandlers::PriorityChangeAbility.add(:ENVY,
  proc { |_ability, _battler, _move, _pri, targets = nil|
      next 1 if targets && targets.length == 1 && targets[0].hasRaisedStatStages?
  }
)

BattleHandlers::PriorityChangeAbility.add(:QUICKBUILD,
  proc { |_ability, _battler, move, _pri, _targets = nil|
      next 1 if move.setsARoom?
  }
)

BattleHandlers::PriorityChangeAbility.add(:TIMEINTERLOPER,
  proc { |_ability, _battler, _move, _pri, _targets = nil|
      next 1
  }
)

BattleHandlers::PriorityChangeAbility.add(:POWERLIFTER,
  proc { |_ability, _battler, move, _pri, _targets = nil|
      next -6 if move.physicalMove?
  }
)
