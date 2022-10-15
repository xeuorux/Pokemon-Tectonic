module BattleHandlers
	def self.triggerPriorityChangeAbility(ability,battler,move,pri,targets=[])
		ret = PriorityChangeAbility.trigger(ability,battler,move,pri,targets)
		return (ret!=nil) ? ret : pri
	end
end

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
      battler.effects[PBEffects::Prankster] = true
      next pri+1
    end
  }
)

BattleHandlers::PriorityChangeAbility.add(:ENVY,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if targets && targets.length == 1 && targets[0].statStagesUp?
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