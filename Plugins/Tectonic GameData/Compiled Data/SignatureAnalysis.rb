# Returns a hash where each key is an ability ID, and each value is a fully evolved pokemon that gets that signature
def getSignatureAbilities()
	abilityCounts = getAbilityCounts()
	abilityCounts.delete_if{|ability,groups| (groups[0].length + groups[1].length) != 1}

	return abilityCounts.map{|ability,groups| [ability,groups[0].concat(groups[1])[0]]}.to_h
end

def getAbilityCounts()
	ability_counts = {}
	GameData::Ability.each do |ability_data|
		ability_counts[ability_data.id] = [[],[]]
	end
	
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form that isn't a regional form
		next if species_data.form != 0
		# ... or if its not fully evolved
		next if species_data.get_evolutions().length > 0
		arrayID = isLegendary?(species_data.id) ? 1 : 0
		species_data.abilities.each do |ability_id|
			ability_counts[ability_id][arrayID].push(species_data.id)
		end
	end

	GameData::Ability.each do |ability_data|
		ability_counts[ability_data.id][0].uniq!
		ability_counts[ability_data.id][1].uniq!
		ability_counts[ability_data.id][0].compact!
		ability_counts[ability_data.id][1].compact!
	end
	
	return ability_counts.sort_by { |ability, groups| -groups[0].length }
end

# Returns a hash where each key is a move ID, and each value is a fully evolved pokemon that gets that signature
def getSignatureMoves()
	moveCounts = getMoveLearnableGroups()
	moveCounts.delete_if{|move,groups| (groups[0].length + groups[1].length) != 1}

	return moveCounts.map {|move,groups| [move,groups[0].concat(groups[1])[0]] }.to_h
end

def getMoveLearnableGroups()
	move_counts = {}
	GameData::Move.each do |move_data|
		move_counts[move_data.id] = [[],[]]
	end
	
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form that isn't a regional form
		next if species_data.form != 0
		# ... or if its not fully evolved
		next if species_data.get_evolutions().length > 0
		groupIndex = isLegendary?(species_data.id) ? 1 : 0
		species_data.moves.each do |learnset_entry|
			move = learnset_entry[1]
			move_counts[move][groupIndex].push(species_data.id)
		end
		species_data.tutor_moves.each do |tutorMoveID|
			move_counts[tutorMoveID][groupIndex].push(species_data.id)
		end

		firstSpecies = species_data
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		end

		firstSpecies.egg_moves.each do |eggMoveID|
			move_counts[eggMoveID][groupIndex].push(species_data.id)
		end
	end

	GameData::Move.each do |move_data|
		move_counts[move_data.id][0].uniq!
		move_counts[move_data.id][0].compact!
		move_counts[move_data.id][1].uniq!
		move_counts[move_data.id][1].compact!
	end
	
	return move_counts.sort_by { |ability, groups| -groups[0].length }
end