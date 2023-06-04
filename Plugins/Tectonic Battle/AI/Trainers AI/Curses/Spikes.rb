PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SPIKES,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(_INTL("Gored Upon the Horns of the Dilemma - Boredom or the Path of Thorns?"))
        battle.sides[0].incrementEffect(:Spikes, GameData::BattleEffect.get(:Spikes).maximum)
        curses_array.push(curse_policy)
        next curses_array
    }
)
