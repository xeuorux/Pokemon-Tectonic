BattleHandlers::PriorityBracketUseItem.add(:CUSTAPBERRY,
    proc { |_item, battler, battle|
        battle.pbCommonAnimation("Nom", battler)
        battle.pbDisplay(_INTL("{1}'s {2} let it move first!", battler.pbThis, battler.itemName))
        battler.pbConsumeItem
    }
)

BattleHandlers::PriorityBracketUseItem.add(:QUICKCLAW,
  proc { |_item, battler, battle|
      battle.pbCommonAnimation("UseItem", battler)
      battle.pbDisplay(_INTL("{1}'s {2} let it move first!", battler.pbThis, battler.itemName))
  }
)
