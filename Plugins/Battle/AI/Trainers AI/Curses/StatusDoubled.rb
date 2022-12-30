PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_STATUS_DOUBLED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates("Statuses Doubled")
        battle.pbDisplaySlower(_INTL("The negative effects of status conditions on your Pokémon are doubled!"))
        battle.pbDisplaySlower(_INTL("Also, status condition immunities by effects are ignored."))
        curses_array.push(curse_policy)
        next curses_array
    }
)
