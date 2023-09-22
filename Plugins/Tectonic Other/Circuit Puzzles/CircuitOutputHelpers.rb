def tutorialBasic(eventIDs)
    state = circuitPuzzle(:TUTORIAL_BASIC)

    if state == 0
        setSwitchesAll(eventIDs,'A',false)
    else
        setSwitchesAll(eventIDs,'A',true)
    end
end