SaveData.register_conversion(:item_repocketing_300) do
  game_version '3.0.0'
  display_title 'Reassigning bag pockets for 3.0.0 changes'
  to_all do |save_data|
    save_data[:bag].reassignPockets()
  end
end
