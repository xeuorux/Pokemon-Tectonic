def moveLearningScreen(pkmn,moves)
	return [] if !pkmn || pkmn.egg?

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