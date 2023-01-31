DOWNSIDE_ABILITIES = %i[SLOWSTART PRIMEVALSLOWSTART DEFEATIST TRUANT]

STATUS_UPSIDE_ABILITIES = %i[GUTS AUDACITY MARVELSCALE MARVELSKIN QUICKFEET]

ALL_STATUS_SCORE_BONUS = 0
STATUS_UPSIDE_MALUS = 60
NON_ATTACKER_BONUS = 30
STATUS_PUNISHMENT_BONUS = 40

def getStatusSettingEffectScore(statusApplying, user, target, ignoreCheck: false)
    case statusApplying
    when :SLEEP
        return getSleepEffectScore(user, target, ignoreCheck: ignoreCheck)
    when :POISON
        return getPoisonEffectScore(user, target, ignoreCheck: ignoreCheck)
    when :BURN
        return getBurnEffectScore(user, target, ignoreCheck: ignoreCheck)
    when :FROSTBITE
        return getFrostbiteEffectScore(user, target, ignoreCheck: ignoreCheck)
    when :NUMB
        return getNumbEffectScore(user, target, ignoreCheck: ignoreCheck)
    when :DIZZY
        return getDizzyEffectScore(user, target, ignoreCheck: ignoreCheck)
    when :LEECHED
        return getLeechEffectScore(user, target, ignoreCheck: ignoreCheck)
    end

    raise _INTL("Given status #{statusApplying} is not valid.")
end

def willHealStatus?(target)
    return true if target.hasActiveAbilityAI?(:SHEDSKIN)
    return true if target.hasActiveAbilityAI?(:HYDRATION) && target.battle.rainy?
    return false
end

def getNumbEffectScore(user, target, ignoreCheck: false)
    return 0 if willHealStatus?(target)
    if target && (ignoreCheck || target.canNumb?(user, false))
        score = 0
        score += 60 if target.hasDamagingAttack?
        score += 60 if target.pbSpeed(true) > user.pbSpeed(true)
        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? ||
                                            user.pbHasMoveFunction?("07C", "579") # Smelling Salts, Spectral Tongue
        score += 60 if user.hasActiveAbilityAI?(:TENDERIZE)
    else
        return 0
    end
    return score
end

def getPoisonEffectScore(user, target, ignoreCheck: false)
    return 0 if willHealStatus?(target)
    if target && (ignoreCheck || target.canPoison?(user, false))
        return 9999 if user.ownersPolicies.include?(:PRIORITIZEDOTS) && user.opposes?(target)
        score = 40
        score += 20 if target.hp == target.totalhp
        score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
        score += 60 if @battle.pbIsTrapped?(target.index)
        score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(%i[TOXICBOOST
                                                                      POISONHEAL].concat(STATUS_UPSIDE_ABILITIES))
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?("07B") # Venoshock
        score *= 1.5 if user.hasActiveAbilityAI?(:AGGRAVATE)
    else
        return 0
    end
    return score
end

def getBurnEffectScore(user, target, ignoreCheck: false)
    return 0 if willHealStatus?(target)
    if target && (ignoreCheck || target.canBurn?(user, false))
        return 9999 if user.ownersPolicies.include?(:PRIORITIZEDOTS) && user.opposes?(target)
        score = 40
        if target.hasPhysicalAttack?
            score += 30
            score += 30 unless target.hasSpecialAttack?
        end
        score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
        score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(%i[FLAREBOOST
                                                                      BURNHEAL].concat(STATUS_UPSIDE_ABILITIES))
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?("50E") # Flare Up
        score *= 1.5 if user.hasActiveAbilityAI?(:AGGRAVATE)
    else
        return 0
    end
    return score
end

def getFrostbiteEffectScore(user, target, ignoreCheck: false)
    return 0 if willHealStatus?(target)
    if target && (ignoreCheck || target.canFrostbite?(user, false))
        return 9999 if user.ownersPolicies.include?(:PRIORITIZEDOTS) && user.opposes?(target)
        score = 40
        if target.hasSpecialAttack?
            score += 30
            score += 30 unless target.hasPhysicalAttack?
        end
        score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
        score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?([:FROSTHEAL].concat(STATUS_UPSIDE_ABILITIES))
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?("50C") # Ice Impact
        score *= 1.5 if user.hasActiveAbilityAI?(:AGGRAVATE)
    else
        return 0
    end
    return score
