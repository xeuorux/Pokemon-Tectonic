def itemGatedFight(itemID,regularBattleIntroText,itemGateIntroText,requestItemText,confirmGiveText,declineGiveText,lackingItemText)
    if getMySwitch("B")
        noticePlayer
        pbMessage(_INTL(regularBattleIntroText))
    else
        showExclamation
        pbWait(20)
        pbMessage(_INTL(itemGateIntroText))
        if pbHasItem?(itemID)
            if pbConfirmMessage(requestItemText)
                pbDeleteItem(itemID)
                pbMessage(_INTL(confirmGiveText))
                setMySwitch("B")
            else
                pbMessage(_INTL(declineGiveText))
                forcePlayerBackwards
                get_self.direction = get_self.original_direction
                command_end # exit event processing
            end
        else
            pbMessage(_INTL(lackingItemText))
            forcePlayerBackwards
            get_self.direction = get_self.original_direction
            command_end # exit event processing
        end
    end
    # If this finishes without event exit, the battle commences
end