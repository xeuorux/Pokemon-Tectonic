def chasmGate
    pbMessage(_INTL("A locked gate. It has a slot for a keycard."))
    if pbHasItem?(:CHASMIDCARD)
        pbMessage(_INTL("You insert the Team Chasm ID Card."))
        pbSEPlay("Door enter",80,100)
        setMySwitch("A")
    end
end

def chasmDoor
    pbMessage(_INTL("A locked door. It has a slot for a keycard."))
    if pbHasItem?(:CHASMIDCARD)
        pbMessage(_INTL("You insert the Team Chasm ID Card."))
        pbSEPlay("Battle catch click",80,100)
        pbMessage(_INTL("The door was unlocked."))
        setMySwitch("A")
    end
end