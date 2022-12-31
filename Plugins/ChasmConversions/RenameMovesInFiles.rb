SaveData.register_conversion(:move_renaming_0) do
  game_version '1.6.3'
  display_title '1.6.3 move renames'
  to_all do |save_data|
    renameAllSavedMovesInBatch(save_data,0)
  end
end

SaveData.register_conversion(:move_renaming_0) do
  game_version '2.0.1'
  display_title '2.0.1 move renames'
  to_all do |save_data|
    renameAllSavedMovesInBatch(save_data,1)
  end
end

def renameAllSavedMovesInBatch(save_data,batch_number)
  move_renames = getRenamedMovesBatch(batch_number)
  eachPokemonInSave(save_data) do |pokemon|
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

def downgradeSaveTo20()
  save_data = SaveData.get_data_from_file(SaveData::FILE_PATH)
  save_data[:game_version] = "2.0.0"
  File.open(SaveData::FILE_PATH, 'wb') { |file| Marshal.dump(save_data, file) }
end