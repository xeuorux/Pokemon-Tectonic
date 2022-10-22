BattleHandlers::AccuracyCalcUserAllyAbility.add(:OCULAR,
    proc { |ability,mods,user,target,move,type|
      mods[:accuracy_multiplier] *= 1.5
    }
)