DebugMenuCommands.register("analyzedistribution", {
  "parent"      => "analysis",
  "name"        => _INTL("Analyze move distribution"),
  "description" => _INTL("See the total distribution of each move."),
  "effect"      => proc { |sprites, viewport|
	move_counts = {}
	GameData::Move.each do |move|
		move_counts[move.id] = [0,0,0,0,0,0]
		# 0 = Species learn by level up
		# 1 = Species learn by TM
		# 2 = Species learn by egg
		# 3 = Species learn as same-type
		# 4 = Species learn as off-type
		# 5 = Species of the same type which don't learn it
	end
		
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form
		if species_data.form != 0
			formName = species_data.real_form_name
			formName.gsub!("%","") if formName
			next
		end
		
		learnSet = []
		species_data.moves.each do |learnset_entry|
			move_id = learnset_entry[1]
			next if learnSet.include?(move_id)
			move_counts[move_id][0] += 1
			learnSet.push(move_id)
		end
		
		species_data.tutor_moves.each do |move_id|
			move_counts[move_id][1] += 1
			learnSet.push(move_id)
		end
		
		species_data.egg_moves.each do |move_id|
			move_counts[move_id][2] += 1
			learnSet.push(move_id)
		end
		
		species_types = [species_data.type1,species_data.type2]
		
		learnSet.uniq!
		learnSet.compact!
		learnSet.each do |move_id|
			moveData = GameData::Move.get(move_id)
			if species_types.include?(moveData.type)
				move_counts[move_id][3] += 1
			else
				move_counts[move_id][4] += 1
			end
		end
		GameData::Move.each do |move|
			next unless species_types.include?(move.type)
			next if learnSet.include?(move.id)
			move_counts[move.id][5] += 1
		end
	end
	
	move_counts = move_counts.sort_by{|move_id,counts| move_id}
	
	File.open("move_distribution.txt","wb") { |file|
		move_counts.each do |move_id,counts|
			moveData = GameData::Move.get(move_id)
			categoryLabel = ["PHYSICAL","SPECIAL","STATUS"][moveData.category]
			file.write("#{move_id},#{moveData.type},#{categoryLabel},#{counts[0]},#{counts[1]},#{counts[2]},#{counts[3]},#{counts[4]},#{counts[5]}\r\n")
		end
	}
	pbMessage(_INTL("Move distribution analysis written to move_distribution.txt"))
  }
})