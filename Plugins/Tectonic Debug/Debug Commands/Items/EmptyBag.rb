DebugMenuCommands.register("emptybag", {
    "parent"      => "itemsmenu",
    "name"        => _INTL("Empty Bag"),
    "description" => _INTL("Remove all items from the Bag."),
    "effect"      => proc {
      $PokemonBag.clear
      pbMessage(_INTL("The Bag was cleared."))
    }
  })