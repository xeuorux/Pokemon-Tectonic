PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_TORMENTED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates("Tormented")
        battle.pbDisplaySlower(_INTL("Your Pokemon gain the \"Tormented\" status when they enter battle."))
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BattlerEnterCurseEffect.add(:CURSE_TORMENTED,
    proc { |_curse_policy, battler, _battle|
        next if battler.opposes?
        battler.applyEffect(:Torment)
    }
)
