#=============================================================================
# Get approximate properties for a battler
#=============================================================================
def pbRoughType(move, user)
    ret = move.pbCalcType(user)
    return ret
end

#=============================================================================
# Nerf the AI at lower levels, to maintain the same playstyle as endgame
# Used in Wish, Switching, and Damage
#=============================================================================
def levelNerf(switch,damage,intensity)
    levelBracket = (level / 5.0).ceil
    levelPenalty = [0,15.0,15.0,13.0,10.0,8.0,5.0][levelBracket]
    levelPenalty *= intensity
    if switch == true
        PBDebug.log("[STAY-IN RATING][LEVEL NERF] #{pbThis} (#{index}) is penalizing switching (+#{levelPenalty.round})")
    elsif damage == true
        levelPenalty = levelPenalty / 5 / 10 + 1.0
        PBDebug.log"[LEVEL NERF] Adjusted score by (+#{((levelPenalty -= 1) * 100).round})%"
    else
        levelPenalty = -levelPenalty / 5 / 10 + 1.0
        PBDebug.log"[LEVEL NERF] Adjusted score by (-#{100 - (levelPenalty * 100).round})%"
    end
    
    return levelPenalty
end

#=============================================================================
# Evaluate the relative speed of a battler
#=============================================================================

def getSpeedTier
    speedTiers = [
        [0,0], # 0 / this should not happen
        [0,0], # 5 / this should not happen
        [23,33], # 10 / base 45 (0 investment) / base 60 (10 investment)
        [26,37], # 15 / base 45 (0 investment) / base 60 (10 investment)
        [35,48], # 20 / base 60 (0 investment) / base 75 (10 investment)
        [38,55], # 25 / base 60 (0 investment) / base 80 (10 investment)
        [41,63], # 30 / base 60 (0 investment) / base 85 (10 investment)
        [47,72], # 35 / base 65 (0 investment) / base 95 (10 investment)
        [54,84], # 40 / base 70 (0 investment) / base 100 (10 investment)
        [57,90], # 45 / base 70 (0 investment) / base 100 (10 investment)
        [61,97], # 50 / base 70 (0 investment) / base 100 (10 investment)
        [64,103], # 55 / base 70 (0 investment) / base 100 (10 investment)
        [68,109], # 60 / base 70 (0 investment) / base 100 (10 investment)
        [71,115], # 65 / base 70 (0 investment) / base 100 (10 investment)
        [75,122], # 70 / base 70 (0 investment) / base 100 (10 investment)
    ]
    tierCheck = speedTiers[(level / 5.0).ceil]
    effectiveSpeed = base_speed
    # TODO: Account for Speed boosting abilities
    effectiveSpeed /= 2 if numbed? && !hasActiveAbility?(:NATURALCURE)
    effectiveSpeed * 1.4 if hasActiveItem?:CHOICESCARF
    effectiveSpeed * 1.1 if hasActiveItem?:SEVENLEAGUEBOOTS
    if effectiveSpeed >= tierCheck[1]
        return 2 # Fast
    elsif effectiveSpeed >= tierCheck[0]
        return 1 # Average
    else
        return 0 # Slow
    end
end

#=============================================================================
# Figure out if the AI should play more aggressively
# because the situation allows/requires it
#=============================================================================
def getUrgency
    urgency = 0
    eachOpposing do |b|
        urgency += 1 if !b.canActThisTurn? # pressure sleeping mons
        urgency += 2 if b.hasSetupMove?
        urgency += 2 if b.hasSetupMove? && b.lastRoundMoveCategory == 2 # Actively setting up
        urgency += 2 if b.hasUseableHazardMove?
        urgency += 1 if b.hasUseableHazardMove? && b.lastRoundMoveCategory == 2 # Actively hazard stacking
        urgency += 2 if b.hasActiveAbilityAI?(:CONTRARY) || b.hasActiveAbilityAI?(:ECCENTRIC) || b.hasActiveAbilityAI?(:PERSISTENTGROWTH)
    end
    if inWeatherTeam && urgency = 0
        weatherInfo = [
            [:SUN_TEAM, @battle.sunny?, :DROUGHT, :HEATROCK],
            [:RAIN_TEAM, @battle.rainy?, :DRIZZLE, :DAMPROCK],
            [:SAND_TEAM, @battle.sandy?, :SANDSTREAM, :SMOOTHROCK],
            [:HAIL_TEAM, @battle.icy?, :SNOWWARNING, :ICYROCK],
            [:MOONGLOW_TEAM, @battle.moonGlowing?, :MOONGAZE, :MIRROREDROCK],
            [:ECLIPSE_TEAM, @battle.eclipsed?, :HARBINGER, :PINPOINTROCK],
        ]    
        weatherInfo.each do |weatherEntry|
            weatherPolicy = weatherEntry[0]
            weatherActive = weatherEntry[1]
            urgency += 1 if weatherActive && weatherPolicy # Weather teams play more aggressively
        end
    end
    urgency = 5 * urgency
    return urgency
end