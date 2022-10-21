class PokeBattle_Battler
    #=============================================================================
    # Mega Evolution, Primal Reversion, Shadow Pokémon
    #=============================================================================
    def hasMega?
        return false if @effects[PBEffects::Transform]
        return @pokemon && @pokemon.hasMegaForm?
    end

    def mega?; return @pokemon && @pokemon.mega?; end
    alias isMega? mega?

    def hasPrimal?
        return false if @effects[PBEffects::Transform]
        return @pokemon && @pokemon.hasPrimalForm?
    end

    def primal?; return @pokemon && @pokemon.primal?; end
    alias isPrimal? primal?

    def shadowPokemon?; return false; end
    alias isShadow? shadowPokemon?

    def inHyperMode?; return false; end
end