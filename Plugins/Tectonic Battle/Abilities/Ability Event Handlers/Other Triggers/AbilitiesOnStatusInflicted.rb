BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
    proc { |ability, battler, user, status|
        next if !user || user.index == battler.index
        next unless user.pbCanSynchronizeStatus?(status, battler)
        battler.battle.pbShowAbilitySplash(battler, ability)
        user.pbInflictStatus(status)
        battler.battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::AbilityOnStatusInflicted.add(:DARING,
    proc { |ability, battler, _user, _status|
        battler.tryRaiseStat(:ATTACK, battler, increment: 3, ability: ability)
    }
)

BattleHandlers::AbilityOnStatusInflicted.add(:IMPULSIVE,
    proc { |ability, battler, _user, _status|
        battler.tryRaiseStat(:SPECIAL_ATTACK, battler, increment: 3, ability: ability)
    }
)