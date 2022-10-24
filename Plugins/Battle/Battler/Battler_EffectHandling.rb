class PokeBattle_Battler
	include EffectHolder

	def applyEffect(effect, value = ni, ignoreFainted=false)
		return if fainted? && !ignoreFainted
		super(effect,value)
		echoln("[BATTLER EFFECT] Effect #{getName(effect)} applied to battler #{pbThis(true)}")
	end

	def disableEffect(effect, ignoreFainted=false)
		return if fainted? && !ignoreFainted
		super(effect)
	end

	def effectActive?(effect, ignoreFainted=false)
		return false if fainted? && !ignoreFainted
		super(effect)
	end

	def countEffect(effect, ignoreFainted=false)
        return 0 if fainted? && !ignoreFainted
		super(effect)
    end

	def processEffectsEOR
		return if fainted?
		@effects.each do |effect, _value|
			next unless effectActive?(effect)
			effectData = GameData::BattleEffect.get(effect)
			effectData.eor_battler(@battle, self)
		end
		super
	end

	def eachEffectAlsoPosition(onlyActive=false,alsoPosition)
		super(onlyActive).each do |effect, value, data|
			yield effect, value, data
		end
		if alsoPosition
			@battle.positions[@index].eachEffect(onlyActive) do |effect, value, data|
				yield effect, value, data
			end
		end
	end

	def getAllEffectHolders()
		holders = [self,@battle.positions[@index],pbOwnSide,@battle.field]
	end

	def eachEffectAllLocations(onlyActive=false)
		getAllEffectHolders().each do |effectHolder|
			effectHolder.eachEffect(onlyActive) do |effect,value,data|
				yield effect,value,data
			end
		end
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
