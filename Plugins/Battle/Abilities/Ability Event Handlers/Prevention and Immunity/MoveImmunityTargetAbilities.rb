BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.bombMove?
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,type,battle|
    next false if user.index==target.index
    next false if type != :FIRE
    battle.pbShowAbilitySplash(target)
    if !target.effects[PBEffects::FlashFire]
      target.effects[PBEffects::FlashFire] = true
      battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPECIAL_ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPEED,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:GRASS,:ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SOUNDPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.soundMove?
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    battle.pbHideAbilitySplash(target)
    next true

  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,:SPECIAL_ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if user.index==target.index || target.opposes?(user)
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",target.pbThis(true)))
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:ELECTRIC,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:WATER,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB,:DRYSKIN)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if !type || Effectiveness.super_effective?(target.damageState.typeMod)
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    battle.pbHideAbilitySplash(target)
    next true
  }
)

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