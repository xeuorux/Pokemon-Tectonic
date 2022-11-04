class PokeBattle_Battler
	include EffectHolder

	def resetEffects()
		@effects.clear
		# Reset values, accounting for baton pass
		GameData::BattleEffect.each_battler_effect do |effectData|
			@effects[effectData.id] = effectData.default
		end
	end

	def applyEffect(effect, value = nil, ignoreFainted=false)
		return if fainted? && !ignoreFainted
		super(effect,value)
		#echoln("[BATTLER EFFECT] Effect #{effect} applied to battler #{pbThis(true)}") if !effectActive?(effect)
		if getData(effect).is_mental?
			pbItemStatusCureCheck
			pbAbilityStatusCureCheck
		end
	end

	def disableEffect(effect, ignoreFainted=false)
		return if fainted? && !ignoreFainted
		#echoln("[BATTLER EFFECT] Effect #{effect} disabled on battler #{pbThis(true)}") if effectActive?(effect)
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

	def getReleventEffectHolders()
		holders = [self,@battle.positions[@index],pbOwnSide,@battle.field]
	end

	def eachEffectAllLocations(onlyActive=false)
		getReleventEffectHolders().each do |effectHolder|
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
		@indicesTargetedLastRound = @indicesTargetedThisRound.clone
		@indicesTargetedThisRound.clear
		@primevalTimer += 1 if boss?
	end
end
