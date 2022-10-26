BattleHandlers::AccuracyCalcUserItem.add(:WIDELENS,
  proc { |item,mults,user,target,move,type|
    mults[:accuracy_multiplier] *= 1.35
  }
)

BattleHandlers::AccuracyCalcUserItem.add(:ZOOMLENS,
  proc { |item,mults,user,target,move,type|
    if (target.battle.choices[target.index][0]!=:UseMove &&
       target.battle.choices[target.index][0]!=:Shift) ||
       target.movedThisRound?
       mults[:accuracy_multiplier] *= 1.2
    end
  }
)