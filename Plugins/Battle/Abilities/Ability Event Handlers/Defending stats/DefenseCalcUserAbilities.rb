BattleHandlers::DefenseCalcUserAbility.add(:FLUFFY,
    proc { |_ability, _user, _battle, defenseMult|
        defenseMult *= 2
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:FURCOAT,
    proc { |_ability, _user, _battle, defenseMult|
        defenseMult *= 2
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:STEELYSHELL,
    proc { |_ability, _user, _battle, defenseMult|
        defenseMult *= 1.25
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:MARVELSCALE,
    proc { |_ability, user, _battle, defenseMult|
        defenseMult *= 1.5 if user.pbHasAnyStatus?
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:DESERTARMOR,
    proc { |_ability, _user, battle, defenseMult|
        defenseMult *= 2 if battle.pbWeather == :Sandstorm
        next defenseMult
    }
)

BattleHandlers::DefenseCalcUserAbility.add(:MOONBUBBLE,
    proc { |_ability, _user, battle, defenseMult|
        defenseMult *= 2 if battle.pbWeather == :Moonglow
        next defenseMult
    }
)
