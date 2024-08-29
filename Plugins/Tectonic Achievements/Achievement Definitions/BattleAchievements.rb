def checkBattleStateAchievements(battle)
    checkWeatherRoomScreenAchievement(battle)
    checkManyHazardsAchievement(battle)
end

def checkWeatherRoomScreenAchievement(battle)
    return if battle.pbWeather == :None
    return unless battle.roomActive?
    playerSideScreen = false
    battle.sides[0].eachEffect(true) do |effect, value, effectData|
        next unless effectData.is_screen?
        playerSideScreen = true
        break
    end
    return unless playerSideScreen
    unlockAchievement(:BATTLE_ACTIVE_WEATHER_ROOM_SCREEN)
end

def checkManyHazardsAchievement(battle)
    opponentHazardCount = 0
    battle.sides[1].eachEffect(true) do |effect, value, effectData|
        next unless effectData.is_hazard?
        opponentHazardCount += 1
    end
    return unless opponentHazardCount >= 4
    unlockAchievement(:BATTLE_ACTIVE_MANY_HAZARDS)
end

Events.onStartBattle += proc {
    unlockAchievement(:ACHIEVE_TRIBAL_BONUS) if playerTribalBonus.hasAnyTribalBonus?
}

def checkUltimateFlexAchievement
    $Trainer.party.each do |partyMember|
        next unless partyMember.species == :SKITTY
        next unless partyMember.shiny?
        unlockAchievement(:DEFEAT_ZAIN_PRIZCA_WEST_SHINY_SKITTY)
    end
end