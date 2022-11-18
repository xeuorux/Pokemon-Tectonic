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