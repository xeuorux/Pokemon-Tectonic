class PokeBattle_Battler
	include EffectHolder

	def processEffectsEOR
		return if fainted?
		@effects.each do |effect, _value|
			next unless effectActive?(effect)
			effectData = GameData::BattleEffect.get(effect)
			effectData.eor_battler(@battle, self)
		end
		super
	end

	def modifyTrackersEOR
		@lastHPLost = 0
		@lastHPLostFromFoe                    = 0
		@tookDamage                           = false
		@tookPhysicalHit                      = false
		@lastRoundMoveFailed                  = @lastMoveFailed
		@lastAttacker.clear
		@lastFoeAttacker.clear
		@indexesTargetedThisTurn.clear
		@primevalTimer += 1 if boss?
	end
end
