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

BattleHandlers::MoveImmunityTargetAbility.add(:COLDRECEPTION,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ICE,:ATTACK,1,battle)
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

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTLESS,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:FAIRY,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:INDUSTRIALIZE,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:STEEL,:SPEED,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:DRAGONSLAYER,
  proc { |ability,user,target,move,type,battle|
    next false if user.index==target.index
    next false if type != :DRAGON
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:PECKINGORDER,
  proc { |ability,user,target,move,type,battle|
    next false if user.index==target.index
    next false if type != :FLYING
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FINESUGAR,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:FIRE,battle)
  }
)