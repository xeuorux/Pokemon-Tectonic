BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability, _user, target, _owner, _move, mults, _baseDmg, _type, aiCheck|
      mults[:final_damage_multiplier] *= 0.75
      target.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:MOONBLANKET,
  proc { |ability, user, target, _owner, _move, mults, _baseDmg, _type, aiCheck|
    if user.battle.moonGlowing?
      mults[:final_damage_multiplier] *= 0.75
      target.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:PROTECTIVEINSTINCT,
  proc { |ability, user, target, _owner, _move, mults, _baseDmg, _type, aiCheck|
    if target.notFullyEvolved?
      mults[:final_damage_multiplier] *= 0.66
      target.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:RAINBOWGUARDIAN,
  proc { |ability, user, target, owner, _move, mults, _baseDmg, _type, aiCheck|
    if owner.effectActive?(:ChoseStatus)
      mults[:final_damage_multiplier] *= 0.66
      target.aiLearnsAbility(ability) unless aiCheck
    end
  }
)