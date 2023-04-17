#########################################
# Status condition abilities
#########################################

BattleHandlers::UserAbilityOnHit.add(:POISONTOUCH,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.physicalMove?
    randomStatusProcUserAbility(ability, :POISON, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:TOXICCLOUD,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.specialMove?
    randomStatusProcUserAbility(ability, :POISON, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:CHRONICCOLD,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.physicalMove?
    randomStatusProcUserAbility(ability, :FROSTBITE, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:CHILLOUT,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.specialMove?
    randomStatusProcUserAbility(ability, :FROSTBITE, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:NUMBINGTOUCH,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.physicalMove?
    randomStatusProcUserAbility(ability, :NUMB, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:NERVENUMBER,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.specialMove?
    randomStatusProcUserAbility(ability, :NUMB, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:STAGGERINGSLAPS,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.physicalMove?
    randomStatusProcUserAbility(ability, :DIZZY, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:BRAINSCRAMBLE,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.specialMove?
    randomStatusProcUserAbility(ability, :DIZZY, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SWARMIMPACT,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.physicalMove?
    randomStatusProcUserAbility(ability, :LEECHED, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SEEDSOWING,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.specialMove?
    randomStatusProcUserAbility(ability, :LEECHED, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:BURNSKILL,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.specialMove?
    randomStatusProcUserAbility(ability, :BURN, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:BURNOUT,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.physicalMove?
    randomStatusProcUserAbility(ability, :BURN, 30, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FROSTWINGS,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.calcType == :FLYING
    randomStatusProcUserAbility(ability, :FROSTBITE, 20, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SHOCKWINGS,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.calcType == :FLYING  
    randomStatusProcUserAbility(ability, :NUMB, 20, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FLAMEWINGS,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.calcType == :FLYING
    randomStatusProcUserAbility(ability, :BURN, 20, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:DAWNBURST,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless user.firstTurn?
    randomStatusProcUserAbility(ability, :BURN, 100, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FLASHFREEZE,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless user.firstTurn?
    randomStatusProcUserAbility(ability, :FROSTBITE, 100, user, target, move, battle, aiChecking, aiNumHits)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FUNGALFLURRY,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless user.firstTurn?
    randomStatusProcUserAbility(ability, :LEECH, 100, user, target, move, battle, aiChecking, aiNumHits)
  }
)

#########################################
# Other status abilities
#########################################

BattleHandlers::UserAbilityOnHit.add(:MENTALDAMAGE,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next if target.fainted?
    next if target.effectActive?(:Disable)
    next unless move.canApplyAdditionalEffects?(user, target, !aiChecking)
    if aiChecking
      next 15
    else
      battle.pbShowAbilitySplash(user, ability)
      target.applyEffect(:Disable,3) if target.canBeDisabled?(true, move)
      battle.pbHideAbilitySplash(user)
    end
  }
)

#########################################
# Stat change abilities
#########################################

BattleHandlers::UserAbilityOnHit.add(:GUARDBREAK,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.physicalMove?
    if aiChecking
      ret = 0
      aiNumHits.times do |i|
          ret += getMultiStatDownEffectScore([:DEFENSE,1], target, user, i)
      end
      next ret
    end
    target.tryLowerStat(:DEFENSE, user, ability: ability)
  }
)

BattleHandlers::UserAbilityOnHit.add(:WILLBREAK,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.specialMove?
    if aiChecking
      ret = 0
      aiNumHits.times do |i|
          ret += getMultiStatDownEffectScore([:SPECIAL_DEFENSE,1], target, user, i)
      end
      next ret
    end
    target.tryLowerStat(:SPECIAL_DEFENSE, user, ability: ability)
  }
)

BattleHandlers::UserAbilityOnHit.add(:RENDINGCLAWS,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless target.damageState.critical
    if aiChecking
      ret = 0
      aiNumHits.times do |i|
          ret += getMultiStatDownEffectScore(ALL_STATS_1, target, user, i)
      end
      next ret
    end
    target.pbLowerMultipleStatStages(ALL_STATS_1, user, ability: ability)
  }
)

#########################################
# Other Abilities
#########################################


BattleHandlers::UserAbilityOnHit.add(:EROSIONCYCLE,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
    next unless move.physicalMove?
    next if user.pbOwnSide.effectAtMax?(:ErodedRock)
    if aiChecking
        next (user.aboveHalfHealth? ? 10 : 5) * aiNumHits
    end
    user.pbOwnSide.incrementEffect(:ErodedRock)
  }
)