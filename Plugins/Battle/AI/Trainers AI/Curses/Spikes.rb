PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SPIKES,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates("Spikes")
        spikesCount = battle.sides[0].incrementEffect(:Spikes, GameData::BattleEffect.get(:Spikes).maximum)
        explanation = _INTL("#{spikesCount} layers of Spikes were scattered around you!")
        battle.amuletActivates(
            _INTL("Gored Upon the Horns of the Dilemma - Boredom or the Path of Thorns?"),
            explanation
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)