end

def getDizzyEffectScore(user, target, ignoreCheck: false)
    canDizzy = target.canDizzy?(user, false) && !target.hasActiveAbility?(:MENTALBLOCK)
    if ignoreCheck || canDizzy
        score = 60 # TODO: Some sort of basic AI for rating abilities?
        score += 20 if target.hp >= target.totalhp / 2
        score += 20 if user.hasDamagingAttack?
        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove?
    else
        return 0
    end
    return score
end

def getLeechEffectScore(user, target, ignoreCheck: false)
    return 0 if willHealStatus?(target)
    canLeech = target.canLeech?(user, false)
    if ignoreCheck || canLeech
        return 9999 if user.ownersPolicies.include?(:PRIORITIZEDOTS) && user.opposes?(target)
        score = 40
        score += NON_ATTACKER_BONUS * 2 unless user.hasDamagingAttack?
        score += 20 if target.hp >= target.totalhp / 2
        score += 30 if target.totalhp > user.totalhp * 2
        score -= 30 if target.totalhp < user.totalhp / 2
        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove?
        score *= 2 if user.hasActiveAbilityAI?(:AGGRAVATE)
        score *= 1.5 if user.hasActiveAbilityAI?(:ROOTED)
        score *= 1.3 if user.hasActiveItem?(:BIGROOT)
        score *= 2 if user.hasAlly?
    else
        return 0
    end
    return score
end

def getSleepEffectScore(user, target, _policies = [])
    score = 200
    score -= 100 if target.hasSleepAttack?
    score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove?
    return score
end

def userWillHitFirst?(user, target, move)
    userSpeed = user.pbSpeed(true)
    targetSpeed = target.pbSpeed(true)

    movePrio = user.battle.getMovePriority(move, user, [target], true)

    return true if movePrio > 0
    return false if movePrio < 0
    return userSpeed > targetSpeed
end

def getFlinchingEffectScore(baseScore, user, target, move)
    return 0 unless userWillHitFirst?(user, target, move)

    if target.hasActiveAbilityAI?(:INNERFOCUS) || target.substituted? ||
       target.effectActive?(:FlinchedAlready)
        return 0
    end

    score = baseScore
    score *= 2 if user.hasAlly?

    return score
end

def getWantsToBeFasterScore(user, other, magnitude = 1)
    return getWantsToBeSlowerScore(user, other, -magnitude)
end

def getWantsToBeSlowerScore(user, other, magnitude = 1)
    userSpeed = user.pbSpeed(true)
    otherSpeed = other.pbSpeed(true)
    if userSpeed < otherSpeed
        return 10 * magnitude
    else
        return -10 * magnitude
    end
end

def getHazardSettingEffectScore(user, _target)
    canChoose = false
    user.eachOpposing do |b|
        next unless user.battle.pbCanChooseNonActive?(b.index)
        canChoose = true
        break
    end
    return 0 unless canChoose # Opponent can't switch in any Pokemon
    score = 0
    score += 20 * user.enemiesInReserveCount
    score += 20 * user.alliesInReserveCount
    return score
end

def getSelfKOMoveScore(user, _target)
    reserves = user.battle.pbAbleNonActiveCount(user.idxOwnSide)
    return -200 if reserves == 0 # don't want to lose or draw
    return ((-user.hp / user.totalhp.to_f) * 100).round
end

def statusSpikesWeightOnSide(side, excludeEffects = [])
    hazardWeight = 0
    hazardWeight += 20 * side.countEffect(:PoisonSpikes) unless excludeEffects.include?(:PoisonSpikes)
    hazardWeight += 20 * side.countEffect(:FlameSpikes) unless excludeEffects.include?(:FlameSpikes)
    hazardWeight += 20 * side.countEffect(:FrostSpikes) unless excludeEffects.include?(:FrostSpikes)
    return 0
end

def hazardWeightOnSide(side, excludeEffects = [])
    hazardWeight = 0
    hazardWeight += 20 * side.countEffect(:Spikes) unless excludeEffects.include?(:Spikes)
    hazardWeight += 50 if side.effectActive?(:StealthRock) && !excludeEffects.include?(:StealthRock)
    hazardWeight += 20 if side.effectActive?(:StickyWeb) && !excludeEffects.include?(:StickyWeb)
    hazardWeight += statusSpikesWeightOnSide(side, excludeEffects)
    return hazardWeight
