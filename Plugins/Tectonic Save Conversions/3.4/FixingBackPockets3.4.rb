SaveData.register_conversion(:item_repocketing_340) do
  game_version '3.4.0'
  display_title 'Reassigning bag pockets for 3.4.0 changes'
  to_all do |save_data|
    save_data[:bag].reassignPockets()
  end
end
