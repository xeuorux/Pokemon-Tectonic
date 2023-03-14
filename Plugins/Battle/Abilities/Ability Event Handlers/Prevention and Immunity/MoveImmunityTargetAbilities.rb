# pbBattleMoveImmunityStatAbility

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :ELECTRIC, :SPECIAL_ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :ELECTRIC, :SPEED, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :GRASS, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:AERODYNAMIC,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :FLYING, :SPEED, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLYTRAP,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :BUG, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:COLDRECEPTION,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :ICE, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CHALLENGER,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :FIGHTING, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTOFJUSTICE,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :DARK, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:INDUSTRIALIZE,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :STEEL, :SPEED, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :WATER, :SPECIAL_ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:ROCKCLIMBER,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :ROCK, :SPEED, 1, battle, showMessages, aiChecking)
    }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FILTHY,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :POISON, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:GLASSFIRING,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :FIRE, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1], nil, battle, showMessages, aiChecking)
  }
)

# pbBattleMoveImmunityHealAbility

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTLESS,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :FAIRY, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:POISONABSORB,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :POISON, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :ELECTRIC, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FINESUGAR,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :FIRE, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |_ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :WATER, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB, :DRYSKIN)

# Other immunities

BattleHandlers::MoveImmunityTargetAbility.add(:DRAGONSLAYER,
  proc { |_ability, user, target, _move, type, battle, showMessages, aiChecking|
      next false if user.index == target.index
      next false if type != :DRAGON
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:PECKINGORDER,
  proc { |_ability, user, target, _move, type, battle, showMessages, aiChecking|
      next false if user.index == target.index
      next false if type != :FLYING
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SLICKSURFACE,
  proc { |_ability, _user, target, move, _type, battle, showMessages|
      next false unless move.healingMove?
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |_ability, user, target, move, _type, battle, showMessages|
      next false if move.statusMove?
      next false if user.index == target.index || target.opposes?(user)
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |_ability, _user, target, move, type, battle, showMessages, aiChecking|
      next false if move.statusMove?
      next false if !type || Effectiveness.super_effective?(target.damageState.typeMod)
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |_ability, _user, target, move, _type, battle, showMessages|
      next false unless move.bombMove?
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |_ability, user, target, _move, type, battle, showMessages, aiChecking|
      next false if user.index == target.index
      next false if type != :FIRE
      battle.pbShowAbilitySplash(target) if showMessages
      unless aiChecking
        if !target.effectActive?(:FlashFire)
            target.applyEffect(:FlashFire)
        elsif showMessages
            battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
        end
      end
      battle.pbHideAbilitySplash(target)
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SOUNDPROOF,
  proc { |_ability, _user, target, move, _type, battle, showMessages|
      next false unless move.soundMove?
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WINTERINSULATION,
  proc { |_ability, _user, target, move, type, battle, showMessages|
      next false unless battle.pbWeather == :Hail
      next false unless %i[FIRE ELECTRIC].include?(type)
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MORPHINGGUARD,
  proc { |_ability, user, target, _move, type, battle, showMessages|
      next false unless user.effectActive?(:MorphingGuard)
      next false unless user.effects[:MorphingGuard] == type
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)