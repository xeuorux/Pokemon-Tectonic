def battleTowerSinglesRegister
    pbMessage(_INTL("Welcome to the Battle Tower."))

    if pbConfirmMessageSerious(_INTL("Would you like to participate in a singles battle challenge?"))
        rules = pbBattleTowerRules(false, false)
        pbBattleChallenge.set(
            "towersingle",
            7,
            rules
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
            pbMessage(_INTL("Sorry, you can't participate. You need three different Pokémon to enter."))
            pbMessage(_INTL("They must be of a different species and hold different items."))
            pbMessage(_INTL("Certain legendary species are also ineligible."))
        end
    end

    pbBattleChallenge.pbCancel
    return false
end

def battleTowerSinglesBattle(opponentEventID)
    pbBattleChallengeGraphic(get_character(opponentEventID))
    pbMessage(pbBattleChallengeBeginSpeech)
    if pbBattleChallengeBattle
        pbBattleChallenge.pbAddWin
        # Player is victorous in their run
        if pbBattleChallenge.pbMatchOver?
            pbBattleChallenge.setDecision(1)
            battleTowerTransferToStart
        else
            pbMessage(_INTL("Let me heal your party."))
            healPartyWithDelay
            pbBattleChallenge.pbGoOn
        end
    else
        pbBattleChallenge.setDecision(2)
        battleTowerTransferToStart
    end
end

def battleTowerTransferToStart
    pbSEPlay('Door Exit',80,100)
    blackFadeOutIn {
        pbBattleChallenge.pbGoToStart
    }
end

def battleTowerRecievePlayerInLobby
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