PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_STORM_TOTEM,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("A Dance of Dualities and Potent Pluralities, A Futile Flailing in the Truth of Totality."),
            _INTL("Turbulent Sky is continually active on the opposing side."),
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BattlerEnterCurseEffect.add(:CURSE_STORM_TOTEM,
    proc { |_curse_policy, battler, _battle|
        next unless battler.opposes?
        battler.pbOwnSide.applyEffect(:TurbulentSky, 1000)
    }
)