SaveData.register_conversion(:replace_busted_radio_220) do
  game_version '2.2.0'
  display_title 'Replacing all instances of Busted Radio with Hi-Vis Jacket'
  to_all do |save_data|
    bag = save_data[:bag]
    bag.pbChangeItem(:BUSTEDRADIO,:HIVISJACKET)
    eachPokemonInSave(save_data) do |pokemon|
      next unless pokemon.hasItem?(:BUSTEDRADIO)
      pokemon.removeItem(:BUSTEDRADIO)
      pokemon.giveItem(:HIVISJACKET)
    end
  end
end