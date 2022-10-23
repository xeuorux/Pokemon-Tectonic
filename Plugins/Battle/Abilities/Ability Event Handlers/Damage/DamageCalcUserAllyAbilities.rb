BattleHandlers::DamageCalcUserAllyAbility.add(:BATTERY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.specialMove?
    mults[:final_damage_multiplier] *= 1.3
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.physicalMove? && [:Sun, :HarshSun].include?(user.battle.pbWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:POWERSPOT,
    proc { |ability,user,target,move,mults,baseDmg,type|
      mults[:final_damage_multiplier]*= 1.3
    }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:STEELYSPIRIT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:POSITIVEOUTLOOK,
  proc { |ability,user,target,move,mults,baseDmg,type|
      mults[:base_damage_multiplier] *= 1.50 if user.pbHasType?(:ELECTRIC) && move.specialMove?
  }
)