BattleHandlers::AccuracyCalcUserItem.add(:WIDELENS,
  proc { |item, mults, _user, _target, _move, _type, aiCheck|
      mults[:accuracy_multiplier] *= 1.35
  }
)

BattleHandlers::AccuracyCalcUserItem.add(:ZOOMLENS,
  proc { |item, mults, user, target, _move, _type, aiCheck|
    if aiCheck
      if target.pbSpeed(true) > user.pbSpeed(true)
          mults[:accuracy_multiplier] *= 2.0
      end
    else
      if (target.battle.choices[target.index][0] != :UseMove &&
        target.battle.choices[target.index][0] != :Shift) ||
        target.movedThisRound?
          mults[:accuracy_multiplier] *= 2.0
      end
    end
  }
)

BattleHandlers::AccuracyCalcUserItem.add(:SKILLHERB,
  proc { |item, mults, user, _target, _move, _type, aiCheck|
      next unless mults[:base_accuracy] < 100
      mults[:base_accuracy] = 0 # Can't miss
      user.applyEffect(:SkillHerbConsumed) unless aiCheck
  }
)