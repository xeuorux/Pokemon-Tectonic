SaveData.register_conversion(:cobalion_moved_305) do
    game_version '3.0.5'
    display_title 'Making sure Cobalion does not reset'
    to_all do |save_data|
      globalVariables = save_data[:variables]
      selfSwitches = save_data[:self_switches]
  
      selfSwitches[[222,7,'A']] = selfSwitches[[122,2,'A']] # Avatar of Cobalion defeated
      selfSwitches[[122,2,'A']] = false
    end
  end