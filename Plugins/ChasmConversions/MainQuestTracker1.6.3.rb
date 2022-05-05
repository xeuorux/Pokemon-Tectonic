SaveData.register_conversion(:main_quest_tracker_conversion) do
  game_version '1.6.3'
  display_title 'Adding MainQuestTracker to pre 1.6.3 saves.'
  to_all do |save_data|
    save_data[:main_quest_tracker] = MainQuestTracker.new if !save_data.has_key?(:main_quest_tracker)
  end
end