#=============================================================================
# Protean-style abilities
#=============================================================================
BattleHandlers::UserAbilityStartOfMove.add(:PROTEAN,
  proc { |ability, user, targets, move, battle|
    moveUseTypeChangeAbility(ability, user, move, battle)
  }
)

BattleHandlers::UserAbilityStartOfMove.copy(:PROTEAN,:FREESTYLE)

BattleHandlers::UserAbilityStartOfMove.add(:SHAKYCODE,
  proc { |ability, user, targets, move, battle|
    moveUseTypeChangeAbility(ability, user, move, battle) if battle.eclipsed?
  }
)

BattleHandlers::UserAbilityStartOfMove.add(:MUTABLE,
  proc { |ability, user, targets, move, battle|
    next if user.effectActive?(:Mutated)
    next unless moveUseTypeChangeAbility(ability, user, move, battle)
    user.applyEffect(:Mutated)
  }
)

BattleHandlers::UserAbilityStartOfMove.add(:SHIFTINGFIST,
  proc { |ability, user, targets, move, battle|
    moveUseTypeChangeAbility(ability, user, move, battle, true) if move.punchingMove?
  }
)

BattleHandlers::UserAbilityStartOfMove.add(:REFRACTIVE,
  proc { |ability, user, targets, move, battle|
    moveUseTypeChangeAbility(ability, user, move, battle, true) if move.lightMove?
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:RAGEMANEUVERS,
  proc { |ability, user, targets, move, battle|
    next unless move.rampagingMove?
    user.applyEffect(:RampageLocked)
  }
)
  
BattleHandlers::UserAbilityStartOfMove.add(:RAINBOWTRAIL,
  proc { |ability, user, targets, move, battle|
    type = move.calcType
    if type == :FIRE && user.effectActive?(:RainbowTrailEntry)
      user.disableEffect(:RainbowTrailEntry)
      user.showMyAbilitySplash(ability)
      battle.pbDisplay(_INTL("{1}'s rainbows shine with an aura of {2}!", user.pbThis, GameData::Type.get(type).name))
      battle.scene.pbRefresh
      user.hideMyAbilitySplash
    end
    next if user.pbHasType?(type)
    if user.effectActive?(:RainbowTrail)
        user.effects[:RainbowTrail].push(type)
    else
        user.applyEffect(:RainbowTrail,[type])
    end

    typeName = GameData::Type.get(type).name
    user.showMyAbilitySplash(ability)
    battle.pbDisplay(_INTL("{1}'s rainbows shine with an aura of {2}!", user.pbThis, typeName))
    battle.scene.pbRefresh
    user.hideMyAbilitySplash
  }
)
