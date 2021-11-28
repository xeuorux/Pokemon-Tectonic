module BattleHandlers
	ItemOnStatLoss                      = ItemHandlerHash.new
	FieldEffectStatLossItem				= ItemHandlerHash.new

	def self.triggerItemOnStatLoss(item,battler,user,move,switched,battle)
		ItemOnStatLoss.trigger(item,battler,user,move,switched,battle)
	end
	
	def self.triggerFieldEffectItem(item,battler,battle)
		FieldEffectStatLossItem.trigger(item,battler,battle)
	end		
end