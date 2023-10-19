BattleHandlers::AbilityOnBattlerFainting.add(:SOULHEART,
    proc { |ability, battler, _fainted, _battle|
        battler.tryRaiseStat(:SPECIAL_ATTACK, battler, ability: ability)
    }
)

BattleHandlers::AbilityOnBattlerFainting.add(:ARCANEFINALE,
    proc { |ability, battler, fainted, battle|
        next if battler.opposes?(fainted)
        next unless battler.isLastAlive?
        next unless battler.form == 0
        battle.pbShowAbilitySplash(battler, ability)
        battler.pbChangeForm(1, _INTL("{1} is the team's finale!", battler.pbThis))
        battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::AbilityOnBattlerFainting.copy(:ARCANEFINALE,:HEROICFINALE)


BattleHandlers::AbilityOnBattlerFainting.add(:SCHADENFREUDE,
    proc { |ability, battler, fainted, _battle|
    battler.applyFractionalHealing(1.0 / 4.0, ability: ability) if battler.opposes?(fainted)
    }
)