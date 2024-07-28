def checkBattleMonumentVictoryAchievements
    unlockAchievement(:WIN_BATTLE_MONUMENT)
    checkBattleMonumentNoTribeOverlapVictoryAchievement
end

def checkBattleMonumentNoTribeOverlapVictoryAchievement
    tribesPresent = []
    return if playerTribalBonus.hasAnyTribeOverlap?
    unlockAchievement(:WIN_BATTLE_MONUMENT)
end