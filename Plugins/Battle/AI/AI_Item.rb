class PokeBattle_AI
    #=============================================================================
    # Decide whether the opponent should use an item on the Pokémon
    #=============================================================================
    def pbEnemyShouldUseItem?(_idxBattler)
        return false
    end

    # NOTE: The AI will only consider using an item on the Pokémon it's currently
    #       choosing an action for.
    def pbEnemyItemToUse(_idxBattler)
        return nil
    end
end
