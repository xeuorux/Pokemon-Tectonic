MOVES_REMOVED_112 = [:DISPLACE,:MESMERIZE,:COYGAZE,:MAJESTICGLARE]

SaveData.register_conversion(:move_renaming_0) do
  game_version '1.12.0'
  display_title '1.12.0 move removals'
  to_all do |save_data|
    eachPokemonInSave(save_data) do |pokemon|
      pokemon.moves.map! { |move|
        moveID = move.id
        if MOVES_REMOVED_112.include?(moveID)
          echoln("Removing #{moveID} on player's #{pokemon.species}")
          nil
        else
          move
        end
      }
      pokemon.moves.compact!
      pokemon.first_moves.map! { |move_id|
        if MOVES_REMOVED_112.include?(move_id)
          echoln("Removing #{move_id} on player's #{pokemon.species}'s first moves array")
          nil
        else
          move_id
        end
      }
      pokemon.first_moves.compact!
    end
  end
end