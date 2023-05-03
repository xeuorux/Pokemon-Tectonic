def latentSoil
    pbMessage(_INTL("A patch of soil which is brimming with potential."))
    if $PokemonBag.pbHasItem?(:LATENTSEED)
        if pbConfirmMessage(_INTL("Plant a Latent Seed?"))
            $PokemonBag.pbDeleteItem(:LATENTSEED)
            $game_variables[31] += 1 # Latent Seeds planted
            return true
        else
            return false
        end
    end
    return false
end
