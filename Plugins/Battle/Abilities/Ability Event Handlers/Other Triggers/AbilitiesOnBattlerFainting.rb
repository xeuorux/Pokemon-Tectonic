BattleHandlers::AbilityOnBattlerFainting.add(:SOULHEART,
    proc { |_ability, battler, _fainted, _battle|
        battler.tryRaiseStat(:SPECIAL_ATTACK, battler, showAbilitySplash: true)
    }
)

BattleHandlers::AbilityOnBattlerFainting.add(:ARCANEFINALE,
    proc { |_ability, battler, fainted, battle|
        next if battler.opposes?(fainted)
        next unless battler.isLastAlive?
        battle.pbShowAbilitySplash(battler)
        battle.pbDisplay(_INTL("{1} is the team's finale!", battler.pbThis))
        battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::AbilityOnBattlerFainting.add(:HEROICFINALE,
    proc { |_ability, battler, fainted, battle|
        next if battler.opposes?(fainted)
        next unless battler.isLastAlive?
        battle.pbShowAbilitySplash(battler)
        battle.pbDisplay(_INTL("{1} is the team's finale!", battler.pbThis))
        battle.pbHideAbilitySplash(battler)
    }
)
