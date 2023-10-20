LARPER_COUNT_VAR = 29

def rescueLarper
    $game_variables[29] += 1
    if $game_variables[29] >= 3
        
        # Enable marshadow and cutscene in the catacombs
        pbSetSelfSwitch(4,'A',true,362)
        pbSetSelfSwitch(58,'A',true,362)
    end
end