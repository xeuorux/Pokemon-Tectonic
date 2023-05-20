DebugMenuCommands.register("mysterygift", {
    "parent"      => "othermenu",
    "name"        => _INTL("Manage Mystery Gifts"),
    "description" => _INTL("Edit and enable/disable Mystery Gifts."),
    "always_show" => true,
    "effect"      => proc {
      pbManageMysteryGifts
    }
  })
  
  DebugMenuCommands.register("extracttext", {
    "parent"      => "othermenu",
    "name"        => _INTL("Extract Text"),
    "description" => _INTL("Extract all text in the game to a single file for translating."),
    "always_show" => true,
    "effect"      => proc {
      pbExtractText
    }
  })
  
  DebugMenuCommands.register("compiletext", {
    "parent"      => "othermenu",
    "name"        => _INTL("Compile Text"),
    "description" => _INTL("Import text and converts it into a language file."),
    "always_show" => true,
    "effect"      => proc {
      pbCompileTextUI
    }
  })
  
  DebugMenuCommands.register("compiledata", {
    "parent"      => "othermenu",
    "name"        => _INTL("Compile Data"),
    "description" => _INTL("Fully compile all data."),
    "always_show" => true,
    "effect"      => proc {
      msgwindow = pbCreateMessageWindow
      Compiler.compile_all(true) { |msg| pbMessageDisplay(msgwindow, msg, false); echoln(msg) }
      pbMessageDisplay(msgwindow, _INTL("All game data was compiled."))
      pbDisposeMessageWindow(msgwindow)
    }
  })
  
  DebugMenuCommands.register("createpbs", {
    "parent"      => "othermenu",
    "name"        => _INTL("Create PBS File(s)"),
    "description" => _INTL("Choose one or all PBS files and create it."),
    "always_show" => true,
    "effect"      => proc {
      cmd = 0
      cmds = [
        _INTL("[Create all]"),
        "abilities.txt",
        "berryplants.txt",
        "connections.txt",
        "encounters.txt",
        "items.txt",
        "metadata.txt",
        "moves.txt",
        "phone.txt",
        "pokemon.txt",
        "pokemonforms.txt",
        "regionaldexes.txt",
        "ribbons.txt",
        "shadowmoves.txt",
        "townmap.txt",
        "trainerlists.txt",
        "trainers.txt",
        "trainertypes.txt",
        "types.txt"
      ]
      loop do
        cmd = pbShowCommands(nil, cmds, -1, cmd)
        case cmd
        when 0  then Compiler.write_all
        when 1  then Compiler.write_abilities
        when 2  then Compiler.write_berry_plants
        when 3  then Compiler.write_connections
        when 4  then Compiler.write_encounters
        when 5  then Compiler.write_items
        when 6  then Compiler.write_metadata
        when 7  then Compiler.write_moves
        when 8  then Compiler.write_phone
        when 9  then Compiler.write_pokemon
        when 10 then Compiler.write_pokemon_forms
        when 11 then Compiler.write_regional_dexes
        when 12 then Compiler.write_ribbons
        when 13 then Compiler.write_shadow_movesets
        when 14 then Compiler.write_town_map
        when 15 then Compiler.write_trainer_lists
        when 16 then Compiler.write_trainers
        when 17 then Compiler.write_trainer_types
        when 18 then Compiler.write_types
        else break
        end
        pbMessage(_INTL("File written."))
      end
    }
  })
  
  DebugMenuCommands.register("renamesprites", {
    "parent"      => "othermenu",
    "name"        => _INTL("Rename Old Sprites"),
    "description" => _INTL("Renames and moves Pokémon/item/trainer sprites from their old places."),
    "always_show" => true,
    "effect"      => proc {
      SpriteRenamer.convert_files
    }
  })
  
  DebugMenuCommands.register("invalidtiles", {
    "parent"      => "othermenu",
    "name"        => _INTL("Fix Invalid Tiles"),
    "description" => _INTL("Scans all maps and erases non-existent tiles."),
    "always_show" => true,
    "effect"      => proc {
      pbDebugFixInvalidTiles
    }
  })
  
  DebugMenuCommands.register("settimetohour", {
    "parent"      => "othermenu",
    "name"        => _INTL("Set time to hour"),
    "description" => _INTL("Set the unreal time to the next instance of some hour on the 24-hour clock."),
    "effect"      => proc { |sprites, viewport|
    params = ChooseNumberParams.new
    params.setMaxDigits(2)
    params.setDefaultValue(0)
    params.setRange(1, 24)
    chosenHour = pbChooseNumber(nil, params) 
    UnrealTime.advance_to(chosenHour - 1, 0, 0)
    pbMessage("Advancing the unreal time system to hour #{chosenHour}")
    }}
  )
  
  DebugMenuCommands.register("deregisterpartner", {
    "parent"      => "othermenu",
    "name"        => _INTL("Reregister Partner"),
    "description" => _INTL("Get rid of any partner trainer joining your battles."),
    "effect"      => proc {
      pbDeregisterPartner
      pbMessage("De-Registered partner.")
    }
  })