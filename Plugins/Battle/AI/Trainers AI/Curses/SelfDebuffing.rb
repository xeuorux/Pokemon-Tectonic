PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SELF_DEBUFFING,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates("Self Debuffing")
        battle.pbDisplaySlower(_INTL("When your Pokemon use damaging moves, their Attack is lowered if that move is physical, and their Sp. Atk is lowered if that move was special. This ignores Contrary."))
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::MoveUsedCurseEffect.add(:CURSE_SELF_DEBUFFING,
    proc { |_curse_policy, user, _target, move|
        next if user.opposes?
        next unless move.damagingMove?

        relevant_stat = move.specialMove? ? :SPECIAL_ATTACK : :ATTACK
        user.pbItemStatRestoreCheck if user.pbLowerStatStage(relevant_stat, 1, nil, true, true)
        next true
    }
)
