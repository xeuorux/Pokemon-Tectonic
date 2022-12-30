BattleHandlers::EVGainModifierItem.add(:MACHOBRACE,
    proc { |_item, _battler, evYield|
        evYield.each_key { |stat| evYield[stat] *= 2 }
    }
)

BattleHandlers::EVGainModifierItem.add(:POWERANKLET,
  proc { |_item, _battler, evYield|
      evYield[:SPEED] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERBAND,
  proc { |_item, _battler, evYield|
      evYield[:SPECIAL_DEFENSE] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERBELT,
  proc { |_item, _battler, evYield|
      evYield[:DEFENSE] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERBRACER,
  proc { |_item, _battler, evYield|
      evYield[:ATTACK] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERLENS,
  proc { |_item, _battler, evYield|
      evYield[:SPECIAL_ATTACK] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERWEIGHT,
  proc { |_item, _battler, evYield|
      evYield[:HP] += 4
  }
)
