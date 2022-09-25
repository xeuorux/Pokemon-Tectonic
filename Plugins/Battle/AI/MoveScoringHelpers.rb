def statusUpsideAbilities()
	return [:GUTS,:AUDACITY,:MARVELSCALE,:QUICKFEET]
end

# Actually used for numbing now
def getParalysisMoveScore(score,user,target,skill=100,policies=[],status=false,twave=false)
	wouldBeFailedTWave = twave && Effectiveness.ineffective?(pbCalcTypeMod(:ELECTRIC,user,target))
	if target.pbCanParalyze?(user,false) && !wouldBeFailedTWave
		score += 10
		aspeed = pbRoughStat(user,:SPEED,skill)
		ospeed = pbRoughStat(target,:SPEED,skill)
		if aspeed<ospeed
			score += 30
		elsif aspeed>ospeed
			score -= 30
		end
		# score += ([target.stages[:ATTACK],0].max)*10
		# score += ([target.stages[:DEFENSE],0].max)*10
		# score += ([target.stages[:SPECIAL_ATTACK],0].max)*10
		# score += ([target.stages[:SPECIAL_DEFENSE],0].max)*10
		# score += ([target.stages[:EVASION],0].max)*10
		score -= 30 if target.hasActiveAbilityAI?(statusUpsideAbilities)
	elsif status
		score = 0 
	end
	return score
end

def getPoisonMoveScore(score,user,target,skill=100,policies=[],status=false)
	if target && target.pbCanPoison?(user,false)
		score += 30
		score -= 30 if target.hasActiveAbilityAI?([:TOXICBOOST,:POISONHEAL].concat(statusUpsideAbilities))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && status
	elsif status
		return 0
	end
	return score
end

def getBurnMoveScore(score,user,target,skill=100,policies=[],status=false)
	if target && target.pbCanBurn?(user,false)
		score += 30
		score -= 30 if target.hasActiveAbilityAI?([:FLAREBOOST,:BURNHEAL].concat(statusUpsideAbilities))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && status
	elsif status
		return 0
	end
	return score
end

def getFrostbiteMoveScore(score,user,target,skill=100,policies=[],status=false)
	if target.pbCanFrostbite?(user,false)
		score += 30
		score -= 30 if target.hasActiveAbilityAI?([:FROSTHEAL].concat(statusUpsideAbilities))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && status
	elsif status
		return 0
	end
	return score
end

def getScoreForPuttingToSleep(score,user,target,skill=100)
	return 0 if target.effects[PBEffects::Yawn] > 0
	  return score + 50
end

def getFlinchingMoveScore(score,user,target,skill,policies)
	userSpeed = pbRoughStat(user,:SPEED,skill)
	targetSpeed = pbRoughStat(target,:SPEED,skill)
	
	if target.hasActiveAbilityAI?(:INNERFOCUS) ||
			target.effects[PBEffects::Substitute] != 0 ||
			target.effects[PBEffects::FlinchedAlready] ||
			targetSpeed > userSpeed
		score -= 20
	else
		score += 20
	end
	return score
end

def getWantsToBeFasterScore(score,user,target,skill=100,magnitude=1)
	return getWantsToBeSlowerScore(score,user,target,skill,-magnitude)
end

def getWantsToBeSlowerScore(score,user,target,skill=100,magnitude=1)
	userSpeed = pbRoughStat(user,:SPEED,skill)
	targetSpeed = pbRoughStat(target,:SPEED,skill)
	if userSpeed<targetSpeed
		score += 10 * magnitude
	else
		score -= 10 * magnitude
	end
	return score
end

def sleepMoveAI(score,user,target,skill=100)
	score += 50 * (target.hp / target.totalhp)
	score += target.stages[:ATTACK] * 10
	score += target.stages[:SPECIAL_ATTACK] * 10
	if !target.pbCanSleep?(user,false)
		score = 10
		score = 0 if skill > PBTrainerAI.mediumSkill
	end
	return score
end

def getHazardSettingMoveScore(score,user,target,skill=100)
	score -= 40
	canChoose = false
	user.eachOpposing do |b|
		next if !user.battle.pbCanChooseNonActive?(b.index)
		canChoose = true
		break
	end
	if !canChoose
		# Opponent can't switch in any Pokemon
		return 0
	else
		score += 20 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
		score += 10 * @battle.pbAbleNonActiveCount(user.idxOwnSide)
	end
	return score
end

#=============================================================================
# Get approximate properties for a battler
#=============================================================================
def pbRoughType(move,user,skill)
	ret = move.pbCalcType(user)
	return ret
end

def pbRoughStat(battler,stat,skill)
	return battler.pbSpeed if stat==:SPEED
	stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
	stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
	stage = battler.stages[stat]+6
	value = 0
	case stat
	when :ATTACK					then value = battler.attack
	when :DEFENSE				 then value = battler.defense
	when :SPECIAL_ATTACK	then value = battler.spatk
	when :SPECIAL_DEFENSE then value = battler.spdef
	when :SPEED					 then value = battler.speed
	end
	return (value.to_f*stageMul[stage]/stageDiv[stage]).floor
end

class PokeBattle_Battler
	def hasPhysicalAttack?
		eachMove do |m|
			next if !m.physicalMove?(m.type)
			return true
			break
		end
		return false
	end

	def hasSpecialAttack?
		eachMove do |m|
			next if !m.specialMove?(m.type)
			return true
			break
		end
		return false
	end

	def hasDamagingAttack?
		eachMove do |m|
			next if !m.damagingMove?
			return true
			break
		end
		return false
	end

	def hasAlly?
		eachAlly do |b|
			return true
			break
		end
		return false
	end

	def hasActiveAbilityAI?(check_ability, ignore_fainted = false)
		return false if @effects[PBEffects::Illusion] && pbOwnedByPlayer?
		return false if !abilityActive?(ignore_fainted)
		return check_ability.include?(@ability_id) if check_ability.is_a?(Array)
		return self.ability == check_ability
	end

	# Returns the active types of this Pokémon. The array should not include the
	# same type more than once, and should not include any invalid type numbers
	# (e.g. -1).
	def pbTypesAI(withType3=false)
		if @effects[PBEffects::Illusion] && pbOwnedByPlayer?
			ret = [@effects[PBEffects::Illusion].type1]
			ret.push(@effects[PBEffects::Illusion].type2) if @effects[PBEffects::Illusion].type2 != @effects[PBEffects::Illusion].type1
		else
			ret = [@type1]
			ret.push(@type2) if @type2!=@type1
		end
		# Burn Up erases the Fire-type.
		ret.delete(:FIRE) if @effects[PBEffects::BurnUp]
		# Roost erases the Flying-type. If there are no types left, adds the Normal-
		# type.
		if @effects[PBEffects::Roost]
			ret.delete(:FLYING)
			ret.push(:NORMAL) if ret.length == 0
		end
		# Add the third type specially.
		if withType3 && @effects[PBEffects::Type3]
			ret.push(@effects[PBEffects::Type3]) if !ret.include?(@effects[PBEffects::Type3])
		end
		return ret
	end

	def pbHasTypeAI?(type)
		return false if !type
		activeTypes = pbTypesAI(true)
		return activeTypes.include?(GameData::Type.get(type).id)
	end
end