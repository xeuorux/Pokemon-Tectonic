DebugMenuCommands.register("deleteteam", {
  "parent"      => "pokemonmenu",
  "name"        => _INTL("Delete Team"),
  "description" => _INTL("Delete the entirety of the player's team."),
  "effect"      => proc {
    $Trainer.party = []
    pbMessage(_INTL("Deleted your entire team."))
  }
})