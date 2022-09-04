SaveData.register_conversion(:move_renaming_0) do
  game_version '1.6.3'
  display_title '1.6.3 move renames'
  to_all do |save_data|
    renameAllSavedMovesInBatch(save_data,0)
  end
end

def renameAllSavedMovesInBatch(save_data,batch_number)
  move_renames = getRenamedMovesBatch(batch_number)
  save_data[:player].party.each do |pokemon|
    newMoves = []
    pokemon.moves.map! { |move|
      moveIDString = move.id.to_s
      if move_renames.has_key?(moveIDString)
        echoln("Renaming #{move} on player's #{pokemon.name}")
        Pokemon::Move.new(move_renames[moveIDString][0].to_sym)
      else
        move
      end
    }
  end 
  storage = save_data[:storage_system]
  
  for i in -1...storage.maxBoxes
    for j in 0...storage.maxPokemon(i)
      pokemon = storage.boxes[i][j]
      if pokemon
        pokemon.moves.map! { |move|
          moveIDString = move.id.to_s
          if move_renames.has_key?(moveIDString)
            echoln("Renaming #{moveIDString} on player's #{pokemon.name}")
            Pokemon::Move.new(move_renames[moveIDString][0].to_sym)
          else
            move
          end
        }
        pokemon.first_moves.map! { |move_id|
          moveIDString = move_id.to_s
          if move_renames.has_key?(moveIDString)
            echoln("Renaming #{moveIDString} on player's #{pokemon.name}'s first moves array")
            move_renames[moveIDString][0].to_sym
          else
            move_id
          end
        }
      end
    end
  end
end