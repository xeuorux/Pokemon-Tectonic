SaveData.register_conversion(:item_repocketing_190) do
  game_version '1.9.0'
  display_title 'Reassigning bag pockets for 1.9.0 changes'
  to_all do |save_data|
    save_data[:bag].reassignPockets()
  end
end
