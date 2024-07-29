Events.onMapLoadIn += proc { |_sender,_e|
    mapID = $game_map.map_id

    next unless $PokEstate.isInEstate?
    currentBox = $PokEstate.estate_box
    next unless $PokemonStorage[currentBox].full?

    unlockAchievement(:FILL_ENTIRE_POKESTATE_PLOT)
}

def incrementSuccessfulCaptureCount(ball)
    $PokemonGlobal.capture_counts_per_ball = {} if $PokemonGlobal.capture_counts_per_ball.nil?
    if $PokemonGlobal.capture_counts_per_ball.key?(ball)
        $PokemonGlobal.capture_counts_per_ball[ball] += 1
    else
        $PokemonGlobal.capture_counts_per_ball[ball] = 1
    end
    checkForCapturesWithBallsAchievements
end

def checkForCapturesWithBallsAchievements
    checkForCapturesWithAestheticBallsAchievement
    checkForCapturesWithFailureEffectBallsAchievement
end

def checkForCapturesWithAestheticBallsAchievement
    counts = $PokemonGlobal.capture_counts_per_ball
    return unless counts.key?(:PREMIERBALL)
    return unless counts.key?(:ROYALBALL)
    return unless counts.key?(:CHERISHBALL)
    unlockAchievement(:CAPTURE_WITH_ALL_AESTHETIC_BALLS)
end

def checkForCapturesWithFailureEffectBallsAchievement
    counts = $PokemonGlobal.capture_counts_per_ball
    return unless counts.key?(:POTIONBALL)
    return unless counts.key?(:SLICEBALL)
    return unless counts.key?(:LEECHBALL)
    return unless counts.key?(:DISABLEBALL)
    unlockAchievement(:CAPTURE_WITH_ALL_FAILURE_EFFECT_BALLS)
end

def checkForCaptureAchievements(ball, battle, pkmn)
    return unless %i[POKEBALL BALLLAUNCHER].include?(ball)
    return unless pkmn.species_data.isLegendary?
    unlockAchievement(:CAPTURE_LEGENDARY_BASIC_BALL)
end