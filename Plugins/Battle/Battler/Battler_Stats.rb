class PokeBattle_Battler
	def getPlainStat(stat)
		plainStatVal = 0
		case stat
		when :ATTACK
			plainStatVal = attack
		when :DEFENSE
			plainStatVal = defense
		when :SPECIAL_ATTACK
			plainStatVal = spatk
		when :SPECIAL_DEFENSE
			plainStatVal = spdef
		when :SPEED
			plainStatVal = speed
		end

		plainStatVal += tribalBonusForStat(stat)
		return plainStatVal
	end

	def plainStats
		ret = {}
		ret[:ATTACK]          = attack
		ret[:DEFENSE]         = defense
		ret[:SPECIAL_ATTACK]  = spatk
		ret[:SPECIAL_DEFENSE] = spdef
		ret[:SPEED]           = speed
		if getsTribalBonuses?
			ret[:ATTACK_TRIBAL] = @tribalBonuses[:ATTACK]
			ret[:DEFENSE_TRIBAL] = @tribalBonuses[:DEFENSE]
			ret[:SPECIAL_ATTACK_TRIBAL] = @tribalBonuses[:SPECIAL_ATTACK]
			ret[:SPECIAL_DEFENSE_TRIBAL] = @tribalBonuses[:SPECIAL_DEFENSE]
			ret[:SPEED_TRIBAL] = @tribalBonuses[:SPEED]
		else
			ret[:ATTACK_TRIBAL] = 0
			ret[:DEFENSE_TRIBAL] = 0
			ret[:SPECIAL_ATTACK_TRIBAL] = 0
			ret[:SPECIAL_DEFENSE_TRIBAL] = 0
			ret[:SPEED_TRIBAL] = 0
		end
		return ret
	end

	def tribalBonusForStat(stat)
		return 0 unless getsTribalBonuses?
		return @tribalBonuses[stat]
	end

	def getsTribalBonuses?
		return false unless defined?(TribalBonus)
		return false unless pbOwnedByPlayer?
		return true
	end

	def puzzleRoom?
		return @battle.field.effectActive?(:PuzzleRoom)
	end

	def oddRoom?
		return @battle.field.effectActive?(:OddRoom)
	end

	def attack
		if puzzleRoom? && oddRoom?
			return sp_def_no_room
		elsif puzzleRoom? && !oddRoom?
			return sp_atk_no_room
		elsif oddRoom? && !puzzleRoom?
			return defense_no_room
		else
			return attack_no_room
		end
	end

	def defense
		if puzzleRoom? && oddRoom?
			return sp_atk_no_room
		elsif puzzleRoom? && !oddRoom?
			return sp_def_no_room
		elsif oddRoom? && !puzzleRoom?
			return attack_no_room
		else
			return defense_no_room
		end
	end

	def spatk
		if puzzleRoom? && oddRoom?
			return defense_no_room
		elsif puzzleRoom? && !oddRoom?
			return attack_no_room
		elsif oddRoom? && !puzzleRoom?
			return sp_def_no_room
		else
			return sp_atk_no_room
		end
	end

	def spdef
		if puzzleRoom? && oddRoom?
			return attack_no_room
		elsif puzzleRoom? && !oddRoom?
			return defense_no_room
		elsif oddRoom? && !puzzleRoom?
			return sp_atk_no_room
		else
			return sp_def_no_room
		end
	end

	OFFENSIVE_LOCK_STAT = 120

	DEFENSIVE_LOCK_STAT = 95

	def attack_no_room
		atk_bonus = tribalBonusForStat(:ATTACK)
		if hasActiveItem?(:POWERLOCK)
			return calcStatGlobal(OFFENSIVE_LOCK_STAT, @level, @pokemon.ev[:ATTACK],hasActiveAbility?(:STYLISH)) + atk_bonus
		else
			return @attack + atk_bonus
		end
	end

	def defense_no_room
		defense_bonus = tribalBonusForStat(:DEFENSE)
		if hasActiveItem?(:GUARDLOCK)
			return calcStatGlobal(DEFENSIVE_LOCK_STAT, @level, @pokemon.ev[:DEFENSE],hasActiveAbility?(:STYLISH)) + defense_bonus
		else
			return @defense + defense_bonus
		end
	end

	def sp_atk_no_room
		spatk_bonus = tribalBonusForStat(:SPECIAL_ATTACK)
		if hasActiveItem?(:ENERGYLOCK)
			return calcStatGlobal(OFFENSIVE_LOCK_STAT, @level, @pokemon.ev[:SPECIAL_ATTACK],hasActiveAbility?(:STYLISH)) + spatk_bonus
		else
			return @spatk + spatk_bonus
		end
	end

	def sp_def_no_room
		spdef_bonus = tribalBonusForStat(:SPECIAL_DEFENSE)
		if hasActiveItem?(:WILLLOCK)
			return calcStatGlobal(DEFENSIVE_LOCK_STAT, @level, @pokemon.ev[:SPECIAL_DEFENSE],hasActiveAbility?(:STYLISH)) + spdef_bonus
		else
			return @spdef + spdef_bonus
		end
	end

	#=============================================================================
	# Query about stats after room modification, stages, and maybe other effects.
	#=============================================================================
	def pbAttack(aiChecking = false)
		return 1 if fainted?
		return statAfterStage(:ATTACK)
	end

	def pbSpAtk(aiChecking = false)
		return 1 if fainted?
		return statAfterStage(:SPECIAL_ATTACK)
	end

	def pbDefense(aiChecking = false)
		return 1 if fainted?
		return statAfterStage(:DEFENSE)
	end

	def pbSpDef(aiChecking = false)
		return 1 if fainted?
		return statAfterStage(:SPECIAL_DEFENSE)
	end

	def pbSpeed(aiChecking = false)
		return 1 if fainted?
		speed = statAfterStage(:SPEED)
		speedMult = 1.0
		# Ability effects that alter calculated Speed
		speedMult = BattleHandlers.triggerSpeedCalcAbility(ability, self, speedMult) if abilityActive? && !ignoreAbilityInAI?(aiChecking)
		# Item effects that alter calculated Speed
		speedMult = BattleHandlers.triggerSpeedCalcItem(item, self, speedMult) if itemActive?
		# Other effects
		speedMult *= 2 if pbOwnSide.effectActive?(:Tailwind)
		speedMult /= 2 if pbOwnSide.effectActive?(:Swamp)
		speedMult *= 2 if effectActive?(:OnDragonRide)
		# Numb and Poison
		unless shouldAbilityApply?(:QUICKFEET, aiChecking)
			if numbed?
				speedMult /= 2
				speedMult /= 2 if pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
			end
			if poisoned? && !shouldAbilityApply?(:POISONHEAL, aiChecking)
				speedMult /= 2
				speedMult /= 2 if pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
			end
		end
		# Calculation
		return [(speed * speedMult).round, 1].max
	end
end
