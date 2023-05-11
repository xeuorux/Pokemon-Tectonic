DebugMenuCommands.register("reinitializebrokenmetadata", {
    "parent"      => "globalmetadata",
    "name"        => _INTL("Re-Initialize Broken Metadata"),
    "description" => _INTL("Set undefined global metadata values to new save file defaults."),
    "effect"      => proc {
       newMetadat = PokemonGlobalMetadata.new
       newMetadat.instance_variables.each do |v|
          begin
              varName = v.to_s.sub('@','')
              defaultValue = newMetadat.send(varName)
              if !$PokemonGlobal.instance_variable_defined?(v)
                  $PokemonGlobal.send(varName + "=",defaultValue)
                  pbMessage(_INTL("Reset #{varName} to a value of #{defaultValue.to_s}."))
              end
          rescue NoMethodError
          rescue NameError
          end
       end
    }
  })