DebugMenuCommands.register("checkbattlecontentlegality", {
  "parent"      => "analysis",
  "name"        => _INTL("Check Battle Legality"),
  "description" => _INTL("Check all trainer and avatar battles to find illegal elements."),
  "effect"      => proc { |sprites, viewport|
	GameData::Trainer.each do |trainerData|
		name = trainerData.real_name
		trainer = trainerData.to_trainer
		trainerInfo = trainerData.trainer_type.to_s + "," + trainerData.real_name + "," + trainerData.version.to_s
		trainer.party.each do |pokemon|
			checkTrainerPokemonLegality(pokemon,trainerInfo)
		end
	end

	GameData::Avatar.each do |avatarData|
		speciesData = GameData::Species.get(avatarData.id)
		if !speciesData.abilities.include?(avatarData.ability.to_sym)
			echoln("ERROR: #{avatarData.ability} not a legal ability on the Avatar of #{speciesData.real_name}")
		end
	end

	pbMessage("Any legality errors written into the console.")
  }}
)

def checkTrainerPokemonLegality(pkmn,trainerInfo)
	species_data = GameData::Species.get_species_form(pkmn.species,pkmn.form)
	if pkmn.species != :SMEARGLE
		pkmn.moves.each do |move|
			return if !move
			moveID = move.id
			next if pkmn.first_moves.include?(moveID)
			next if species_data.tutor_moves.include?(moveID)
			
			firstSpecies = species_data
			while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
				firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
			end
			next if firstSpecies.egg_moves.include?(moveID)
			
			learnsViaLevel = false
			learnsAtAll = false
			species_data.moves.each do |learnset_entry|
				break if learnset_entry[0] > pkmn.level
				if learnset_entry[1] == moveID
					learnsAtAll = true
					if learnset_entry[0] <= pkmn.level
						learnsViaLevel = true 
					end
				end
			end
			next if learnsViaLevel
			
			if learnsAtAll
				echoln("WARNING: #{moveID} learned early on #{pkmn.name} on #{trainerInfo}")
			else
				echoln("ERROR: #{moveID} learned illegaly on #{pkmn.name} on #{trainerInfo}")
			end
		end
	end
	
	# TO DO: check for illegal per evolution
	prevolutions = species_data.get_prevolutions()
	return if prevolutions.length == 0
	prevo_info =  prevolutions[0] # Assume only one possible prevo
	name = species_data.real_name
	name += "(#{species_data.real_form_name})" if species_data.form != 0
	if [:Level,:LevelDay,:LevelNight,:LevelMale,:LevelFemale,:LevelRain,:LevelDarkInParty].include?(prevo_info[1])
		if prevo_info[2] > pkmn.level
			echoln("ERROR: Level #{pkmn.level} is too low to be able to aquire a #{name} on #{trainerInfo}")
		end
	elsif [:Item,:ItemMale,:ItemFemale,:ItemDay,:ItemNight,:ItemHappiness].include?(prevo_info[1])
		if pkmn.level < 32
			echoln("WARNING: Level #{pkmn.level} may be too low to reasonably aquire a #{name} on #{trainerInfo}")
		end
	end
end