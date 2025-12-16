SaveData.register_conversion(:poh_quest_conversion) do
  game_version '3.4.0'
  display_title 'Initializing the Player Owned House quest global variable'
  to_all do |save_data|
    globalSwitches = save_data[:switches]
    globalVariables = save_data[:variables]
    selfSwitches = save_data[:self_switches]

    pohQuestStage = 0
    pohQuestStage += 1 if selfSwitches[[231,1,'B']] # Bought the house
    pohQuestStage += 1 if selfSwitches[[207,12,'B']] # Basic ammenities
    pohQuestStage += 1 if selfSwitches[[207,12,'C']] # Upgrades added
    globalVariables[PLAYER_OWNED_HOUSE_QUEST_GLOBAL_VAR] = pohQuestStage
  end
end