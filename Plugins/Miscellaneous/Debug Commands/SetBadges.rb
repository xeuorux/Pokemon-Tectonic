DebugMenuCommands.register("setbadges", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Badges"),
  "description" => _INTL("Toggle possession of each Gym Badge."),
  "effect"      => proc {
    badgecmd = 0
    loop do
      badgecmds = []
      badgecmds.push(_INTL("Give all"))
      badgecmds.push(_INTL("Remove all"))
      for i in 0...8
        badgecmds.push(_INTL("{1} Badge {2}", $Trainer.badges[i] ? "[Y]" : "[  ]", i + 1))
      end
      badgecmd = pbShowCommands(nil, badgecmds, -1, badgecmd)
      break if badgecmd < 0
      if badgecmd == 0   # Give all
        8.times { |i|
          $Trainer.badges[i] = true
          $game_switches[4+i] = true
        }
      elsif badgecmd == 1   # Remove all
        8.times { |i|
          $Trainer.badges[i] = false
          $game_switches[4+i] = false
        }
      else
        $Trainer.badges[badgecmd - 2] = !$Trainer.badges[badgecmd - 2]
		    $game_switches[2+badgecmd] = $Trainer.badges[badgecmd - 2]
      end
    end

    updateTotalBadgesVar()
  }
})