def triIslandNews?
    return $game_switches[12] && !$game_switches[97] # Tournament defeated, not yet had tri island cutscene
end

def startTriIslandCutscene
    $game_switches[154] = true # Display Tri Island unlock cutscene
end