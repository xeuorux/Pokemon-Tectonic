DebugMenuCommands.register("addrockwalls", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Add Rock Walls"),
  "description" => _INTL("Add Rock walls replacing the cave wall placeholder tiles."),
  "effect"      => proc {
      Compiler.edit_maps
}
})