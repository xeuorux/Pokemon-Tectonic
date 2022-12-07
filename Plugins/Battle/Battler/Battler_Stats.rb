class PokeBattle_Battler
	def getPlainStat(stat)
		case stat
		when :ATTACK
			return attack
		when :DEFENSE
			return defense
		when :SPECIAL_ATTACK
			return spatk
		when :SPECIAL_DEFENSE
			return spdef
		when :SPEED
			return speed
		end
		return -1
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
			return base_special_defense
		elsif puzzleRoom? && !oddRoom?
			return base_special_attack
		elsif oddRoom? && !puzzleRoom?
			return base_defense
		else
			return base_attack
		end
	end

	def defense
		if puzzleRoom? && oddRoom?
			return base_special_attack
		elsif puzzleRoom? && !oddRoom?
			return base_special_defense
		elsif oddRoom? && !puzzleRoom?
			return base_attack
		else
			return base_defense
		end
	end

	def spatk
		if puzzleRoom? && oddRoom?
			return base_defense
		elsif puzzleRoom? && !oddRoom?
			return base_attack
		elsif oddRoom? && !puzzleRoom?
			return base_special_defense
		else
			return base_special_attack
		end
	end

	def spdef
		if puzzleRoom? && oddRoom?
			return base_attack
		elsif puzzleRoom? && !oddRoom?
			return base_defense
		elsif oddRoom? && !puzzleRoom?
			return base_special_attack
		else
			return base_special_defense
		end
	end

	OFFENSIVE_LOCK_STAT = 120

	DEFENSIVE_LOCK_STAT = 95

	def speed
		return base_speed
	end

	# Don't use for HP
	def recalcStat(stat,base)
		return calcStatGlobal(base, @level, @pokemon.ev[stat],hasActiveAbility?(:STYLISH))
	end

	def base_attack
		attack_bonus = tribalBonusForStat(:ATTACK)
		if hasActiveItem?([:POWERLOCK,:POWERKEY])
			return recalcStat(:ATTACK,OFFENSIVE_LOCK_STAT) + attack_bonus
		else
			return @attack + attack_bonus
		end
	end

	def base_defense
		defense_bonus = tribalBonusForStat(:DEFENSE)
		if hasActiveItem?(:GUARDLOCK)
			return recalcStat(:DEFENSE,DEFENSIVE_LOCK_STAT) + defense_bonus
		elsif hasActiveItem?(:POWERKEY)
			return recalcStat(:DEFENSE,OFFENSIVE_LOCK_STAT) + defense_bonus
		else
			return @defense + defense_bonus
		end
	end

	def base_special_attack
		spatk_bonus = tribalBonusForStat(:SPECIAL_ATTACK)
		if hasActiveItem?([:ENERGYLOCK,:ENERGYKEY])
			return recalcStat(:SPECIAL_ATTACK,OFFENSIVE_LOCK_STAT) + spatk_bonus
		else
			return @spatk + spatk_bonus
		end
	end

	def base_special_defense
		spdef_bonus = tribalBonusForStat(:SPECIAL_DEFENSE)
		if hasActiveItem?(:WILLLOCK)
			return recalcStat(:SPECIAL_DEFENSE,DEFENSIVE_LOCK_STAT) + spdef_bonus
		elsif hasActiveItem?(:ENERGYKEY)
			return recalcStat(:SPECIAL_DEFENSE,OFFENSIVE_LOCK_STAT) + spdef_bonus
		else
			return @spdef + spdef_bonus
		end
	end

	def base_speed
		speed_bonus = tribalBonusForStat(:SPEED)
		return @speed + speed_bonus
	end

	#=============================================================================
	# Query about stats after room modification, stages, abilities and item modifiers.
	#=============================================================================
	AI_CHEATS_FOR_STAT_ABILITIES = true

	def pbAttack(aiChecking = false,stage=-1)
		return 1 if fainted?
		attack = statAfterStage(:ATTACK,stage)
		attackMult = 1.0

		if !ignoreAbilityInAI?(aiChecking) || AI_CHEATS_FOR_STAT_ABILITIES
			attackMult = BattleHandlers.triggerAttackCalcUserAbility(ability, self, @battle, attackMult) if abilityActive?
			eachAlly do |ally|
				next unless ally.abilityActive?
				attackMult = BattleHandlers.triggerAttackCalcAllyAbility(ally.ability, self, @battle, attackMult)
			end
		end
		attackMult = BattleHandlers.triggerAttackCalcUserItem(item, self, battle, attackMult) if itemActive?

		# Dragon Ride
		attackMult *= 1.5 if effectActive?(:OnDragonRide)

		# Calculation
		return [(attack * attackMult).round, 1].max
	end

	def pbSpAtk(aiChecking = false,stage=-1)
		return 1 if fainted?
		special_attack = statAfterStage(:SPECIAL_ATTACK,stage)
		spAtkMult = 1.0

		if !ignoreAbilityInAI?(aiChecking) || AI_CHEATS_FOR_STAT_ABILITIES
			spAtkMult = BattleHandlers.triggerSpecialAttackCalcUserAbility(ability, self, @battle, spAtkMult) if abilityActive?
			eachAlly do |ally|
				next unless ally.abilityActive?
				spAtkMult = BattleHandlers.triggerSpecialAttackCalcAllyAbility(ally.ability, self, @battle, spAtkMult)
			end
		end
		spAtkMult = BattleHandlers.triggerSpecialAttackCalcUserItem(item, self, battle, spAtkMult) if itemActive?
		
		# Calculation
		return [(special_attack * spAtkMult).round, 1].max
	end

	def pbDefense(aiChecking = false,stage=-1)
		return 1 if fainted?
		defense = statAfterStage(:DEFENSE,stage)
		defenseMult = 1.0

		if !ignoreAbilityInAI?(aiChecking) || AI_CHEATS_FOR_STAT_ABILITIES
			defenseMult = BattleHandlers.triggerDefenseCalcUserAbility(ability, self, @battle, defenseMult) if abilityActive?
			eachAlly do |ally|
				next unless ally.abilityActive?
				defenseMult = BattleHandlers.triggerDefenseCalcAllyAbility(ally.ability, self, @battle, defenseMult)
			end
		end
		defenseMult = BattleHandlers.triggerDefenseCalcUserItem(item, self, battle, defenseMult) if itemActive?
		
		# Calculation
		return [(defense * defenseMult).round, 1].max
	end

	def pbSpDef(aiChecking = false,stage=-1)
		return 1 if fainted?
		special_defense = statAfterStage(:SPECIAL_DEFENSE,stage)
		spDefMult = 1.0

		if !ignoreAbilityInAI?(aiChecking) || AI_CHEATS_FOR_STAT_ABILITIES
			spDefMult = BattleHandlers.triggerSpecialDefenseCalcUserAbility(ability, self, @battle, spDefMult) if abilityActive?
			eachAlly do |ally|
				next unless ally.abilityActive?
				spDefMult = BattleHandlers.triggerSpecialDefenseCalcAllyAbility(ally.ability, self, @battle, spDefMult)
			end
		end
		spDefMult = BattleHandlers.triggerSpecialDefenseCalcUserItem(item, self, battle, spDefMult) if itemActive?
		
		# Calculation
		return [(special_defense * spDefMult).round, 1].max
	end

	def pbSpeed(aiChecking = false,stage=-1)
		return 1 if fainted?
		speed = statAfterStage(:SPEED,stage)
		speedMult = 1.0
		if !ignoreAbilityInAI?(aiChecking) || AI_CHEATS_FOR_STAT_ABILITIES
			# Ability effects that alter calculated Speed
			speedMult = BattleHandlers.triggerSpeedCalcAbility(ability, self, speedMult) if abilityActive? && !ignoreAbilityInAI?(aiChecking)
		end
		# Item effects that alter calculated Speed
		speedMult = BattleHandlers.triggerSpeedCalcItem(item, self, speedMult) if itemActive?
		# Other effects
		speedMult *= 2 if pbOwnSide.effectActive?(:Tailwind)
		speedMult /= 2 if pbOwnSide.effectActive?(:Swamp)
		speedMult *= 2 if effectActive?(:OnDragonRide)
		# Numb
		unless shouldAbilityApply?(:QUICKFEET, aiChecking)
			if numbed?
				speedMult /= 2
				speedMult /= 2 if pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
			end
		end
		# Calculation
		return [(speed * speedMult).round, 1].max
	end

	def getFinalStat(stat,aiChecking = false,stage=-1)
		case stat
		when :ATTACK
			return pbAttack(aiChecking,stage)
		when :DEFENSE
			return pbDefense(aiChecking,stage)
		when :SPECIAL_ATTACK
			return pbSpAtk(aiChecking,stage)
		when :SPECIAL_DEFENSE
			return pbSpDef(aiChecking,stage)
		when :SPEED
			return pbSpeed(aiChecking,stage)
		end
		return -1
	end
end
