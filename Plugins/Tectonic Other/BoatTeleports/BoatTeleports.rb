CASABA_VILLA_DOCK = _INTL("Casaba Villa")
MAINLAND_DOCK = _INTL("Feebas' Fin")
ELEIG_BOATING_DOCK = _INTL("Eleig Boating Dock")
SWEETROCK_DOCK = _INTL("Sweetrock Harbor")

def boatTravel(currentDock = "")
    casabaVillaCommand = -1
    mainlandDockCommand = -1
    sweetrockHarborCommand = -1
    eleigBoatingCommand = -1

    commands = []
    commands[casabaVillaCommand = commands.length] = _INTL(CASABA_VILLA_DOCK) if currentDock != CASABA_VILLA_DOCK
    commands[mainlandDockCommand = commands.length] = _INTL(MAINLAND_DOCK) if currentDock != MAINLAND_DOCK
    commands[eleigBoatingCommand = commands.length] = _INTL(ELEIG_BOATING_DOCK) if $game_switches[70] && currentDock != ELEIG_BOATING_DOCK
    commands[sweetrockHarborCommand = commands.length] = _INTL(SWEETROCK_DOCK) if $game_switches[71] && currentDock != SWEETROCK_DOCK
    commands.push(_INTL("Cancel"))

    choice = pbMessage(_INTL("Where would you like to go?"),commands,commands.length)
    if casabaVillaCommand >= -1 && choice == casabaVillaCommand
        transferPlayer(30,42,Up,136)
    elsif mainlandDockCommand >= -1 && choice == mainlandDockCommand
        transferPlayer(38,31,Up,59)
    elsif eleigBoatingCommand > -1 && choice == eleigBoatingCommand
        transferPlayer(47,17,Up,185)
    elsif sweetrockHarborCommand > -1 && choice == sweetrockHarborCommand
        transferPlayer(18,55,Up,217)
    end
end