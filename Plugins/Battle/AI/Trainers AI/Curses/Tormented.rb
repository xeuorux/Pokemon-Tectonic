PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_TORMENTED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Lucid? Lose it. Lunacy looms lucent. Let loose."),
            _INTL("Your Pokemon are Tormented on entry.")
        )
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
