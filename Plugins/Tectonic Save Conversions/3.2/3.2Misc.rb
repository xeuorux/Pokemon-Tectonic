
SaveData.register_conversion(:misc_fixes_3_2_0) do
    game_version '3.2.0'
    display_title 'Fixing misc. stuff'
    to_all do |save_data|
        globalSwitches = save_data[:switches]
        globalVariables = save_data[:variables]
        selfSwitches = save_data[:self_switches]
        itemBag = save_data[:bag]
    
        itemBag.pbChangeItem(:ZYGARDECUBE,:CELLBOOSTER)
        itemBag.pbStoreItem(:RUSTEDCOMPASS) if globalSwitches[130] # Defeated Avatars of Zacian and Zamazenta
        itemBag.pbStoreItem(:SOOTHECHARM) if selfSwitches[[7,39,'A']]
        itemBag.pbStoreItem(:MAGNETICGAUNTLET) if globalSwitches[126] # Defeated Avatar of Zeraora
        itemBag.pbStoreItem(:POKEXRAY) if selfSwitches[[136,2,'A']] # Talked to Professor Tamarind on Casaba Villa dock
        globalSwitches[251] = true if selfSwitches[[219,2,'A']]

        # Rename Rain to Rainstorm
        renameHash = {}
        renameHash["RAIN"] = ["RAINSTORM"]
        eachPokemonInSave(save_data) do |pokemon,_location|
            renameMovesOnPokemon(pokemon, renameHash)
        end

        # Switch donation boxes to new graphic
        storage = save_data[:storage_system]

        index = 1
        for i in 0...storage.maxBoxes
            next unless storage.boxes[i].isDonationBox?
            storage.boxes[i].background = "donation"
            storage.boxes[i].name = _INTL("Donation Box {1}",index)
            index += 1
        end
    end
end