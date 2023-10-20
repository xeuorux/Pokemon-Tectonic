def corviknightWarp
    Pokemon.play_cry(:CORVIKNIGHT, 0)
    pbMessage("This Corviknight has a saddle on its back.")
    if pbConfirmMessage(_INTL("Climb onto it?"))
        pbMessage("You're whisked south of the river!")
        transferPlayerToEvent(45,Down)
    end
end