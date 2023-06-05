PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_EXTRA_TYPES,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("A Portrait of the Opposition in Radiant Ulfire and Stygian Blue"),
            _INTL("Enemy Pokemon all have an extra type.")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BattlerEnterCurseEffect.add(:CURSE_EXTRA_TYPES,
    proc { |_curse_policy, battler, battle|
        next unless battler.opposes?

        type = nil
        case battler.species
        when :MRRIME
            type = :FAIRY
        when :METAGROSS
            type = :FLYING
        when :LUNATONE
            type = :ELECTRIC
        when :CRABOMINABLE
            type = :DARK
        when :GLALIE
            type = :GHOST
        when :GIRAFARIG
            type = :STEEL
        end
        battler.effects[:Type3] = type

        battle.scene.pbRefresh
    }
)
