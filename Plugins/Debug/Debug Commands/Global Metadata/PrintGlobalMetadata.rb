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