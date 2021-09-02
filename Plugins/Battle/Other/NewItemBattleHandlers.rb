module BattleHandlers
	ItemOnStatLoss                      = ItemHandlerHash.new

	def self.triggerItemOnStatLoss(item,battler,user,move,switched,battle)
		ItemOnStatLoss.trigger(item,battler,user,move,switched,battle)
	end
end