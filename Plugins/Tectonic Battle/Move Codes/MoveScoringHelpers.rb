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
    return true if target.hasActiveAbilityAI?(:OXYGENATION) && target.battle.sunny?
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
        score = -10
        if target.takesIndirectDamage?
            score += 50
            score += 20 if target.hp == target.totalhp
            score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
            score += 30 if target.trapped?
            score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
            score *= 1.5 if user.hasActiveAbilityAI?(:AGGRAVATE)
            score *= 2 if user.ownersPolicies.include?(:PRIORITIZEDOTS) && user.opposes?(target)
        end
        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(%i[TOXICBOOST POISONHEAL].concat(STATUS_UPSIDE_ABILITIES))
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?("07B") # Venoshock
    else
        return 0
    end
    return score
end

def getBurnEffectScore(user, target, ignoreCheck: false)
    return 0 if willHealStatus?(target)
    if target && (ignoreCheck || target.canBurn?(user, false))
        score = -10

        if target.takesIndirectDamage?
            score += 50
            score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
            score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
            score *= 1.5 if user.hasActiveAbilityAI?(:AGGRAVATE)
            score *= 2 if user.ownersPolicies.include?(:PRIORITIZEDOTS) && user.opposes?(target)
        end

        if target.hasPhysicalAttack?
            score += 30
            score += 30 unless target.hasSpecialAttack?
        end
        
        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(%i[FLAREBOOST BURNHEAL].concat(STATUS_UPSIDE_ABILITIES))
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?("50E") # Flare Up
    else
        return 0
    end
    return score
end

def getFrostbiteEffectScore(user, target, ignoreCheck: false)
    return 0 if willHealStatus?(target)
    if target && (ignoreCheck || target.canFrostbite?(user, false))
        score = -10

        if target.takesIndirectDamage?
            score += 50
            score += 20 if target.hp >= target.totalhp / 2 || target.hp <= target.totalhp / 8
            score += NON_ATTACKER_BONUS unless user.hasDamagingAttack?
            score *= 1.5 if user.hasActiveAbilityAI?(:AGGRAVATE)
            score *= 2 if user.ownersPolicies.include?(:PRIORITIZEDOTS) && user.opposes?(target)
        end

        if target.hasSpecialAttack?
            score += 30
            score += 30 unless target.hasPhysicalAttack?
        end

        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?([:FROSTHEAL].concat(STATUS_UPSIDE_ABILITIES))
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove? || user.pbHasMoveFunction?("50C") # Ice Impact
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
    return -10 unless target.takesIndirectDamage?
    canLeech = target.canLeech?(user, false)
    if ignoreCheck || canLeech
        score = -10
        if target.takesIndirectDamage?
            score += 50
            score += NON_ATTACKER_BONUS * 2 unless user.hasDamagingAttack?
            score += 20 if target.hp >= target.totalhp / 2
            score += 30 if target.totalhp > user.totalhp * 2
            score -= 30 if target.totalhp < user.totalhp / 2
            score *= 2 if user.hasActiveAbilityAI?(:AGGRAVATE)
            score *= 1.5 if user.hasActiveAbilityAI?(:ROOTED)
            score *= 1.3 if user.hasActiveItem?(:BIGROOT)
            score *= 2 if user.ownersPolicies.include?(:PRIORITIZEDOTS) && user.opposes?(target)
        end

        score -= STATUS_UPSIDE_MALUS if target.hasActiveAbilityAI?(STATUS_UPSIDE_ABILITIES)
        score += STATUS_PUNISHMENT_BONUS if user.hasStatusPunishMove?
    else
        return 0
    end
    return score
end

def getSleepEffectScore(user, target, _policies = [])
    score = 150
    score -= 100 if target.hasSleepAttack?
    score += STATUS_PUNISHMENT_BONUS if user&.hasStatusPunishMove?
    score -= 60 if target.hasActiveAbilityAI?(%i[SNORING SNOOZEFEST])
    if target.hasActiveAbilityAI?(:DREAMWEAVER)
        score -= getMultiStatUpEffectScore([:SPECIAL_ATTACK, 2],target,target)
    end
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
    return 0 if target.hasActiveAbilityAI?(GameData::Ability::FLINCH_IMMUNITY_ABILITIES)
    return 0 if target.substituted? && !move.ignoresSubstitute?(user)
    return 0 if target.effectActive?(:FlinchImmunity)
    return 0 if target.battle.pbCheckSameSideAbility(:HEARTENINGAROMA,target.index)

    score = baseScore
    score *= 2.0 if user.hasAlly?

    score /= 2.0 if user.battle.moonGlowing? && target.flinchedByMoonglow?(true)

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

