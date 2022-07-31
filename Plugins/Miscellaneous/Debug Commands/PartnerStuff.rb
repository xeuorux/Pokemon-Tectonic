DebugMenuCommands.register("deregisterpartner", {
  "parent"      => "main",
  "name"        => _INTL("Reregister Partner"),
  "description" => _INTL("Get rid of any partner trainer joining your battles."),
  "effect"      => proc {
    pbDeregisterPartner
    pbMessage("De-Registered partner.")
  }
})