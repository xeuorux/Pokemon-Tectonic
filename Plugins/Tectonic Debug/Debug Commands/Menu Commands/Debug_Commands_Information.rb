DebugMenuCommands.register("setmetadata", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Metadata"),
    "description" => _INTL("Edit global and map metadata."),
    "always_show" => true,
    "effect"      => proc {
      pbMetadataScreen(pbDefaultMap)
    }
  })

  DebugMenuCommands.register("addfalsemetadata", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Add false metadata"),
    "description" => _INTL("For the important first 3 entries of map metadata, add false where there is nil."),
    "effect"      => proc {
      GameData::MapMetadata.each do |map_metadata|
        metadata_hash = {
          :id                   => map_metadata.id,
          :outdoor_map          => map_metadata.outdoor_map,
          :announce_location    => map_metadata.announce_location,
          :can_bicycle          => map_metadata.can_bicycle,
          :always_bicycle       => map_metadata.always_bicycle,
          :teleport_destination => map_metadata.teleport_destination,
          :weather              => map_metadata.weather,
          :town_map_position    => map_metadata.town_map_position,
          :dive_map_id          => map_metadata.dive_map_id,
          :dark_map             => map_metadata.dark_map,
          :safari_map           => map_metadata.safari_map,
          :snap_edges           => map_metadata.snap_edges,
          :random_dungeon       => map_metadata.random_dungeon,
          :battle_background    => map_metadata.battle_background,
          :wild_battle_BGM      => map_metadata.wild_battle_BGM,
          :trainer_battle_BGM   => map_metadata.trainer_battle_BGM,
          :wild_victory_ME      => map_metadata.wild_victory_ME,
          :trainer_victory_ME   => map_metadata.trainer_victory_ME,
          :wild_capture_ME      => map_metadata.wild_capture_ME,
          :town_map_size        => map_metadata.town_map_size,
          :battle_environment   => map_metadata.battle_environment
        }
        metadata_hash[:outdoor_map] = false if metadata_hash[:outdoor_map].nil?
        metadata_hash[:announce_location] = false if metadata_hash[:announce_location].nil?
        metadata_hash[:can_bicycle] = false if metadata_hash[:can_bicycle].nil?
        # Add metadata's data to records
        GameData::MapMetadata.register(metadata_hash)
        GameData::MapMetadata.save
      end
      Compiler.write_metadata
    }
  })
  
  DebugMenuCommands.register("mapconnections", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Map Connections"),
    "description" => _INTL("Connect maps using a visual interface. Can also edit map encounters/metadata."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbConnectionsEditor }
    }
  })
  
  DebugMenuCommands.register("terraintags", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Terrain Tags"),
    "description" => _INTL("Edit the terrain tags of tiles in tilesets. Required for tags 8+."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbTilesetScreen }
    }
  })
  
  DebugMenuCommands.register("setencounters", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Wild Encounters"),
    "description" => _INTL("Edit the wild Pokémon that can be found on maps, and how they are encountered."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbEncountersEditor }
    }
  })
  
  DebugMenuCommands.register("trainertypes", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Trainer Types"),
    "description" => _INTL("Edit the properties of trainer types."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbTrainerTypeEditor }
    }
  })
  
  DebugMenuCommands.register("edittrainers", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Individual Trainers"),
    "description" => _INTL("Edit individual trainers, their Pokémon and items."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbTrainerBattleEditor }
    }
  })
  
  DebugMenuCommands.register("edititems", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Items"),
    "description" => _INTL("Edit item data."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbItemEditor }
    }
  })
  
  DebugMenuCommands.register("editpokemon", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Pokémon"),
    "description" => _INTL("Edit Pokémon species data."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbPokemonEditor }
    }
  })
  
  DebugMenuCommands.register("editdexes", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Regional Dexes"),
    "description" => _INTL("Create, rearrange and delete Regional Pokédex lists."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbRegionalDexEditorMain }
    }
  })
  
  DebugMenuCommands.register("positionsprites", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Edit Pokémon Sprite Positions"),
    "description" => _INTL("Reposition Pokémon sprites in battle."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn {
        sp = SpritePositioner.new
        sps = SpritePositionerScreen.new(sp)
        sps.pbStart
      }
    }
  })
  
  DebugMenuCommands.register("autopositionsprites", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Auto-Position All Sprites"),
    "description" => _INTL("Automatically reposition all Pokémon sprites in battle. Don't use lightly."),
    "always_show" => true,
    "effect"      => proc {
      if pbConfirmMessage(_INTL("Are you sure you want to reposition all sprites?"))
        msgwindow = pbCreateMessageWindow
        pbMessageDisplay(msgwindow, _INTL("Repositioning all sprites. Please wait."), false)
        Graphics.update
        pbAutoPositionAll
        pbDisposeMessageWindow(msgwindow)
      end
    }
  })
  
  DebugMenuCommands.register("autopositionbacksprites", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Auto-Position Back Sprites"),
    "description" => _INTL("Automatically reposition all Pokémon back sprites. Don't use lightly."),
    "always_show" => true,
    "effect"      => proc {
      if pbConfirmMessage(_INTL("Are you sure you want to reposition all back sprites?"))
        msgwindow = pbCreateMessageWindow
        pbMessageDisplay(msgwindow, _INTL("Repositioning all back sprites. Please wait."), false)
        Graphics.update
        
        GameData::Species.each do |sp|
          Graphics.update if sp.id_number % 50 == 0
          bitmap1 = GameData::Species.sprite_bitmap(sp.species, sp.form, nil, nil, nil, true)
          if bitmap1 && bitmap1.bitmap   # Player's y
            sp.back_sprite_x = 0
            sp.back_sprite_y = (bitmap1.height - (findBottom(bitmap1.bitmap) + 1)) / 2
            data = GameData::Species.get(sp)
            if data.abilities.include?(:LEVITATE) || data.abilities.include?(:DESERTSPIRIT)
              sp.back_sprite_y -= 4
            elsif data.egg_groups.include?(:Water2)
              sp.back_sprite_y -= 2
            end
          end
          bitmap1.dispose if bitmap1
        end
        GameData::Species.save
        Compiler.write_pokemon
        Compiler.write_pokemon_forms
        
        pbDisposeMessageWindow(msgwindow)
      end
    }
  })
  
  DebugMenuCommands.register("animeditor", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Battle Animation Editor"),
    "description" => _INTL("Edit the battle animations."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbAnimationEditor }
    }
  })
  
  DebugMenuCommands.register("animorganiser", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Battle Animation Organiser"),
    "description" => _INTL("Rearrange/add/delete battle animations."),
    "always_show" => true,
    "effect"      => proc {
      pbFadeOutIn { pbAnimationsOrganiser }
    }
  })
  
  DebugMenuCommands.register("importanims", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Import All Battle Animations"),
    "description" => _INTL("Import all battle animations from the \"Animations\" folder."),
    "always_show" => true,
    "effect"      => proc {
      pbImportAllAnimations
    }
  })
  
  DebugMenuCommands.register("exportanims", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Export All Battle Animations"),
    "description" => _INTL("Export all battle animations individually to the \"Animations\" folder."),
    "always_show" => true,
    "effect"      => proc {
      pbExportAllAnimations
    }
  })

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

  DebugMenuCommands.register("bossifyspecies", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Create bossified graphics"),
    "description" => _INTL("Create bossified graphics for a given species"),
    "effect"      => proc { |sprites, viewport|
    speciesGraphicName = pbEnterText(_INTL("Enter internal name."),0,20)
    createBossGraphics(speciesGraphicName.to_sym)
    }
  })
  
  DebugMenuCommands.register("createallbossifiedsprites", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Create bossified graphics for all"),
    "description" => _INTL("Create bossified graphics for every avatar in avatars.txt at 1.5 size"),
    "effect"      => proc { |sprites, viewport|
    pbMessage("Generating bossified graphics for all forms of all species listed in avatars.txt")
    createBossSpritesAllSpeciesForms
    pbMessage("Finished")
    }
  })

  DebugMenuCommands.register("importtribalassignment", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Import Tribes"),
    "description" => _INTL("Import tribes from comma seperated value file tribe_assignment.txt"),
    "effect"      => proc { |sprites, viewport|
      importTribes
    }
  })
  
  def importTribes
    speciesCount = 0
    Compiler.pbCompilerEachCommentedLine("tribe_assignment.txt") { |line, line_no|
      line = Compiler.pbGetCsvRecord(line, line_no, [0, "*n"])
  
      next unless line.length > 1
  
      speciesName = line[0]
      speciesData = GameData::Species.get(speciesName.to_sym)
      tribeList = speciesData.tribes
      
      speciesCount += 1
      echoln("Importing #{line.length - 1} tribes for species #{speciesName}")
  
      for index in 1..line.length do
        tribeName = line[index]
        next unless tribeName
        tribe = tribeName.to_sym
        raise _INTL("Cannot import tribe #{tribe} for species #{speciesName}, its not a defined tribe") unless GameData::Tribe.exists?(tribe)
        tribeList.push(tribe)
      end
  
      tribeList.uniq!
      tribeList.compact!
      speciesData.tribes = tribeList
    }
  
    GameData::Species.save
    Compiler.write_pokemon
  
    pbMessage(_INTL("Tribes imported for #{speciesCount} species!"))
  end
  