BattleHandlers::PriorityChangeAbility.add(:PRANKSTER,
  proc { |ability, battler, move, _pri, _targets = nil, aiCheck = false|
      if move.statusMove?
          battler.applyEffect(:Prankster) unless aiCheck
          next 1
      end
  }
)

BattleHandlers::PriorityChangeAbility.add(:TRIAGE,
  proc { |ability, _battler, move, _pri, _targets = nil, _aiCheck = false|
      next 3 if move.healingMove?
  }
)

BattleHandlers::PriorityChangeAbility.add(:FAUXLIAGE,
  proc { |ability, battler, move, _pri, _targets = nil, _aiCheck = false|
      next 1 if move.calcType == :GRASS
  }
)

BattleHandlers::PriorityChangeAbility.add(:ENVY,
  proc { |ability, _battler, _move, _pri, targets = nil, _aiCheck = false|
      next 1 if targets && targets.length == 1 && targets[0].hasRaisedStatSteps?
  }
)

BattleHandlers::PriorityChangeAbility.add(:QUICKBUILD,
  proc { |ability, _battler, move, _pri, _targets = nil, _aiCheck = false|
      next 1 if move.setsARoom?
  }
)

BattleHandlers::PriorityChangeAbility.add(:TIMEINTERLOPER,
  proc { |ability, _battler, _move, _pri, _targets = nil, _aiCheck = false|
      next 1
  }
)

BattleHandlers::PriorityChangeAbility.add(:POWERLIFTER,
  proc { |ability, _battler, move, _pri, _targets = nil, _aiCheck = false|
      next -6 if move.physicalMove?
  }
)
