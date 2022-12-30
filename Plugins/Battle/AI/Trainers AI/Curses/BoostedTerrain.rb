PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_ELECTRIC,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates("Boosted Electric Terrain")
        battle.pbDisplaySlower(_INTL("The battle starts with Electric Terrain. When active, Electric-types are 50% faster."))
        curses_array.push(curse_policy)
        battle.pbStartTerrain(nil, :Electric, false)
        next curses_array
    }
)
