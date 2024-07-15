def ancientGrassHole
    pbMessage(_INTL("An impassable hole, filled with stunted grass."))
    if pbHasItem?(:FLORASCEPTRE)
        if pbConfirmMessageSerious(_INTL("Use the Flora Sceptre?"))
            pbMessage(_INTL("With a flourish, you wave the Flora Scepter over the hole."))
            pbWait(20)
            pbSEPlay('Anim/PRSFX- Growth',100,50)
            pbWait(20)
            setMySwitch("A")
            pbMessage(_INTL("The grass grew over the hole!"))
        end
    else
        pbMessage(_INTL("If that grass grew over the hole, you'd possibly be able to cross it."))
    end
end