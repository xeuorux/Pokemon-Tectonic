
BattleHandlers::TargetItemOnHit.add(:AIRBALLOON,
  proc { |item,user,target,move,battle|
    battle.pbDisplay(_INTL("{1}'s {2} popped!",target.pbThis,target.itemName))
	target.pbScavenge
    target.pbConsumeItem(false,true)
    target.pbSymbiosis

  }
)