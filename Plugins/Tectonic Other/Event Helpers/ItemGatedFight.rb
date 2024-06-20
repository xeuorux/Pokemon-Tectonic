def itemGatedFight(itemID,regularBattleIntroText,itemGateIntroText,requestItemText,confirmGiveText,declineGiveText,lackingItemText)
    if getMySwitch("B")
        noticePlayer
        pbMessage(regularBattleIntroText)
    else
        showExclamation
        pbWait(20)
        pbMessage(itemGateIntroText)
        if pbHasItem?(itemID)
            if pbConfirmMessageSerious(requestItemText)
                pbDeleteItem(itemID)
                pbMessage(_INTL("You hand over the {1}.",getItemName(itemID)))
                pbMessage(confirmGiveText)
                setMySwitch("B")
            else
                pbMessage(declineGiveText)
                forcePlayerBackwards
                get_self.direction = get_self.original_direction
                command_end # exit event processing
            end
        else
            pbMessage(lackingItemText)
            forcePlayerBackwards
            get_self.direction = get_self.original_direction
            command_end # exit event processing
        end
    end
    # If this finishes without event exit, the battle commences
end