def startTournamentIfValid
    if hasAllEightBadges? && defeatedYezeraWhitebloom? && !$game_switches[12] # Won Championship
        $game_switches[64] = true # Tournament Running
    end
end

def defeatedYezeraWhitebloom?
    defeated = pbGetSelfSwitch(17, 'B', 258)
    echoln("Has the player defeated Yezera in Whitebloom? #{defeated}")
    return defeated
end

def rollCredits
    pbWait(20)
    oldScene = $scene
    $PokemonGlobal.creditsPlayed = false
    callback = proc {
        $scene = oldScene
        properlySave
    }
    $scene = Scene_Credits.new(callback)
end