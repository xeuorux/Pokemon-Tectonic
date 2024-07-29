def checkBattleMonumentVictoryAchievements
    unlockAchievement(:WIN_BATTLE_MONUMENT)
    checkBattleMonumentAllSameGenerationAchievement
end

def checkBattleMonumentNoTribeOverlapVictoryAchievement
    return if playerTribalBonus.hasAnyTribeOverlap?
    unlockAchievement(:WIN_BATTLE_MONUMENT_NO_TRIBE_OVERLAP)
end

def checkBattleMonumentAllSameGenerationAchievement
    firstGeneration = $Trainer.party[0].species_data.generation
    return if $Trainer.party.any? { |partyMember| partyMember.species_data.generation != firstGeneration }
    unlockAchievement(:WIN_BATTLE_MONUMENT_ALL_SAME_GENERATION)
end