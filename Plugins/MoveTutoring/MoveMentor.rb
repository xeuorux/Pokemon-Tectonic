def mentorCoordinator()
	if !teamEditingAllowed?()
		showNoTeamEditingMessage()
		return
	end

	if isTempSwitchOff?("A")
		pbMessage(_INTL("I help your Pokemon to teach each other moves through mentorships!"))
		pbMessage(_INTL("Pokemon can teach any move they know to any other Pokemon you have who can learn that move."))
		pbMessage(_INTL("Any Pokemon in your party or in your PC can be a mentor!"))
		setTempSwitchOn("A")
	end
	if pbConfirmMessage(_INTL("Would you like one of your party members to learn a move through mentoring?"))
		while true do
			pbChoosePokemon(1,3,proc{|p|
				p.can_mentor_move?
			},false)
			if $game_variables[1] < 0
				pbMessage(_INTL("If your Pokémon need to mentor each other, come to me."))
				break
			elsif !pbGetPokemon(1).can_mentor_move?
				pbMessage(_INTL("Sorry, it doesn't appear that #{1} can have any moves mentored to it at the moment..",p.name))
			else
				pbMentorMoveScreen(pbGetPokemon(1))
			end
		end
	else
		pbMessage(_INTL("If your Pokémon need to mentor each other, come to me."))
	end
end

def getMentorableMoves()
	movesKnownByMentors = []
	eachPokemonInPartyOrStorage do |otherPkmn|
		otherPkmn.moves.each do |m|
			movesKnownByMentors.push(m.id)
		end
	end
	movesKnownByMentors.uniq!
	movesKnownByMentors.compact!
	return movesKnownByMentors
end

def pbMentorMoveScreen(pkmn)
	movesKnownByMentors = getMentorableMoves()
	return false if movesKnownByMentors.length == 0

	mentorableMoves = pkmn.learnable_moves & movesKnownByMentors # Get the elements shared by both arrays
	return false if mentorableMoves.length == 0

	return moveLearningScreen(pkmn,getRelearnableMoves(pkmn))
end

class Pokemon
	def can_mentor_move?
		return false if egg? || shadowPokemon?
		species_data = GameData::Species.get(@species)
		firstSpecies = species_data
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		end
		
		possibleMoves = []
		eachPokemonInPartyOrStorage do |otherPkmn|
			otherPkmn.moves.each do |m|
				possibleMoves.push(m.id)
			end
		end
		possibleMoves.uniq!
		possibleMoves.compact!
		
		firstSpecies.egg_moves.each { |m| 
			next if hasMove?(m)
			return true if possibleMoves.include?(m)
		}
		species_data.tutor_moves.each { |m|
			next if hasMove?(m)
			return true if possibleMoves.include?(m)
		}
		species_data.moves.each { |learnset_entry|
			m = learnset_entry[1]
			next if hasMove?(m)
			return true if possibleMoves.include?(m)
		}
		return false
	end
end