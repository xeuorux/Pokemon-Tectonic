ItemHandlers::UseFromBag.add(:POKEXRAY,proc { |item|
    if getViewableTeams.empty?
        pbMessage(_INTL("There's no one near by to use the Poké X-Ray on!"))
        next 0
    end
    next 2
})

POKE_XRAY_RANGE = 6

def getViewableTeams
    viewableTeams = []
    eachTrainerWithAutoFollowerInMap do |event, match, trainer|
		next if event.name.downcase.include?("noxray")
        next unless match[4].nil? || match[4] == "0"
		xDif = (event.x - $game_player.x).abs
		yDif = (event.y - $game_player.y).abs
		next unless xDif <= POKE_XRAY_RANGE && yDif <= POKE_XRAY_RANGE # Must be nearby
        next if pbGetSelfSwitch(event.id,'D') # Must not already be fled
        next if event.character_name == ""
		viewableTeams.push(trainer)
    end
    viewableTeams.uniq!
    return viewableTeams
end

ItemHandlers::UseInField.add(:POKEXRAY,proc { |item|
    viewableTeams = getViewableTeams
    if viewableTeams.empty?
        pbMessage(_INTL("There's no one near by to use the Poké X-Ray on!"))
        next 0
    end
    if viewableTeams.length == 1
        chosenTrainer = viewableTeams[0]
    else
        commands = []
        viewableTeams.each do |trainer|
            commands.push(trainer.full_name)
        end
        commands.push(_INTL("Cancel"))
        choice = pbMessage(_INTL("Point the Poké X-Ray at which trainer?"),commands,commands.length)
        next 0 if choice == commands.length - 1
        chosenTrainer = viewableTeams[choice]
    end
    pbMessage(_INTL("You point the Poké X-Ray at {1}...",chosenTrainer.full_name))
    trainerShowcase(chosenTrainer)
    next 1
})