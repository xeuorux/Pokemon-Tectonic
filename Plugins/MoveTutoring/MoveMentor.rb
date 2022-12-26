def mentorCoordinator(skipExplanation=false)
	if !teamEditingAllowed?()
		showNoTeamEditingMessage()
		return
	end

	if isTempSwitchOff?("A") && !skipExplanation
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

def getMovesKnownByMentors()
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

def getMentorableMoves(pkmn)
	movesKnownByMentors = getMovesKnownByMentors()
	mentorableMoves = pkmn.learnable_moves & movesKnownByMentors
	return mentorableMoves
end

def pbMentorMoveScreen(pkmn)
	mentorableMoves = getMentorableMoves(pkmn)
	return false if mentorableMoves.empty?
	return moveLearningScreen(pkmn,mentorableMoves)
end

class Pokemon
	def can_mentor_move?
		return false if egg? || shadowPokemon?
		return !getMentorableMoves(self).empty?
	end
end