BattleHandlers::SpeedCalcItem.add(:CHOICESCARF,
    proc { |_item, _battler, mult|
        next mult * 1.33
    }
)

BattleHandlers::SpeedCalcItem.add(:MACHOBRACE,
  proc { |_item, _battler, mult|
      next mult / 2
  }
)

BattleHandlers::SpeedCalcItem.copy(:MACHOBRACE, :POWERANKLET, :POWERBAND, :POWERBELT, :POWERBRACER, :POWERLENS,
:POWERWEIGHT)

BattleHandlers::SpeedCalcItem.add(:QUICKPOWDER,
  proc { |_item, battler, mult|
      next mult * 2 if battler.isSpecies?(:DITTO) && !battler.transformed?
  }
)

BattleHandlers::SpeedCalcItem.add(:IRONBALL,
  proc { |_item, _battler, mult|
      next mult / 2
  }
)

BattleHandlers::SpeedCalcItem.add(:SEVENLEAGUEBOOTS,
  proc { |_item, _battler, mult|
      next mult * 1.1
  }
)
