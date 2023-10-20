def electricFenceDectivates
    pbSEPlay("Anim/PRSFX- Paralysis", 100, 120)
end

def electricFenceActivates
    pbSEPlay("Anim/PRSFX- Paralysis", 100, 120)
end

def circuitTutorialBasic(eventIDs)
    solved = circuitPuzzle(:TUTORIAL_BASIC)

    if solved
        setSwitchesAll(eventIDs,'A',true)
    else
        setSwitchesAll(eventIDs,'A',false)
        electricFenceActivates
    end
end

def circuitTutorialResistors(eventIDs)
    solved = circuitPuzzle(:TUTORIAL_RESISTORS)

    if solved
        setSwitchesAll(eventIDs,'A',true)
    else
        setSwitchesAll(eventIDs,'A',false)
        electricFenceActivates
    end
end