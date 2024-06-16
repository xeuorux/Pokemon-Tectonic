
SaveData.register_conversion(:misc_fixes_3_2_0) do
    game_version '3.2.0'
    display_title 'Fixing misc. stuff'
    to_all do |save_data|
      globalSwitches = save_data[:switches]
      globalVariables = save_data[:variables]
      selfSwitches = save_data[:self_switches]
      itemBag = save_data[:bag]
  
      itemBag.pbChangeItem(:ZYGARDECUBE,:CELLBOOSTER)
      itemBag.pbStoreItem(:RUSTEDCOMPASS) if globalSwitches[130]
    end
  end
  