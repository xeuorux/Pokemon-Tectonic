BattleHandlers::AbilityOnAllySwitchIn.add(:SWARMINSTINCT,
    proc { |ability, switcher, bearer, battle, aiCheck|
        next getMultiStatUpEffectScore([:SPEED, 1], bearer, bearer) if aiCheck
        battle.pbShowAbilitySplash(bearer, ability)
        bearer.tryRaiseStat(:SPEED, bearer, increment: 1)
        battle.pbHideAbilitySplash(bearer)
    }
)

BattleHandlers::AbilityOnAllySwitchIn.add(:PROTECTIVEINSTINCT,
  proc { |ability, switcher, bearer, battle, aiCheck|
      next 0 if aiCheck
      next unless switcher.notFullyEvolved?
      battle.pbShowAbilitySplash(bearer, ability)
      battle.pbDisplay(_INTL("{1} bonds with its younger allies!", bearer.pbThis))
      battle.pbHideAbilitySplash(bearer)
  }
) 