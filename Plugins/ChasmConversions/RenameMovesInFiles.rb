SaveData.register_conversion(:move_renaming_0) do
  game_version '9.9.9'
  display_title 'Changing move names in Pokemon'
  to_all do |save_data|
    echoln("Checking for needed move renames!")
    renameAllSavedMovesInBatch(save_data,0)
  end
end

def renameAllSavedMovesInBatch(save_data,batch_number)
  move_renames = getRenamedMovesBatch(batch_number)
  save_data[:player].party.each do |pokemon|
    pokemon.moves.map! { |move|
      if MOVE_RENAMES.has_key?(move)
        echoln("Renaming #{move} on player's #{pokemon.name}")
        next MOVE_RENAMES[move][0]
      else
        next move
      end
    }
  end 
  storage = save_data[:storage_system]
  
  for i in -1...storage.maxBoxes
    for j in 0...storage.maxPokemon(i)
      pokemon = storage.boxes[i][j]
      if pokemon
        pokemon.moves.map! { |move|
          if MOVE_RENAMES.has_key?(move)
            echoln("Renaming #{move} on player's #{pokemon.name}")
            next MOVE_RENAMES[move][0]
          else
            next move
          end
        }
      end
    end
  end
end