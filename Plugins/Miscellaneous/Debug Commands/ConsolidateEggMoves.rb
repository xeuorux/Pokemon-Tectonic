DebugMenuCommands.register("consolidateeggmoves", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Consolidate Egg Moves"),
  "description" => _INTL("For every tutor move that a whole line shares, move it into the egg moves list of the lowest stage pokemon instead."),
  "effect"      => proc { |sprites, viewport|
    GameData::Species.each do |species_data|
      # Only look at pokemon that are the base of an evolutionary line
      next if species_data.get_prevolutions().length > 0
      next if species_data.get_evolutions().length == 0

      # Get the list of all pokemon in that line
      evolutions = getEvosInLineAsList(species_data)
      
      # Create the list of tutor moves that every evo learns
      sharedTutorMoves = []
      species_data.tutor_moves.each do |tutorMove|
        includedInAll = true
        evolutions.each do |evoLineSpecies|
          evoLineSpeciesData = GameData::Species.get(evoLineSpecies)
          includedInAll = false if !evoLineSpeciesData.tutor_moves.include?(tutorMove)
        end
        sharedTutorMoves.push(tutorMove) if includedInAll
      end

      echoln("The evolutionary line starting with #{species_data.id} shares these tutor moves: #{sharedTutorMoves.to_s}")

      fullLine = evolutions.clone
      fullLine.push(species_data.id) # This might be unneccessary, not sure if its there already
      sharedTutorMoves.each do |sharedTutorMove|
        species_data.egg_moves.push(sharedTutorMove)

        fullLine.each do |lineSpecies|
          lineSpeciesData = GameData::Species.get(lineSpecies)
          lineSpeciesData.tutor_moves.delete(sharedTutorMove)
        end
      end

      species_data.egg_moves.uniq!
      species_data.egg_moves.compact!
      fullLine.each do |lineSpecies|
        lineSpeciesData = GameData::Species.get(lineSpecies)
        lineSpeciesData.tutor_moves.uniq!
        lineSpeciesData.tutor_moves.compact!
      end
    end

    GameData::Species.save
    Compiler.write_pokemon
    Compiler.write_pokemon_forms

    pbMessage(_INTL("Tutor moves consolidated!"))
  }
})
