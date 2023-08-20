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
        chosenPartyIndex = pbDetermineSwitch(idxBattler)
        if chosenPartyIndex >= 0
            @battle.pbRegisterSwitch(idxBattler,chosenPartyIndex)
            return true
        end
        return false
    end

    def pbDetermineSwitch(idxBattler)
        battler = @battle.battlers[idxBattler]
        owner = @battle.pbGetOwnerFromBattlerIndex(idxBattler)

        stayInRating = 0
        PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is determining whether it should switch out")

        # Defensive matchup
        defensiveMatchupRating,killInfoArray = worstDefensiveMatchupAgainstActiveFoes(battler)
        defensiveMatchupRating = (0.5 * defensiveMatchupRating).floor
        stayInRating += defensiveMatchupRating
        PBDebug.log("[STAY-IN RATING] #{battler.pbThis} defensive matchup rating: #{defensiveMatchupRating.to_change}")

        # Value of its own moves
        bestMoveScore,killInfo = switchRatingBestMoveScore(battler,killInfoArray: killInfoArray)
        offensiveMatchupRating = (0.5 * bestMoveScore).floor
        stayInRating += offensiveMatchupRating
        PBDebug.log("[STAY-IN RATING] #{battler.pbThis} offensive matchup rating: #{offensiveMatchupRating.to_change}")

        # Other things that affect the stay in rating
        stayInRating += miscStayInRatingModifiers(battler)

        # Determine who to swap into if at all
        PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is trying to find a switch. Staying in is rated: #{stayInRating}.")
        list = pbGetPartyWithSwapRatings(idxBattler)
        listSwapOutCandidates(battler, list)

        # Only considers swapping into pokemon whose rating would be at least a +35 upgrade
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

        # Pokémon is about to faint because of Perish Song
        if battler.effects[:PerishSong] == 2
            stayInRating -= 10
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is soon-ish to die to perish song (-10)")
        elsif battler.effects[:PerishSong] == 1
            stayInRating -= 50
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is about to die to perish song (-50)")
        end

        # More likely to switch when poison has worsened
        if battler.poisoned?
            poisonBias = battler.getPoisonDoublings * -20
            stayInRating += poisonBias
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is poisoned at count (#{battler.getStatusCount(:POISON)}) (#{poisonBias.to_change})")
        end

        # More likely to switch when cursed
        if battler.effectActive?(:Curse)
            stayInRating -= 15
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) is cursed (-15)")
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
                pursuitScore = pbEvaluateMoveTrainer(b, pursuitMove, targets: [battler]) / 2
                stayInRating += pursuitScore
                PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) has an opponent that can target it with pursuit (#{pursuitScore.to_change})")
            end
        end

        # Less likely to switch when coming in later would cause it to die to hazards
        entryDamage, hazardScore = @battle.applyHazards(battler,true)
        if entryDamage >= battler.hp
            stayInRating += 40
            PBDebug.log("[STAY-IN RATING] #{battler.pbThis} (#{battler.index}) likely to die to hazards if switches back in later (+40)")
        end

        # Less likely to switch when has self-mending
        stayInRating += 10 if battler.hasActiveAbilityAI?(:SELFMENDING)

        return stayInRating
    end

    def pbDefaultChooseNewEnemy(idxBattler, safeSwitch = false)
        list = pbGetPartyWithSwapRatings(idxBattler, safeSwitch)
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
    def pbGetPartyWithSwapRatings(idxBattler, safeSwitch = false)
        list = []
        battlerSlot = @battle.battlers[idxBattler]

        @battle.pbParty(idxBattler).each_with_index do |pkmn, partyIndex|
            next unless pkmn.able?
            next if battlerSlot.pokemonIndex == partyIndex
            next unless @battle.pbCanSwitch?(idxBattler, partyIndex)
            switchScore = getSwitchRatingForPartyMember(pkmn,partyIndex, battlerSlot, safeSwitch)
            list.push([partyIndex, switchScore])
        end
        list.sort_by! { |entry| entry[1].nil? ? 99999 : -entry[1] }
        return list
    end

    def getSwitchRatingForPartyMember(pkmn,partyIndex,battlerSlot, safeSwitch = false)
        switchScore = 0

        # Create a battler to simulate what would happen if the Pokemon was in battle right now
        fakeBattler = PokeBattle_Battler.new(@battle, battlerSlot.index, true)
        fakeBattler.pbInitializeFake(pkmn,partyIndex)

        # Account for hazards
        hazardSwitchScore,entryDamageTaken,dieingOnEntry = getHazardEvaluationForEnteringBattler(fakeBattler)
        switchScore += hazardSwitchScore

        # Track the damage taken
        fakeBattler.hp -= entryDamageTaken

        # More want to swap if has a entry ability that matters
        # Intentionally checked even if the pokemon will die on entry
        switchScore += getEntryAbilityEvaluationForEnteringBattler(fakeBattler,dieingOnEntry)

        if safeSwitch
            echoln("[SWITCH SCORING] Evaluating #{fakeBattler.pbThis} as a SAFE switch")
        else
            echoln("[SWITCH SCORING] Evaluating #{fakeBattler.pbThis} as a UN-SAFE switch")
        end

        # Only matters if the pokemon will live
        unless dieingOnEntry
            # Find the worst matchup against the current player battlers
            defensiveMatchupRating,killInfoArray = worstDefensiveMatchupAgainstActiveFoes(fakeBattler)
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

            offensiveMatchupRating,killInfo = switchRatingBestMoveScore(fakeBattler, killInfoArray: killInfoArray)
            if safeSwitch
                offensiveMatchupRating = (0.5 * offensiveMatchupRating).floor
            else
                offensiveMatchupRating = (0.25 * offensiveMatchupRating).floor
            end
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

        return switchScore
    end

    def getHazardEvaluationForEnteringBattler(battler)
        # Calculate how much damage the pokemon is likely to take from entry hazards
        entryDamage, hazardScore = @battle.applyHazards(battler,true)

        dieingOnEntry = false

        # Try not to swap in pokemon who will die to entry hazard damage
        if battler.hp <= entryDamage
            hazardScore -= 80
            dieingOnEntry = true
            entryDamage = battler.hp
            echoln("[SWITCH SCORING] #{battler.pbThis} will die from hazards! (-80)")
        elsif entryDamage > 0
            percentDamage = (entryDamage / battler.totalhp.to_f)
            hazardDamageSwitchMalus = -(percentDamage * 100).floor
            hazardScore += hazardDamageSwitchMalus
            percentDamageDisplay = (100 * percentDamage).round(1)
            echoln("[SWITCH SCORING] #{battler.pbThis} will take #{percentDamageDisplay} percent HP damage from hazards (#{hazardDamageSwitchMalus.to_change})")
        end

        return hazardScore,entryDamage,dieingOnEntry
    end

    def getEntryAbilityEvaluationForEnteringBattler(battler,dieingOnEntry)
        totalAbilityScore = 0
        battler.eachActiveAbility do |abilityID|
            switchAbilityEffectScore = 0
            case abilityID
            when :INTIMIDATE
                battler.eachOpposing do |opposingBattler|
                    switchAbilityEffectScore += getMultiStatDownEffectScore([:ATTACK,2],battler,opposingBattler)
                end
            when :FASCINATE
                battler.eachOpposing do |opposingBattler|
                    switchAbilityEffectScore += getMultiStatDownEffectScore([:SPECIAL_ATTACK,2],battler,opposingBattler)
                end
            when :FRUSTRATE
                battler.eachOpposing do |opposingBattler|
                    switchAbilityEffectScore += getMultiStatDownEffectScore([:SPEED,2],battler,opposingBattler)
                end
            when :CRAGTERROR && @battle.sandy?
                battler.eachOpposing do |opposingBattler|
                    switchAbilityEffectScore += getMultiStatDownEffectScore(ATTACKING_STATS_2,battler,opposingBattler)
                end
            when :DRAMATICLIGHTING && @battle.eclipsed?
                battler.eachOpposing do |opposingBattler|
                    switchAbilityEffectScore += getMultiStatDownEffectScore(ATTACKING_STATS_2,battler,opposingBattler)
                end
            when :DROUGHT, :INNERLIGHT
                switchAbilityEffectScore += getWeatherSettingEffectScore(:Sun,battler,@battle)
            when :DRIZZLE, :STORMBRINGER
                switchAbilityEffectScore += getWeatherSettingEffectScore(:Rain,battler,@battle)
            when :SNOWWARNING, :FROSTSCATTER
                switchAbilityEffectScore += getWeatherSettingEffectScore(:Hail,battler,@battle)
            when :SANDSTREAM, :SANDBURST
                switchAbilityEffectScore += getWeatherSettingEffectScore(:Sand,battler,@battle)
            when :MOONGAZE, :LUNARLOYALTY
                switchAbilityEffectScore += getWeatherSettingEffectScore(:Moonglow,battler,@battle)
            when :HARBINGER, :SUNEATER
                switchAbilityEffectScore += getWeatherSettingEffectScore(:Eclipse,battler,@battle)
            end
            abilitySwitchModifier = (switchAbilityEffectScore / 2.5).ceil
            totalAbilityScore += abilitySwitchModifier
            echoln("[SWITCH SCORING] #{battler.pbThis} values the effect of #{abilityID} as #{switchAbilityEffectScore} (#{abilitySwitchModifier.to_change})")
        end
        return totalAbilityScore
    end

    # The battler passed in could be a real battler, or a fake one
    def worstDefensiveMatchupAgainstActiveFoes(battler)
        if @precalculatedDefensiveMatchup.key?(battler.personalID)
            precalcedScore,killInfoArray = @precalculatedDefensiveMatchup[battler.personalID]
            echoln("[DEFENSIVE MATCHUP] Defensive matchup for #{battler.pbThis(true)} already calced this round: #{precalcedScore}")
            return precalcedScore,killInfoArray
        end
        matchups = []
        killInfoArray = []
        battler.eachOpposing(true) do |opposingBattler|
            matchup,killInfo = rateDefensiveMatchup(battler, opposingBattler)
            matchups.push(matchup)
            killInfoArray.push(killInfo) if killInfo
        end
        if matchups.empty?
            worstDefensiveMatchup = 0
        else
            worstDefensiveMatchup = matchups.min
        end
        @precalculatedDefensiveMatchup[battler.personalID] = [worstDefensiveMatchup,killInfoArray]
        return worstDefensiveMatchup,killInfoArray
    end

    # The battler passed in could be a real battler, or a fake one
    def rateDefensiveMatchup(battler, opposingBattler)
        # How good are the opponent's moves against me?
        bestMoveScore,killInfo = switchRatingBestMoveScore(opposingBattler, opposingBattler: battler)
        matchupScore = -1 * bestMoveScore

        # Set-up counterplay scoring
        if      (battler.hasActiveItem?(:REDCARD) && !opposingBattler.hasActiveItem?(:PROXYFIST)) ||
                battler.hasActiveAbility?(%i[SMOKEINSINCT PERISHSONG CURIOUSMEDICINE DRIFTINGMIST])
            matchupScore += statStepsValueScore(battler)
        end

        # Value of stalling
        matchupScore += passingTurnBattlerEffectScore(battler,@battle)

        # Fear of unknown
        matchupScore -= opposingBattler.unknownMovesCountAI * 2

        return matchupScore,killInfo
    end

    def switchRatingBestMoveScore(battler, opposingBattler: nil, killInfoArray: [])
        maxScore,killInfo = highestMoveScoreForBattler(battler, opposingBattler: opposingBattler, killInfoArray: killInfoArray)
        maxMoveScoreBiasChange = -40
        maxMoveScoreBiasChange += (maxScore / 2.5).round
        return maxMoveScoreBiasChange,killInfo
    end

    def highestMoveScoreForBattler(battler, opposingBattler: nil, killInfoArray: [])
        choices,killInfo = pbGetBestTrainerMoveChoices(battler, opposingBattler: opposingBattler, killInfoArray: killInfoArray)

        maxScore = 0
        bestMove = nil
        choices.each do |c|
            next unless c[1] > maxScore
            maxScore = c[1]
            bestMove = battler.moves[c[0]].id
        end
        if opposingBattler
            echoln("[MOVES SCORING] #{battler.pbThis}'s best move against target #{opposingBattler.pbThis(true)} is #{bestMove} at score #{maxScore}")
        else
            echoln("[MOVES SCORING] #{battler.pbThis}'s best move is #{bestMove} at score #{maxScore}")
        end
        return maxScore,killInfo
    end
end
