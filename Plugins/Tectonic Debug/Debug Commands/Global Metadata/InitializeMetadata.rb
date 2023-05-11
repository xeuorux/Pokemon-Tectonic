DebugMenuCommands.register("initializemetadata", {
    "parent"      => "globalmetadata",
    "name"        => _INTL("Initialize Metadata"),
    "description" => _INTL("Reset global metadata values to new save file defaults."),
    "effect"      => proc {
       $PokemonGlobal = PokemonGlobalMetadata.new
       pbMessage(_INTL("Reset global metadata values to new save file defaults."))
    }
  })
  
  