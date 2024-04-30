PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SPIKES,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Gored Upon the Horns of the Dilemma - Boredom or the Path of Thorns?"),
            _INTL("One layer of spikes will be placed on your side each turn!"),
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BeginningOfTurnCurseEffect.add(:CURSE_SPIKES,
    proc { |curse_policy, battle|
        battle.sides[0].incrementEffect(:Spikes)
    }
)