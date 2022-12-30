LEVEL_CAPS_USED = true
LEVEL_CAP_VAR = 26
MAX_LEVEL_CAP = 70

def increaseLevelCap(increase)
    return unless LEVEL_CAPS_USED
    setLevelCap($game_variables[LEVEL_CAP_VAR] + increase)
end

def setLevelCap(newCap)
    return unless LEVEL_CAPS_USED
    $game_variables[LEVEL_CAP_VAR] = newCap
    pbMessage(_INTL("\\wmLevel cap raised to {1}!\\me[Bug catching 3rd]\\wtnp[80]\1", newCap))
end

def levelCapMaxed?
    return $game_variables[LEVEL_CAP_VAR] >= MAX_LEVEL_CAP
end

def getLevelCap
    return $game_variables[LEVEL_CAP_VAR]
end
