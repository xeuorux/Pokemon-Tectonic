BattleHandlers::ExpGainModifierItem.add(:LUCKYEGG,
    proc { |item,battler,exp|
      next exp*3/2
    }
  )