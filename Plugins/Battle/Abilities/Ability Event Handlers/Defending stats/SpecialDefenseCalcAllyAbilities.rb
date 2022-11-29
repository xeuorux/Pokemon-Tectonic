BattleHandlers::SpecialDefenseCalcAllyAbility.add(:FLOWERGIFT,
    proc { |ability,user,battle,spDefMult|
        spDefMult *= 1.5 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcAllyAbility.add(:NEGATIVEOUTLOOK,
    proc { |ability,user,battle,spDefMult|
        spDefMult *= 1.5 if target.pbHasType?(:ELECTRIC)
        next spDefMult
    }
)