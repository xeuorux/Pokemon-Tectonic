BattleHandlers::AttackCalcAllyAbility.add(:FLOWERGIFT,
    proc { |ability, _user, battle, attackMult|
        attackMult *= 1.5 if battle.sunny?
        next attackMult
    }
)
