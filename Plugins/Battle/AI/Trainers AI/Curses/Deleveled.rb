class Pokemon
    attr_accessor :pre_curse_exp
end

PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_DELEVELED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates("Deleveled")
        battle.pbDisplaySlower(_INTL(""))

        battle.amuletActivates(
            _INTL("Forevers Traversed yet Ever No Better"),
            _INTL("Your Pokemon lose 10 levels for this fight. EXP goes to the Dispenser.")
        )

        battle.expCapped = true

        $Trainer.party.each do |pokemon|
            pokemon.pre_curse_exp = pokemon.exp
            pokemon.level = [1, pokemon.level - 10].max
            pokemon.calc_stats
        end

        battle.eachSameSideBattler(0) do |battler|
            battler.pbUpdate
        end

        battle.scene.pbRefresh

        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BattleEndCurse.add(:CURSE_DELEVELED,
    proc { |_curse_policy, _battle|
        $Trainer.party.each do |pokemon|
            pokemon.exp = pokemon.pre_curse_exp
            pokemon.calc_stats
        end
    }
)
