BattleHandlers::PriorityBracketUseItem.add(:CUSTAPBERRY,
    proc { |item, battler, battle|
        battle.pbCommonAnimation("Nom", battler)
        battle.pbDisplay(_INTL("{1}'s {2} let it move first!", battler.pbThis, getItemName(battler.baseItem)))
        battler.pbConsumeItem(item)
    }
)

BattleHandlers::PriorityBracketUseItem.add(:QUICKCLAW,
  proc { |item, battler, battle|
      battle.pbCommonAnimation("UseItem", battler)
      battle.pbDisplay(_INTL("{1}'s {2} let it move first!", battler.pbThis, getItemName(battler.baseItem)))
  }
)
