##############################################
# GENERATION REWARDS (40 of them)
##############################################

gen1Rewards = [[:EXPCANDYM,4],[:EXPCANDYM,8],[:EXPCANDYL,3],[:EXPCANDYL,4],[:EXPCANDYL,5],[:EXPCANDYL,6]]
gen1Thresholds = [14,23,36,58,94,151]

gen2Rewards = [[:EXPCANDYM,4],[:EXPCANDYM,8],[:EXPCANDYL,3],[:EXPCANDYL,4],[:EXPCANDYL,5]]
gen2Thresholds = [15,25,40,65,100]

gen3Rewards = gen1Rewards.clone
gen3Thresholds = [12,20,32,52,84,135]

gen4Rewards = gen2Rewards.clone
gen4Thresholds = [16,26,41,66,107]

gen5Rewards = gen1Rewards.clone
gen5Thresholds = [15,25,40,60,100,156]

gen6Rewards = [[:EXPCANDYM,4],[:EXPCANDYM,8],[:EXPCANDYL,3],[:EXPCANDYL,4]]
gen6Thresholds = [17,28,45,72]

gen7Rewards = gen6Rewards.clone
gen7Thresholds = [20,40,60,81]

gen8Rewards = gen6Rewards.clone
gen8Thresholds = [22,44,67,89]

generationRewardsHash = {
    gen1Thresholds => gen1Rewards,
    gen2Thresholds => gen2Rewards,
    gen3Thresholds => gen3Rewards,
    gen4Thresholds => gen4Rewards,
    gen5Thresholds => gen5Rewards,
    gen6Thresholds => gen6Rewards,
    gen7Thresholds => gen7Rewards,
    gen8Thresholds => gen8Rewards,
}

generationRewardsHash.each_with_index do |kvp,generationIndex|
    generationThresholds    = kvp[0]
    generationRewards       = kvp[1]
    realGeneration          = generationIndex + 1
    generationThresholds.each_with_index do |threshold,thresholdIndex|
        id = ("GEN" + realGeneration.to_s + "AWARD" + thresholdIndex.to_s).to_sym
        PokEstate::GrantAwards.add(id,
            proc { |pokedex|
                next generationReward(realGeneration,threshold,generationRewards[thresholdIndex])
            }
        )
    end
end

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
