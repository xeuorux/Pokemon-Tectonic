DebugMenuCommands.register("earnbadge", {
  "parent"      => "playermenu",
  "name"        => _INTL("Earn a Badge"),
  "description" => _INTL("Earn a certain badge, cutscene and all."),
  "effect"      => proc {
    badgecmd = 0
    loop do
      badgecmds = []
      for i in 0...8
        badgecmds.push(_INTL("Badge {1}", i + 1))
      end
      badgecmd = pbShowCommands(nil, badgecmds, -1, badgecmd)
      break if badgecmd < 0
      earnBadge(badgecmd)
    end
  }
})