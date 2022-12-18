BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 0.75
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:MISTBLANKET,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 0.75 if user.battle.field.terrain == :Fairy
  }
)