end

def getSwitchOutEffectScore(user, _target)
    score = 30
    score -= hazardWeightOnSide(user.pbOwnSide)
    return score
end

def getForceOutEffectScore(_user, target)
    return 0 if target.substituted?
    return 0 if target.battle.pbCanChooseNonActive?(target.index)
    return hazardWeightOnSide(target.pbOwnSide)
end

def getHealingEffectScore(user, target, magnitude = 5)
    score = 0

    score += magnitude * 5 if target.hp <= (target.totalhp * 2) / 3

    score += magnitude * 5 if target.hp <= target.totalhp / 3

    score *= 1.5 if target.hasActiveAbilityAI?(:ROOTED)
    score *= 1.3 if target.hasActiveItem?(:BIGROOT)

    score *= -1 if target.effectActive?(:NerveBreak)

    score *= 1 + (target.stages[:DEFENSE] / 5)
    score *= 1 + (target.stages[:SPECIAL_DEFENSE] / 5)

    score *= -1 if user.opposes?(target)

    return score
end

def getMultiStatUpEffectScore(statUpArray, user, target)
    echoln("[EFFECT SCORING] Scoring the effect of raising stats #{statUpArray.to_s} on target #{target.pbThis(true)}")
    
    if user.battle.field.effectActive?(:GreyMist)
        echoln("[EFFECT SCORING] Grey Mist is active, scoring 0.")
        return 0
    end

    score = 0

    for i in 0...statUpArray.length / 2
        statSymbol = statUpArray[i * 2]
        statIncreaseAmount = statUpArray[i * 2 + 1]

        # Give no extra points for attacking stats you can't use
        if statSymbol == :ATTACK && !target.hasPhysicalAttack?
            echoln("[EFFECT SCORING] Ignoring Attack changes, the target has no physical attacks")
            next
        end
        if statSymbol == :SPECIAL_ATTACK && !target.hasSpecialAttack?
            echoln("[EFFECT SCORING] Ignoring Sp. Atk changes, the target has no special attacks")
            next
        end

        # Increase the score more for boosting attacking stats
        if %i[ATTACK SPECIAL_ATTACK].include?(statSymbol)
            increase = 40
        else
            increase = 30
        end

        increase *= statIncreaseAmount
        increase -= target.stages[statSymbol] * 10 # Reduce the score for each existing stage

        score += increase

        echoln("[EFFECT SCORING] The change to #{statSymbol} by #{statIncreaseAmount} increases the score by #{increase}")
    end

    # Stat up moves tend to be strong on the first turn
    score *= 1.2 if target.firstTurn?

    # Stat up moves tend to be strong when you have HP to use
    score *= 1.2 if target.hp > target.totalhp / 2

    # Stat up moves tend to be strong when you are protected by a substitute
    score *= 1.2 if target.substituted?

    # Feel more free to use the move the fewer pokemon that can attack the buff receiver this turn
    target.eachPotentialAttacker do |_b|
        score *= 0.8
    end

    if target.hasActiveAbility?(:CONTRARY)
        score *= -1
        echoln("[EFFECT SCORING] The target has Contrary! Inverting the score.")
    end
    if user.opposes?(target)
        score *= -1
        echoln("[EFFECT SCORING] The target opposes the user! Inverting the score.")
    end

    return score
end

