BattleHandlers::DamageCalcTargetAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.specialMove? && [:Sun, :HarshSun].include?(user.battle.pbWeather)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 0.75
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:NEGATIVEOUTLOOK,
    proc { |ability,user,target,move,mults,baseDmg,type|
      mults[:final_damage_multiplier] *= (2.0/3.0) if target.pbHasType?(:ELECTRIC) && move.specialMove?
       }
)