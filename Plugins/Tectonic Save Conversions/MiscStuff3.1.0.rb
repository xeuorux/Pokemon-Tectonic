SaveData.register_conversion(:cobalion_moved_310) do
    game_version '3.1.0'
    display_title 'Making sure Cobalion does not reset'
    to_all do |save_data|
      globalVariables = save_data[:variables]
      selfSwitches = save_data[:self_switches]
  
      selfSwitches[[222,7,'A']] = selfSwitches[[122,2,'A']] # Avatar of Cobalion defeated
      selfSwitches[[122,2,'A']] = false
    end
end

  
SaveData.register_conversion(:amwi_berry_rename_310) do
  game_version '3.1.0'
  display_title 'Replacing all Amwi Berries with Cado Berries.'
  to_all do |save_data|
    bag = save_data[:bag]
    bag.pbChangeItem(:AMWIBERRY,:CADOBERRY)
    eachPokemonInSave(save_data) do |pokemon,_location|
      next unless pokemon.hasItem?(:AMWIBERRY)
      pokemon.removeItem(:AMWIBERRY)
      pokemon.giveItem(:CADOBERRY)
    end
  end
end


SaveData.register_conversion(:donation_boxes_310) do 
  game_version '3.1.0'
  display_title 'Adding Donation Boxes.'
  to_all do |save_data|
    storage = save_data[:storage_system]
    storage.addDonationBoxes()
  end
end