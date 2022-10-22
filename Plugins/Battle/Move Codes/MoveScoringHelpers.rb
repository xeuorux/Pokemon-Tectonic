DOWNSIDE_ABILITIES = [:SLOWSTART,:DEFEATIST,:TRUANT]

STATUS_UPSIDE_ABILITIES = [:GUTS,:AUDACITY,:MARVELSCALE,:MARVELSKIN,:QUICKFEET]

def getStatusSettingMoveScore(statusApplying,score,user,target,skill=100,policies=[],statusMove=false)
	case statusApplying
	when :SLEEP
		return getSleepMoveScore(score,user,target,skill,policies,statusMove)
	when :POISON
		return getPoisonMoveScore(score,user,target,skill,policies,statusMove)
	when :BURN
		return getBurnMoveScore(score,user,target,skill,policies,statusMove)
	when :FROSTBITE
		return getFrostbiteMoveScore(score,user,target,skill,policies,statusMove)
	when :PARALYSIS
		return getParalysisMoveScore(score,user,target,skill,policies,statusMove)
	when :FROZEN
		return 0
	when :FLUSTERED
		return getFlusterMoveScore(score,user,target,skill,policies,statusMove)
	when :MYSTIFIED
		return getMystifyMoveScore(score,user,target,skill,policies,statusMove)
	end

	return score
end

# Actually used for numbing now
def getParalysisMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	if target && target.pbCanParalyze?(user,false)
		score += 10
		aspeed = pbRoughStat(user,:SPEED,skill)
		ospeed = pbRoughStat(target,:SPEED,skill)
		if aspeed < ospeed
			score += 30
		elsif aspeed > ospeed
			score -= 30
		end
		score -= 60 if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
		score += 50 if statusMove && user.hasStatusPunishMove?
	elsif statusMove
		return 0
	end
	return score
end

def getPoisonMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	if target && target.pbCanPoison?(user,false)
		score += 30
		score -= 60 if target.hasActiveAbilityAI?([:TOXICBOOST,:POISONHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && statusMove
		score += 50 if statusMove && user.hasStatusPunishMove?
	elsif statusMove
		return 0
	end
	return score
end

def getBurnMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	if target && target.pbCanBurn?(user,false)
		score += 30
		score -= 60 if target.hasActiveAbilityAI?([:FLAREBOOST,:BURNHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && statusMove
		score += 50 if statusMove && user.hasStatusPunishMove?
	elsif statusMove
		return 0
	end
	return score
end

def getFrostbiteMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	if target && target.pbCanFrostbite?(user,false)
		score += 30
		score -= 60 if target.hasActiveAbilityAI?([:FROSTHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && statusMove
		score += 50 if statusMove && user.hasStatusPunishMove?
	elsif statusMove
		return 0
	end
	return score
end

def getSleepMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	return 0 if statusMove && target.effects[PBEffects::Yawn] > 0
	if target.hasSleepAttack?
		score += 20
	else
		score += 100
	end
	score += 50 if statusMove && user.hasStatusPunishMove?
	return score
end

def getFlusterMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	canFluster = target.pbCanFluster?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
	if canFluster
		score += 20
		score += 20 if user.hasPhysicalAttack?
		score -= 60 if target.hasActiveAbilityAI?([:FLUSTERFLOCK].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && statusMove
		score += 50 if statusMove && user.hasStatusPunishMove?
	elsif statusMove?
		return 0
	end
	return score
end

def getMystifyMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	canMystify = target.pbCanMystify?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
    if canMystify
		score += 20
		score += 20 if user.hasSpecialAttack?
		score -= 60 if target.hasActiveAbilityAI?([:HEADACHE].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && statusMove
		score += 50 if statusMove && user.hasStatusPunishMove?
	elsif statusMove?
		return 0
	end
	return score
end

def getFlinchingMoveScore(score,user,target,skill,policies,magnitude=3)
	userSpeed = pbRoughStat(user,:SPEED,skill)
    targetSpeed = pbRoughStat(target,:SPEED,skill)
    
    if target.hasActiveAbilityAI?(:INNERFOCUS) || target.effects[PBEffects::Substitute] > 0 ||
          target.effects[PBEffects::FlinchedAlready] || targetSpeed > userSpeed
      score -= magnitude * 10
    else
      score += magnitude * 10
    end
	return score
end

def getWantsToBeFasterScore(score,user,other,skill=100,magnitude=1)
	return getWantsToBeSlowerScore(score,user,other,skill,-magnitude)
end

def getWantsToBeSlowerScore(score,user,other,skill=100,magnitude=1)
	userSpeed = pbRoughStat(user,:SPEED,skill)
	otherSpeed = pbRoughStat(other,:SPEED,skill)
	if userSpeed < otherSpeed
		score += 10 * magnitude
	else
		score -= 10 * magnitude
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
	return 0 if !canChoose # Opponent can't switch in any Pokemon
		
	score += 20 * user.enemiesInReserveCount
	score += 10 * user.alliesInReserveCount
	return score
end

def getSelfKOMoveScore(score,user,target,skill=100)
	reserves = user.battle.pbAbleNonActiveCount(user.idxOwnSide)
	return 0 if reserves == 0 # don't want to lose or draw
	return 0 if user.hp > user.totalhp / 2
	score -= 30 if user.hp > user.totalhp / 8
	return score
end

def statusSpikesWeightOnSide(side,excludeEffects=[])
	hazardWeight = 0
	hazardWeight += 20 * side.effects[PBEffects::PoisonSpikes] if !excludeEffects.include?(PBEffects::PoisonSpikes)
	hazardWeight += 20 * side.effects[PBEffects::FlameSpikes] if !excludeEffects.include?(PBEffects::FlameSpikes)
	hazardWeight += 20 * side.effects[PBEffects::FrostSpikes] if !excludeEffects.include?(PBEffects::FrostSpikes)
	return 0
end

def hazardWeightOnSide(side,excludeEffects=[])
	hazardWeight = 0
	hazardWeight += 20 * side.effects[PBEffects::Spikes] if !excludeEffects.include?(PBEffects::Spikes)
	hazardWeight += 50 if side.effects[PBEffects::StealthRock] if !excludeEffects.include?(PBEffects::StealthRock)
	hazardWeight += 20 if side.effects[PBEffects::StickyWeb]
	hazardWeight += statusSpikesWeightOnSide(side,excludeEffects)
	return hazardWeight
end

def getSwitchOutMoveScore(score,user,target,skill=100)
	score -= 10
	score -= hazardWeightOnSide(user.pbOwnSide)
	return score
end

def getForceOutMoveScore(score,user,target,skill=100,statusMove=false)
	return 0 if target.substituted?
	count = 0
	@battle.pbParty(target.index).each_with_index do |pkmn,i|
		count += 1 if @battle.pbCanSwitchLax?(target.index,i)
	end
	return 0 if count
	score += hazardWeightOnSide(target.pbOwnSide)
	return score
end

def getSelfKOMoveScore(score,user,target,skill=100)
	reserves = user.battle.pbAbleNonActiveCount(user.idxOwnSide)
	return 0 if reserves == 0 # don't want to lose or draw
	return 0 if user.hp > user.totalhp / 2
	score -= 30 if user.hp > user.totalhp / 8
	return score
end

def getHealingMoveScore(score,user,target,skill=100,magnitude=5)
	return 0 if user.opposes?(target) && !target.effects[PBEffects::NerveBreak]
    return 0 if !user.opposes?(target) && target.effects[PBEffects::NerveBreak]
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

def getMultiStatUpMoveScore(statUp,score,user,target,skill=100,statusMove=true)
    # Stat up moves tend to be strong on the first turn
    score += 50 if target.firstTurn? && statusMove

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
    if statusMove
      return 0 if upsPhysicalAttack && !upsSpecialAttack && !target.hasPhysicalAttack?
      return 0 if !upsPhysicalAttack && upsSpecialAttack && !target.hasSpecialAttack?
    end

	score -= 10 if !upsPhysicalAttack && !upsSpecialAttack # Boost moves that dont up offensives are worse
	
	return score
end