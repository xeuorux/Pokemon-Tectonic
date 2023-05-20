DebugMenuCommands.register("warp", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Warp to Map"),
    "description" => _INTL("Instantly warp to another map of your choice."),
    "effect"      => proc { |sprites, viewport|
      map = pbWarpToMap
      if map
        pbFadeOutAndHide(sprites)
        pbDisposeMessageWindow(sprites["textbox"])
        pbDisposeSpriteHash(sprites)
        viewport.dispose
        if $scene.is_a?(Scene_Map)
          $game_temp.player_new_map_id    = map[0]
          $game_temp.player_new_x         = map[1]
          $game_temp.player_new_y         = map[2]
          $game_temp.player_new_direction = 2
          $scene.transfer_player
        else
          pbCancelVehicles
          $MapFactory.setup(map[0])
          $game_player.moveto(map[1], map[2])
          $game_player.turn_down
          $game_map.update
          $game_map.autoplay
        end
        $game_map.refresh
        next true   # Closes the debug menu to allow the warp
      end
    }
  })
  
  DebugMenuCommands.register("refreshmap", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Refresh Map"),
    "description" => _INTL("Make all events on this map, and common events, refresh themselves."),
    "effect"      => proc {
      $game_map.need_refresh = true
      pbMessage(_INTL("The map will refresh."))
    }
  })
  
  DebugMenuCommands.register("switches", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Switches"),
    "description" => _INTL("Edit all Game Switches (except Script Switches)."),
    "effect"      => proc {
      pbDebugVariables(0)
    }
  })
  
  DebugMenuCommands.register("variables", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Variables"),
    "description" => _INTL("Edit all Game Variables. Can set them to numbers or text."),
    "effect"      => proc {
      pbDebugVariables(1)
    }
  })

  DebugMenuCommands.register("seteventswitch", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Set Event Switch"),
    "description" => _INTL("Set a switch of an event on a map"),
    "effect"      => proc {
      chosenMap = pbListScreen("Choose Map",MapLister.new($game_map.map_id))
      if chosenMap >= 0
        chosenEvent = pbListScreen("Choose Event on #{pbGetMapNameFromId(chosenMap)}",EventLister.new(chosenMap))
        if chosenEvent >= 0
          while true
            currentA = $game_self_switches[[chosenMap, chosenEvent, 'A']]
            currentB = $game_self_switches[[chosenMap, chosenEvent, 'B']]
            currentC = $game_self_switches[[chosenMap, chosenEvent, 'C']]
            currentD = $game_self_switches[[chosenMap, chosenEvent, 'D']]
  
            cmdA = -1
            cmdB = -1
            cmdC = -1
            cmdD = -1
            switchCommands = [_INTL("Done")]
            switchCommands[cmdA = switchCommands.length] = _INTL("Switch A (#{currentA})")
            switchCommands[cmdB = switchCommands.length] = _INTL("Switch B (#{currentB})")
            switchCommands[cmdC = switchCommands.length] = _INTL("Switch C (#{currentC})")
            switchCommands[cmdD = switchCommands.length] = _INTL("Switch D (#{currentD})")
            pbMessage(_INTL("Which switch would you like to swap?"))
            tileCommand = pbShowCommands(nil, switchCommands, -1)
            break if tileCommand == 0
            switchName = ['A','B','C','D'][tileCommand-1]
            $game_self_switches[[chosenMap, chosenEvent, switchName]] = !$game_self_switches[[chosenMap, chosenEvent, switchName]]
            $MapFactory.getMap(chosenMap, false).need_refresh = true if $MapFactory.hasMap?(chosenMap)
          end
        end
      end
    }
  })
  
  class EventLister
    def initialize(mapID)
      @commands = []
      mapData = Compiler::MapData.new
      @map = mapData.getMap(mapID)
      @events = []
      for key in @map.events.keys
        event = @map.events[key]
        next if !event || event.pages.length==0
        @events.push(event)
      end
      @index = 0
    end
  
    def startIndex
      return @index
    end
  
    def setViewport(viewport); end
  
    def commands
      @commands.clear
      for i in 0...@events.length
        event = @events[i]
        @commands.push("#{event.name} (#{event.id})")
      end
      return @commands
    end
  
    def value(index)
      return (index<0) ? -1 : @events[index].id
    end
  
    def refresh(index); end
  
    def dispose; end
  end
  
  DebugMenuCommands.register("usepc", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Use PC"),
    "description" => _INTL("Use a PC to access Pokémon storage and player's PC."),
    "effect"      => proc {
      pbPokeCenterPC
    }
  })
  
  DebugMenuCommands.register("togglewallpapers", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Toggle Storage Wallpapers"),
    "description" => _INTL("Unlock and lock special wallpapers used in Pokémon storage."),
    "effect"      => proc {
      w = $PokemonStorage.allWallpapers
      if w.length <= PokemonStorage::BASICWALLPAPERQTY
        pbMessage(_INTL("There are no special wallpapers defined."))
      else
        paperscmd = 0
        unlockarray = $PokemonStorage.unlockedWallpapers
        loop do
          paperscmds = []
          paperscmds.push(_INTL("Unlock all"))
          paperscmds.push(_INTL("Lock all"))
          for i in PokemonStorage::BASICWALLPAPERQTY...w.length
            paperscmds.push(_INTL("{1} {2}", unlockarray[i] ? "[Y]" : "[  ]", w[i]))
          end
          paperscmd = pbShowCommands(nil, paperscmds, -1, paperscmd)
          break if paperscmd < 0
          if paperscmd == 0   # Unlock all
            for i in PokemonStorage::BASICWALLPAPERQTY...w.length
              unlockarray[i] = true
            end
          elsif paperscmd == 1   # Lock all
            for i in PokemonStorage::BASICWALLPAPERQTY...w.length
              unlockarray[i] = false
            end
          else
            paperindex = paperscmd - 2 + PokemonStorage::BASICWALLPAPERQTY
            unlockarray[paperindex] = !$PokemonStorage.unlockedWallpapers[paperindex]
          end
        end
      end
    }
  })
  
  DebugMenuCommands.register("daycare", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Day Care"),
    "description" => _INTL("View Pokémon in the Day Care and edit them."),
    "effect"      => proc {
      pbDebugDayCare
    }
  })
  
  DebugMenuCommands.register("relicstone", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Use Relic Stone"),
    "description" => _INTL("Shadow Pokémon. Choose a Pokémon to show to the Relic Stone for purification."),
    "effect"      => proc {
      pbRelicStone
    }
  })
  
  DebugMenuCommands.register("purifychamber", {
    "parent"      => "fieldmenu",
    "name"        => _INTL("Use Purify Chamber"),
    "description" => _INTL("Shadow Pokémon. Open the Purify Chamber for purification."),
    "effect"      => proc {
      pbPurifyChamber
    }
  })

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
  