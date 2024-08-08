SWORDS_OF_JUSTICE_DEFEATED_VAR = 30

def progressSwordsOfJusticeQuest
    incrementGlobalVar(SWORDS_OF_JUSTICE_DEFEATED_VAR)
    return unless getGlobalVariable(SWORDS_OF_JUSTICE_DEFEATED_VAR) == 3
    currentBGM = $game_system.playing_bgm
    pbBGMFade(1.0)
    pbWait(Graphics.frame_rate)
    pbMessage(_INTL("\\wmThe words of a poem appear in your mind."))
    pbMessage(_INTL("\\ss\\wm\"Watchful eye, a towering sight.\""))
    pbMessage(_INTL("\\ss\\wm\"Budding hope, with 3-fold might.\""))
    pbMessage(_INTL("\\ss\\wm\"We await you, o slayer...\""))
    pbWait(Graphics.frame_rate)
    pbBGMPlay(currentBGM)
end