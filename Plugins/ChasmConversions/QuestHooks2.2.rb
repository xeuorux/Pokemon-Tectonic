SaveData.register_conversion(:spawning_swords_22) do
  game_version '2.2.0'
  display_title 'Setting the global variable for swords of justice defeated in 2.2'
  to_all do |save_data|
    globalVariables = save_data[:variables]
    selfSwitches = save_data[:self_switches]

    globalVariables[30] = 0
    globalVariables[30] += 1 if selfSwitches[[11,28,'A']] # Avatar of Terrakion defeated
    globalVariables[30] += 1 if selfSwitches[[122,2,'A']] # Avatar of Cobalion defeated
    globalVariables[30] += 1 if selfSwitches[[211,3,'A']] # Avatar of Virizion defeated
  end
end