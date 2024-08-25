#===============================================================================
# Start a trainer battle
#===============================================================================
def pbTrainerBattleCore(*args)
    outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
    canLose    = $PokemonTemp.battleRules["canLose"] || false
    randomOrder = $PokemonTemp.battleRules["randomOrder"] || false
    # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
    if $Trainer.able_pokemon_count == 0 || debugControl
        if $DEBUG
            if pbConfirmMessageSerious(_INTL("Perfect battle?"))
                trackPerfectBattle(true)
                pbMessage(_INTL("SKIPPING BATTLE PERFECT..."))
            else
                trackPerfectBattle(false)
                pbMessage(_INTL("SKIPPING BATTLE..."))
            end
            pbMessage(_INTL("AFTER WINNING...")) if $Trainer.able_pokemon_count > 0
        end
        pbSet(outcomeVar, ($Trainer.able_pokemon_count == 0) ? 0 : 1) # Treat it as undecided/a win
        $PokemonTemp.clearBattleRules
        $PokemonGlobal.nextBattleBGM       = nil
        $PokemonGlobal.nextBattleME        = nil
        $PokemonGlobal.nextBattleCaptureME = nil
        $PokemonGlobal.nextBattleBack      = nil
        return ($Trainer.able_pokemon_count == 0) ? 0 : 1 # Treat it as undecided/a win
    end
    # Record information about party Pokémon to be used at the end of battle (e.g.
    # comparing levels for an evolution check)
    Events.onStartBattle.trigger(nil)
    # Generate trainers and their parties based on the arguments given
    foeTrainers    = []
    foeItems       = []
    foeEndSpeeches = []
    foeParty       = []
    foePartyStarts = []
    for arg in args
        raise _INTL("Expected an array of trainer data, got {1}.", arg) unless arg.is_a?(Array)
        if arg.is_a?(NPCTrainer)
            foeTrainers.push(arg)
            foePartyStarts.push(foeParty.length)
            arg.party = arg.party.shuffle if randomOrder
            arg.party.each { |pkmn| foeParty.push(pkmn) }
            foeEndSpeeches.push(arg.lose_text)
            foeItems.push(arg.items)
        else
            # [trainer type, trainer name, ID, speech (optional)]
            trainer = pbLoadTrainer(arg[0], arg[1], arg[2])
            pbMissingTrainer(arg[0], arg[1], arg[2]) unless trainer
            return 0 unless trainer
            Events.onTrainerPartyLoad.trigger(nil, trainer)
            foeTrainers.push(trainer)
            foePartyStarts.push(foeParty.length)
            trainer.party = trainer.party.shuffle if randomOrder
            trainer.party.each { |pkmn| foeParty.push(pkmn) }
            foeEndSpeeches.push(arg[3] || trainer.lose_text)
            foeItems.push(trainer.items)
        end
    end
    # Calculate who the player trainer(s) and their party are
    playerTrainers    = [$Trainer]
    playerParty       = $Trainer.party
    playerPartyStarts = [0]
    room_for_partner = (foeParty.length > 1)
    if !room_for_partner && $PokemonTemp.battleRules["size"] &&
       !%w[single 1v1 1v2 1v3].include?($PokemonTemp.battleRules["size"])
        room_for_partner = true
    end
    playerParty = loadPartnerTrainer(playerTrainers, playerParty, playerPartyStarts) if room_for_partner
    # Create the battle scene (the visual side of it)
    scene = pbNewBattleScene
    # Create the battle class (the mechanics side of it)
    battle = PokeBattle_Battle.new(scene, playerParty, foeParty, playerTrainers, foeTrainers)
    battle.party1starts = playerPartyStarts
    battle.party2starts = foePartyStarts
    battle.items        = foeItems
    battle.endSpeeches  = foeEndSpeeches
    # Set various other properties in the battle class
    pbPrepareBattle(battle)
    $PokemonTemp.clearBattleRules
    # End the trainer intro music
    Audio.me_stop
    # Perform the battle itself
    decision = 0
    if battle.autoTesting
        decision = battle.pbStartBattle
    else
        pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers), battle.singleBattle? ? 1 : 3, foeTrainers) do
            pbSceneStandby do
                decision = battle.pbStartBattle
            end
            pbAfterBattle(decision, canLose)
        end
    end
    Input.update
    # Save the result of the battle in a Game Variable (1 by default)
    #    0 - Undecided or aborted
    #    1 - Player won
    #    2 - Player lost
    #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
    #    5 - Draw
    pbSet(outcomeVar, decision)
    $PokemonGlobal.respawnPoint = nil
    refreshSpeakerWindow
    $game_switches[TIME_OUT_SWITCH] = decision == 6 # Mark if the battle was a time-out victory
    return decision
end

def loadPartnerTrainer(playerTrainers, playerParty, playerPartyStarts)
    if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"]
        ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
        ally.id    = $PokemonGlobal.partner[2]
        ally.party = $PokemonGlobal.partner[3]
        ally.flags = $PokemonGlobal.partner[4]
        playerTrainers.push(ally)
        playerParty = []
        $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
        playerPartyStarts.push(playerParty.length)
        ally.party.each { |pkmn| playerParty.push(pkmn) }
        setBattleRule("double") unless $PokemonTemp.battleRules["size"]
        return playerParty
    end
    return playerParty
