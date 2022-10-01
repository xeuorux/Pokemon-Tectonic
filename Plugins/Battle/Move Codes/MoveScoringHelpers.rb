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
def getParalysisMoveScore(score,user,target,skill=100,policies=[],statusMove=false,twave=false)
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
		score -= 60 if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
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
	elsif statusMove
		return 0
	end
	return score
end

def getFrostbiteMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	if target.pbCanFrostbite?(user,false)
		score += 30
		score -= 60 if target.hasActiveAbilityAI?([:FROSTHEAL].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && statusMove
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
	return score
end

def getFlusterMoveScore(score,user,target,skill=100,policies=[],statusMove=false)
	canFluster = target.pbCanFluster?(user,false) && !target.hasActiveAbility?(:MENTALBLOCK)
	if canFluster
		score += 20
		score += 20 if user.hasPhysicalAttack?
		score -= 60 if target.hasActiveAbilityAI?([:FLUSTERFLOCK].concat(STATUS_UPSIDE_ABILITIES))
		score = 9999 if policies.include?(:PRIORITIZEDOTS) && statusMove
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
	elsif statusMove?
		return 0
	end
	return score
end

def getFlinchingMoveScore(score,user,target,skill,policies)
	userSpeed = pbRoughStat(user,:SPEED,skill)
    targetSpeed = pbRoughStat(target,:SPEED,skill)
    
    if target.hasActiveAbilityAI?(:INNERFOCUS) || target.effects[PBEffects::Substitute] != 0 ||
          target.effects[PBEffects::FlinchedAlready] || targetSpeed > userSpeed
      score -= 30
    else
      score += 30
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
	if !canChoose
		# Opponent can't switch in any Pokemon
		return 0
	else
		score += 20 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
		score += 10 * @battle.pbAbleNonActiveCount(user.idxOwnSide)
	end
	return score
end

def getSelfKOMoveScore(score,user,target,skill=100)
	reserves = user.battle.pbAbleNonActiveCount(user.idxOwnSide)
	return 0 if reserves == 0 # don't want to lose or draw
	return 0 if user.hp > user.totalhp / 2
	score -= 30 if user.hp > user.totalhp / 8
	return score
end

def hazardWeightOnSide(side)
	hazardWeight = 0
	hazardWeight += 20 * side.effects[PBEffects::Spikes]
	hazardWeight += 20 * side.effects[PBEffects::ToxicSpikes]
	hazardWeight += 20 * side.effects[PBEffects::FlameSpikes]
	hazardWeight += 20 * side.effects[PBEffects::FrostSpikes]
	hazardWeight += 50 if side.effects[PBEffects::StealthRock]
	return hazardWeight
end

def getSwitchOutMoveScore(score,user,target,skill=100)
	score -= 10
	score -= hazardWeightOnSide(user.pbOwnSide)
	return score
end

def getForceOutMoveScore(score,user,target,skill=100,statusMove=false)
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

def getTargetedHealingMoveScore(score,user,target,skill)
	return 0 if user.opposes?(target) && !target.effects[PBEffects::NerveBreak]
    return 0 if !user.opposes?(target) && target.effects[PBEffects::NerveBreak]

	score += 20 if target.hasActiveAbilityAI?(:ROOTED)
    score += 10 if target.hasActiveAbilityAI?(:ROOTED)
    score += 10 if target.hasActiveItem?(:BIGROOT)
    if target.hp <= target.totalhp / 2
      score += 20
    end
	return score
end