BattleHandlers::EVGainModifierItem.add(:MACHOBRACE,
    proc { |item, _battler, evYield|
        evYield.each_key { |stat| evYield[stat] *= 2 }
    }
)

BattleHandlers::EVGainModifierItem.add(:POWERANKLET,
  proc { |item, _battler, evYield|
      evYield[:SPEED] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERBAND,
  proc { |item, _battler, evYield|
      evYield[:SPECIAL_DEFENSE] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERBELT,
  proc { |item, _battler, evYield|
      evYield[:DEFENSE] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERBRACER,
  proc { |item, _battler, evYield|
      evYield[:ATTACK] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERLENS,
  proc { |item, _battler, evYield|
      evYield[:SPECIAL_ATTACK] += 4
  }
)

BattleHandlers::EVGainModifierItem.add(:POWERWEIGHT,
  proc { |item, _battler, evYield|
      evYield[:HP] += 4
  }
)
