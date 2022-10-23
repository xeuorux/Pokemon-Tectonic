BattleHandlers::AccuracyCalcUserItem.add(:WIDELENS,
  proc { |item,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.35
  }
)

BattleHandlers::AccuracyCalcUserItem.add(:ZOOMLENS,
  proc { |item,mods,user,target,move,type|
    if (target.battle.choices[target.index][0]!=:UseMove &&
       target.battle.choices[target.index][0]!=:Shift) ||
       target.movedThisRound?
      mods[:accuracy_multiplier] *= 1.2
    end
  }
)