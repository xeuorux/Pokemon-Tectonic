BattleHandlers::DefenseCalcUserAbility.add(:FLUFFY,
    proc { |ability, _user, _battle, defenseMult|
        defenseMult *= 2
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:FURCOAT,
    proc { |ability, _user, _battle, defenseMult|
        defenseMult *= 2
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:MARVELSCALE,
    proc { |ability, user, _battle, defenseMult|
        defenseMult *= 1.5 if user.pbHasAnyStatus?
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:DESERTARMOR,
    proc { |ability, _user, battle, defenseMult|
        defenseMult *= 2 if battle.pbWeather == :Sandstorm
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:MOONBUBBLE,
    proc { |ability, _user, battle, defenseMult|
        defenseMult *= 2 if battle.pbWeather == :Moonglow
        next defenseMult
    }
)
