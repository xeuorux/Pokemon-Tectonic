WIN_COUNT_VARIABLE = 28

BLACKOUT_NURSE_EVENT_ID = 45
BLACKOUT_NURSE_MAP_ID = 329

# The position on the map enemy trainers should be found when you are going to battle them
OPPONENT_MAP_POSITION = [22,16]


# Trainer Type, name, version number, cursed version number, arena event ID
POOL_1 = [
    [:LEADER_Samorn_2,"Samorn",2,3,2],
    [:LEADER_Lambert_2,"Lambert",2,3,3],
    [:LEADER_Eko_2,"Eko",2,3,4],
    [:COOLTRAINER_M7,"X",1,2,5],
    [:FORMERCHAMP_Elise,"Elise",1,2,6],
]

POOL_2 = [
    [:TRAINER_Alessa,"Alessa",3,4,7],
    [:TRAINER_Eifion,"Eifion",1,2,8],
    [:LEADER_Helena_2,"Helena",2,3,9],
    [:LEADER_Bence_2,"Bence",2,3,10],
]

CHAMPION = [:TRAINER_Zain,"Zain",2,3,11]

class PokemonGlobalMetadata
    attr_accessor :tournament
end

class RandomTournament
    attr_reader :matches
    attr_reader :matchesWon

    def initialize()
        @matches = []
        @matchesWon = 0
    end

    def resetTournament()
        initialize()
    end

    def initializeTournament()
        @matchesWon = 0
        $game_variables[WIN_COUNT_VARIABLE] = 0

        firstMatch = POOL_1.sample
        secondMatch = nil
        loop do
            secondMatch = POOL_1.sample
            break unless secondMatch == firstMatch
        end

        thirdMatch = POOL_2.sample
        fourthMatch = nil
        loop do
            fourthMatch = POOL_2.sample
            break unless fourthMatch == thirdMatch
        end

        fifthMatch = CHAMPION

        @matches = [firstMatch,secondMatch,thirdMatch,fourthMatch,fifthMatch]
    end

    def winMatch()
        @matchesWon += 1
        $game_variables[WIN_COUNT_VARIABLE] = @matchesWon
    end

    def nextMatch()
        return @matches[@matchesWon]
    end

    def tournamentBattle()
        next_match = nextMatch()
        trainerType = next_match[0]
        trainerName = next_match[1]
        version = next_match[2]
        version = next_match[3] if $PokemonGlobal.tarot_amulet_active && !next_match[3].nil?
        return pbTrainerBattle(trainerType,trainerName,nil,false,version)
    end

    def opponentEvent()
        return $game_system.map_interpreter.get_character(nextMatch()[4])
    end

    def prepareOpponent()
        opponent_event = opponentEvent()
        opponent_event.moveto(OPPONENT_MAP_POSITION[0],OPPONENT_MAP_POSITION[1])
        opponent_event.turn_left()
    end

    def activateOpponent()
       pbSetSelfSwitch(opponentEvent().id,'A')
    end

    def tournamentWon?
        return @matchesWon >= 5
    end
end

def tournamentBattle()
    return $PokemonGlobal.tournament.tournamentBattle()
end

def nextOpponentName()
    return $PokemonGlobal.tournament.nextMatch()[1]
end

def winTournamentMatch()
    $PokemonGlobal.tournament.winMatch()
    pbMessage("\\wmThe victor is \\PN!\\me[Bug catching 1st]")
end

def enterTournament()
    $PokemonGlobal.tournament = RandomTournament.new if !$PokemonGlobal.tournament
    $PokemonGlobal.tournament.initializeTournament()
end

def resetTournament()
    $PokemonGlobal.tournament.resetTournament()
end

def promptForTournamentCommitment()
    unless $DEBUG
        pbMessage(_INTL("The waiting room for tournament entrants is ahead."))
        pbMessage(_INTL("Once you enter, you will not be able to save or interact with your team in any way until the tournament is complete."))
        pbMessage(_INTL("This means swapping Pokemon, moves, abilities, or items, or even changing your team order."))
        pbMessage(_INTL("A nurse is provided, however, for healing between matches."))
    end
    return pbConfirmMessageSerious(_INTL("Enter and begin the tournament?"))
end

def promptForTournamentQuit()
    pbMessage(_INTL("If you leave, the tournament will be reset and your progress within it will be lost."))
    return pbConfirmMessageSerious(_INTL("Would you still like to leave the tournament?"))
end

def promptForMatchCommitment()
    pbMessage(_INTL("#{nextOpponentName} awaits you in the arena."))
    return pbConfirmMessageSerious(_INTL("Are you ready to battle?"))
end

def handleMatchDecline()
    pbMessage(_INTL("Ok, let me know when you are ready to battle #{nextOpponentName}."))
end

def tournamentWon?
    return $PokemonGlobal.tournament.tournamentWon?
end

def alertNextMatch()
    return if tournamentWon?
    pbMessage(_INTL("Your next match will be against #{nextOpponentName}."))
    pbMessage(_INTL("Return to me when you are ready to battle."))
end

def introduceMatch()
    pbWait(20)
    pbMessage(_INTL("\\wmThe match between #{nextOpponentName} and \\PN will now begin!"))
    pbWait(20)
end

def prepareOpponent()
    $PokemonGlobal.tournament.prepareOpponent()
end

def activateOpponent()
    $PokemonGlobal.tournament.activateOpponent()
end

def displayCurrentOdds()
    displayRoundOdds($PokemonGlobal.tournament.matchesWon + 1)
end

def displayRoundOdds(round)
    return if round < 1 || round > 6
    if round == 6
        pbMessage(_INTL("Odds are displayed for the grand final, gathered from a spectator poll."))
        pbMessage(_INTL("Only 20%% of respondents expect you to win against your brother."))
    else
        index = round-1
        ordinal = ["second", "third", "fourth", "fifth"][index]
        percent = [60,55,45,35][index]
        pbMessage(_INTL("Odds are displayed for the #{ordinal} round matches, gathered from a spectator poll."))
        pbMessage(_INTL("#{percent}%% of respondents expect you to win against #{nextOpponentName()}."))
    end
end

def tournamentTrainerEnd(event,map_id)
    pbTrainerEnd
    pbSetSelfSwitch(event.id,'A',false,map_id)
end

def setCenterToBackupNurse
    $PokemonGlobal.pokecenterMapId     = BLACKOUT_NURSE_MAP_ID
    mapData = Compiler::MapData.new
    map = mapData.getMap(BLACKOUT_NURSE_MAP_ID)
    event = map.events[BLACKOUT_NURSE_EVENT_ID]
    $PokemonGlobal.pokecenterX         = event.x
    $PokemonGlobal.pokecenterY         = event.y + 1
    $PokemonGlobal.pokecenterDirection = Up
end