def getHazardSettingEffectScore(user, _target, magnitude = 10)
    canChoose = false
    user.eachOpposing do |b|
        next unless user.battle.pbCanChooseNonActive?(b.index)
        canChoose = true
        return 0 if b.hasHazardRemovalMove?
        break
    end
    return 0 unless canChoose # Opponent can't switch in any Pokemon
    score = magnitude * 2
    score += magnitude * user.enemiesInReserveCount
    score += magnitude * user.alliesInReserveCount
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
    return hazardWeight
end

def hazardWeightOnSide(side, excludeEffects = [])
    hazardWeight = 0
    hazardWeight += 20 * side.countEffect(:Spikes) unless excludeEffects.include?(:Spikes)
    hazardWeight += 40 if side.effectActive?(:StealthRock) && !excludeEffects.include?(:StealthRock)
    hazardWeight += 40 if side.effectActive?(:FeatherWard) && !excludeEffects.include?(:FeatherWard)
    hazardWeight += 20 if side.effectActive?(:StickyWeb) && !excludeEffects.include?(:StickyWeb)
    hazardWeight += statusSpikesWeightOnSide(side, excludeEffects)
    return hazardWeight
end

def getSwitchOutEffectScore(switcher, scoreStatSteps = true)
    return 0 if switcher.battle.pbCanChooseNonActive?(switcher.index)
    return 0 if switcher.trapped?
    score = 5 + switcher.alliesInReserveCount * 5
    score *= 1.5 if switcher.ownersPolicies.include?(:PRIORITIZEUTURN)
    score -= hazardWeightOnSide(switcher.pbOwnSide)
    score -= statStepsValueScore(switcher) if scoreStatSteps
    return score
end

def getForceOutEffectScore(_user, target, random = true)
    return 0 if target.battle.pbCanChooseNonActive?(target.index)
    return 0 if target.effectActive?(:Ingrain)
    score = random ? 10 : -15
    score += hazardWeightOnSide(target.pbOwnSide)
    score += statStepsValueScore(target)
    return score
end

def statStepsValueScore(battler)
    score = 0
    GameData::Stat.each_battle do |s|
        statStep = battler.steps[s.id]
        if s.id == :ATTACK
            next unless battler.hasPhysicalAttack?
        elsif s.id == :SPECIAL_ATTACK
            next unless battler.hasSpecialAttack?
        end
        score += statStep * 5
    end
    echoln("[EFFECT SCORING] Scoring the total value of the stat steps on #{battler.pbThis(true)} as #{score}.")
    return score
end

def getHealingEffectScore(user, target, magnitude = 5)
    score = 0

    score += magnitude * 5 if target.hp <= (target.totalhp * 2) / 3

    score += magnitude * 5 if target.hp <= target.totalhp / 3

    score *= 1.5 if target.hasActiveAbilityAI?(:ROOTED)
    score *= 2.0 if target.hasActiveAbilityAI?(:GLOWSHROOM) && user.battle.moonGlowing?
    score *= 1.3 if target.hasActiveItem?(:BIGROOT)

    score *= -1 if target.effectActive?(:NerveBreak)

    score *= 1 + (target.steps[:DEFENSE] / 5)
    score *= 1 + (target.steps[:SPECIAL_DEFENSE] / 5)

    score *= -1 if user.opposes?(target)

    return score
end

