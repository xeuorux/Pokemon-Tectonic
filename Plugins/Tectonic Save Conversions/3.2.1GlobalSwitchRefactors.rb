SaveData.register_conversion(:global_switch_refactor_3_2_1) do
    game_version '3.2.1'
    display_title '3.2.1 global switch refactor.'
    to_all do |save_data|
        globalSwitches = save_data[:switches]

        # phone calls
        globalSwitches[226] = globalSwitches[61] # 4th badge call
        globalSwitches[227] = globalSwitches[62] # Climbing Gear Call
        globalSwitches[228] = globalSwitches[54] # 8th badge call
        globalSwitches[229] = globalSwitches[153] # battle monument call
        globalSwitches[230] = globalSwitches[66] # battle monument call
        globalSwitches[231] = globalSwitches[67] # battle monument call
        globalSwitches[232] = globalSwitches[226] # dr hekata phone call

        # docks and islands
        globalSwitches[301] = globalSwitches[70] # Eleig Boating Dock Unlocked
        globalSwitches[302] = globalSwitches[71] # Sweetrock Dock Unlocked
        globalSwitches[303] = globalSwitches[81] # Guardian Island
        globalSwitches[304] = globalSwitches[84] # Eventide Isle
        globalSwitches[305] = globalSwitches[86] # Isle of Dragons
        globalSwitches[306] = globalSwitches[97] # Tri Island
        globalSwitches[307] = globalSwitches[99] # Battle Monument
        globalSwitches[308] = globalSwitches[151] # Spirit Atoll

        # map added elements
        globalSwitches[326] = globalSwitches[52] # Volcanic Shore
        globalSwitches[327] = globalSwitches[51] # Underground River
        globalSwitches[328] = globalSwitches[50] # Tempest Realm
        globalSwitches[329] = globalSwitches[55] # Guardian Island
        globalSwitches[330] = globalSwitches[85] # Eventide Isle
        globalSwitches[331] = globalSwitches[87] # Isle of Dragons
        globalSwitches[332] = globalSwitches[98] # Tri Island
        globalSwitches[333] = globalSwitches[100] # Battle Monument
        globalSwitches[334] = globalSwitches[152] # Spirit Atoll
    end
end