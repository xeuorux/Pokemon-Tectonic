SaveData.register_conversion(:spawning_regis_21) do
  game_version '2.1.0'
  display_title 'Setting the global switches for regi freedom and larpers in 2.1'
  to_all do |save_data|
    globalSwitches = save_data[:switches]
    selfSwitches = save_data[:self_switches]

    # Regirock is freed when villain 1 is defeated or traitorized
    globalSwitches[72] = globalSwitches[65] || globalSwitches[57]

    # Regice is freed when villain 2 is defeated or traitorized
    globalSwitches[73] = selfSwitches[[309,6,'B']] || globalSwitches[58]

    # Registeel is freed when sang 2 is defeated
    globalSwitches[74] = selfSwitches[[212,52,'D']]

    # Regieleki and regidrago are freed when yezera 5 is defeated
    globalSwitches[75] = globalSwitches[76] = selfSwitches[[258, 17, 'B']]

    # Larpers are defeated in the vibrant cave
    globalSwitches[53] = selfSwitches[[126, 6, 'D']]
  end
end
