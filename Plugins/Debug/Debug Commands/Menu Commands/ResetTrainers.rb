DebugMenuCommands.register("resettrainers", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Reset Map's Trainers"),
    "description" => _INTL("Turn off Self Switches A and D for all events with \"Trainer\" in their name."),
    "effect"      => proc {
      if $game_map
        for event in $game_map.events.values
          if event.name[/trainer/i]
            $game_self_switches[[$game_map.map_id, event.id, "A"]] = false
            $game_self_switches[[$game_map.map_id, event.id, "D"]] = false
          end
        end
        $game_map.need_refresh = true
        pbMessage(_INTL("All Trainers on this map were reset."))
      else
        pbMessage(_INTL("This command can't be used here."))
      end
    }
  })
  