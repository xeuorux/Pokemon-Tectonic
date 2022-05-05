SaveData.register_conversion(:pokestate_tracker) do
  game_version '1.6.1'
  display_title 'Adding PokEstate object to pre 1.6.1 saves.'
  to_all do |save_data|
    save_data[:pokestate_tracker] = PokEstate.new if !save_data.has_key?(:pokestate_tracker)
  end
end