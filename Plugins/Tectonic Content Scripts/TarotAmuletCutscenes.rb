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

def addLightnessOverlay(overFrames = 40)
    newSprite = DarknessSprite.new(viewport: Spriteset_Map.viewport, color: Color.new(255,255,255,200),numFades: 20, radius: 360, innerRadius: 64, diminishmentMult: 0.85, opacityMult: 0.0)
    $PokemonTemp.darknessSprite = newSprite
    $scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
    overFrames.times do |i|
        $PokemonTemp.darknessSprite.opacityMult = (i / overFrames.to_f) if i % 5 == 0
        pbWait(1)
    end
    $PokemonTemp.darknessSprite.opacityMult = 1.0
    pbWait(1)
end

def removeLightnessOverlay(overFrames = 40)
    return unless $PokemonTemp.darknessSprite
    startingRadius = $PokemonTemp.darknessSprite.radius
    overFrames.times do |i|
        $PokemonTemp.darknessSprite.opacityMult = 1 - (i / overFrames.to_f) if i % 5 == 0
        pbWait(1)
    end
    $PokemonTemp.darknessSprite.dispose
    $PokemonTemp.darknessSprite = nil
end