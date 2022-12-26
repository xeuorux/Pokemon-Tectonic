def moveLearningScreen(pkmn,moves)
	return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?

	if !teamEditingAllowed?()
		showNoTeamEditingMessage()
		return
	end

	moves.sort! { |move_a, move_b|
		moveDataA = GameData::Move.get(move_a)
		moveDataB = GameData::Move.get(move_b)

		scoreA = moveDataA.category * 1000 - moveDataA.base_damage
		scoreB = moveDataB.category * 1000 - moveDataB.base_damage

		scoreA <=> scoreB
	}
	
	retval = true
	pbFadeOutIn {
	  scene = MoveLearner_Scene.new
	  screen = MoveLearnerScreen.new(scene)
	  retval = screen.pbStartScreen(pkmn,moves)
	}
	return retval
end

def eachPokemonInPartyOrStorage()
	$Trainer.party.each do |pkmn|
		yield pkmn
	end

	for i in 0...$PokemonStorage.maxBoxes
		for j in 0...$PokemonStorage.maxPokemon(i)
			pkmn = $PokemonStorage[i, j]
			yield pkmn if pkmn
		end
	end
end

class Pokemon
	def learnable_moves(skipAlreadyLearned = true)
		species_data = GameData::Species.get(@species)

		moves = []

		# Gather egg moves
		firstSpecies = species_data
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		end
		
		firstSpecies.egg_moves.each do |m| 
			next if hasMove?(m) && skipAlreadyLearned
			moves.push(m)
		end

		# Gather tutor moves
		species_data.tutor_moves.each do |m|
			next if hasMove?(m) && skipAlreadyLearned
			moves.push(m)
		end

		# Gather level up moves
		species_data.moves.each { |learnset_entry|
			m = learnset_entry[1]
			next if hasMove?(m) && skipAlreadyLearned
			moves.push(m)
		}

		moves.uniq!
		moves.compact!

		return moves
	end
end