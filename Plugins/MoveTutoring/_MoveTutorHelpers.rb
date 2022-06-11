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
	def mentorable_moves()
		species_data = GameData::Species.get(@species)

		moves = []

		# Gather mentorable moves from egg moves
		firstSpecies = species_data
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		end
		firstSpecies.egg_moves.each do |m| 
			next if hasMove?(m)
			moves.push(m)
		end

		# Gather mentorable moves from tutor moves
		species_data.tutor_moves.each do |m|
			next if hasMove?(m)
			moves.push(m)
		end

		# Gather mentorable moves from level up moves
		species_data.moves.each { |learnset_entry|
			m = learnset_entry[1]
			next if hasMove?(m)
			moves.push(m)
		}

		moves.uniq!
		moves.compact!

		return moves
	end
end