DebugMenuCommands.register("analyzedistribution", {
  "parent"      => "analysis",
  "name"        => _INTL("Analyze move distribution"),
  "description" => _INTL("See the total distribution of each move."),
  "effect"      => proc { |sprites, viewport|
	move_counts = {}
	GameData::Move.each do |move|
		move_counts[move.id] = [0,0,0,0]
		# 0 = Species learn by level up
		# 1 = Species learn by Tutor
		# 2 = Species learn as same-type
		# 3 = Species learn as off-type
	end
		
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form
		if species_data.form != 0
			formName = species_data.real_form_name
			formName.gsub!("%","") if formName
			next
		end

		# Don't check the species if its not a final evo
		next if species_data.get_evolutions.length > 0

		echoln("Checking the moves of #{species_data.real_name}")
		
		learnSet = []
		species_data.moves.each do |learnset_entry|
			move_id = learnset_entry[1]
			next if learnSet.include?(move_id)
			move_counts[move_id][0] += 1
			learnSet.push(move_id)
		end
		
		# Gather tutor moves
		tutorSet = []
		species_data.tutor_moves.each do |move_id|
			move_counts[move_id][1] += 1
			learnSet.push(move_id)
			tutorSet.push(move_id)
		end

		# Gather line moves
		firstSpecies = species_data
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		end
		
		firstSpecies.egg_moves.each do |move_id| 
			next if tutorSet.include?(move_id)
			move_counts[move_id][1] += 1
			learnSet.push(move_id)
			tutorSet.push(move_id)
		end
		
		species_types = [species_data.type1,species_data.type2]
		
		learnSet.uniq!
		learnSet.compact!
		learnSet.each do |move_id|
			moveData = GameData::Move.get(move_id)
			if species_types.include?(moveData.type)
				move_counts[move_id][2] += 1
			else
				move_counts[move_id][3] += 1
			end
		end
	end
	
	move_counts = move_counts.sort_by{|move_id,counts| move_id}
	
	File.open("move_distribution.txt","wb") { |file|
		file.write("Move, Type, Category, Level Up Count, Tutor Count, Same-Type Count, Off-type Count\r\n")
		move_counts.each do |move_id,counts|
			moveData = GameData::Move.get(move_id)
			categoryLabel = ["PHYSICAL","SPECIAL","STATUS"][moveData.category]
			file.write("#{move_id},#{moveData.type},#{categoryLabel},#{counts[0]},#{counts[1]},#{counts[2]},#{counts[3]}\r\n")
		end
	}
	pbMessage(_INTL("Move distribution analysis written to move_distribution.txt"))
  }
})