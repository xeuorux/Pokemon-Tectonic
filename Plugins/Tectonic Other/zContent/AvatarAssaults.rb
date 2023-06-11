def startAvatarAssaultEvent1
    $game_switches[101] = true
    $game_switches[102] = true
    $PokemonGlobal.forceMapBGM("CATASTROPHE",25) # Grouz
end

def endAvatarAssaultEvent1
    $game_switches[102] = false
    $game_switches[103] = true
end

def startAvatarAssaultEvent2
    $game_switches[104] = true
    $game_switches[105] = true
end

def endAvatarAssaultEvent2
    $game_switches[105] = false
    $game_switches[106] = true
end

def startAvatarAssaultEvent3
    $game_switches[107] = true
    $game_switches[108] = true
end

def endAvatarAssaultEvent3
    $game_switches[108] = false
    $game_switches[109] = true
end