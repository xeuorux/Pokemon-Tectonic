class PokeBattle_Battler
    #=============================================================================
    # Mega Evolution, Primal Reversion, Shadow Pokémon
    #=============================================================================
    def hasMega?
        return false if effectActive?(:Transform)
        return @pokemon&.hasMegaForm?
    end

    def mega?
        return @pokemon&.mega?
    end
    alias isMega? mega?

    def hasPrimal?
        return false if effectActive?(:Transform)
        return @pokemon&.hasPrimalForm?
    end

    def primal?
        return @pokemon&.primal?
    end
    alias isPrimal? primal?

    def shadowPokemon?
        return false
    end
    alias isShadow? shadowPokemon?

    def inHyperMode?
        return false
    end
end
