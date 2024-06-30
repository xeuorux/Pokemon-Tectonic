
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

      # Rename Rain to Rainstorm
      renameHash = {}
      renameHash["RAIN"] = ["RAINSTORM"]
      eachPokemonInSave(save_data) do |pokemon,_location|
        renameMovesOnPokemon(pokemon, renameHash)
      end
    end
  end
  