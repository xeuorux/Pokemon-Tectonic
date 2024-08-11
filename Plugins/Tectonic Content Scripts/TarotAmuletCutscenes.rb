TAROT_CUTSCENE_PROGRESS_GLOBAL = 39
PLAY_TAROT_AMULET_CUTSCENE_GLOBAL = 351
TAROT_CUTSCENE_PLAYED_AT_GYM_GLOBAL = 359

# gymIndex from 1 to 8
def checkTarotAmuletCutscene(gymIndex)
    return unless tarotAmuletActive?
    tarotCutScenePlayedGlobal = TAROT_CUTSCENE_PLAYED_AT_GYM_GLOBAL + (gymIndex - 1)
    if getGlobalSwitch(tarotCutScenePlayedGlobal)
        echoln("Tarot Amulet cutscene already played for this gym.")
        return
    end
    # Mark this gym as having been triggered already
    setGlobalSwitch(tarotCutScenePlayedGlobal)

    # Start the next cutscene in the sequence
    globalIDToEnable = PLAY_TAROT_AMULET_CUTSCENE_GLOBAL + getGlobalVariable(TAROT_CUTSCENE_PROGRESS_GLOBAL)
    setGlobalSwitch(globalIDToEnable)

    # Progress the cutscene progress
    incrementGlobalVar(TAROT_CUTSCENE_PROGRESS_GLOBAL)
end