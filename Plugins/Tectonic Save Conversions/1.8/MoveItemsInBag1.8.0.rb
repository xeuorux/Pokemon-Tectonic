SaveData.register_conversion(:item_repocketing_180) do
  game_version '1.8.0'
  display_title 'Reassigning bag pockets for 1.8.0 changes'
  to_all do |save_data|
    save_data[:bag].reassignPockets()
  end
end
