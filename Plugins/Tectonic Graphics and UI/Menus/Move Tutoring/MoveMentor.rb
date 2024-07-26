# Whether or not a Pokemon's "previously known moves" can also be mentored to other mons
# This means any move that shows up when using the move relearner
CAN_MENTOR_PREVIOUS_MOVES = true

def mentorCoordinator(skipExplanation = false)
    unless teamEditingAllowed?
        showNoTeamEditingMessage
        return
    end

    skipExplanation = true if $PokemonSystem.brief_team_building_npcs == 0

    if isTempSwitchOff?("A") && !skipExplanation
        pbMessage(_INTL("I help your Pokemon to teach each other moves through mentorships!"))
        pbMessage(_INTL("Pokemon can teach any move they know to any other Pokemon you have who can learn that move."))
        pbMessage(_INTL("Any Pokemon in your party or in your PC can be a mentor!"))
        setTempSwitchOn("A")
    end
    if skipExplanation || pbConfirmMessage(_INTL("Would you like one of your party members to learn a move through mentoring?"))
        pbMessage(_INTL("Choose the party member to mentor.")) if skipExplanation
        while true
            pbChoosePokemon(1, 3, proc { |p|
                p.can_mentor_move?
            }, false)
            if $game_variables[1] < 0
                pbMessage(_INTL("If your Pokémon need to mentor each other, come to me.")) unless skipExplanation
                break
            elsif !pbGetPokemon(1).can_mentor_move?
                pbMessage(_INTL("Sorry, it doesn't appear that 1 can have any moves mentored to it at the moment..",
p.name))
            else
                loop do
                    break unless pbMentorMoveScreen(pbGetPokemon(1))
                end
            end
        end
    else
        pbMessage(_INTL("If your Pokémon need to mentor each other, come to me."))
    end
end

def getMovesKnownByMentors(pokemonToSkip = nil)
    movesKnownByMentors = []
    eachPokemonInPartyOrStorage do |otherPkmn|
        next if pokemonToSkip && pokemonToSkip.personalID == otherPkmn.personalID
        otherPkmn.moves.each do |m|
            movesKnownByMentors.push(m.id)
        end
        movesKnownByMentors.concat(getRelearnableMoves(otherPkmn)) if CAN_MENTOR_PREVIOUS_MOVES
    end
    movesKnownByMentors.uniq!
    return movesKnownByMentors
end

def getMentorableMoves(pkmn)
    movesKnownByMentors = getMovesKnownByMentors(pkmn)
    mentorableMoves = pkmn.learnable_moves & movesKnownByMentors
    return mentorableMoves
end

def pbMentorMoveScreen(pkmn)
    mentorableMoves = getMentorableMoves(pkmn)
    return false if mentorableMoves.empty?
    return moveLearningScreen(pkmn, mentorableMoves, true)
end

class Pokemon
    def can_mentor_move?
        return false if egg?

        ourLearnableMoves = learnable_moves
        eachPokemonInPartyOrStorage do |otherPkmn|
            next if otherPkmn.personalID == @personalID
            otherPkmn.moves.each do |m|
                next if hasMove?(m.id)
                next unless ourLearnableMoves.include?(m.id)
                return true
            end
            if CAN_MENTOR_PREVIOUS_MOVES
                getRelearnableMoves(otherPkmn).each do |m|
                    next if hasMove?(m)
                    next unless ourLearnableMoves.include?(m)
                    return true
                end
            end
        end

        return false
    end
end
