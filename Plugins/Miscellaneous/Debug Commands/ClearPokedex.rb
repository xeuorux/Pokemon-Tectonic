DebugMenuCommands.register("cleardex", {
  "parent"      => "playermenu",
  "name"        => _INTL("Clear PokeDex"),
  "description" => _INTL("Clear all data from the player's pokedex."),
  "effect"      => proc {
    $Trainer.pokedex.clear
    pbMessage(_INTL("The PokeDex was cleared."))
  }
})