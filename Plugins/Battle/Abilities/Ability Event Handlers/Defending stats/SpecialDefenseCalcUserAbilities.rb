BattleHandlers::SpecialDefenseCalcUserAbility.add(:MARVELSKIN,
    proc { |_ability, user, _battle, spDefMult|
        spDefMult *= 2 if user.pbHasAnyStatus?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:SOLARCELL,
    proc { |_ability, _user, battle, spDefMult|
        spDefMult *= 1.25 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:FLOWERGIFT,
    proc { |_ability, _user, battle, spDefMult|
        spDefMult *= 1.5 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:ICESCALES,
    proc { |_ability, _user, _battle, spDefMult|
        spDefMult *= 2
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:PARANOID,
    proc { |_ability, _user, _battle, spDefMult|
        spDefMult *= 2
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:EXOADAPTION,
    proc { |_ability, _user, _battle, spDefMult|
        spDefMult *= 1.25
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:HEATVEIL,
    proc { |_ability, _user, _battle, spDefMult|
        spDefMult *= 2 if battle.pbWeather == :Sun
        next spDefMult
    }
)