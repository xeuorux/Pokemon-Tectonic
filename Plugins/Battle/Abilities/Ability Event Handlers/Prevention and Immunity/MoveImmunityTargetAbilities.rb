BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |ability,user,target,move,type,battle,showMessages|
    next false if !move.bombMove?
    if showMessages
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,type,battle,showMessages|
    next false if user.index==target.index
    next false if type != :FIRE
    battle.pbShowAbilitySplash(target) if showMessages
    if !target.effectActive?(:FlashFire)
      target.applyEffect(:FlashFire)
    else
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true))) if showMessages
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPECIAL_ATTACK,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPEED,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:GRASS,:ATTACK,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SOUNDPROOF,
  proc { |ability,user,target,move,type,battle,showMessages|
    next false if !move.soundMove?
    if showMessages
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
    next true

  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,:SPECIAL_ATTACK,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |ability,user,target,move,type,battle,showMessages|
    next false if move.statusMove?
    next false if user.index==target.index || target.opposes?(user)
    if showMessages
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",target.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:ELECTRIC,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:WATER,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB,:DRYSKIN)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |ability,user,target,move,type,battle,showMessages|
    next false if move.statusMove?
    next false if !type || Effectiveness.super_effective?(target.damageState.typeMod)
    if showMessages
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:AERODYNAMIC,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:FLYING,:SPEED,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLYTRAP,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:BUG,:ATTACK,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:COLDRECEPTION,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ICE,:ATTACK,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:POISONABSORB,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:POISON,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CHALLENGER,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:FIGHTING,:ATTACK,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTOFJUSTICE,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:DARK,:ATTACK,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTLESS,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:FAIRY,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:INDUSTRIALIZE,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:STEEL,:SPEED,1,battle,showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:DRAGONSLAYER,
  proc { |ability,user,target,move,type,battle,showMessages|
    next false if user.index==target.index
    next false if type != :DRAGON
    if showMessages
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:PECKINGORDER,
  proc { |ability,user,target,move,type,battle,showMessages|
    next false if user.index==target.index
    next false if type != :FLYING
    if showMessages
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FINESUGAR,
  proc { |ability,user,target,move,type,battle,showMessages|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:FIRE,battle,showMessages)
  }
)