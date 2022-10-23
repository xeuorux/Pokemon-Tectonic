BattleHandlers::WeightCalcItem.add(:FLOATSTONE,
    proc { |item,battler,w|
      next [w/2,1].max
    }
  )