def latentSoil
    pbMessage(_INTL("A patch of soil which is brimming with potential."))
    if $PokemonBag.pbHasItem?(:LATENTSEED)
        if pbConfirmMessage(_INTL("Plant a Latent Seed?"))
            $PokemonBag.pbDeleteItem(:LATENTSEED)
            $game_variables[31] += 1 # Latent Seeds planted
            pbMessage(_INTL("Right as you push the seed into the soil, a sapling bursts out of it!"))
            pbSEPlay("Anim/PRSFX- Growth",60,110)
            return true
        else
            return false
        end
    end
    return false
end
