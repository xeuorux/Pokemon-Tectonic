BattleHandlers::DefenseCalcUserAbility.add(:FLUFFY,
    proc { |ability,user,battle,defenseMult|
        defenseMult *= 2
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:FURCOAT,
    proc { |ability,user,battle,defenseMult|
        defenseMult *= 2
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:STEELYSHELL,
    proc { |ability,user,battle,defenseMult|
        defenseMult *= 1.25
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:MARVELSCALE,
    proc { |ability,user,battle,defenseMult|
      defenseMult *= 1.5 if user.pbHasAnyStatus?
      next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:HEADSTRONG,
    proc { |ability,user,battle,defenseMult|
        defenseMult *= 2 if battle.field.terrain == :Psychic
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:DESERTARMOR,
    proc { |ability,user,battle,defenseMult|
        defenseMult *= 2 if battle.pbWeather == :Sandstorm
        next defenseMult
    }
)