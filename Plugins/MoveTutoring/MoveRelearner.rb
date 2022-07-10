def moveRelearner()
	if isTempSwitchOff?("A")
		pbMessage(_INTL("I'm the Pokémon Move Maniac."))
		pbMessage(_INTL("I know every single move that Pokémon learn while leveling up or evolving."))
		pbMessage(_INTL("I can teach moves to your Pokémon -- at no cost!"))
		setTempSwitchOn("A")
	end
	if pbConfirmMessage(_INTL("Do you want me to teach one of your Pokémon a move?"))
		while true do
			pbChoosePokemon(1,3,proc{|p|
				p.can_relearn_move?
			},false)
			if $game_variables[1] < 0
				pbMessage(_INTL("If your Pokémon need to learn a move, come to me!"))
				break
			elsif !pbGetPokemon(1).can_relearn_move?
				pbMessage(_INTL("Sorry, it doesn't appear as if I have any move I can teach to your \v[3]."))
			else
				pbRelearnMoveScreen(pbGetPokemon(1))
			end
		end
	else
		pbMessage(_INTL("If your Pokémon need to learn a move, come to me!"))
	end
end

def pbRelearnMoveScreen(pkmn)
	return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
	
	moves = []
	pkmn.getMoveList.each do |m|
		next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
		moves.push(m[1]) if !moves.include?(m[1])
	end
	
	pkmn.first_moves.each do |m|
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

class Pokemon
	def can_relearn_move?
		return false if egg? || shadowPokemon?
		this_level = self.level
		getMoveList.each { |m| return true if m[0] <= this_level && !hasMove?(m[1]) }
		@first_moves.each { |m| return true if !hasMove?(m) }
		return false
	end
end