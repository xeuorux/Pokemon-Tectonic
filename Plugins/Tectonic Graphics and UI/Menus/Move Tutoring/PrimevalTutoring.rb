def primevalTutor()
    if !teamEditingAllowed?()
		showNoTeamEditingMessage()
		return
	end

    while true do
        pbChoosePokemon(1,3,proc{|p|
            p.species == :SMEARGLE
        },false)
        if $game_variables[1] < 0
            break
        else
            pbPrimevalTutorScreen(pbMapInterpreter.pbGetPokemon(1))
        end
    end
end

def pbPrimevalTutorScreen(pkmn)
    primevalMoves = getPrimevalMoves(pkmn)
    return false if primevalMoves.empty?
    return moveLearningScreen(pkmn, primevalMoves, true)
end

def getPrimevalMoves(pkmn)
    moves = []
    GameData::Move.each do |moveData|
        next unless moveData.primeval
        next if pkmn.hasMove?(moveData.id)
        moves.push(moveData.id)
    end
    return moves
end