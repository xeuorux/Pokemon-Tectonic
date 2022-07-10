class Pokemon
	def can_egg_move?
		return false if egg? || shadowPokemon?
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

def pbEggMoveScreen(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
	moves = []
    firstSpecies = GameData::Species.get(pkmn.species)
	while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
		firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
	end
    firstSpecies.egg_moves.each do |m|
      next if pkmn.hasMove?(m)
      moves.push(m) if !moves.include?(m)
    end

	retval = true
	pbFadeOutIn {
		scene = MoveLearner_Scene.new
		screen = MoveLearnerScreen.new(scene)
		retval = screen.pbStartScreen(pkmn,moves)
	}
	return retval
end