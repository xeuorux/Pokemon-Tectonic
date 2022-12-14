DOWNSIDE_ABILITIES = [:SLOWSTART,:PRIMEVALSLOWSTART,:DEFEATIST,:TRUANT]

STATUS_UPSIDE_ABILITIES = [:GUTS,:AUDACITY,:MARVELSCALE,:MARVELSKIN,:QUICKFEET]

ALL_STATUS_SCORE_BONUS = 15

def getStatusSettingMoveScore(statusApplying,score,user,target,policies=[])
	case statusApplying
	when :SLEEP
		return getSleepMoveScore(score,user,target,policies)
	when :POISON
		return getPoisonMoveScore(score,user,target,policies)
	when :BURN
		return getBurnMoveScore(score,user,target,policies)
	when :FROSTBITE
		return getFrostbiteMoveScore(score,user,target,policies)
	when :NUMB
		return getNumbMoveScore(score,user,target,policies)
	when :DIZZY
		return getDizzyMoveScore(score,user,target,policies)
	end

	return score
end

# Actually used for numbing now
def getNumbMoveScore(score,user,target,policies=[])
	if target && target.canNumb?(user,false)
		score += ALL_STATUS_SCORE_BONUS
		aspeed = user.pbSpeed(true)
		ospeed = target.pbSpeed(true)
		if aspeed < ospeed
			score += 30
		elsif aspeed > ospeed
			score -= 30
		end
		score -= 60 if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
		score += 50 if user.hasStatusPunishMove?
	else
		return 0
	end
	return score
end

