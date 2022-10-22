BattleHandlers::AccuracyCalcTargetAbility.add(:TANGLEDFEET,
    proc { |ability,mods,user,target,move,type|
      mods[:accuracy_multiplier] /= 2 if target.confused? || target.charmed?
    }
  )