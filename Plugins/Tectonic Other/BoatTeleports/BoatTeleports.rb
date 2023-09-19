CASABA_VILLA_DOCK = _INTL("Casaba Villa")
MAINLAND_DOCK = _INTL("Feebas' Fin")
ELEIG_BOATING_DOCK = _INTL("Eleig Boating Dock")
SWEETROCK_DOCK = _INTL("Sweetrock Harbor")
TAPU_ISLAND = _INTL("Guardian Island")
EVENTIDE_ISLE = _INTL("Eventide Isle")
DRAGON_ISLAND = _INTL("Isle of Dragons")
TRI_ISLAND = _INTL("Tri Island")
MONUMENT_ISLAND = _INTL("Battle Monument")
SPIRIT_ATOLL = _INTL("Spirit Atoll")

def boatTravel(currentDock = "")
    casabaVillaCommand = -1
    mainlandDockCommand = -1
    sweetrockHarborCommand = -1
    eleigBoatingCommand = -1
    tapuIslandCommand = -1
    eventideIsleCommand = -1
    dragonIslandCommand = -1
    triIslandCommand = -1
    monumentIslandCommand = -1
    spiritAtollCommand = -1

    commands = []
    commands[casabaVillaCommand = commands.length] = _INTL(CASABA_VILLA_DOCK) if currentDock != CASABA_VILLA_DOCK
    commands[mainlandDockCommand = commands.length] = _INTL(MAINLAND_DOCK) if currentDock != MAINLAND_DOCK
    commands[eleigBoatingCommand = commands.length] = _INTL(ELEIG_BOATING_DOCK) if $game_switches[70] && currentDock != ELEIG_BOATING_DOCK
    commands[sweetrockHarborCommand = commands.length] = _INTL(SWEETROCK_DOCK) if $game_switches[71] && currentDock != SWEETROCK_DOCK
    commands[tapuIslandCommand = commands.length] = _INTL(TAPU_ISLAND) if $game_switches[81] && currentDock != TAPU_ISLAND
    commands[eventideIsleCommand = commands.length] = _INTL(EVENTIDE_ISLE) if $game_switches[84] && currentDock != EVENTIDE_ISLE
    commands[dragonIslandCommand = commands.length] = _INTL(DRAGON_ISLAND) if $game_switches[86] && currentDock != DRAGON_ISLAND
    commands[triIslandCommand = commands.length] = _INTL(TRI_ISLAND) if $game_switches[97] && currentDock != TRI_ISLAND
    commands[monumentIslandCommand = commands.length] = _INTL(MONUMENT_ISLAND) if $game_switches[99] && currentDock != MONUMENT_ISLAND
    commands[spiritAtollCommand = commands.length] = _INTL(SPIRIT_ATOLL) if $game_switches[151] && currentDock != SPIRIT_ATOLL
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
    elsif tapuIslandCommand > -1 && choice == tapuIslandCommand
        teleportToGuardianIsland
    elsif eventideIsleCommand > -1 && choice == eventideIsleCommand
        teleportToEventideIsle
    elsif dragonIslandCommand > -1 && choice == dragonIslandCommand
        teleportToDragonIsle
    elsif triIslandCommand > -1 && choice == triIslandCommand
        teleportToTriIsland
    elsif monumentIslandCommand > -1 && choice == monumentIslandCommand
        teleportToMonumentIsland
    elsif spiritAtollCommand > -1 && choice == spiritAtollCommand
        teleportToSpiritAtoll
    end
end

def teleportToGuardianIsland
    $game_switches[55] = true # Mark player as having visited this island
    transferPlayer(49,60,Up,377)
end

def teleportToEventideIsle
    $game_switches[85] = true # Mark player as having visited this island
    transferPlayer(21,37,Up,413)
end

def teleportToDragonIsle
    $game_switches[87] = true # Mark player as having visited this island
    transferPlayer(21,28,Up,356)
end

def teleportToTriIsland
    $game_switches[98] = true # Mark player as having visited this island
    transferPlayer(54,49,Up,411)
end

def teleportToMonumentIsland
    $game_switches[100] = true # Mark player as having visited this island
    transferPlayer(31,48,Up,357)
end

def teleportToSpiritAtoll
    $game_switches[152] = true # Mark player as having visited this island
    transferPlayer(20,37,Up,182)
end