def getMultiStatUpEffectScore(statUpArray, user, target, fakeStepModifier = 0)
    echoln("[EFFECT SCORING] Scoring the effect of raising stats #{statUpArray.to_s} on target #{target.pbThis(true)}")
    
    if user.battle.field.effectActive?(:GreyMist)
        echoln("[EFFECT SCORING] Grey Mist is active, scoring 0.")
        return 0
    end

    score = 0

    for i in 0...statUpArray.length / 2
        statSymbol = statUpArray[i * 2]
        statIncreaseAmount = statUpArray[i * 2 + 1]

        statIncreaseAmount = [PokeBattle_Battler::STAT_STEP_BOUND,statIncreaseAmount * 2].min if target.hasActiveAbilityAI?(:SIMPLE)

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
            increase = 20
        elsif statSymbol == :DEFENSE
            increase = target.tookPhysicalHitLastRound ? 20 : 10
        elsif statSymbol == :SPECIAL_DEFENSE
            increase = target.tookSpecialHitLastRound ? 20 : 10
        else
            increase = 15
        end

        increase *= statIncreaseAmount
        step = target.steps[statSymbol] + fakeStepModifier
        increase -= step * 5 # Reduce the score for each existing step
        increase = 0 if increase < 0

        score += increase

        echoln("[EFFECT SCORING] The change to #{statSymbol} by #{statIncreaseAmount} at step #{step} increases the score by #{increase}")
    end

    # Stat ups tend to be stronger on the first turn
    score *= 1.2 if target.firstTurn?

    # Stat ups tend to be stronger when the target has HP to use
    score *= 1.2 if target.hp > target.totalhp / 2

    # Stat ups tend to be stronger when the target is protected by a substitute
    score *= 1.2 if target.substituted?

    # Feel more free to use the move the fewer pokemon that can attack the buff receiver this turn
    target.eachPredictedAttacker do |_b|
        score *= 0.7
    end

    if target.hasActiveAbilityAI?(:CONTRARY)
        score *= -1
        echoln("[EFFECT SCORING] The target has Contrary! Inverting the score.")
    elsif target.hasActiveAbilityAI?(:ECCENTRIC)
        score *= -0.5
    end

    if user.opposes?(target)
        score *= -1
        echoln("[EFFECT SCORING] The target opposes the user! Inverting the score.")
    end

    enemiesCanSteal = false
    target.eachOpposing do |opp|
        next unless opp.hasStatBoostStealingMove?
        enemiesCanSteal = true
        echoln("[EFFECT SCORING] A foe of the target can steal the boost! Inverting the score.")
        break
    end

    score *= -1 if enemiesCanSteal

    return score
end

def getMultiStatDownEffectScore(statDownArray, user, target, fakeStepModifier = 0)
    echoln("[EFFECT SCORING] Scoring the effect of lowering stats #{statDownArray.to_s} on target #{target.pbThis(true)}")
    
    if user.battle.field.effectActive?(:GreyMist)
        echoln("[EFFECT SCORING] Grey Mist is active, scoring 0.")
        return 0
    end

    score = 0

    for i in 0...statDownArray.length / 2
        statSymbol = statDownArray[i * 2]
        statDecreaseAmount = statDownArray[i * 2 + 1]

        statDecreaseAmount = [PokeBattle_Battler::STAT_STEP_BOUND,statDecreaseAmount * 2].min if target.hasActiveAbilityAI?(:SIMPLE)

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
            scoreIncrease = 20
        else
            scoreIncrease = 15
        end

        scoreIncrease *= statDecreaseAmount
        step = target.steps[statSymbol] + fakeStepModifier
        scoreIncrease += step * 5 # Increase the score for each existing step
        scoreIncrease = 0 if scoreIncrease < 0

        score += scoreIncrease
        
        echoln("[EFFECT SCORING] The change to #{statSymbol} by #{statDecreaseAmount} at step #{step} increases the score by #{scoreIncrease}")
    end

    # Stat downs tend to be stronger when the target has HP to use
    score *= 1.2 if target.firstTurn?

    # Stat downs tend to be stronger when the target has HP to use
    score *= 1.2 if target.hp > target.totalhp / 2

    # Stat downs tend to be weaker when the target is able to swap out
    score /= 2 if user.battle.pbCanSwitch?(target.index)

    if target.hasActiveAbilityAI?(:CONTRARY)
        score *= -1
        echoln("[EFFECT SCORING] The target has Contrary! Inverting the score.")
    elsif target.hasActiveAbilityAI?(:ECCENTRIC)
        score *= -0.5
    end

    unless user.opposes?(target)
        score *= -1
        echoln("[EFFECT SCORING] The target is an ally of the user! Inverting the score.")
    end

    return score
end

