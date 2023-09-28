def itemGatedFight(itemID,regularBattleIntroText,itemGateIntroText,requestItemText,confirmGiveText,declineGiveText,lackingItemText)
    if getMySwitch("B")
        noticePlayer
        pbMessage(_INTL(regularBattleIntroText))
    else
        showExclamation
        pbMessage(_INTL(itemGateIntroText))
        if pbHasItem?(itemID)
            if pbConfirmMessage(requestItemText)
                pbDeleteItem(itemID)
                pbMessage(_INTL(confirmGiveText))
                setMySwitch("B")
            else
                pbMessage(_INTL(declineGiveText))
                forcePlayerBackwards
                command_end # exit event processing
            end
        else
            pbMessage(_INTL(lackingItemText))
            forcePlayerBackwards
            command_end # exit event processing
        end
    end
    # If this finishes without event exit, the battle commences
end