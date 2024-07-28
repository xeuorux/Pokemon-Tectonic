def ancientGrassHole
    pbMessage(_INTL("An impassable hole, filled with stunted grass."))
    if pbHasItem?(:FLORASCEPTRE)
        if pbConfirmMessageSerious(_INTL("Use the Flora Sceptre?"))
            pbMessage(_INTL("With a flourish, you wave the Flora Scepter over the hole."))
            pbWait(10)
            pbMoveRoute(get_self,  [
                PBMoveRoute::DirectionFixOff,
                PBMoveRoute::PlaySE,RPG::AudioFile.new("Anim/PRSFX- Growth"),
                PBMoveRoute::TurnLeft,
                PBMoveRoute::Wait,25,
                PBMoveRoute::PlaySE,RPG::AudioFile.new("Anim/PRSFX- Growth"),
                PBMoveRoute::TurnRight,
                PBMoveRoute::Wait,25,
                PBMoveRoute::PlaySE,RPG::AudioFile.new("Anim/PRSFX- Growth"),
                PBMoveRoute::TurnUp,
                PBMoveRoute::Wait,25,
                PBMoveRoute::PlaySE,RPG::AudioFile.new("Anim/PRSFX- Growth"),
                PBMoveRoute::DirectionFixOn,
            ])
            pbWait(150)
            pbSEPlay('Anim/PRSFX- Growth')
            setMySwitch("A")
            pbWait(25)
            pbMessage(_INTL("The grass grew over the hole!"))
        end
    else
        pbMessage(_INTL("If that grass grew over the hole, you'd possibly be able to cross it."))
    end
end