# pbBattleMoveImmunityStatAbility
BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :ELECTRIC, :SPEED, 1, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :GRASS, ATTACKING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:AERODYNAMIC,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :FLYING, :SPEED, 1, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLYTRAP,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :BUG, ATTACKING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:COLDRECEPTION,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :ICE, ATTACKING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CHALLENGER,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :FIGHTING, ATTACKING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTOFJUSTICE,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :DARK, ATTACKING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:INDUSTRIALIZE,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :STEEL, :SPEED, 1, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:ROCKCLIMBER,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :ROCK, :SPEED, 1, battle, showMessages, aiCheck)
    }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FILTHY,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :POISON, DEFENDING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:GLASSFIRING,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :FIRE, DEFENDING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VENOMDETTA,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :POISON, ATTACKING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FOOLHARDY,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :PSYCHIC, ATTACKING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FIREFIGHTER,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityStatAbility(ability, user, target, move, type, :FIRE, ATTACKING_STATS_1, nil, battle, showMessages, aiCheck)
  }
)

# pbBattleMoveImmunityHealAbility

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTLESS,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :FAIRY, battle, showMessages, aiCheck, canOverheal: true)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:POISONABSORB,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :POISON, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :ELECTRIC, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FINESUGAR,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :FIRE, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :WATER, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STEELABSORB,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
    next pbBattleMoveImmunityHealAbility(ability, user, target, move, type, :STEEL, battle, showMessages, aiCheck)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB, :DRYSKIN)

# Other immunities

BattleHandlers::MoveImmunityTargetAbility.add(:DRAGONSLAYER,
  proc { |ability, user, target, _move, type, battle, showMessages, aiCheck|
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
  proc { |ability, user, target, _move, type, battle, showMessages, aiCheck|
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

def typeModToCheck(battle, type, user, target, move, aiCheck)
  if aiCheck
    typeMod = battle.battleAI.pbCalcTypeModAI(type, user, target, move)
  else
    typeMod = target.damageState.typeMod
  end
  return typeMod
end

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |ability, user, target, move, type, battle, showMessages, aiCheck|
      next false if move.statusMove?
      next false if !type
      next false if Effectiveness.super_effective?(typeModToCheck(battle, type, user, target, move, aiCheck))
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
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
      next false unless battle.icy?
      next false unless %i[FIRE ELECTRIC].include?(type)
      if showMessages
        battle.pbShowAbilitySplash(target, ability)
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
        battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:INDESTRUCTIBLE,
  proc { |ability, user, target, _move, type, battle, showMessages|
      next false unless target.effectActive?(:Indestructible)
      next false unless target.effects[:Indestructible] == type
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FULLBLUBBER,
  proc { |ability, user, target, _move, type, battle, showMessages, aiCheck|
      next false if user.index == target.index
      next false unless %i[FIRE ICE].include?(type)
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MUPROTOCOL,
  proc { |ability, user, target, _move, type, battle, showMessages, aiCheck|
      next false if user.index == target.index
      next false unless user.shouldItemApply?(:MEMORYSET, aiCheck)
      next false unless type == user.itemTypeChosen
      if showMessages
          battle.pbShowAbilitySplash(target, ability)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
          
          target.aiLearnsItem(:MEMORYSET)
      end
      next true
  }
)