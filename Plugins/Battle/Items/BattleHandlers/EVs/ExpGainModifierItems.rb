BattleHandlers::ExpGainModifierItem.add(:LUCKYEGG,
    proc { |item, _battler, exp|
        next exp * 3 / 2
    }
)
