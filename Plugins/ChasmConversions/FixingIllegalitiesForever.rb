SaveData.register_conversion(:fix_pokemon_illegalities) do
    game_version Settings::GAME_VERSION
    display_title 'Finding and fixing illegal elements on all owned Pokemon.'
    to_all do |save_data|
      removeIllegalElementsFromAllPokemon(save_data)
    end
  end

  def removeIllegalElementsFromAllPokemon(save_data)
    eachPokemonInSave(save_data) do |pokemon, location|
      #echoln("#{pokemon.name} learnable moves: #{pokemon.learnable_moves(false).to_s}")
      #echoln("#{pokemon.name} legal abilities: #{pokemon.species_data.legalAbilities.to_s}")
  
      name = pokemon.name
      name = "#{name} (#{pokemon.species_data.name})" if pokemon.nicknamed?
  
      # Find and remove illegal moves
      pokemon.moves.each do |move|
        next if move.nil?
        moveID = move.id
        
        remove = false
  
        moveData = GameData::Move.get(moveID)
        if !moveData.learnable? && !(pokemon.species == :SMEARGLE && moveData.primeval)
          pbMessage(_INTL("\\l[4]Pokemon #{name} in #{location} has move #{moveData.name} in its move list. That move has been cut from the game or is not legal to learn. Removing now."))
          remove = true
        end
  
        unless pokemon.learnable_moves(false).include?(moveID) && pokemon.species != :SMEARGLE
          pbMessage(_INTL("\\l[4]Pokemon #{name} in #{location} has move #{moveData.name} in its move list. That move is not legal for its species. Removing now."))
          remove = true
        end
  
        if remove
          pokemon.forget_move(moveID)
          pokemon.remove_first_move(moveID)
        end
      end
  
      # Find and fix illegal abilities
      unless pokemon.species_data.legalAbilities.include?(pokemon.ability_id)
        oldAbilityName = pokemon.ability.name
        pokemon.recalculateAbilityFromIndex
        newAbilityName = pokemon.ability.name
        pbMessage(_INTL("\\l[4]Pokemon #{name} in #{location} has ability #{oldAbilityName}. That ability is not legal for its species. Switching to #{newAbilityName}."))
      end
  
      # Check and remove illegal items
      pokemon.items.clone.each do |item|
        itemData = GameData::Item.get(item)
        next if itemData.legal?
        pbMessage(_INTL("\\l[4]Pokemon #{name} in #{location} has item #{itemData.name}. That item has been cut from the game or is not legal to own. Removing now."))
        pokemon.removeItem(item)
      end
    end
  rescue StandardError
    pbMessage(_INTL("An error occured while checking for the legality of your party."))
    pbPrintException($!)
  end