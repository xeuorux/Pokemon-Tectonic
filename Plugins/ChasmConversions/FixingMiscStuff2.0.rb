SaveData.register_conversion(:misc_fixes_v2) do
  game_version '2.0.0'
  display_title 'Fixing a variety of save breaking changes for 2.0'
  to_all do |save_data|
    save_data[:bag].pbChangeItem(:MISTYSEED,:FAIRYSEED)

    # Change everyone to andro for safety
    charID = 2
    meta = GameData::Metadata.get_player(charID)
    save_data[:player].character_ID = charID
    save_data[:player].trainer_type = meta[0]
    save_data[:game_player].character_name = meta[1]
    save_data[:pokemon_system].gendered_look = charID
  end
end
