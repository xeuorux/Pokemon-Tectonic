BattleHandlers::SpeedCalcItem.add(:CHOICESCARF,
    proc { |item, _battler, mult|
        next mult * 1.4
    }
)

BattleHandlers::SpeedCalcItem.add(:IRONBALL,
  proc { |item, _battler, mult|
      next mult / 2
  }
)

BattleHandlers::SpeedCalcItem.add(:SEVENLEAGUEBOOTS,
  proc { |item, _battler, mult|
      next mult * 1.1
  }
)

BattleHandlers::SpeedCalcItem.add(:AGILITYHERB,
  proc { |item, battler, mult|
      if battler.effectActive?(:AgilityHerb)
        next mult * 2.0
      else
        next mult
      end
  }
)

