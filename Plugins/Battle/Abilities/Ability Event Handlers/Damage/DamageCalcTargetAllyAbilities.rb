BattleHandlers::DamageCalcTargetAllyAbility.add(:NEGATIVEOUTLOOK,
    proc { |ability,user,target,move,mults,baseDmg,type|
      mults[:final_damage_multiplier] *= (2.0/3.0) if target.pbHasType?(:ELECTRIC) && move.specialMove?
       }
)