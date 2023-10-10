class Pokemon
    def can_tutor_move?
        return false if egg?
        species_data = GameData::Species.get(@species)
        species_data.tutor_moves.each { |m| 
            return true if !hasMove?(m)
        }
        return false
    end
end

def pbTutorMoveScreen(pkmn)
    return [] if !pkmn || pkmn.egg?
    moves = []
    species_data = GameData::Species.get(pkmn.species)
    species_data.tutor_moves.each do |m|
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