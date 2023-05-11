BattleHandlers::WeightCalcItem.add(:FLOATSTONE,
    proc { |item, _battler, w|
        next [w / 2, 1].max
    }
)
