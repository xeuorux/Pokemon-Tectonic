
SaveData.register_conversion(:global_switch_refactor_3_2_0) do
  game_version '3.2.0'
  display_title 'Setting global switches based on self-switches.'
  to_all do |save_data|
    globalSwitches = save_data[:switches]
    globalVariables = save_data[:variables]
    selfSwitches = save_data[:self_switches]
    itemBag = save_data[:bag]

    globalSwitches[201] = selfSwitches[[34,41,'B']] # Ansel active
    globalSwitches[202] = selfSwitches[[316,5,'A']] # Praveen active
    globalSwitches[203] = selfSwitches[[270,3,'B']] # Casey active
    globalSwitches[204] = selfSwitches[[165,33,'A']] # Vincent active
    globalSwitches[205] = selfSwitches[[265,3,'A']] # Chara active

    # Base the ironclad dojo stage on Scilla's switches
    ironDojoStage = 0
    ironDojoStage += 1 if selfSwitches[[206,3,'A']]
    ironDojoStage += 1 if selfSwitches[[206,3,'B']] 
    ironDojoStage += 1 if selfSwitches[[206,3,'C']] 
    ironDojoStage += 1 if selfSwitches[[206,3,'D']] 
    globalVariables[36] = ironDojoStage
  end
end
