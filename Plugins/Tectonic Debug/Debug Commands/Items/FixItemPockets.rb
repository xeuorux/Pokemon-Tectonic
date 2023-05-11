DebugMenuCommands.register("fixpockets", {
  "parent"      => "itemsmenu",
  "name"        => _INTL("Fix item pockets"),
  "description" => _INTL("Remove all items from the bag, then put them back in, to reset pocket location"),
  "effect"      => proc {
    pbMessage("Fixing item pockets.")
    $PokemonBag.reassignPockets()
    pbMessage("All items reassigned.")
  }
})