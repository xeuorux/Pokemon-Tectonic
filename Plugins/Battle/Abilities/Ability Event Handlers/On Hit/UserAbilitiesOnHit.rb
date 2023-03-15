BattleHandlers::UserAbilityOnHit.add(:POISONTOUCH,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:POISON, 30, user, target, move, battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:TOXICCLOUD,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:POISON, 30, user, target, move, battle) if move.specialMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:CHRONICCOLD,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:FROSTBITE, 30, user, target, move, battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:SHOCKSTYLE,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:NUMB, 50, user, target, move, battle) if move.type == :FIGHTING
  }
)

BattleHandlers::UserAbilityOnHit.add(:FROSTWINGS,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:FROSTBITE, 20, user, target, move, battle) if move.type == :FLYING
  }
)

BattleHandlers::UserAbilityOnHit.add(:SHOCKWINGS,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:NUMB, 20, user, target, move, battle) if move.type == :FLYING
  }
)

BattleHandlers::UserAbilityOnHit.add(:FLAMEWINGS,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:BURN, 20, user, target, move, battle) if move.type == :FLYING
  }
)

BattleHandlers::UserAbilityOnHit.add(:BURNSKILL,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:BURN, 30, user, target, move, battle) if move.specialMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:CHILLOUT,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:FROSTBITE, 30, user, target, move, battle) if move.specialMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:NUMBINGTOUCH,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:NUMB, 30, user, target, move, battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:NERVENUMBER,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:NUMB, 30, user, target, move, battle) if move.specialMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:DAWNBURST,
  proc { |_ability, user, target, move, battle|
      next if user.turnCount > 1
      randomStatusProcAbility(:BURN, 100, user, target, move, battle)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FLASHFREEZE,
  proc { |_ability, user, target, move, battle|
      next if user.turnCount > 1
      randomStatusProcAbility(:FROSTBITE, 100, user, target, move, battle)
  }
)

BattleHandlers::UserAbilityOnHit.add(:BRAINSCRAMBLE,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:DIZZY, 30, user, target, move, battle) if move.specialMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:STAGGERINGSLAPS,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:DIZZY, 30, user, target, move, battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:SWARMIMPACT,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:LEECHED, 30, user, target, move, battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:BURNOUT,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:BURN, 30, user, target, move, battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:NUMBINGTOUCH,
  proc { |_ability, user, target, move, battle|
      randomStatusProcAbility(:NUMB, 30, user, target, move, battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:MENTALDAMAGE,
  proc { |_ability, user, target, move, battle|
    next if target.fainted? || target.effectActive?(:Disable)
    next unless move.canApplyAdditionalEffects?(user, target, true)
    battle.pbShowAbilitySplash(user)
    target.applyEffect(:Disable,3) if target.canBeDisabled?(true, move)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:ROCKCYCLE,
  proc { |_ability, user, target, move, battle|
    user.pbOwnSide.applyEffect(:ErodedRock) if move.physicalMove?
  }
)