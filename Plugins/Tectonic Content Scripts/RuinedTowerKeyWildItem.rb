Events.onWildPokemonCreate += proc {|sender,e|
    next if pbHasItem?(:RUINEDTOWERKEY)
    pokemon = e[0]
    chance = 1
    chance *= 5 if [
        258, # Whitebloom Town
        216, # Highland Lake
        288, # Underground River
        218, # Abyssal Cavern
        186, # Frostflow Farms
        11, # Eleig River Crossing
        185, # Eleig Stretch
        130, # Canal Desert
        316, # Sandstone Estuary
    ].include?($game_map.map_id)
    chance *= 2 if pokemon.hasType?(:FLYING)
    chance *= 2 if getLevelCap >= 20
    chance *= 2 if getLevelCap >= 35
    chance *= 2 if getLevelCap >= 50

    chance *= 2 if herdingActive?
    next unless rand(1000) < chance
    pokemon.setItems([:RUINEDTOWERKEY])
}