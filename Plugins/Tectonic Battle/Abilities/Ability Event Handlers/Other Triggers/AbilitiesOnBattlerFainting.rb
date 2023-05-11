BattleHandlers::AbilityOnBattlerFainting.add(:SOULHEART,
    proc { |ability, battler, _fainted, _battle|
        battler.tryRaiseStat(:SPECIAL_ATTACK, battler, ability: ability)
    }
)

BattleHandlers::AbilityOnBattlerFainting.add(:ARCANEFINALE,
    proc { |ability, battler, fainted, battle|
        next if battler.opposes?(fainted)
        next unless battler.isLastAlive?
        battle.pbShowAbilitySplash(battler, ability)
        battle.pbDisplay(_INTL("{1} is the team's finale!", battler.pbThis))
        battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::AbilityOnBattlerFainting.add(:HEROICFINALE,
    proc { |ability, battler, fainted, battle|
        next if battler.opposes?(fainted)
        next unless battler.isLastAlive?
        battle.pbShowAbilitySplash(battler, ability)
        battle.pbDisplay(_INTL("{1} is the team's finale!", battler.pbThis))
        battle.pbHideAbilitySplash(battler)
    }
)
