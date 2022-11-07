BattleHandlers::ItemOnIntimidated.add(:ADRENALINEORB,
    proc { |item,battler,battle|
      next battler.tryRaiseStat(:SPEED,battler,item: item)
    }
  )