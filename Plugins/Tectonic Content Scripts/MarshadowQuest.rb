LARPER_COUNT_VAR = 29
CATACOMBS_B3_MAP_ID = 362

def rescueLarper
    $game_variables[LARPER_COUNT_VAR] += 1
    if $game_variables[LARPER_COUNT_VAR] >= 3
        
        # Enable marshadow and cutscene in the catacombs
        pbSetSelfSwitch(4,'A',true,CATACOMBS_B3_MAP_ID)
        pbSetSelfSwitch(58,'A',true,CATACOMBS_B3_MAP_ID)
    end
end