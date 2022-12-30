BattleHandlers::ExpGainModifierItem.add(:LUCKYEGG,
    proc { |_item, _battler, exp|
        next exp * 3 / 2
    }
)
