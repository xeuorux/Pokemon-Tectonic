module BattleHandlers
	AbilityOnEnemySwitchIn              = AbilityHandlerHash.new
	MoveImmunityAllyAbility           	= AbilityHandlerHash.new
    OnBerryConsumedAbility           	  = AbilityHandlerHash.new

	def self.triggerAbilityOnEnemySwitchIn(ability,switcher,bearer,battle)
		AbilityOnEnemySwitchIn.trigger(ability,switcher,bearer,battle)
	end
	
	def self.triggerMoveImmunityAllyAbility(ability,user,target,move,type,battle,ally)
		ret = MoveImmunityAllyAbility.trigger(ability,user,target,move,type,battle,ally)
		return (ret!=nil) ? ret : false
	end

  def self.triggerOnBerryConsumedAbility(ability,user,berry,own_item,battle)
		ret = OnBerryConsumedAbility.trigger(ability,user,berry,own_item,battle)
		return (ret!=nil) ? ret : false
	end
end