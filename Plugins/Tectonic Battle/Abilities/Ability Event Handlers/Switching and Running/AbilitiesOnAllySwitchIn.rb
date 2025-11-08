BattleHandlers::AbilityOnAllySwitchIn.add(:SWARMINSTINCT,
    proc { |ability, switcher, bearer, battle, aiCheck|
        next getMultiStatUpEffectScore([:SPEED, 1], bearer, bearer) if aiCheck
        battle.pbShowAbilitySplash(bearer, ability)
        bearer.tryRaiseStat(:SPEED, bearer, increment: 1)
        battle.pbHideAbilitySplash(bearer)
    }
)
