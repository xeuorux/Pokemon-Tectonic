BattleHandlers::SpecialDefenseCalcUserAbility.add(:MARVELSKIN,
    proc { |ability,user,battle,spDefMult|
        spDefMult *= 2 if user.pbHasAnyStatus?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:SOLARCELL,
    proc { |ability,user,battle,spDefMult|
        spDefMult *= 1.25 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:FLOWERGIFT,
    proc { |ability,user,battle,spDefMult|
        spDefMult *= 1.5 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:ICESCALES,
    proc { |ability,user,battle,spDefMult|
        spDefMult *= 2
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:PARANOID,
    proc { |ability,user,battle,spDefMult|
        spDefMult *= 2
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:EXOADAPTION,
    proc { |ability,user,battle,spDefMult|
        spDefMult *= 1.5
        next spDefMult
    }
)