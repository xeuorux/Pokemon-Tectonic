BattleHandlers::AccuracyCalcUserAllyAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

BattleHandlers::AccuracyCalcUserAllyAbility.add(:OCULAR,
    proc { |ability,mods,user,target,move,type|
      mods[:accuracy_multiplier] *= 1.5
    }
)