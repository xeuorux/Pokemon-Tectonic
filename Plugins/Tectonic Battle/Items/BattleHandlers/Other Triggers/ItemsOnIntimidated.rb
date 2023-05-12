BattleHandlers::ItemOnIntimidated.add(:ADRENALINEORB,
    proc { |item, battler, _battle|
        next battler.tryRaiseStat(:SPEED, battler, item: item, increment: 2)
    }
)
