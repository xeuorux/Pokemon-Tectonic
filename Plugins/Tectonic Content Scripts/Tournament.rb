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
    [:COOLTRAINER_M7,"X",0,1,5],
    [:FORMERCHAMP_Elise,"Elise",1,2,6],
]

POOL_2 = [
    [:TRAINER_Alessa,"Alessa",3,4,7],
    [:TRAINER_Eifion,"Eifion",1,2,8],
    [:LEADER_Helena_2,"Helena",2,3,9],
    [:LEADER_Bence_2,"Bence",2,3,10],
]

CHAMPION = [:TRAINER_Zain,"Zain",2,3,11]

FINAL_ROUND = 5

class RandomTournament
    attr_reader :matches
    attr_reader :matchesWon
    attr_reader :attempts
    attr_reader :cursed_wins
    attr_reader :perfect_wins

    def initialize()
        @matches = []
        @matchesWon = 0
        @attempts = 0
        @cursed_wins = 0
        @perfect_wins = 0

        prepMatches

        @active = false
    end

    def beginAttempt
        @attempts += 1
        @matchesWon = 0
        @cursed_wins = 0
        @perfect_wins = 0
        $game_variables[WIN_COUNT_VARIABLE] = 0
        @active = true
    end

    def resetTournament()
        initialize()
    end

    def leaveTournament
        @active = false
    end

    def prepMatches()
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
        @cursed_wins += 1 if tarotAmuletActive?
        @perfect_wins += 1 if battlePerfected?
        $game_variables[WIN_COUNT_VARIABLE] = @matchesWon
        @active = false if tournamentWon?
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
       pbSetSelfSwitch(opponentEvent.id,'A')
    end

    def tournamentWon?
        return @matchesWon >= FINAL_ROUND
    end

    def tournamentActive?
        return @active
    end

    def takeTournamentSnapshot()
        flags = []
        flags.push("perfect") if @perfect_wins == FINAL_ROUND
        flags.push("cursed") if @cursed_wins == FINAL_ROUND
        teamSnapshot("Makyan Champion", flags)
    end
end

def tournamentBattle()
    return $PokemonGlobal.tournament.tournamentBattle()
end

def nextOpponentName()
    trainer = $PokemonGlobal.tournament.nextMatch
    trainer_data = GameData::Trainer.get(trainer[0], trainer[1], trainer[2])
    return trainer_data.name
end

def winTournamentMatch()
    $PokemonGlobal.tournament.winMatch()
    pbMessage(_INTL("\\wmThe victor is \\PN!\\me[Bug catching 1st]"))
end

def enterTournament()
    $PokemonGlobal.tournament = RandomTournament.new if !$PokemonGlobal.tournament
    properlySave
    $PokemonGlobal.tournament.beginAttempt
end

def resetTournament()
    $PokemonGlobal.tournament.resetTournament unless $PokemonGlobal.tournament.nil?
end

def leaveTournament
    $PokemonGlobal.tournament.leaveTournament unless $PokemonGlobal.tournament.nil?
end

def promptForTournamentCommitment()
    if $PokemonGlobal.tournament.nil? || $PokemonGlobal.tournament.attempts == 0
        pbMessage(_INTL("The waiting room for tournament entrants is ahead."))
        pbMessage(_INTL("Once you enter, you will not be able to interact with your team in any way until the tournament is complete."))
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
    pbMessage(_INTL("{1} awaits you in the arena.", nextOpponentName))
    return pbConfirmMessageSerious(_INTL("Are you ready to battle?"))
end

def handleMatchDecline()
    pbMessage(_INTL("Ok, let me know when you are ready to battle {1}.", nextOpponentName))
end

def tournamentWon?
    return $PokemonGlobal.tournament.tournamentWon?
end

def alertNextMatch()
    return if tournamentWon?
    pbMessage(_INTL("Your next match will be against {1}.", nextOpponentName))
    pbMessage(_INTL("Return to me when you are ready to battle."))
end

def introduceMatch()
    pbWait(20)
    pbMessage(_INTL("\\wmThe match between {1} and \\PN will now begin!", nextOpponentName))
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
    return if round < 1 || round > FINAL_ROUND
    if round == FINAL_ROUND
        pbMessage(_INTL("Odds are displayed for the grand final, gathered from a spectator poll."))
        pbMessage(_INTL("Only 20 percent of respondents expect you to win against your brother."))
    else
        index = round-1
        ordinal = [_INTL("second"), _INTL("third"), _INTL("fourth"), _INTL("fifth")][index]
        percent = [60,55,45,35][index]
        pbMessage(_INTL("Odds are displayed for the {1} round matches, gathered from a spectator poll.", ordinal))
        pbMessage(_INTL("{1} percent of respondents expect you to win against {2}.", percent, nextOpponentName()))
    end
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

def takeTournamentSnapshot()
    return $PokemonGlobal.tournament.takeTournamentSnapshot()
end