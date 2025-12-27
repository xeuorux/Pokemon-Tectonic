SaveData.register_conversion(:vs_recorder_3_4_0) do
    game_version '3.4.0'
    display_title 'Adding the VS Recorder 3.4.0'
    to_all do |save_data|
        globalSwitches = save_data[:switches]
        globalVariables = save_data[:variables]
        selfSwitches = save_data[:self_switches]
        itemBag = save_data[:bag]
    
        itemBag.pbStoreItem(:VSRECORDER, 1, false)
    end
end