def getWeatherSettingEffectScore(weatherType, user, battle, finalDuration = 4, checkExtensions = true)
    if battle.primevalWeatherPresent? || battle.pbCheckGlobalAbility(%i[AIRLOCK CLOUDNINE)])
        echoln("[EFFECT SCORING] Score for setting weather #{weatherType} is 0 due to presence of weather-disabling ability")
        return 0
    end

    finalDuration = user.getWeatherSettingDuration(weatherType, finalDuration, true) if checkExtensions
    currentDuration = battle.field.weather == weatherType ? battle.field.weatherDuration : 0

    if currentDuration >= finalDuration
        echoln("[EFFECT SCORING] Score for setting weather #{weatherType} is 0 due to final duration #{finalDuration} being less than the current duration #{currentDuration}")
        return 0
    end

    finalScore = (10 * finalDuration**0.7).ceil
    currentScore = (10 * currentDuration**0.7).ceil
    score = finalScore - currentScore

    echoln("[EFFECT SCORING] Base score for setting weather #{weatherType} calculated as #{score} from difference of #{finalDuration}-turn final duration score (#{finalScore}) and #{currentDuration}-turn current duration score (#{currentScore})")

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
    when :Moonglow
        weatherMatchesPolicy = true if user.ownersPolicies.include?(:MOONGLOW_TEAM)
        hasSynergyAbility = true if user.hasActiveAbilityAI?(GameData::Ability::MOONGLOW_ABILITIES)
        hasSynergisticType = true if user.pbHasAttackingType?(:FAIRY)
    when :Eclipse
        weatherMatchesPolicy = true if user.ownersPolicies.include?(:ECLIPSE_TEAM)
        hasSynergyAbility = true if user.hasActiveAbilityAI?(GameData::Ability::ECLIPSE_ABILITIES)
        hasSynergisticType = true if user.pbHasAttackingType?(:PSYCHIC)
    end
    
    if weatherMatchesPolicy
        echoln("[EFFECT SCORING] Base score for setting weather #{weatherType} tripled due to relevant policy")
        score *= 3
    end

    hasSynergyAbility = true if user.hasActiveAbilityAI?(GameData::Ability::GENERAL_WEATHER_ABILITIES)

    score *= 1.2 if hasSynergisticType
    score *= 1.4 if hasSynergyAbility && user.aboveHalfHealth?
   
    return score
end

def getCriticalRateBuffEffectScore(user, steps = 1)
    return 0 if user.effectAtMax?(:FocusEnergy)
    score = 20
    score += 15 if user.firstTurn?
    score += 30 if user.hasActiveAbilityAI?(%i[SUPERLUCK SNIPER])
    score += 15 if user.hasHighCritAttack?
    score *= steps
    return score
end

def getHPLossEffectScore(user, fraction)
    score = -80 * fraction
    if user.hp <= user.totalhp * fraction
        return -300 unless user.alliesInReserve?
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
    score /= 2 if user.battle.pbCanSwitch?(target.index)
    return score
end

def getMovesLikelihoodScore(battler)
    score = 0
    battler.eachAIKnownMove do |move|
        next unless yield move
        thisMoveScore = move.getEffectScore(battler,battler)
        score = thisMoveScore if thisMoveScore > score
    end
    return score
end

def getSetupLikelihoodScore(battler,&block)
    return getMovesLikelihoodScore(battler) { |move|
        next false if block&.call(move) == false
        next !move.statUp.empty?
    }
end

def getHazardLikelihoodScore(battler,&block)
    return getMovesLikelihoodScore(battler) { |move|
        next false if block&.call(move) == false
        next move.hazardMove?
    }
end

def passingTurnEffectScore(battle,sideIndex = 1)
    score = 0
    battle.eachBattler do |b|
        healthChange = predictedEOTHealing(battle,b)
        healthChange -= predictedEOTDamage(battle,b)

        healthPercentage = healthChange / b.totalhp.to_f
        battlerScore = (healthPercentage * 100).ceil
        battlerScore *= -1 if b.index % 2 != sideIndex
        score += battlerScore
    end
    return score
end

def predictedEOTDamage(battle,battler)
    damage = 0
    # Sandstorm
    # Hail

    # Status DOTs
    damage += battle.damageFromDOTStatus(battler, :POISON, true) if battler.poisoned?
    damage += battle.damageFromDOTStatus(battler, :LEECHED, true) if battler.leeched?
    damage += battle.damageFromDOTStatus(battler, :BURN, true) if battler.burned?
    damage += battle.damageFromDOTStatus(battler, :FROSTBITE, true) if battler.frostbitten?

    # Curse
    # Trapping DOT

    # Bad Dreams
    # Painful Presence

    # Sticky Barb

    return damage
end

def predictedEOTHealing(battle,battler)
    healing = 0
    # Aqua Ring
    # Ingrain
    # Wish

    # Grotesque Vitals, Fighting Valor, Well Supplied
    # Rain Dish, Dry Skin
    # Fine Sugar, Heat Savor
    # Rock Body
    # Ice Body
    # Vital Rhythm

    # Leftovers

    # Harvest, Larder
    return healing
end

def getAquaRingEffectScore(user)
    return 0 if user.effectActive?(:AquaRing)
    score = 40
    score += 40 if user.aboveHalfHealth?
    return score
end