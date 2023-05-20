DebugMenuCommands.register("fieldmenu", {
    "parent"      => "main",
    "name"        => _INTL("Field options..."),
    "description" => _INTL("Warp to maps, edit switches/variables, use the PC, edit Day Care, etc.")
  })

DebugMenuCommands.register("battlemenu", {
    "parent"      => "main",
    "name"        => _INTL("Battle options..."),
    "description" => _INTL("Start battles, reset this map's trainers, ready rematches, edit roamers, etc.")
})

DebugMenuCommands.register("pokemonmenu", {
    "parent"      => "main",
    "name"        => _INTL("Pokémon options..."),
    "description" => _INTL("Give Pokémon, heal party, fill/empty PC storage, etc.")
  })

  DebugMenuCommands.register("itemsmenu", {
    "parent"      => "main",
    "name"        => _INTL("Item options..."),
    "description" => _INTL("Give and take items.")
  })

  DebugMenuCommands.register("playermenu", {
    "parent"      => "main",
    "name"        => _INTL("Player options..."),
    "description" => _INTL("Set money, badges, Pokédexes, player's appearance and name, etc.")
  })

  DebugMenuCommands.register("editorsmenu", {
    "parent"      => "main",
    "name"        => _INTL("Information editors..."),
    "description" => _INTL("Edit information in the PBS files, terrain tags, battle animations, etc."),
    "always_show" => true
  })

  DebugMenuCommands.register("globalmetadata", {
    "parent"      => "main",
    "name"        => _INTL("Global Metadata..."),
    "description" => _INTL("Edit and View Global Metadata entries."),
  })

DebugMenuCommands.register("analysis", {
    "parent"      => "main",
    "name"        => _INTL("Analysis..."),
    "description" => _INTL("Analyze and create reports about game data."),
    "always_show" => true
})

DebugMenuCommands.register("randomizer", {
  "parent"      => "main",
  "name"        => _INTL("Randomizer..."),
  "description" => _INTL("Deal with randomizer")
})

DebugMenuCommands.register("waypoints", {
  "parent"      => "main",
  "name"        => _INTL("Waypoints..."),
  "description" => _INTL("Edit information about waypoints."),
  "always_show" => true,
})

DebugMenuCommands.register("othermenu", {
    "parent"      => "main",
    "name"        => _INTL("Other options..."),
    "description" => _INTL("Mystery Gifts, translations, compile data, etc."),
    "always_show" => true
  })