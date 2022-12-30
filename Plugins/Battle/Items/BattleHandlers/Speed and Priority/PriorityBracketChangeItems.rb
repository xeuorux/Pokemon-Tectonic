BattleHandlers::PriorityBracketChangeItem.add(:CUSTAPBERRY,
    proc { |_item, battler, subPri, _battle|
        next unless battler.canConsumePinchBerry?
        next 1 if subPri < 1
    }
)

BattleHandlers::PriorityBracketChangeItem.add(:LAGGINGTAIL,
  proc { |_item, _battler, subPri, _battle|
      next -1 if subPri == 0
  }
)

BattleHandlers::PriorityBracketChangeItem.copy(:LAGGINGTAIL, :FULLINCENSE)

BattleHandlers::PriorityBracketChangeItem.add(:QUICKCLAW,
  proc { |_item, _battler, subPri, battle|
      next 1 if subPri < 1 && battle.pbRandom(100) < 20
  }
)
