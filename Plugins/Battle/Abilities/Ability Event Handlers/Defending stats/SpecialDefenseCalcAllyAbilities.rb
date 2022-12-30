BattleHandlers::SpecialDefenseCalcAllyAbility.add(:FLOWERGIFT,
    proc { |_ability, _user, battle, spDefMult|
        spDefMult *= 1.5 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcAllyAbility.add(:NEGATIVEOUTLOOK,
    proc { |_ability, user, _battle, spDefMult|
        spDefMult *= 1.5 if user.pbHasType?(:ELECTRIC)
        next spDefMult
    }
)
