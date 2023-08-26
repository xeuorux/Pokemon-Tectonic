def battleMonumentSinglesRegister
    pbMessage(_INTL("Welcome to the Battle Monument."))

    if pbConfirmMessage(_INTL("Take the singles battle challenge?"))
        rules = pbBattleMonumentRules(false)
        pbBattleChallenge.set(
            "monumentsingle",
            7,
            rules,
            false
        )

        rules.setNumber(6)

        errorList = []
        if rules.ruleset.isValid?($Trainer.party,errorList)
            pbBattleChallenge.setParty($Trainer.party)
            pbMessage(_INTL("Please come this way."))
            pbBattleChallenge.start(0, 7)
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

def battleMonumentSinglesBattle(opponentEventID)
    blackFadeOutIn {
        event = get_character(opponentEventID)
        overworldFileName = pbBattleChallenge.nextTrainer.trainer_type.to_s
        bitmap = AnimatedBitmap.new("Graphics/Characters/" + overworldFileName)
        bitmap.dispose
        event.character_name = overworldFileName
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
    if pbBattleChallenge.decision == 1
        pbMessage(_INTL("Congratulations for winning."))
        pbMessage(_INTL("Please take this prize."))
        pbReceiveItem(:EXPCANDYXL)
        pbBattleChallenge.pbEnd
    else
        pbMessage(_INTL("Thanks for playing."))
        pbBattleChallenge.pbEnd
    end
    pbMessage(_INTL("Come back another time."))
end