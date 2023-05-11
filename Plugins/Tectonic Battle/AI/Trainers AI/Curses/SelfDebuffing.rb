PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SELF_DEBUFFING,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Every Beat Betrays the Beast's Burden"),
            _INTL("After your Pokemon attack, the attacking stat that was used is lowered by 4 steps.")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::MoveUsedCurseEffect.add(:CURSE_SELF_DEBUFFING,
    proc { |_curse_policy, user, _target, move|
        next if user.opposes?
        next unless move.damagingMove?

        relevant_stat = move.specialMove? ? :SPECIAL_ATTACK : :ATTACK
        user.pbItemStatRestoreCheck if user.pbLowerStatStep(relevant_stat, 4, nil, true, true)
        next true
    }
)
