PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_FIGHT_EXTENDED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("The Visitation of the Illusive Inevitable: Landfall"),
            _INTL("Yezera won't leave the battle early. This is a true fight!")
        )
        battle.turnsToSurvive = -1
        battle.scene.pbHideTurnCountReminder
        curses_array.push(curse_policy)
        next curses_array
    }
)
