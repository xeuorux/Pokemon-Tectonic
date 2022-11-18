def rollCredits
    pbWait(20)
    properlySave
    $PokemonGlobal.creditsPlayed = false
    $scene = Scene_Credits.new(callback)
end