end

#===============================================================================
# Standard methods that start a trainer battle of various sizes
#===============================================================================
# Used by most trainer events, which can be positioned in such a way that
# multiple trainer events spot the player at once. The extra code in this method
# deals with that case and can cause a double trainer battle instead.
def pbTrainerBattle(trainerID, trainerName, endSpeech = nil,
                    doubleBattle = false, trainerPartyID = 0, canLose = false, outcomeVar = 1, random = false)
    # If there is another NPC trainer who spotted the player at the same time, and
    # it is possible to have a double battle (the player has 2+ able Pokémon or
    # has a partner trainer), then record this first NPC trainer into
    # $PokemonTemp.waitingTrainer and end this method. That second NPC event will
    # then trigger and cause the battle to happen against this first trainer and
    # themselves.
    if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning? &&
       ($Trainer.able_pokemon_count > 1 ||
       ($Trainer.able_pokemon_count > 0 && $PokemonGlobal.partner))
        thisEvent = pbMapInterpreter.get_character(0)
        # Find all other triggered trainer events
        triggeredEvents = $game_player.pbTriggeredTrainerEvents([2], false)
        otherEvent = []
        for i in triggeredEvents
            next if i.id == thisEvent.id
            next if $game_self_switches[[$game_map.map_id, i.id, "A"]]
            otherEvent.push(i)
        end
        # Load the trainer's data, and call an event which might modify it
        trainer = pbLoadTrainer(trainerID, trainerName, trainerPartyID)
        pbMissingTrainer(trainerID, trainerName, trainerPartyID) unless trainer
        return false unless trainer
        Events.onTrainerPartyLoad.trigger(nil, trainer)
        # If there is exactly 1 other triggered trainer event, and this trainer has
        # 6 or fewer Pokémon, record this trainer for a double battle caused by the
        # other triggered trainer event
        if otherEvent.length == 1 && trainer.party.length <= Settings::MAX_PARTY_SIZE
            trainer.lose_text = endSpeech if endSpeech && !endSpeech.empty?
            $PokemonTemp.waitingTrainer = [trainer, thisEvent.id]
            return false
        end
    end
    # Set some battle rules
    setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
    setBattleRule("canLose") if canLose
    setBattleRule("double") if doubleBattle || $PokemonTemp.waitingTrainer
    setBattleRule("randomOrder") if random
    # Perform the battle
    if $PokemonTemp.waitingTrainer
        waitingTrainer = $PokemonTemp.waitingTrainer
        decision = pbTrainerBattleCore($PokemonTemp.waitingTrainer,
        [trainerID, trainerName, trainerPartyID, endSpeech]
        )
    else
        decision = pbTrainerBattleCore([trainerID, trainerName, trainerPartyID, endSpeech])
    end
    # Finish off the recorded waiting trainer, because they have now been battled
    if decision == 1 && $PokemonTemp.waitingTrainer # Win
        pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "A", true)
    end
    $PokemonTemp.waitingTrainer = nil
    # Return true if the player won the battle, and false if any other result
    return [1, 6].include?(decision)
end

def pbDoubleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                          trainerID2, trainerName2, trainerPartyID2 = 0, endSpeech2 = nil,
                          canLose = false, outcomeVar = 1)
    # Set some battle rules
    setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
    setBattleRule("canLose") if canLose
    setBattleRule("double")
    # Perform the battle
    decision = pbTrainerBattleCore(
        [trainerID1, trainerName1, trainerPartyID1, endSpeech1],
    [trainerID2, trainerName2, trainerPartyID2, endSpeech2]
    )
    # Return true if the player won the battle, and false if any other result
    return [1, 6].include?(decision)
end

def pbTripleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                          trainerID2, trainerName2, trainerPartyID2, endSpeech2,
                          trainerID3, trainerName3, trainerPartyID3 = 0, endSpeech3 = nil,
                          canLose = false, outcomeVar = 1)
    # Set some battle rules
    setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
    setBattleRule("canLose") if canLose
    setBattleRule("triple")
    # Perform the battle
    decision = pbTrainerBattleCore(
        [trainerID1, trainerName1, trainerPartyID1, endSpeech1],
    [trainerID2, trainerName2, trainerPartyID2, endSpeech2],
    [trainerID3, trainerName3, trainerPartyID3, endSpeech3]
    )
    # Return true if the player won the battle, and false if any other result
    return [1, 6].include?(decision)
end

def pbTrainerBattleRandom(trainerID, trainerName, partyID = 0)
    pbTrainerBattle(trainerID, trainerName, nil, false, partyID, false, 1, true)
end

def pbLaneTrainerBattle(trainerID, trainerName, trainerPartyID = 0, canLose = false, outcomeVar = 1)
    setBattleRule("lanetargeting")
    setBattleRule("doubleshift")
    return pbTrainerBattle(trainerID, trainerName, nil, true, trainerPartyID, canLose, outcomeVar)
end

PERFECTED_SWITCH = 38
def trackPerfectBattle(perfectingState)
    $game_switches[PERFECTED_SWITCH] = perfectingState
end

def battlePerfected?
	return $game_switches[PERFECTED_SWITCH]
end

TIME_OUT_SWITCH = 37
def battleTimedOut?
    return $game_switches[TIME_OUT_SWITCH]
end