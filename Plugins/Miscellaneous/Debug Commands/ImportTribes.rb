DebugMenuCommands.register("importtribalassignment", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Import Tribes"),
  "description" => _INTL("Import tribes from comma seperated value file tribe_assignment.txt"),
  "effect"      => proc { |sprites, viewport|
    importTribes
  }
})

def importTribes
  speciesCount = 0
  Compiler.pbCompilerEachCommentedLine("tribe_assignment.txt") { |line, line_no|
    line = Compiler.pbGetCsvRecord(line, line_no, [0, "*n"])

    next unless line.length > 1

    speciesName = line[0]
    speciesData = GameData::Species.get(speciesName.to_sym)
    tribeList = speciesData.tribes
    
    speciesCount += 1
    echoln("Importing #{line.length - 1} tribes for species #{speciesName}")

    for index in 1..line.length do
      tribeName = line[index]
      next unless tribeName
      tribe = tribeName.to_sym
      raise _INTL("Cannot import tribe #{tribe} for species #{speciesName}, its not a defined tribe") unless GameData::Tribe.exists?(tribe)
      tribeList.push(tribe)
    end

    tribeList.uniq!
    tribeList.compact!
    speciesData.tribes = tribeList
  }

  GameData::Species.save
  Compiler.write_pokemon

  pbMessage(_INTL("Tribes imported for #{speciesCount} species!"))
end
