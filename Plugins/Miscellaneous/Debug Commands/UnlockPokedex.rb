DebugMenuCommands.register("unlockdex", {
  "parent"      => "playermenu",
  "name"        => _INTL("Unlock PokeDex"),
  "description" => _INTL("Unlock's the PokeDex like at the beginning of the game."),
  "effect"      => proc {
    $Trainer.has_pokedex = true
    unlockDex() 
    pbMessage(_INTL("The PokeDex was unlocked."))
  }
})