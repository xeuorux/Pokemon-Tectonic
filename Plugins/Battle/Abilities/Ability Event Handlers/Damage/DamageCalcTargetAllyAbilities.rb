BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:MISTBLANKET,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.field.terrain == :Fairy
  }
)
