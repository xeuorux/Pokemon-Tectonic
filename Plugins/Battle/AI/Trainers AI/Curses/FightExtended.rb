PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_FIGHT_EXTENDED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates("Yezera's Spirit")
        battle.pbDisplaySlower(_INTL("Yezera won't leave the battle early. This is a true fight!"))
        battle.turnsToSurvive = -1
        curses_array.push(curse_policy)
        next curses_array
    }
)
