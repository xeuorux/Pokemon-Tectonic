class Integer
    def to_change
        if self > 0
            return "+" + to_s
        else
            return "-" + to_s
        end
    end
end

class PokeBattle_AI
    #=============================================================================
    # Decide whether the opponent should switch Pokémon
    #=============================================================================
    def pbEnemyShouldWithdraw?(idxBattler, choices = [])
        return pbEnemyShouldWithdrawEx?(idxBattler, choices)
    rescue StandardError => exception
        echoln("FAILURE ENCOUNTERED IN pbEnemyShouldWidthdraw FOR BATTLER INDEX #{idxBattler}")
        return false
    end

    def pbEnemyShouldWithdrawEx?(idxBattler, choices = [])
        battler = @battle.battlers[idxBattler]
        owner = @battle.pbGetOwnerFromBattlerIndex(idxBattler)
        policies = owner.policies || []

        switchingBias = 0
        PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is determining whether it should switch out")

        # if battler.firstTurn? && @battle.turnCount != 0
        #     switchingBias -= 1
        #     PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is less likely to switch on its first turn after switching in (-1)")
        # end

        # Reactive matchup considerations
        # Ignore these protocols if this is an AI trainer helping you in a boss battle
        unless @battle.bossBattle? && !policies.include?(:PROACTIVE_MATCHUP_SWAPPER)
            # Figure out the effectiveness of the last move that hit it
            typeMod = battler.lastRoundHighestTypeModFromFoe
            if typeMod >= 0
                effectivenessSwitchBiasMod = 0
                if Effectiveness.hyper_effective?(typeMod)
                    effectivenessSwitchBiasMod += 2
                elsif Effectiveness.super_effective?(typeMod)
                    effectivenessSwitchBiasMod += 1
                elsif Effectiveness.not_very_effective?(typeMod)
                    effectivenessSwitchBiasMod -= 1
                elsif Effectiveness.ineffective?(typeMod)
                    effectivenessSwitchBiasMod -= 2
                end
                switchingBias += effectivenessSwitchBiasMod
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) takes into account the effectiveness of its last hit taken (#{effectivenessSwitchBiasMod.to_change})")
            end

            # More or less likely to switch based on if you have a good move to use
            maxScore = 0
            choices.each do |c|
                maxScore = c[1] if c[1] > maxScore
            end
            maxMoveScoreBiasChange = 4
            maxMoveScoreBiasChange -= (maxScore / 25.0).round
            switchingBias += maxMoveScoreBiasChange
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) max score among its #{choices.length} choices is #{maxScore} (#{maxMoveScoreBiasChange.to_change})")

            # If there is a single foe and it is resting after Hyper Beam or is
            # Truanting (i.e. free turn)
            if @battle.pbSideSize(battler.index + 1) == 1 && !battler.pbDirectOpposing.fainted?
                opposingBattler = battler.pbDirectOpposing
                unless opposingBattler.canActThisTurn?
                    switchingBias -= 2
                    PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) thinks the opposing battler can't act this turn (-2)")
                end
            end
        end

        # "Sacrificed Not Swaps" policy
        sacrificing = false
        if policies.include?(:SACS_NOT_SWAPS) && battler.hp <= battler.totalhp / 4
            switchingBias -= 1
            sacrificing = true
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) at or below 25% HP, so values saccing itself for tempo (-1)")
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) will ignore switch evaluation checks about avoiding death")
        else # Check effects that put the pokemon in danger

            # Pokémon is about to faint because of Perish Song
            if battler.effects[:PerishSong] == 1
                switchingBias += 2
                switchingBias += 2 if user.aboveHalfHealth?
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is to die to perish song (+2)")
            end

            # More likely to switch when leech seeded
            if battler.effectActive?(:LeechSeed)
                switchingBias += 1
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is seeded (+1)")
            end

            # More likely to switch when poison has worsened
            if battler.poisoned?
                poisonBias = 1 + battler.getPoisonDoublings * 2
                switchingBias += poisonBias
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is poisoned at count (#{battler.getStatusCount(:POISON)}) (+#{poisonBias})")
            end
        end

        # More likely to switch when drowsy
        if battler.effectActive?(:Yawn)
            switchingBias += 1
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is drowsy (+1)")
        end

        # Tries to determine if its in a good or bad type matchup
        # Used for Cool Trainers
        if policies.include?(:PROACTIVE_MATCHUP_SWAPPER)
            unless sacrificing
                currentMatchupRating = rateMatchupAgainstFoes(battler, battler.pokemon, battler.pokemonIndex)
                switchingBias -= currentMatchupRating
                PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) evaluates its current matchup (#{-currentMatchupRating.to_change})")
            end
        elsif switchingBias <= 0
            PBDebug.log("[AI SWITCH] #{battler.pbThis} decides it doesn't have any reason to switch (final switching bias: #{switchingBias})")
            return false
        end

        # Determine who to swap into if at all
        PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is trying to find a teammate to swap into. Its switching bias is #{switchingBias}.")
        list = pbGetPartyWithSwapRatings(idxBattler)
        listSwapOutCandidates(battler, list)

        # Only considers swapping into pokemon whose rating would be at least a +2 upgrade
        list.delete_if { |val| !@battle.pbCanSwitch?(idxBattler, val[0]) || (switchingBias + val[1] <= 1) }

        if list.length > 0
            partySlotNumber = list[0][0]
            if @battle.pbRegisterSwitch(idxBattler, partySlotNumber)
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{idxBattler}) will switch with #{@battle.pbParty(idxBattler)[partySlotNumber].name}")
                return true
            end
        else
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) fails to find any swap candidates.")
        end
        return false
    end

    def pbDefaultChooseNewEnemy(idxBattler, _party)
        list = pbGetPartyWithSwapRatings(idxBattler)
        list.delete_if { |val| !@battle.pbCanSwitchLax?(idxBattler, val[0]) }
        if list.length != 0
            listSwapOutCandidates(@battle.battlers[idxBattler], list)
            return list[0][0]
        end
        return -1
    end

    def getRoughAttackingTypes(battler)
        return nil if battler.fainted?
        attackingTypes = [battler.pokemon.type1, battler.pokemon.type2]
        unless battler.lastMoveUsed.nil?
            moveData = GameData::Move.get(battler.lastMoveUsed)
            attackingTypes.push(moveData.type)
        end
        attackingTypes.uniq!
        attackingTypes.compact!
        return attackingTypes
    end

    def getPartyMemberAttackingTypes(pokemon)
        attackingTypes = []

        pokemon.moves.each do |move|
            next if move.category == 2 # Status
            attackingTypes.push(move.type)
        end

        attackingTypes.uniq!
        attackingTypes.compact!
        return attackingTypes
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
    def pbGetPartyWithSwapRatings(idxBattler)
        list = []
        battlerSlot = @battle.battlers[idxBattler]

        policies = battlerSlot.ownersPolicies

        @battle.pbParty(idxBattler).each_with_index do |pkmn, partyIndex|
            next unless pkmn.able?
            next if battlerSlot.pokemonIndex == partyIndex

            switchScore = 0

            # Determine if the pokemon will be airborne
            airborne = pkmn.hasType?(:FLYING) || pkmn.hasAbility?(:LEVITATE) || LEVITATION_ITEMS.include?(pkmn.item)
            airborne = false if @battle.field.effectActive?(:Gravity)
            airborne = false if pkmn.item == :IRONBALL

            willAbsorbSpikes = false

            # Calculate how much damage the pokemon is likely to take from entry hazards
            entryDamage = 0
            if !airborne && pkmn.ability != :MAGICGUARD && pkmn.item != :HEAVYDUTYBOOTS
                # Spikes
                spikesCount = battlerSlot.pbOwnSide.countEffect(:Spikes)
                if spikesCount > 0
                    spikesDenom = [8, 6, 4][spikesCount - 1]
                    entryDamage += pkmn.totalhp / spikesDenom
                end

                # Stealth Rock
                if battlerSlot.pbOwnSide.effectActive?(:StealthRock)
                    types = pkmn.types
                    stealthRockHPRatio = @battle.getTypedHazardHPRatio(:ROCK, types[0], types[1] || nil)
                    entryDamage += pkmn.totalhp * stealthRockHPRatio
                end

                # Feather Ward
                if battlerSlot.pbOwnSide.effectActive?(:FeatherWard)
                    types = pkmn.types
                    featherWardHPRatio = @battle.getTypedHazardHPRatio(:STEEL, types[0], types[1] || nil)
                    entryDamage += pkmn.totalhp * featherWardHPRatio
                end

                # Each of the status setting spikes
                battlerSlot.pbOwnSide.eachEffect(true) do |_effect, value, data|
                    next unless data.is_status_hazard?
                    hazardInfo = data.type_applying_hazard

                    if hazardInfo[:absorb_proc].call(pkmn)
                        willAbsorbSpikes = true
                    else
                        statusSpikesDenom = [16, 4][value - 1]
                        entryDamage += pkmn.totalhp / statusSpikesDenom
                    end
                end
            end

            # Try not to swap in pokemon who will die to entry hazard damage
            if pkmn.hp <= entryDamage
                switchScore -= 4
                dieingOnEntry = true
            elsif willAbsorbSpikes
                switchScore += 1
            else
                switchScore -= ((entryDamage / pkmn.totalhp.to_f) * 4).floor
            end

            # Analyze the player's active battlers to their susceptibility to being debuffed
            attackDebuffers = 0
            specialDebuffers = 0
            speedDebuffers = 0
            battlerSlot.eachOpposing do |opposingBattler|
                next if opposingBattler.hasActiveAbilityAI?(:INNERFOCUS)
                if opposingBattler.hasActiveAbilityAI?(:CONTRARY)
                    attackDebuffers -= 1
                    specialDebuffers -= 1
                    speedDebuffers -= 1
                else
                    if opposingBattler.hasPhysicalAttack? && opposingBattler.stages[:ATTACK] > -2 && opposingBattler.pbCanLowerStatStage?(:ATTACK)
                        attackDebuffers += 1
                    end
                    if opposingBattler.hasSpecialAttack? && opposingBattler.stages[:SPECIAL_ATTACK] > -2 && opposingBattler.pbCanLowerStatStage?(:SPECIAL_ATTACK)
                        specialDebuffers += 1
                    end
                    if opposingBattler.pbSpeed > pkmn.speed && opposingBattler.pbCanLowerStatStage?(:SPEED)
                        speedDebuffers += 1
                    end
                end
            end

            # More want to swap if has a entry ability that matters
            # Intentionally checked even if the pokemon will die on entry
            settingSun = @battle.pbWeather != :Sun && policies.include?(:SUN_TEAM)
            settingRain = @battle.pbWeather != :Rain && policies.include?(:RAIN_TEAM)
            settingHail = @battle.pbWeather != :Hail && policies.include?(:HAIL_TEAM)
            settingSand = @battle.pbWeather != :Sandstorm && policies.include?(:SAND_TEAM)
            alliesInReserve = battlerSlot.alliesInReserveCount

            case pkmn.ability
            when :INTIMIDATE
                switchScore += attackDebuffers
            when :FASCINATE
                switchScore += specialDebuffers
            when :FRUSTRATE
                switchScore += speedDebuffers
            when :DROUGHT, :INNERLIGHT
                switchScore += alliesInReserve if settingSun
            when :DRIZZLE, :STORMBRINGER
                switchScore += alliesInReserve if settingRain
            when :SNOWWARNING, :FROSTSCATTER
                switchScore += alliesInReserve if settingHail
            when :SANDSTREAM, :SANDBURST
                switchScore += alliesInReserve if settingSand
            end

            # Only matters if the pokemon will live
            unless dieingOnEntry
                # Find the worst type matchup against the current player battlers
                switchScore += rateMatchupAgainstFoes(battlerSlot, pkmn, partyIndex)
            end

            # For preserving the pokemon placed in the last slot
            if policies.include?(:PRESERVE_LAST_POKEMON) && partyIndex == @battle.pbParty(idxBattler).length - 1
                switchScore = -99
            end

            list.push([partyIndex, switchScore])
        end
        list.sort_by! { |entry| entry[1].nil? ? 9999 : -entry[1] }
        return list
    end

    # The pokemon passed in could be be the pokemon in the given battler slot, or somewhere in the party
    def rateMatchupAgainstFoes(battlerSlot, pokemon, partyIndex)
        matchups = []
        battlerSlot.eachOpposing do |opposingBattler|
            matchup = rateMatchup(battlerSlot, pokemon, pokemon, getRoughAttackingTypes(opposingBattler))
            matchups.push(matchup)
        end
        if matchups.empty?
            return 0
        else
            return matchups.min
        end
    end

    # The pokemon passed in could be be the pokemon in the given battler slot, or somewhere in the party
    def rateMatchup(battlerSlot, pokemon, partyIndex, attackingtypes = nil)
        typeModDefensive = Effectiveness::NORMAL_EFFECTIVE

        # Get the worse defensive type mod among any of the given types
        typeModDefensive = pbCalcMaxOffensiveTypeMod(attackingtypes, pokemon) unless attackingtypes.nil?

        matchupScore = 0
        # Modify the type matchup score based on the defensive matchup
        if Effectiveness.ineffective?(typeModDefensive)
            matchupScore += 4
        elsif Effectiveness.not_very_effective?(typeModDefensive)
            matchupScore += 2
        elsif Effectiveness.hyper_effective?(typeModDefensive)
            matchupScore -= 4
        elsif Effectiveness.super_effective?(typeModDefensive)
            matchupScore -= 2
        end

        maxScore = highestMoveScoreForHypotheticalBattle(battlerSlot,pokemon,partyIndex)
        maxMoveScoreBiasChange = -4
        maxMoveScoreBiasChange += (maxScore / 25.0).round
        matchupScore += maxMoveScoreBiasChange

        return matchupScore
    end

    def pbCalcMaxOffensiveTypeMod(attackingTypes, victimPokemon)
        victimPokemon = victimPokemon.disguisedAs if victimPokemon.is_a?(PokeBattle_Battler) && victimPokemon.illusion?
        maxTypeMod = 0
        attackingTypes.each do |attackingType|
            mod = Effectiveness.calculate(attackingType, victimPokemon.type1, victimPokemon.type2)
            maxTypeMod = mod if mod > maxTypeMod
        end
        return maxTypeMod
    end

    def highestMoveScoreForHypotheticalBattle(battlerSlot,pokemon,partyIndex)
        fakeBattler = battlerSlot.clone
        fakeBattler.pbInitPokemon(pokemon,partyIndex)
        choices = pbGetBestTrainerMoveChoices(fakeBattler, fakeBattler.ownersPolicies)

        maxScore = 0
        choices.each do |c|
            maxScore = c[1] if c[1] > maxScore
        end
        return maxScore
    end
end
