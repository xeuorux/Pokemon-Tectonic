def battleMonumentSinglesRegister
    pbMessage(_INTL("Welcome to the Battle Monument."))

    if pbConfirmMessage(_INTL("Take the singles battle challenge?"))
        rules = pbBattleMonumentRules(false)
        pbBattleChallenge.set(
            "monumentsingle",
            5,
            rules,
            false
        )

        rules.setNumber(6)

        errorList = []
        if rules.ruleset.isValid?($Trainer.party,errorList)
            pbBattleChallenge.setParty($Trainer.party)
            pbMessage(_INTL("Please come this way."))
            pbBattleChallenge.start
            return true
        else
            pbMessage(_INTL("Your party is not legal for this challenge."))
            errorList.each do |error|
                pbMessage(error)
            end
        end
    end

    pbBattleChallenge.pbCancel
    return false
end

def battleMonumentSinglesBattle(opponentEventID,followerEventID)
    blackFadeOutIn {
        nextTrainer = pbBattleChallenge.nextTrainer

        # Set the sprite for the opponent
        opponentCharacterName = nextTrainer.trainer_type.to_s
        # bitmap = AnimatedBitmap.new("Graphics/Characters/" + overworldFileName)
        # bitmap.dispose
        get_character(opponentEventID).character_name = opponentCharacterName

        # Set the sprite for the follower pokemon
        pokemon = nextTrainer.to_trainer.displayPokemonAtIndex(0)
        followerCharacterName = GameData::Species.ow_sprite_filename(pokemon.species,pokemon.form,pokemon.gender,pokemon.shiny?).gsub!("Graphics/Characters/","")
	    get_character(followerEventID).character_name = followerCharacterName
    }
    pbMessage(_INTL("The match will now begin!"))
    if pbBattleChallengeBattle
        pbBattleChallenge.pbAddWin
        # Player is victorous in their run
        if pbBattleChallenge.pbMatchOver?
            pbBattleChallenge.setDecision(1)
            battleMonumentTransferToStart
        else
            pbMessage(_INTL("Let me heal your party."))
            healPartyWithDelay
            pbBattleChallenge.pbGoOn
        end
    else
        pbBattleChallenge.setDecision(2)
        battleMonumentTransferToStart
    end
end

def battleMonumentTransferToStart
    pbSEPlay('Door Exit',80,100)
    blackFadeOutIn {
        pbBattleChallenge.pbGoToStart
    }
end

def battleMonumentRecievePlayerInLobby
    battleChallenge = pbBattleChallenge
    wins = battleChallenge.battleNumber - 1
    if pbBattleChallenge.decision == 1
        checkBattleMonumentVictoryAchievements
        pbMessage(_INTL("Congratulations on your victory!"))
        earnBattlePoints(50)
    elsif wins
        pbMessage(_INTL("Thanks for playing."))
        
        echoln("Wins: #{wins}")
        case wins
        when 1
            earnBattlePoints(3)
        when 2
            earnBattlePoints(6)
        when 3
            earnBattlePoints(12)
        when 4
            earnBattlePoints(25)
        when 5
            earnBattlePoints(50)
        end
    else
        pbMessage(_INTL("Better luck next time."))
    end
    pbBattleChallenge.pbEnd
    pbMessage(_INTL("Come back another time."))
end