def getMultiStatDownEffectScore(statDownArray, user, target)
    echoln("[EFFECT SCORING] Scoring the effect of lowering stats #{statDownArray.to_s} on target #{target.pbThis(true)}")
    
    if user.battle.field.effectActive?(:GreyMist)
        echoln("[EFFECT SCORING] Grey Mist is active, scoring 0.")
        return 0
    end

    score = 0

    for i in 0...statDownArray.length / 2
        statSymbol = statDownArray[i * 2]
        statDecreaseAmount = statDownArray[i * 2 + 1]

        if statSymbol == :ACCURACY
            echoln("The AI will never use a move that reduces accuracy.")
            return -100
        end

        # Give no extra points for attacking stats you can't use
        if statSymbol == :ATTACK && !target.hasPhysicalAttack?
            echoln("[EFFECT SCORING] Ignoring Attack changes, the target has no physical attacks")
            next
        end
        if statSymbol == :SPECIAL_ATTACK && !target.hasSpecialAttack?
            echoln("[EFFECT SCORING] Ignoring Sp. Atk changes, the target has no special attacks")
            next
        end

        # Increase the score more for boosting attacking stats
        if %i[ATTACK SPECIAL_ATTACK].include?(statSymbol)
            scoreIncrease = 40
        else
            scoreIncrease = 30
        end

        scoreIncrease *= statDecreaseAmount
        scoreIncrease += target.stages[statSymbol] * 10 # Increase the score for each existing stage

        score += scoreIncrease
        
        echoln("[EFFECT SCORING] The change to #{statSymbol} by #{statDecreaseAmount} increases the score by #{scoreIncrease}")
    end

    # Stat up moves tend to be strong on the first turn
    score *= 1.2 if target.firstTurn?

    # Stat up moves tend to be strong when you have HP to use
    score *= 1.2 if target.hp > target.totalhp / 2

    score *= 2 if @battle.pbIsTrapped?(target.index)

    if target.hasActiveAbility?(:CONTRARY)
        score *= -1
        echoln("[EFFECT SCORING] The target has Contrary! Inverting the score.")
    end
    unless user.opposes?(target)
        score *= -1
        echoln("[EFFECT SCORING] The target is an ally of the user! Inverting the score.")
    end

    return score
end

def getWeatherSettingEffectScore(weatherType, user, battle, duration = 4)
    return 0 if battle.primevalWeatherPresent? || battle.pbCheckGlobalAbility(:AIRLOCK) ||
                battle.pbCheckGlobalAbility(:CLOUDNINE) || battle.pbWeather == @weatherType

    score = 10 * user.getWeatherSettingDuration(weatherType, duration, true)

    weatherMatchesPolicy = false
    hasSynergyAbility = false
    hasSynergisticType = false
    case weatherType
    when :Sun
        weatherMatchesPolicy = true if user.ownersPolicies.include?(:SUN_TEAM)
        hasSynergyAbility = true if user.hasActiveAbilityAI?(GameData::Ability::SUN_ABILITIES)
        hasSynergisticType = true if user.pbHasAttackingType?(:FIRE)
    when :Rain
        weatherMatchesPolicy = true if user.ownersPolicies.include?(:RAIN_TEAM)
        hasSynergyAbility = true if user.hasActiveAbilityAI?(GameData::Ability::RAIN_ABILITIES)
        hasSynergisticType = true if user.pbHasAttackingType?(:WATER)
    when :Sandstorm
        weatherMatchesPolicy = true if user.ownersPolicies.include?(:SANDSTORM_TEAM)
        hasSynergyAbility = true if user.hasActiveAbilityAI?(GameData::Ability::SAND_ABILITIES)
        hasSynergisticType = true if user.pbHasTypeAI?(:ROCK)
    when :Hail
        weatherMatchesPolicy = true if user.ownersPolicies.include?(:HAIL_TEAM)
        hasSynergyAbility = true if user.hasActiveAbilityAI?(GameData::Ability::HAIL_ABILITIES)
        hasSynergisticType = true if user.pbHasTypeAI?(:ICE)
    end
    return 300 if weatherMatchesPolicy

    score += 20 if hasSynergisticType
    score += 40 if hasSynergyAbility
    score += 10 if user.aboveHalfHealth?

    score += 20 if user.pbHasMoveFunction?("087") # Weather Ball
   
    return score
end

def getCriticalRateBuffEffectScore(user, stages = 1)
    score = 20
    score += 15 if user.firstTurn?
    score += 30 if user.hasActiveAbilityAI?(%i[SUPERLUCK SNIPER])
    score += 15 if user.hasHighCritAttack?
    score *= stages
    return score
end

def getHPLossEffectScore(user, fraction)
    score = -80 * fraction
    if user.hp <= user.totalhp * fraction
        return 0 unless user.alliesInReserve?
        score *= 2
    end
    return score
end

def getSuppressAbilityEffectScore(user, target)
    score = 0
    if target.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        score = -70
    else
        score = 70
    end

    score *= -1 unless user.opposes?(target)

    return score
end

def getCurseEffectScore(user, target)
    score = 50
    score += 50 if target.aboveHalfHealth?
    score *= 1.5 if user.hasActiveAbilityAI?(:AGGRAVATE)
    return score
end
