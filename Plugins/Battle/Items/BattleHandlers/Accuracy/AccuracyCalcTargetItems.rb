BattleHandlers::AccuracyCalcTargetItem.add(:BRIGHTPOWDER,
    proc { |_item, mults, _user, _target, _move, _type|
        mults[:accuracy_multiplier] *= 0.9
    }
)

BattleHandlers::AccuracyCalcTargetItem.copy(:BRIGHTPOWDER, :LAXINCENSE)
