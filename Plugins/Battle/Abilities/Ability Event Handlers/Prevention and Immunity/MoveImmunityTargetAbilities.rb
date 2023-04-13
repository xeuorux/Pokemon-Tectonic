# pbBattleMoveImmunityStatAbility

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :ELECTRIC, :SPECIAL_ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :ELECTRIC, :SPEED, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :GRASS, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:AERODYNAMIC,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :FLYING, :SPEED, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLYTRAP,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :BUG, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:COLDRECEPTION,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :ICE, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CHALLENGER,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :FIGHTING, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTOFJUSTICE,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :DARK, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:INDUSTRIALIZE,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :STEEL, :SPEED, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :WATER, :SPECIAL_ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:ROCKCLIMBER,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :ROCK, :SPEED, 1, battle, showMessages, aiChecking)
    }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FILTHY,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :POISON, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:GLASSFIRING,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :FIRE, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1], nil, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VENOMDETTA,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :POISON, :ATTACK, 1, battle, showMessages, aiChecking)
  }
)

# pbBattleMoveImmunityHealAbility

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTLESS,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :FAIRY, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:POISONABSORB,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :POISON, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :ELECTRIC, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FINESUGAR,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :FIRE, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :WATER, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STEELABSORB,
  proc { |ability, user, target, move, type, battle, showMessages, aiChecking|
    next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :STEEL, battle, showMessages, aiChecking)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB, :DRYSKIN)

# Other immunities

BattleHandlers::MoveImmunityTargetAbility.add(:DRAGONSLAYER,
  proc { |ability, user, target, _move, type, battle, showMessages, aiChecking|
      next false if user.index == target.index
      next false if type != :DRAGON
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:PECKINGORDER,
  proc { |ability, user, target, _move, type, battle, showMessages, aiChecking|
      next false if user.index == target.index
      next false if type != :FLYING
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SLICKSURFACE,
  proc { |ability, _user, target, move, _type, battle, showMessages|
      next false unless move.healingMove? && move.damagingMove?
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |ability, user, target, move, _type, battle, showMessages|
      next false if move.statusMove?
      next false if user.index == target.index || target.opposes?(user)
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |ability, _user, target, move, type, battle, showMessages, aiChecking|
      next false if move.statusMove?
      next false if !type
      if aiChecking
        typeMod = battle.battleAI.pbCalcTypeModAI(type, user, target, move)
      else
        typeMod = target.damageState.typeMod
      end
      next false if Effectiveness.super_effective?(typeMod)
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |ability, _user, target, move, _type, battle, showMessages|
      next false unless move.bombMove?
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |ability, user, target, _move, type, battle, showMessages, aiChecking|
      next false if user.index == target.index
      next false if type != :FIRE
      battle.pbShowAbilitySplash(target, ability) if showMessages
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
  proc { |ability, _user, target, move, _type, battle, showMessages|
      next false unless move.soundMove?
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WINTERINSULATION,
  proc { |ability, _user, target, move, type, battle, showMessages|
      next false unless battle.pbWeather == :Hail
      next false unless %i[FIRE ELECTRIC].include?(type)
      if showMessages
        battle.pbShowAbilitySplash(target, ability)
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
        battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MORPHINGGUARD,
  proc { |ability, user, target, _move, type, battle, showMessages|
      next false unless target.effectActive?(:MorphingGuard)
      next false unless target.effects[:MorphingGuard] == type
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)