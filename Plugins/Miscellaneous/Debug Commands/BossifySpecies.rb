DebugMenuCommands.register("bossifyspecies", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Create bossified graphics"),
  "description" => _INTL("Create bossified graphics for a given species"),
  "effect"      => proc { |sprites, viewport|
	speciesGraphicName = pbEnterText(_INTL("Enter internal name."),0,20)
	createBossGraphics(speciesGraphicName)
  }
})
