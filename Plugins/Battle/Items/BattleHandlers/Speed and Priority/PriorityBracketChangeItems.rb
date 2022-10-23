BattleHandlers::PriorityBracketChangeItem.add(:CUSTAPBERRY,
    proc { |item,battler,subPri,battle|
      next if !battler.canConsumePinchBerry?
      next 1 if subPri<1
    }
  )
  
  BattleHandlers::PriorityBracketChangeItem.add(:LAGGINGTAIL,
    proc { |item,battler,subPri,battle|
      next -1 if subPri==0
    }
  )
  
  BattleHandlers::PriorityBracketChangeItem.copy(:LAGGINGTAIL,:FULLINCENSE)
  
  BattleHandlers::PriorityBracketChangeItem.add(:QUICKCLAW,
    proc { |item,battler,subPri,battle|
      next 1 if subPri<1 && battle.pbRandom(100)<20
    }
  )