PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SUPER_ITEMS,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Bedecked with Iron, Bedighted with Venom, Bewinged with Vaults Open and Weapons Free"),
            _INTL("Opposing Pokemon hold super-powerful items. Stolen items turn to dust.")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)
