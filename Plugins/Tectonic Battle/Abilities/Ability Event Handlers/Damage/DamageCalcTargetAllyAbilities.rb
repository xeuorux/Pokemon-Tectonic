BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type, aiCheck|
      mults[:final_damage_multiplier] *= 0.75
      target.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:MOONBLANKET,
  proc { |ability, user, target, _move, mults, _baseDmg, _type, aiCheck|
    if user.battle.moonGlowing?
      mults[:final_damage_multiplier] *= 0.75
      target.aiLearnsAbility(ability) unless aiCheck
    end
  }
)
