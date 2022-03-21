DebugMenuCommands.register("analyzetrainers", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Analyze Trainers"),
  "description" => _INTL("Find out which Pokemon arent yet used, or used multiple times."),
  "effect"      => proc { |sprites, viewport|
	echoln("Analyzing trainers")
	
	speciesUsed = {}
	GameData::Species.each do |species_data|
		next if species_data.form != 0
		speciesUsed[species_data.species] = []
	end
	
	trainerNamesCompleted = []
	GameData::Trainer.each do |trainerData|
		name = trainerData.real_name
		next if trainerNamesCompleted.include?(name)
		trainerNamesCompleted.push(name)
		trainerData.pokemon.each do |partyEntry|
			species = partyEntry[:species]
			speciesUsed[species].push(trainerData)
		end
	end
	
	unusedPokemon = []
	pokemonUsedMoreThanOnce = []
	pokemonUsedWhichShouldntBe = []
	speciesUsed.each do |species,arrayOfTrainerData|
		if isLegendary?(species) || isQuarantined?(species)
			if arrayOfTrainerData.length >= 1
				pokemonUsedWhichShouldntBe.push([species,arrayOfTrainerData])
			end
		else
			arrayOfTrainerData.uniq!
			arrayOfTrainerData.compact!
			if arrayOfTrainerData.length == 0
				unusedPokemon.push(species)
			elsif arrayOfTrainerData.length >= 2
				pokemonUsedMoreThanOnce.push([species,arrayOfTrainerData])
			end
		end
	end
	pokemonUsedMoreThanOnce.sort_by! {|entry| -entry[1].length}
	
	echoln("All the species which have been used whom should not be (#{pokemonUsedWhichShouldntBe.length}): ")
	pokemonUsedWhichShouldntBe.each do |entry|
		echoln(entry[0].to_s)
	end
	
	echoln("All the species which have been used more than once (#{pokemonUsedMoreThanOnce.length}): ")
	pokemonUsedMoreThanOnce.each do |entry|
		trainerInfoList = entry[1].map{|trainerData| GameData::TrainerType.get(trainerData.trainer_type).real_name + " " + trainerData.real_name}
		echoln("#{entry[0]} (#{entry[1].length}) : #{trainerInfoList}}")
	end
	
	echoln("All the species which have not been used and should be (#{unusedPokemon.length}): ")
	unusedPokemon.each do |species|
		species_data = GameData::Species.get(species)
		prevolutions = species_data.get_prevolutions
		levelAvailable = 0
		if prevolutions.length != 0
			prevo = prevolutions[0]
			if [:Level,:LevelDay,:LevelNight,:LevelMale,:LevelFemale,:LevelRain,
					:AttackGreater,:AtkDefEqual,:DefenseGreater,:LevelDarkInParty,
					:Silcoon,:Cascoon,:Ninjask,:Shedinja].include?(prevo[1])
				levelAvailable = prevo[2]
			end
		end
		
		echoln("#{species.to_s},#{species_data.type1},#{species_data.type2},#{levelAvailable == 0 ? "" : levelAvailable.to_s}")
	end
  }}
)