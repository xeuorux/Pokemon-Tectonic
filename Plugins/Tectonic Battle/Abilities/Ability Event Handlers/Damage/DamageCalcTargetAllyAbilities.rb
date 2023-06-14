BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability, _user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:MISTBLANKET,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.moonGlowing?
  }
)
