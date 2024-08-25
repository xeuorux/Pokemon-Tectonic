def moveRelearner
	unless teamEditingAllowed?
		showNoTeamEditingMessage
		return
	end

    choices = []
    choices[cmdMoveRelearning = choices.length] = _INTL("Relearn Moves")
    choices[cmdExplainMoveRelearning = choices.length] = _INTL("What is Move Relearning?")
    choices.push(_INTL("Cancel"))
    choice = pbMessage(_INTL("I'm the Move Relearner. How can I help?"),choices,choices.length)

    if choice == cmdMoveRelearning
		while true do
			pbChoosePokemon(1,3,proc{|p|
				p.can_relearn_move?
			},false)
			if $game_variables[1] < 0
				break
			elsif !pbGetPokemon(1).can_relearn_move?
				pbMessage(_INTL("Sorry, it doesn't appear as if I have any move I can teach to your \v[3]."))
			else
				loop do
					break unless pbRelearnMoveScreen(pbGetPokemon(1))
				end
			end
		end
    elsif choice == cmdExplainMoveRelearning
        pbMessage(_INTL("I can teach moves to your Pokémon -- at no cost!"))
        pbMessage(_INTL("I know every single move that Pokémon learn while leveling up or evolving."))
        pbMessage(_INTL("I can also help Pokemon to relearn moves they learned through TMs, Mentoring, or Sketching!"))
    end
end

def getRelearnableMoves(pkmn)
	moves = []
	pkmn.getMoveList.each do |m|
		next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
		moves.push(m[1]) if !moves.include?(m[1])
	end
	
	pkmn.first_moves.each do |m|
		next if pkmn.hasMove?(m)
		moves.push(m) if !moves.include?(m)
	end

	moves.uniq!
	moves.compact!
	
	return moves
end

def pbRelearnMoveScreen(pkmn)
	relearnableMoves = getRelearnableMoves(pkmn)
	return false if relearnableMoves.empty?
	return moveLearningScreen(pkmn,relearnableMoves)
end

class Pokemon
	def can_relearn_move?
		return false if egg?
		return !getRelearnableMoves(self).empty?
	end
end