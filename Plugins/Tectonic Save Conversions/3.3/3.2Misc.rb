SaveData.register_conversion(:new_boss_loot_3_3_0) do
    game_version '3.3.0'
    display_title 'Adding new boss loot 3.3.0'
    to_all do |save_data|
        globalSwitches = save_data[:switches]
        globalVariables = save_data[:variables]
        selfSwitches = save_data[:self_switches]
        itemBag = save_data[:bag]
    
        itemBag.pbStoreItem(:VIPCARD) if globalSwitches[127] # Defeated Avatar of Meloetta
        itemBag.pbStoreItem(:OMINOUSEGG) if globalSwitches[129] # Defeated Avatar of Yveltal
        itemBag.pbStoreItem(:CHROMACLARION) if globalSwitches[131] # Defeated Avatar of Xerneas
    end
end