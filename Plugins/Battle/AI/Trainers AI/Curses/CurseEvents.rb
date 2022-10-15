class PokeBattle_Battle
	BattleStartApplyCurse 				= HandlerHash2.new
	BattleEndCurse						= HandlerHash2.new
	BattlerEnterCurseEffect 			= HandlerHash2.new
	BattlerFaintedCurseEffect			= HandlerHash2.new
	EffectivenessChangeCurseEffect 		= HandlerHash2.new
	MoveUsedCurseEffect					= HandlerHash2.new
	BeginningOfTurnCurseEffect			= HandlerHash2.new
	
	def triggerBattleStartApplyCurse(curse_policy,battle,curses_array)
		ret = BattleStartApplyCurse.trigger(curse_policy,battle,curses_array)
		return ret || curses_array
	end
	
	def triggerBattleEndCurse(curse_policy,battle)
		BattleEndCurse.trigger(curse_policy,battle)
	end
	
	def triggerBattlerEnterCurseEffect(curse_policy,battler,battle)
		ret = BattlerEnterCurseEffect.trigger(curse_policy,battler,battle)
		return ret || false
	end

	def triggerBattlerFaintedCurseEffect(curse_policy,battler,battle)
		ret = BattlerFaintedCurseEffect.trigger(curse_policy,battler,battle)
		return ret || false
	end
	
	def triggerEffectivenessChangeCurseEffect(curse_policy,moveType,user,target,effectiveness)
		ret = EffectivenessChangeCurseEffect.trigger(curse_policy,moveType,user,target,effectiveness)
		return ret || effectiveness
	end
	
	def triggerBeginningOfTurnCurseEffect(curse_policy,battle)
		BeginningOfTurnCurseEffect.trigger(curse_policy,battle)
	end
	
	def triggerMoveUsedCurseEffect(curse_policy,user,target,move)
		ret = MoveUsedCurseEffect.trigger(curse_policy,user,target,move)
		return ret || true
	end
	
	def amuletActivates(curseName)
		pbDisplaySlower(_INTL("The Tarot Amulet glows with power!"))
		pbDisplaySlower(_INTL("You have been afflicted with the curse: #{curseName}"))
	end
	
	def pbDisplaySlower(string)
		pbDisplay(string + "\1")
	end
end