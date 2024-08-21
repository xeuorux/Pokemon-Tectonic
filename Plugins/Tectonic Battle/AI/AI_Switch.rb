class Integer
    def to_change
        if self >= 0
            return "+" + to_s
        else
            return to_s
        end
    end
end

class PokeBattle_AI
    def pbEnemyShouldWithdraw?(idxBattler)
        return false if @battleArena
        return battlePalaceWithdraw?(idxBattler) if @battleArena
        chosenPartyIndex = pbDetermineSwitch(idxBattler)
        if chosenPartyIndex >= 0
            @battle.pbRegisterSwitch(idxBattler, chosenPartyIndex)
            return true
        end
        return false
    end

    def battlePalaceWithdraw?(idxBattler)
        thispkmn = @battle.battlers[idxBattler]
        shouldswitch = false
        if thispkmn.effects[:PerishSong] == 1
            shouldswitch = true
        elsif !@battle.pbCanChooseAnyMove?(idxBattler) &&
              thispkmn.turnCount && thispkmn.turnCount > 5
            shouldswitch = true
        else
            hppercent = thispkmn.hp * 100 / thispkmn.totalhp
            percents = []
            maxindex = -1
            maxpercent = 0
            factor = 0
            @battle.pbParty(idxBattler).each_with_index do |pkmn, i|
                if @battle.pbCanSwitch?(idxBattler, i)
                    percents[i] = 100 * pkmn.hp / pkmn.totalhp
                    if percents[i] > maxpercent
                        maxindex = i
                        maxpercent = percents[i]
                    end
                else
                    percents[i] = 0
                end
            end
            if hppercent < 50
                factor = (maxpercent < hppercent) ? 20 : 40
            end
            if hppercent < 25
                factor = (maxpercent < hppercent) ? 30 : 50
            end
            case thispkmn.status
            when :SLEEP, :FROZEN
                factor += 20
            when :POISON, :BURN
                factor += 10
            when :NUMB
                factor += 15
            end
            if @justswitched[idxBattler]
                factor -= 60
                factor = 0 if factor < 0
            end
            shouldswitch = (pbAIRandom(100) < factor)
            if shouldswitch && maxindex >= 0
                @battle.pbRegisterSwitch(idxBattler, maxindex)
                return true
            end
        end
        @justswitched[idxBattler] = shouldswitch
        if shouldswitch
            @battle.pbParty(idxBattler).each_with_index do |_pkmn, i|
                next unless @battle.pbCanSwitch?(idxBattler, i)
                @battle.pbRegisterSwitch(idxBattler, i)
                return true
            end
        end
        return false
    end

    def pbDetermineSwitch(idxBattler)
        battler = @battle.battlers[idxBattler]
        owner = @battle.pbGetOwnerFromBattlerIndex(idxBattler)

        stayInRating = 0
        PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is determining whether it should switch out")

        # Defensive matchup
        defensiveMatchupRating, killInfoArray = worstDefensiveMatchupAgainstActiveFoes(battler)
        defensiveMatchupRating = (0.5 * defensiveMatchupRating).floor
        stayInRating += defensiveMatchupRating
        PBDebug.log("[STAY-IN RATING] #{battler.pbThis} defensive matchup rating: #{defensiveMatchupRating.to_change}")

        # Value of its own moves
        bestMoveScore, killInfo = switchRatingBestMoveScore(battler, killInfoArray: killInfoArray)
        offensiveMatchupRating = (0.5 * bestMoveScore).floor
        
        urgency = 0
        if offensiveMatchupRating < 0
            urgency = battler.getUrgency
            PBDebug.log("[STAY-IN RATING] Urgency is #{urgency}")
            offensiveMatchupRating -= urgency
        else
            PBDebug.log("[STAY-IN RATING] No Urgency is needed")
        end
        
        stayInRating += offensiveMatchupRating
        PBDebug.log("[STAY-IN RATING] #{battler.pbThis} offensive matchup rating: #{offensiveMatchupRating.to_change}")

        # Other things that affect the stay in rating
        stayInRating += miscStayInRatingModifiers(battler)
        stayInRating += speedTierRating(battler)
        stayInRating += battler.levelNerf(true,false,0.4).round if battler.level <= 30 # AI nerf

        # Determine who to swap into if at all
        PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is trying to find a switch. Staying in is rated: #{stayInRating}.")
        list = pbGetPartyWithSwapRatings(idxBattler,urgency)
        listSwapOutCandidates(battler, list)

        # Only considers swapping into pokemon whose rating would be at least a +30 upgrade
        upgradeThreshold = 30
        upgradeThreshold -= 5 if owner.tribalBonus.hasTribeBonus?(:CHARMER)
        list.delete_if { |val| val[1] < stayInRating + upgradeThreshold }

        if list.empty?
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) fails to find any swap candidates (stay-in rating: #{stayInRating}).")
        else
            partySlotNumber = list[0][0]
            if @battle.pbCanSwitch?(idxBattler, partySlotNumber)
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{idxBattler}) will switch with #{@battle.pbParty(idxBattler)[partySlotNumber].name}")
                return partySlotNumber
            end
        end
        return -1
    rescue StandardError => exception
        echoln("FAILURE ENCOUNTERED IN pbDetermineSwitch FOR BATTLER INDEX #{idxBattler}")
        return -1
    end

    def miscStayInRatingModifiers(battler)
        stayInRating = 0

        # Less likely to switch when coming in later would cause it to die to hazards
        entryDamage, hazardScore = @battle.applyHazards(battler, true)
        if entryDamage >= battler.hp
            stayInRating += 30
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) likely to die to hazards if switches back in later (+30)")
            return stayInRating # Selfish modifiers don't matter
        end

        # Pokémon is about to faint because of Perish Song
        if battler.effects[:PerishSong] == 2
            stayInRating -= 10
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is soon-ish to die to perish song (-10)")
        elsif battler.effects[:PerishSong] == 1
            stayInRating -= 25
            stayInRating -= 25 if battler.hp > battler.totalhp / 2
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is about to die to perish song (#{stayInRating})")
        end

        # More likely to switch when poison has worsened
        if battler.poisoned?
            poisonBias = battler.getPoisonDoublings * -20
            stayInRating += poisonBias
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is poisoned at count (#{battler.getStatusCount(:POISON)}) (#{poisonBias.to_change})")
        end

        # More likely to switch when cursed
        if battler.effectActive?(:Curse)
            stayInRating -= 20
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is cursed (-20)")
        end

        # More likely to switch when drowsy
        if battler.effectActive?(:Yawn)
            stayInRating -= 25
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is drowsy (-25)")
        end

        # Less likely to switch when any opponent has a force switch out move
        # Even less likely if the opponent just used such a move
        battler.eachOpposing do |b|
            if b.hasForceSwitchMove?
                stayInRating += 10
                PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) has an opponent that can force swaps (+10)")
            end

            pursuitMove = b.canChoosePursuit?(battler)
            if pursuitMove
                pursuitScore, pursuitKillInfo = pbGetMoveScore(pursuitMove, b, battler)
                pursuitScore = (pursuitScore / PokeBattle_AI::EFFECT_SCORE_TO_SWITCH_SCORE_CONVERSION_RATIO).ceil
                stayInRating += pursuitScore
                PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) has an opponent that can target it with pursuit (#{pursuitScore.to_change})")
            end
        end

        # Less likely to switch when has perrenial payload
        stayInRating += 15 if battler.hasActiveAbilityAI?(:PERENNIALPAYLOAD)

        # Less likely to switch if FEAR
        stayInRating += 30 if battler.ownersPolicies.include?(:FEAR) && battler.level <= 10
        
        # More likely to switch if weather setter in policy
        weatherSwitchInfo = [
            [:SUN_TEAM, @battle.sunny?, :DROUGHT, :HEATROCK],
            [:RAIN_TEAM, @battle.rainy?, :DRIZZLE, :DAMPROCK],
            [:SANDSTORM_TEAM, @battle.sandy?, :SANDSTREAM, :SMOOTHROCK],
            [:HAIL_TEAM, @battle.icy?, :SNOWWARNING, :ICYROCK],
            [:MOONGLOW_TEAM, @battle.moonGlowing?, :MOONGAZE, :MIRROREDROCK],
            [:ECLIPSE_TEAM, @battle.eclipsed?, :HARBINGER, :PINPOINTROCK],
        ]
        weatherSwitchInfo.each do |weatherSwitchEntry|
            weatherPolicy = weatherSwitchEntry[0]
            weatherActive = weatherSwitchEntry[1]
            weatherAbility = weatherSwitchEntry[2]
            weatherItem = weatherSwitchEntry[3]
            if battler.ownersPolicies.include?(weatherPolicy)
                if weatherActive
                    if battler.hasActiveAbilityAI?(weatherAbility) || battler.hasItem?(weatherItem)
                    stayInRating -= 13 
                    PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) wants to switch to preserve its weather (-13)")
                    end
                elsif battler.hasActiveAbilityAI?(weatherAbility)
                    stayInRating -= 20
                    PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) wants to switch so it can reset the weather (-20)")
                end
            end
        end
        
        # Less likely to switch if has stat boosts
        unless battler.hasActiveAbilityAI?(:DOWNLOAD) || battler.hasActiveAbilityAI?(:SELECTIVESCUTES) # This should be a more complicated check but prob not worth time
            stayInSteps = statStepsValueScore(battler) * 0.06
            stayInSteps = stayInSteps.round
            if stayInSteps > 0
                stayInRating += stayInSteps
                PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) wants to keep its stat steps (#{stayInSteps.to_change})")
            end
        end
        return stayInRating
    end

    # Less likely to be preserved if needs to "use" HP for turns, and has low HP
    def speedTierRating(battler)
        stayInRating = 0
        if battler.hp <= battler.totalhp * 0.5
            sTier = battler.getSpeedTier
            if sTier == 2
                PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is bloodied and FAST, no penalty")
                return stayInRating
            else
                currentHP = battler.hp.to_f
                currentHP += battler.totalhp * 0.25 if battler.hasActiveAbilityAI?(:REGENERATOR) || battler.hasActiveAbilityAI?(:HOLIDAYCHEER)
                currentHP += battler.totalhp * 0.1 if battler.hasTribeBonus?(:CARETAKER)
                currentHP += battler.totalhp * 0.5 if battler.hasActiveAbilityAI?(:REFRESHMENTS) && battler.ownersPolicies.include?(:SUN_TEAM)
                currentHP += battler.totalhp * 0.5 if battler.hasActiveAbilityAI?(:TOLLTHEBELLS) && battler.ownersPolicies.include?(:ECLIPSE_TEAM)
                if currentHP > battler.totalhp * 0.5
                    PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is bloodied but will regenerate, no penalty")
                    return stayInRating
                end
                currentHP /= battler.totalhp * 0.6 # .6 instead of .5 is intentional to bias score
                if sTier == 1
                    stayInRating += 23
                    stayInRating -= 23 * currentHP
                    PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is bloodied and AVERAGE (+#{stayInRating.round})")
                    return stayInRating.round
                else
                    stayInRating += 42
                    stayInRating -= 42 * currentHP
                    PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is bloodied and SLOW (+#{stayInRating.round})")
                    return stayInRating.round
                end
            end    
        end
        return stayInRating
    end

    def pbDefaultChooseNewEnemy(idxBattler, safeSwitch = false)
        urgency = 0
        list = pbGetPartyWithSwapRatings(idxBattler, safeSwitch,urgency)
        list.delete_if { |val| !@battle.pbCanSwitchLax?(idxBattler, val[0]) }
        if list.length != 0
            listSwapOutCandidates(@battle.battlers[idxBattler], list)
            return list[0][0]
        end
        return -1
    end

    def listSwapOutCandidates(battler, list)
        PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) swap out candidates are:")
        list.each do |listEntry|
            enemyTrainer = @battle.pbGetOwnerFromBattlerIndex(battler.index)
            allyPokemon = enemyTrainer.party[listEntry[0]]
            next if allyPokemon.nil?
            PBDebug.log("#{allyPokemon.name || "Party member #{listEntry[0]}"}: #{listEntry[1]}")
        end
    end

    # Rates every other Pokemon in the trainer's party and returns a sorted list of the indices and swap in rating
    def pbGetPartyWithSwapRatings(idxBattler, safeSwitch = false,urgency)
        list = []
        battlerSlot = @battle.battlers[idxBattler]

        @battle.pbParty(idxBattler).each_with_index do |pkmn, partyIndex|
            next unless pkmn.able?
            next if battlerSlot.pokemonIndex == partyIndex
            next unless @battle.pbCanSwitch?(idxBattler, partyIndex)
            switchScore = getSwitchRatingForPartyMember(pkmn, partyIndex, battlerSlot, safeSwitch,urgency)
            list.push([partyIndex, switchScore])
        end
        list.sort_by! { |entry| entry[1].nil? ? 99_999 : -entry[1] }
        return list
    end

    def getSwitchRatingForPartyMember(pkmn, partyIndex, battlerSlot, safeSwitch = false,urgency)
        switchScore = 0

        # Create a battler to simulate what would happen if the Pokemon was in battle right now
        fakeBattler = PokeBattle_Battler.new(@battle, battlerSlot.index, true)
        fakeBattler.pbInitializeFake(pkmn, partyIndex)

        # Account for hazards
        hazardSwitchScore, entryDamageTaken, dieingOnEntry = getHazardEvaluationForEnteringBattler(fakeBattler)
        switchScore += hazardSwitchScore

        # Track the damage taken
        fakeBattler.hp -= entryDamageTaken

        # More want to swap if has a entry ability that matters
        # Intentionally checked even if the pokemon will die on entry
        switchScore += getEntryAbilityEvaluationForEnteringBattler(fakeBattler, dieingOnEntry)

        if safeSwitch
            echoln("[SWITCH SCORING] Evaluating #{fakeBattler.pbThis} as a SAFE switch")
        else
            echoln("[SWITCH SCORING] Evaluating #{fakeBattler.pbThis} as a UN-SAFE switch")
        end

        # Only matters if the pokemon will live
        unless dieingOnEntry
            # Find the worst matchup against the current player battlers
            defensiveMatchupRating, killInfoArray = worstDefensiveMatchupAgainstActiveFoes(fakeBattler)
            if safeSwitch
                defensiveMatchupRating = (0.5 * defensiveMatchupRating).floor
            else
                defensiveMatchupRating = (0.75 * defensiveMatchupRating).floor
            end
            switchScore += defensiveMatchupRating
            if killInfoArray.empty?
                echoln("[SWITCH SCORING] #{fakeBattler.pbThis} defensive matchup rating: #{defensiveMatchupRating.to_change} (doesn't think it can be fainted)")
            else
                echoln("[SWITCH SCORING] #{fakeBattler.pbThis} defensive matchup rating: #{defensiveMatchupRating.to_change} (thinks can be fainted!)")
            end

            offensiveMatchupRating, killInfo = switchRatingBestMoveScore(fakeBattler, killInfoArray: killInfoArray)
            if safeSwitch
                offensiveMatchupRating = (0.5 * offensiveMatchupRating).floor unless urgency >= 20
            else
                offensiveMatchupRating = (0.25 * offensiveMatchupRating).floor unless urgency >= 20
            end
            offensiveMatchupRating -= urgency * 0.5 if offensiveMatchupRating <= 0
            offensiveMatchupRating = offensiveMatchupRating.floor
            switchScore += offensiveMatchupRating
            if killInfo
                echoln("[SWITCH SCORING] #{fakeBattler.pbThis} offensive matchup rating: #{offensiveMatchupRating.to_change} (thinks can faint a foe!)")
            else
                echoln("[SWITCH SCORING] #{fakeBattler.pbThis} offensive matchup rating: #{offensiveMatchupRating.to_change} (doesn't think it can faint anyone)")
            end
        end

        # For preserving the pokemon placed in the last slot
        if battlerSlot.ownersPolicies.include?(:PRESERVE_LAST_POKEMON) && partyIndex == @battle.pbParty(battlerSlot.index).length - 1
            switchScore = -50
            echoln("[SWITCH SCORING] #{fakeBattler.pbThis} should be preserved by policy (-50)")
        end

        # Focus sash Endeavor quick Attack Rattata
        if battlerSlot.ownersPolicies.include?(:FEAR)
            if safeSwitch && fakeBattler.level <= 10
                canEndeavor = false
                fakeBattler.eachOpposing do |b|
                    next if b.pbHasType?(:GHOST)
                    canEndeavor = true
                switchScore += 30 if canEndeavor
                end
            end
        end

        return switchScore
    end

    def getHazardEvaluationForEnteringBattler(battler)
        # Calculate how much damage the pokemon is likely to take from entry hazards
        entryDamage, hazardScore = @battle.applyHazards(battler, true)

        dieingOnEntry = false

        # Try not to swap in pokemon who will die to entry hazard damage
        if battler.hp <= entryDamage
            hazardScore -= 40
            dieingOnEntry = true
            entryDamage = battler.hp
            echoln("[SWITCH SCORING] #{battler.pbThis} will die from hazards! (-40)")
        elsif entryDamage > 0
            percentDamage = (entryDamage / battler.totalhp.to_f)
            hazardDamageSwitchMalus = -(percentDamage * 10).floor
            hazardScore += hazardDamageSwitchMalus
            percentDamageDisplay = (100 * percentDamage).round(1)
            echoln("[SWITCH SCORING] #{battler.pbThis} will take #{percentDamageDisplay} percent HP damage from hazards (#{hazardDamageSwitchMalus.to_change})")
        end

        return hazardScore, entryDamage, dieingOnEntry
    end

    def getEntryAbilityEvaluationForEnteringBattler(battler, _dieingOnEntry)
        totalAbilityScore = 0
        battler.eachActiveAbility do |abilityID|
            switchAbilityEffectScore = BattleHandlers.triggerAbilityOnSwitchIn(abilityID, battler, @battle, true)
            abilitySwitchModifier = (switchAbilityEffectScore / PokeBattle_AI::EFFECT_SCORE_TO_SWITCH_SCORE_CONVERSION_RATIO).ceil
            totalAbilityScore += abilitySwitchModifier
            echoln("[SWITCH SCORING] #{battler.pbThis} values the effect of #{abilityID} as #{switchAbilityEffectScore} (#{abilitySwitchModifier.to_change})")
        end
        return totalAbilityScore
    end

    # The battler passed in could be a real battler, or a fake one
    def worstDefensiveMatchupAgainstActiveFoes(battler)
        matchups = []
        killInfoArray = []
        battler.eachOpposing(true) do |opposingBattler|
            scoringKey = [battler.personalID, opposingBattler.personalID]
            if @precalculatedDefensiveMatchup.key?(scoringKey)
                matchup, killInfo = @precalculatedDefensiveMatchup[scoringKey]
            else
                matchup, killInfo = rateDefensiveMatchup(battler, opposingBattler)
                @precalculatedDefensiveMatchup[scoringKey] = [matchup, killInfo]
            end
            matchups.push(matchup)
            killInfoArray.push(killInfo) if killInfo
        end
        if matchups.empty?
            worstDefensiveMatchup = 0
        else
            worstDefensiveMatchup = matchups.min
        end
        return worstDefensiveMatchup, killInfoArray
    end

    # The battler passed in could be a real battler, or a fake one
    def rateDefensiveMatchup(battler, opposingBattler)
        # How good are the opponent's moves against me?
        bestMoveScore, killInfo = switchRatingBestMoveScore(opposingBattler, opposingBattler: battler)
        matchupScore = -1 * bestMoveScore

        # Set-up counterplay scoring
        if      (battler.hasActiveItemAI?(:REDCARD) && opposingBattler.activatesTargetItem?(true)) ||
                battler.hasActiveAbilityAI?(GameData::Ability.getByFlag("SetupCounterAI"))
            matchupScore += statStepsValueScore(opposingBattler) * 0.15
        end

        # Value of stalling > DISABLED < 
        #matchupScore += passingTurnBattlerEffectScore(battler, @battle)

        # Fear of unknown
        matchupScore -= opposingBattler.unknownMovesCountAI * 2

        return matchupScore, killInfo
    end

    EFFECT_SCORE_TO_SWITCH_SCORE_CONVERSION_RATIO = 2.5

    def switchRatingBestMoveScore(battler, opposingBattler: nil, killInfoArray: [])
        maxScore, killInfo = highestMoveScoreForBattler(battler, opposingBattler: opposingBattler,
killInfoArray: killInfoArray)
        maxMoveScoreBiasChange = -40
        maxMoveScoreBiasChange += (maxScore / EFFECT_SCORE_TO_SWITCH_SCORE_CONVERSION_RATIO).round
        return maxMoveScoreBiasChange, killInfo
    end

    def highestMoveScoreForBattler(battler, opposingBattler: nil, killInfoArray: [])
        choices, killInfo = pbGetBestTrainerMoveChoices(battler, opposingBattler: opposingBattler,
killInfoArray: killInfoArray)

        maxScore = 0
        bestMove = nil
        choices.each do |c|
            next unless c[1] > maxScore
            maxScore = c[1]
            bestMove = battler.getMoves[c[0]].id
        end
        if opposingBattler
            echoln("[MOVES SCORING] #{battler.pbThis}'s best move against target #{opposingBattler.pbThis(true)} is #{bestMove} at score #{maxScore}")
        else
            echoln("[MOVES SCORING] #{battler.pbThis}'s best move is #{bestMove} at score #{maxScore}")
        end
        return maxScore, killInfo
    end
end
