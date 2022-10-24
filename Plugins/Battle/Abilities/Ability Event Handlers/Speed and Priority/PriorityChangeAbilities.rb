BattleHandlers::PriorityChangeAbility.add(:GALEWINGS,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if battler.hp==battler.totalhp && move.type == :FLYING
  }
)

BattleHandlers::PriorityChangeAbility.add(:PRANKSTER,
  proc { |ability,battler,move,pri,targets=nil|
    if move.statusMove?
      battler.applyEffect(:Prankster)
      next pri+1
    end
  }
)

BattleHandlers::PriorityChangeAbility.add(:TRIAGE,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+3 if move.healingMove?
  }
)

BattleHandlers::PriorityChangeAbility.add(:MAESTRO,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if move.soundMove?
  }
)

BattleHandlers::PriorityChangeAbility.add(:FAUXLIAGE,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if battler.battle.field.terrain==:Grassy
  }
)

BattleHandlers::PriorityChangeAbility.add(:LIGHTTRICK,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if targets && targets.length == 1 && targets[0].status != :NONE
  }
)

BattleHandlers::PriorityChangeAbility.add(:DECEPTIVE,
  proc { |ability,battler,move,pri|
    if move.statusMove? && battler.battle.field.terrain == :Misty
      battler.applyEffect(:Prankster)
      next pri+1
    end
  }
)

BattleHandlers::PriorityChangeAbility.add(:ENVY,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if targets && targets.length == 1 && targets[0].hasRaisedStatStages?
  }
)

BattleHandlers::PriorityChangeAbility.add(:QUICKBUILD,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if move.setsARoom?
  }
)

BattleHandlers::PriorityChangeAbility.add(:TIMEINTERLOPER,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1
  }
)