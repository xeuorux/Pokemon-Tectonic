SaveData.register_conversion(:move_renaming_0) do
    game_version '2.1.0'
    display_title '2.1.0 move removals'
    to_all do |save_data|
      eachPokemonInSave(save_data) do |pokemon|
        pokemon.moves.map! { |move|
            move_id = move.id
            if !valid_move?(move_id)
                echoln("Removing #{move_id} on player's #{pokemon.species}")
                nil
            else
                move
            end
        }
        pokemon.moves.compact!
        pokemon.first_moves.map! { |move_id|
            if !valid_move?(move_id)
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

def valid_move?(move_id)
    return false unless GameData::Move.exists?(move_id)
    number = GameData::Move.get(move_id).id_number
    return false if number >= 2000 && number < 3000
    return true
end