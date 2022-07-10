BattleHandlers::MoveImmunityTargetAbility.add(:AERODYNAMIC,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:FLYING,:SPEED,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLYTRAP,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:BUG,:ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:COLDPROOF,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ICE,:SPECIAL_DEFENSE,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:POISONABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:POISON,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CHALLENGER,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:FIGHTING,:ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTOFJUSTICE,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:DARK,:ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:ARTIFICIALNOCTURNE,
  proc { |ability,user,target,move,type,battle,mult|
	if user.battle.pbWeather == :Sandstorm
		next (pbBattleMoveImmunityHealAbility(user,target,move,type,:BUG,battle) || pbBattleMoveImmunityHealAbility(user,target,move,type,:FAIRY,battle) || pbBattleMoveImmunityHealAbility(user,target,move,type,:FIRE,battle))
	end
  }
)