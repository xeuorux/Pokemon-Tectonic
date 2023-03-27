BattleHandlers::AccuracyCalcUserItem.add(:WIDELENS,
  proc { |item, mults, _user, _target, _move, _type|
      mults[:accuracy_multiplier] *= 1.35
  }
)

BattleHandlers::AccuracyCalcUserItem.add(:ZOOMLENS,
  proc { |item, mults, _user, target, _move, _type|
      if (target.battle.choices[target.index][0] != :UseMove &&
         target.battle.choices[target.index][0] != :Shift) ||
         target.movedThisRound?
          mults[:accuracy_multiplier] *= 1.2
      end
  }
)
