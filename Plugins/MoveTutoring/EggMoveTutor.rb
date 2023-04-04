class Pokemon
	def can_egg_move?
		return false if egg?
		firstSpecies = GameData::Species.get(@species)
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		end
		firstSpecies.egg_moves.each { |m| 
			return true if !hasMove?(m)
		}
		return false
	end
end

def getEggMoves(pkmn)
	moves = []

    firstSpecies = GameData::Species.get(pkmn.species)
	while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
		firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
	end

    firstSpecies.egg_moves.each do |m|
      next if pkmn.hasMove?(m)
      moves.push(m)
    end
	
	moves.uniq!
	moves.compact!

	return moves
end

def pbEggMoveScreen(pkmn)
    return moveLearningScreen(pkmn,getEggMoves(pkmn))
end