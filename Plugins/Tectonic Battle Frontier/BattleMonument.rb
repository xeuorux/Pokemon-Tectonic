def battleMonumentSinglesRegister
    pbMessage(_INTL("Welcome to the Battle Monument."))

    if pbConfirmMessage(_INTL("Take the singles battle challenge?"))
        rules = pbBattleMonumentRules(false, false)
        pbBattleChallenge.set(
            "monumentsingle",
            7,
            rules,
            false
        )

        rules.setNumber(4)

        if pbHasEligible?
            pbMessage(_INTL("Please choose the four Pokémon that will enter."))
            if pbEntryScreen
                pbMessage(_INTL("Please come this way."))
                pbBattleChallenge.start(0, 7)
                return true
            end
        else
            pbMessage(_INTL("Sorry, you can't participate. You need four different Pokémon to enter."))
            pbMessage(_INTL("They must be of a different species."))
            pbMessage(_INTL("Certain legendary or unusual species are also ineligible."))
        end
    end

    pbBattleChallenge.pbCancel
    return false
end

def battleMonumentSinglesBattle(opponentEventID)
    blackFadeOutIn {
        pbBattleChallengeGraphic(get_character(opponentEventID))
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