SaveData.register_conversion(:extra_condensed_light_2_3) do
  game_version '2.3.0'
  display_title 'Adding a condensed light if already perfected Psychic Felicia'
  to_all do |save_data|
	selfSwitches = save_data[:self_switches]
    save_data[:bag].pbStoreItem(:CONDENSEDLIGHT, 1, false) if selfSwitches[[257,11,'D']]
  end
end

SaveData.register_conversion(:oran_berry_rename_2_3) do
  game_version '2.3.0'
  display_title 'Replacing all Oran Berries with Amwi Berries.'
  to_all do |save_data|
    bag = save_data[:bag]
    bag.pbChangeItem(:ORANBERRY,:AMWIBERRY)
    eachPokemonInSave(save_data) do |pokemon|
      next unless pokemon.hasItem?(:ORANBERRY)
      pokemon.removeItem(:ORANBERRY)
      pokemon.giveItem(:AMWIBERRY)
    end
  end
end
