def revealCrystalClimb(eventID)
    pbMessage(_INTL("With a touch, the crystal reservoir activates!"))
    pbWait(10)
    pbSEPlay("Anim/PRSFX- Diamond Storm3",80,100)
    pbWait(20)
    if eventID.is_a?(Array)
        eventID.each do |trueID|
            pbSetSelfSwitch(trueID,'A')
        end
    else
        pbSetSelfSwitch(eventID,'A')
    end
    pbWait(10)
    setMySwitch('A')
end

def inertCrystal
    pbMessage(_INTL("The crystal reservoir has already spent its energy."))
end

def inactiveCrystalClimb
    pbMessage(_INTL("Budding crystals. They're much too weak to climb on."))
end