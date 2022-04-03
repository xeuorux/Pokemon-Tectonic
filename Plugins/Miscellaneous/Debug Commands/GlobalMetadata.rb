DebugMenuCommands.register("globalmetadata", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Global Metadata"),
  "description" => _INTL("Edit and View Global Metadata entries."),
})

DebugMenuCommands.register("printglobalmetadata", {
  "parent"      => "globalmetadata",
  "name"        => _INTL("Print Global Metadata"),
  "description" => _INTL("Print out each accessible or readable variable of the global metadata."),
  "effect"      => proc {
	 $PokemonGlobal.instance_variables.each do |v|
		begin
			varName = v.to_s.sub('@','')
			echoln("#{varName}: #{$PokemonGlobal.send(varName)}")
		rescue NoMethodError
		rescue NameError
		end
	 end
	 pbMessage(_INTL("Variables printed to console."))
  }
})

DebugMenuCommands.register("initializemetadata", {
  "parent"      => "globalmetadata",
  "name"        => _INTL("Initialize Metadata"),
  "description" => _INTL("Reset global metadata values to new save file defaults."),
  "effect"      => proc {
	 $PokemonGlobal = PokemonGlobalMetadata.new
	 pbMessage(_INTL("Reset global metadata values to new save file defaults."))
  }
})

DebugMenuCommands.register("reinitializebrokenmetadata", {
  "parent"      => "globalmetadata",
  "name"        => _INTL("Re-Initialize Broken Metadata"),
  "description" => _INTL("Set nil global metadata values to new save file defaults."),
  "effect"      => proc {
	 newMetadat = PokemonGlobalMetadata.new
	 $PokemonGlobal.instance_variables.each do |v|
		begin
			varName = v.to_s.sub('@','')
			defaultValue = newMetadat.send(varName)
			if $PokemonGlobal.send(varName).nil? && !defaultValue.nil?
				$PokemonGlobal.send(varName + "=",defaultValue)
				pbMessage(_INTL("Reset #{varName} to a value of #{defaultValue.to_s}."))
			end
		rescue NoMethodError
		rescue NameError
		end
	 end
  }
})