def getPoisonMoveScore(score,user,target,policies=[])
	if target && target.canPoison?(user,false)
		score += ALL_STATUS_SCORE_BONUS
		score += 20 if target.hp == target.totalhp
		score -= 60 if target.hasActiveAbilityAI?([:TOXICBOOST,:POISONHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS)
		score += 50 if user.hasStatusPunishMove?
	else
		return 0
	end
	return score
end

def getBurnMoveScore(score,user,target,policies=[])
	if target && target.canBurn?(user,false)
		score += ALL_STATUS_SCORE_BONUS
		score -= 60 if target.hasActiveAbilityAI?([:FLAREBOOST,:BURNHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS)
		score += 50 if user.hasStatusPunishMove?
	else
		return 0
	end
	return score
end

def getFrostbiteMoveScore(score,user,target,policies=[])
	if target && target.canFrostbite?(user,false)
		score += ALL_STATUS_SCORE_BONUS
		score -= 60 if target.hasActiveAbilityAI?([:FROSTHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS)
		score += 50 if user.hasStatusPunishMove?
	else
		return 0
	end
	return score
end

def getSleepMoveScore(score,user,target,policies=[])
	if target.hasSleepAttack?
		score += 20
	else
		score += 100
	end
	score += 50 if user.hasStatusPunishMove?
	return score
end

def getDizzyMoveScore(score,user,target,policies=[])
	canDizzy = target.canDizzy?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
	if canDizzy
		score += ALL_STATUS_SCORE_BONUS
		score += 20 if user.hasDamagingAttack?
		score -= 60 if target.hasActiveAbilityAI?([:FLUSTERFLOCK,:HEADACHE].concat(STATUS_UPSIDE_ABILITIES))
		score += 50 if user.hasStatusPunishMove?
	else
		return 0
	end
	return score
end

def getLeechMoveScore(score,user,target,policies=[])
	canLeech = target.canLeech?(user,false)
	if canLeech
		score += ALL_STATUS_SCORE_BONUS
		score += 20 if target.hp > target.totalhp / 2
		score += 30 if target.totalhp > user.totalhp * 2
		score -= 30 if target.totalhp < user.totalhp / 2
		score -= 60 if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
		score = 9999 if policies.include?(:PRIORITIZEDOTS)
		score += 50 if user.hasStatusPunishMove?
	else
		return 0
	end
	return score
end

def getFlinchingMoveScore(score,user,target,policies,magnitude=3)
	userSpeed = user.pbSpeed(true)
    targetSpeed = target.pbSpeed(true)
    
    if target.hasActiveAbilityAI?(:INNERFOCUS) || target.substituted? ||
          target.effectActive?(:FlinchedAlready) || targetSpeed > userSpeed
      score -= magnitude * 10
    else
      score += magnitude * 10
    end
	return score
end

def getWantsToBeFasterScore(score,user,other,magnitude=1)
	return getWantsToBeSlowerScore(score,user,other,-magnitude)
end

def getWantsToBeSlowerScore(score,user,other,magnitude=1)
	userSpeed = user.pbSpeed(true)
	otherSpeed = other.pbSpeed(true)
	if userSpeed < otherSpeed
		score += 10 * magnitude
	else
		score -= 10 * magnitude
	end
	return score
end

def getHazardSettingMoveScore(score,user,target)
	score -= 40
	canChoose = false
	user.eachOpposing do |b|
		next if !user.battle.pbCanChooseNonActive?(b.index)
		canChoose = true
		break
	end
	return 0 if !canChoose # Opponent can't switch in any Pokemon
		
	score += 20 * user.enemiesInReserveCount
	score += 10 * user.alliesInReserveCount
	return score
end

def getSelfKOMoveScore(score,user,target)
	reserves = user.battle.pbAbleNonActiveCount(user.idxOwnSide)
	return 0 if reserves == 0 # don't want to lose or draw
	return 0 if user.hp > user.totalhp / 2
	score -= 30 if user.hp > user.totalhp / 8
	return score
end

def statusSpikesWeightOnSide(side,excludeEffects=[])
	hazardWeight = 0
	hazardWeight += 20 * side.countEffect(:PoisonSpikes) if !excludeEffects.include?(:PoisonSpikes)
	hazardWeight += 20 * side.countEffect(:FlameSpikes) if !excludeEffects.include?(:FlameSpikes)
	hazardWeight += 20 * side.countEffect(:FrostSpikes) if !excludeEffects.include?(:FrostSpikes)
	return 0
end

def hazardWeightOnSide(side,excludeEffects=[])
	hazardWeight = 0
	hazardWeight += 20 * side.countEffect(:Spikes) if !excludeEffects.include?(:Spikes)
	hazardWeight += 50 if side.effectActive?(:StealthRock) && !excludeEffects.include?(:StealthRock)
	hazardWeight += 20 if side.effectActive?(:StickyWeb) && !excludeEffects.include?(:StickyWeb)
	hazardWeight += statusSpikesWeightOnSide(side,excludeEffects)
	return hazardWeight
end

def getSwitchOutMoveScore(score,user,target)
	score -= 10
	score -= hazardWeightOnSide(user.pbOwnSide)
	return score
end

def getForceOutMoveScore(score,user,target)
	return 0 if target.substituted?
	count = 0
	@battle.pbParty(target.index).each_with_index do |pkmn,i|
		count += 1 if @battle.pbCanSwitchLax?(target.index,i)
	end
	return 0 if count
	score += hazardWeightOnSide(target.pbOwnSide)
	return score
end

def getSelfKOMoveScore(score,user,target)
	reserves = user.battle.pbAbleNonActiveCount(user.idxOwnSide)
	return 0 if reserves == 0 # don't want to lose or draw
	return 0 if user.hp > user.totalhp / 2
	score -= 30 if user.hp > user.totalhp / 8
	return score
end

def getHealingMoveScore(score,user,target,magnitude=5)
	return 0 if user.opposes?(target) && !target.effectActive?(:NerveBreak)
    return 0 if !user.opposes?(target) && target.effectActive?(:NerveBreak)
    if target.hp <= target.totalhp / 2
      	score += magnitude * 10
	  	score += 10 if target.hasActiveAbilityAI?(:ROOTED)
    	score += 10 if target.hasActiveItem?(:BIGROOT)
    end
	if !user.opposes?(target)
		score += target.stages[:DEFENSE] * 2 * magnitude
		score += target.stages[:SPECIAL_DEFENSE] * 2 * magnitude
	end
	return score
end

def getMultiStatUpMoveScore(statUp,score,user,target)
    # Stat up moves tend to be strong on the first turn
    score += 20 if target.firstTurn?

	# Stat up moves tend to be strong when you have HP to use
    score += 30 if target.hp > target.totalhp / 2
	
	# Stat up moves tend to be strong when you are protected by a substitute
	score += 30 if target.substituted?

    # Feel more free to use the move the fewer pokemon that can attack the buff receiver this turn
    target.eachPotentialAttacker do |b|
      score -= 20
    end

    # Analyze each stat up entry
	upsPhysicalAttack = false
	upsSpecialAttack = false
	totalStats = 0
	for i in 0...statUp.length/2
		statSymbol = statUp[i*2]
		score -= target.stages[statSymbol] * 10 # Reduce the score for each existing stage
		upsPhysicalAttack = true if statSymbol == :ATTACK
		upsSpecialAttack = true if statSymbol == :SPECIAL_ATTACK
		totalStats += 1
	end

    score += 20 if totalStats > 2	 # Stat up moves that raise 3 or more stats are better

	# Check if it boosts an offensive stat that the pokemon can't actually use
    return 0 if upsPhysicalAttack && !upsSpecialAttack && !target.hasPhysicalAttack?
    return 0 if !upsPhysicalAttack && upsSpecialAttack && !target.hasSpecialAttack?

	score -= 10 if !upsPhysicalAttack && !upsSpecialAttack # Boost moves that dont up offensives are worse
	
	return score
end