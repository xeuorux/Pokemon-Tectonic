BattleHandlers::WeightCalcItem.add(:FLOATSTONE,
    proc { |_item, _battler, w|
        next [w / 2, 1].max
    }
)
