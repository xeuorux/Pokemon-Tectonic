BattleHandlers::DamageCalcUserAllyAbility.add(:POWERSPOT,
    proc { |_ability, _user, _target, _move, mults, _baseDmg, _type, _aiCheck|
        mults[:final_damage_multiplier] *= 1.3
    }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:STEELYSPIRIT,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:GRASSYSPIRIT,
    proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
        mults[:base_damage_multiplier] *= 1.5 if type == :GRASS
    }
  )

BattleHandlers::DamageCalcUserAllyAbility.add(:TOXICATTITUDE,
    proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
        mults[:base_damage_multiplier] *= 1.5 if type == :POISON
    }
  )
  