class PokeBattle_Battle
	BattleStartApplyCurse = HandlerHash2.new
	BattlerEnterCurseEffect = HandlerHash2.new
	EffectivenessChangeCurseEffect = HandlerHash2.new
	
	def triggerBattleStartApplyCurse(curse_policy,battle,curses_array)
		echoln("Triggering possible curses for policy: #{curse_policy}")
		ret = BattleStartApplyCurse.trigger(curse_policy,battle,curses_array)
		return ret || curses_array
	end
	
	def triggerBattlerEnterCurseEffect(curse_policy,battler,battle)
		ret = BattlerEnterCurseEffect.trigger(curse_policy,battler,battle)
		return ret || false
	end
	
	def triggerEffectivenessChangeCurseEffect(curse_policy,moveType,user,target,effectiveness)
		ret = EffectivenessChangeCurseEffect.trigger(curse_policy,moveType,user,target,effectiveness)
		return ret || effectiveness
	end
	
	def amuletActivates(curseName)
		pbDisplay(_INTL("The Tarot Amulet glows with power!\1"))
		pbDisplay(_INTL("You have been afflicted with the curse: #{curseName}\1"))
	end
end