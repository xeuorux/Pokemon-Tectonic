class PokeBattle_AI
    #=============================================================================
    # Decide whether the opponent should use an item on the Pokémon
    #=============================================================================
    def pbEnemyShouldUseItem?(idxBattler)
        return false
    end

    # NOTE: The AI will only consider using an item on the Pokémon it's currently
    #       choosing an action for.
    def pbEnemyItemToUse(idxBattler)
        return nil
    end
end
  