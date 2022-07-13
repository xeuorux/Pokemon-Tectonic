DebugMenuCommands.register("bossifyspecies", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Create bossified graphics"),
  "description" => _INTL("Create bossified graphics for a given species"),
  "effect"      => proc { |sprites, viewport|
	speciesGraphicName = pbEnterText(_INTL("Enter internal name."),0,20)
	createBossGraphics(speciesGraphicName)
  }
})

DebugMenuCommands.register("createallbossifiedsprites", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Create bossified graphics for all"),
  "description" => _INTL("Create bossified graphics for every avatar in avatars.txt at 1.5 size"),
  "effect"      => proc { |sprites, viewport|
  pbMessage("Generating bossified graphics for all forms of all species listed in avatars.txt")
  avatarSpeciesIDs = []
	GameData::Avatar.each do |avatar_data|
    # Find all genders/forms of @species that have been seen
    avatarSpeciesIDs.push(avatar_data.id)
  end
  GameData::Species.each do |sp|
    next if !avatarSpeciesIDs.include?(sp.species)
    createBossGraphics(sp.id.to_s)
  end
  pbMessage("Finished")
  }
})
