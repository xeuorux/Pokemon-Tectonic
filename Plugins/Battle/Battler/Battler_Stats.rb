class PokeBattle_Battler
	def plainStats
		ret = {}
		ret[:ATTACK]          = attack
		ret[:DEFENSE]         = defense
		ret[:SPECIAL_ATTACK]  = spatk
		ret[:SPECIAL_DEFENSE] = spdef
		ret[:SPEED]           = speed
		if getsTribalBonuses?
			bonuses = $Tribal_Bonuses.getTribeBonuses(@pokemon)
			ret[:ATTACK_TRIBAL] = bonuses[:ATTACK]
			ret[:DEFENSE_TRIBAL] = bonuses[:DEFENSE]
			ret[:SPECIAL_ATTACK_TRIBAL] = bonuses[:SPECIAL_ATTACK]
			ret[:SPECIAL_DEFENSE_TRIBAL] = bonuses[:SPECIAL_DEFENSE]
			ret[:SPEED_TRIBAL] = bonuses[:SPEED]
		else
			ret[:ATTACK_TRIBAL] = 0
			ret[:DEFENSE_TRIBAL] = 0
			ret[:SPECIAL_ATTACK_TRIBAL] = 0
			ret[:SPECIAL_DEFENSE_TRIBAL] = 0
			ret[:SPEED_TRIBAL] = 0
		end
		return ret
	end

	def getBonus(stat)
		return 0 unless getsTribalBonuses?
		return $Tribal_Bonuses.getTribeBonuses(@pokemon)[stat]
	end

	def getsTribalBonuses?
		return false unless defined?(TribalBonus)
		return false unless pbOwnedByPlayer?
		return true
	end

	def attack
		if @battle.field.effects[PBEffects::PuzzleRoom].positive? && @battle.field.effects[PBEffects::OddRoom].positive?
			return sp_def_no_room
		elsif @battle.field.effects[PBEffects::PuzzleRoom].positive? && @battle.field.effects[PBEffects::OddRoom] <= 0
			return sp_atk_no_room
		elsif @battle.field.effects[PBEffects::OddRoom].positive? && @battle.field.effects[PBEffects::PuzzleRoom] <= 0
			return defense_no_room
		else
			return attack_no_room
		end
	end

	def defense
		if @battle.field.effects[PBEffects::PuzzleRoom].positive? && @battle.field.effects[PBEffects::OddRoom].positive?
			return sp_atk_no_room
		elsif @battle.field.effects[PBEffects::PuzzleRoom].positive? && @battle.field.effects[PBEffects::OddRoom] <= 0
			return sp_def_no_room
		elsif @battle.field.effects[PBEffects::OddRoom].positive? && @battle.field.effects[PBEffects::PuzzleRoom] <= 0
			return attack_no_room
		else
			return defense_no_room
		end
	end

	def spatk
		if @battle.field.effects[PBEffects::PuzzleRoom].positive? && @battle.field.effects[PBEffects::OddRoom].positive?
			return defense_no_room
		elsif @battle.field.effects[PBEffects::PuzzleRoom].positive? && @battle.field.effects[PBEffects::OddRoom] <= 0
			return attack_no_room
		elsif @battle.field.effects[PBEffects::OddRoom].positive? && @battle.field.effects[PBEffects::PuzzleRoom] <= 0
			return sp_def_no_room
		else
			return sp_atk_no_room
		end
	end

	def spdef
		if @battle.field.effects[PBEffects::PuzzleRoom].positive? && @battle.field.effects[PBEffects::OddRoom].positive?
			return attack_no_room
		elsif @battle.field.effects[PBEffects::PuzzleRoom].positive? && @battle.field.effects[PBEffects::OddRoom] <= 0
			return defense_no_room
		elsif @battle.field.effects[PBEffects::OddRoom].positive? && @battle.field.effects[PBEffects::PuzzleRoom] <= 0
			return sp_atk_no_room
		else
			return sp_def_no_room
		end
	end

	OFFENSIVE_LOCK_STAT = 120

	DEFENSIVE_LOCK_STAT = 95

	def attack_no_room
		atk_bonus = getBonus(:ATTACK)
		if hasActiveItem?(:POWERLOCK)
			return calcStatGlobal(OFFENSIVE_LOCK_STAT, @level, @pokemon.ev[:ATTACK],
																									hasActiveAbility?(:STYLISH)) + atk_bonus
		else
			return @attack + atk_bonus
		end
	end

	def defense_no_room
		defense_bonus = getBonus(:DEFENSE)
		if hasActiveItem?(:GUARDLOCK)
			return calcStatGlobal(DEFENSIVE_LOCK_STAT, @level, @pokemon.ev[:DEFENSE],
																									hasActiveAbility?(:STYLISH)) + defense_bonus
		else
			return @defense + defense_bonus
		end
	end

	def sp_atk_no_room
		spatk_bonus = getBonus(:SPECIAL_ATTACK)
		if hasActiveItem?(:ENERGYLOCK)
			return calcStatGlobal(OFFENSIVE_LOCK_STAT, @level, @pokemon.ev[:SPECIAL_ATTACK],
																									hasActiveAbility?(:STYLISH)) + spatk_bonus
		else
			return @spatk + spatk_bonus
		end
	end

	def sp_def_no_room
		spdef_bonus = getBonus(:SPECIAL_DEFENSE)
		if hasActiveItem?(:WILLLOCK)
			return calcStatGlobal(DEFENSIVE_LOCK_STAT, @level, @pokemon.ev[:SPECIAL_DEFENSE],
																									hasActiveAbility?(:STYLISH)) + spdef_bonus
		else
			return @spdef + spdef_bonus
		end
	end

	def pbSpeed(aiChecking = false)
		return 1 if fainted?
		stageMul = STAGE_MULTIPLIERS
		stageDiv = STAGE_DIVISORS
		stage = @stages[:SPEED] + 6
		speed_bonus = getBonus(:SPEED)
		speed = (@speed + speed_bonus) * stageMul[stage] / stageDiv[stage]
		speedMult = 1.0
		# Ability effects that alter calculated Speed
		speedMult = BattleHandlers.triggerSpeedCalcAbility(ability, self, speedMult) if abilityActive? && ignoreAbilityInAI?(aiChecking)
		# Item effects that alter calculated Speed
		speedMult = BattleHandlers.triggerSpeedCalcItem(item, self, speedMult) if itemActive?
		# Other effects
		speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind].positive?
		speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp].positive?
		speedMult *= 2 if @effects[PBEffects::OnDragonRide]
		# Paralysis and Chill
		unless shouldAbilityApply?(:QUICKFEET, aiChecking)
			if paralyzed?
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
