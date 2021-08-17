module BattleHandlers
	ItemOnStatLoss                      = ItemHandlerHash.new

	def self.triggerItemOnStatLoss(item,battler,user,move,switched,battle)
		ItemOnStatLoss.trigger(item,battler,user,move,switched,battle)
	end

	AbilityOnEnemySwitchIn              = AbilityHandlerHash.new

	def self.triggerAbilityOnEnemySwitchIn(ability,switcher,bearer,battle)
		AbilityOnEnemySwitchIn.trigger(ability,switcher,bearer,battle)
	end
	
	def self.triggerPriorityChangeAbility(ability,battler,move,pri,targets=[])
		ret = PriorityChangeAbility.trigger(ability,battler,move,pri,targets)
		return (ret!=nil) ? ret : pri
	end
end