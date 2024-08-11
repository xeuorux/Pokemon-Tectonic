TAROT_CUTSCENE_PROGRESS_GLOBAL = 39
PLAY_TAROT_AMULET_CUTSCENE_GLOBAL = 351
TAROT_CUTSCENE_PLAYED_AT_GYM_GLOBAL = 359

# gymIndex from 1 to 8
def checkTarotAmuletCutscene(gymIndex)
    return unless tarotAmuletActive?
    tarotCutScenePlayedGlobal = TAROT_CUTSCENE_PLAYED_AT_GYM_GLOBAL + (gymIndex - 1)
    return if getGlobalSwitch(tarotCutScenePlayedGlobal)
    tarotIndex = getGlobalVariable(TAROT_CUTSCENE_PROGRESS_GLOBAL) + gymIndex
    globalIDToEnable = PLAY_TAROT_AMULET_CUTSCENE_GLOBAL + tarotIndex
    setGlobalSwitch(tarotCutScenePlayedGlobal)
    setGlobalSwitch(globalIDToEnable)
    incrementGlobalVar(TAROT_CUTSCENE_PROGRESS_GLOBAL)
end