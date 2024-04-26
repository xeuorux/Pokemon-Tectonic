##############################################
# TYPE REWARDS (54 of them)
##############################################
typeThreshold = [10,25,50]
typeRewards = [[:EXPCANDYM,8],[:EXPCANDYL,4],[:EXPCANDYXL,2]]

PokEstate::LoadDataDependentAwards += proc {
    # For every type, create three award event subscribers at different thresholds
    GameData::Type.each do |type|
        next if type.pseudo_type
        next if type.id == :MUTANT
        typeThreshold.each_with_index do |threshold,thresholdIndex|
            id = ("TYPE" + type.id.to_s + "AWARD" + thresholdIndex.to_s).to_sym
            PokEstate::GrantAwards.add(id,
                proc { |pokedex|
                    next typeReward(type.id,threshold,typeRewards[thresholdIndex])
                }
            )
        end
    end
}

##############################################
# TRIBE REWARDS (66 of them)
##############################################
tribeThreshold = [10,20,40]
tribeRewards = [[:EXPCANDYM,6],[:EXPCANDYL,3],[:EXPCANDYL,6]]

PokEstate::LoadDataDependentAwards += proc {
    # For every type, create three award event subscribers at different thresholds
    GameData::Tribe.each do |tribe|
        tribeThreshold.each_with_index do |threshold,thresholdIndex|
            id = ("TRIBE" + tribe.id.to_s + "AWARD" + thresholdIndex.to_s).to_sym
            PokEstate::GrantAwards.add(id,
                proc { |pokedex|
                    next tribeReward(tribe.id,threshold,tribeRewards[thresholdIndex])
                }
            )
        end
    end
}

##############################################
# ROUTE REWARDS (23 of them)
##############################################
SMALL_ROUTES =
[
    136, # Casaba Villa
    138, # Scenic Trail
    30, # Windy Way
    51, # Foreclosed Tunnel
    26, # Bluepoint Grotto

    59, # Mainland Dock
    60, # Shipping Lane
    130, # Canal Desert

    3, # The Shift
    55, # Floral Rest
    11, # Eleig River Crossing
    7, # Wet Walkways

    186, # Frostflow Farms
    216, # Highland Lake

    193, # Volcanic Shore
    196, # Boiling Cave

    288, # Underground River
    218, # Abyssal Cavern
]

BIG_ROUTES = 
[
    38, # Bluepoint Beach
    53, # The Shelf
    301, # County Park
    185, # Eleig Stretch
    211, # Split Peaks
]

PokEstate::LoadDataDependentAwards += proc {   
    SMALL_ROUTES.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYM,8],_INTL("all species on #{routeName}")]
                end
                next
            }
        )
    end

    BIG_ROUTES.each do |routeID|
        routeName = pbGetMapNameFromId(routeID)
        id = ("ROUTE" + routeName + "AWARD").to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                if pokedex.allOwnedFromRoute?(routeID)
                    next [[:EXPCANDYL,3],_INTL("all species on #{routeName}")]
                end
                next
            }
        )
    end
}
