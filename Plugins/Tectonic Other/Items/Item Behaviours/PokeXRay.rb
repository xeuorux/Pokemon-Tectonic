ItemHandlers::UseFromBag.add(:POKEXRAY,proc { |item|
    if getViewableTeams.empty?
        pbMessage(_INTL("There's no one near by to use the Poké X-Ray on!"))
        next 0
    end
    next 2
})

POKE_XRAY_WIDTH = 8
POKE_XRAY_HEIGHT = 6

def getViewableTeams
    viewableTeams = []
    eachTrainerWithAutoFollowerInMap do |event, trainer, partyIndex|
		next if event.name.downcase.include?("noxray")
		xDif = (event.x - $game_player.x).abs
		yDif = (event.y - $game_player.y).abs
		next unless xDif <= POKE_XRAY_WIDTH && yDif <= POKE_XRAY_HEIGHT # Must be nearby
        next if pbGetSelfSwitch(event.id,'D') # Must not already be fled
        next if event.character_name == ""

        # Remove any existing trainers with the same ID, and replace them with a new lower party index
        # if appropriate
        lowestPartyIndex = partyIndex
        viewableTeams.each do |existingEvent,existingtrainer,existingPartyIndex|
            next unless existingtrainer.full_name == trainer.full_name
            lowestPartyIndex = existingPartyIndex if existingPartyIndex < lowestPartyIndex
        end
        viewableTeams.reject! do |existingEvent,existingtrainer,existingPartyIndex|
            existingtrainer.full_name == trainer.full_name
        end
		viewableTeams.push([event,trainer,lowestPartyIndex])
    end
    return viewableTeams
end

ItemHandlers::UseInField.add(:POKEXRAY,proc { |item|
    viewableTeams = getViewableTeams
    if viewableTeams.empty?
        pbMessage(_INTL("There's no one near by to use the Poké X-Ray on!"))
        next 0
    end
    if viewableTeams.length == 1
        chosenTeamInfo = viewableTeams[0]
    else
        commands = []
        viewableTeams.each do |event,trainer,partyIndex|
            commands.push(trainer.full_name)
        end
        commands.push(_INTL("Cancel"))
        choice = pbMessage(_INTL("Point the Poké X-Ray at which trainer?"),commands,commands.length)
        next 0 if choice == commands.length - 1
        chosenTeamInfo = viewableTeams[choice]
    end

    chosenEvent = chosenTeamInfo[0]
    chosenTrainer = chosenTeamInfo[1]
    chosenPartyIndex = chosenTeamInfo[2]

    pbMessage(_INTL("You point the Poké X-Ray at {1}...",chosenTrainer.full_name))

    trainerShowcase(chosenTrainer, npcTrainer: true, illusionsFool: true, startWithIndex: chosenPartyIndex)
    
    dialogueOnUsingPokeXRay(chosenEvent, chosenTrainer)
    
    next 1
})

def dialogueOnUsingPokeXRay(event, trainer)
    if trainer.trainer_type == :LEADER_Victoire
        pbMessage(_INTL("Victoire notices you glancing at the Poké X-Ray."))
        pbMessage(_INTL("She smiles slightly and gives you an inscrutable look."))
    end
end