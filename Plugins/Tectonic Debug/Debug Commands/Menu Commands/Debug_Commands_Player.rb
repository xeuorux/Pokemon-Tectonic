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
        for i in 0...24
          badgecmds.push(_INTL("{1} Badge {2}", $Trainer.badges[i] ? "[Y]" : "[  ]", i + 1))
        end
        badgecmd = pbShowCommands(nil, badgecmds, -1, badgecmd)
        break if badgecmd < 0
        if badgecmd == 0   # Give all
          24.times { |i| $Trainer.badges[i] = true }
        elsif badgecmd == 1   # Remove all
          24.times { |i| $Trainer.badges[i] = false }
        else
          $Trainer.badges[badgecmd - 2] = !$Trainer.badges[badgecmd - 2]
        end
      end
    }
  })

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
  
  DebugMenuCommands.register("setmoney", {
    "parent"      => "playermenu",
    "name"        => _INTL("Set Money"),
    "description" => _INTL("Edit how much money you have."),
    "effect"      => proc {
      params = ChooseNumberParams.new
      params.setRange(0, Settings::MAX_MONEY)
      params.setDefaultValue($Trainer.money)
      $Trainer.money = pbMessageChooseNumber(_INTL("Set the player's money."), params)
      pbMessage(_INTL("You now have ${1}.", $Trainer.money.to_s_formatted))
    }
  })
  
  DebugMenuCommands.register("setcoins", {
    "parent"      => "playermenu",
    "name"        => _INTL("Set Coins"),
    "description" => _INTL("Edit how many Game Corner Coins you have."),
    "effect"      => proc {
      params = ChooseNumberParams.new
      params.setRange(0, Settings::MAX_COINS)
      params.setDefaultValue($Trainer.coins)
      $Trainer.coins = pbMessageChooseNumber(_INTL("Set the player's Coin amount."), params)
      pbMessage(_INTL("You now have {1} Coins.", $Trainer.coins.to_s_formatted))
    }
  })
  
  DebugMenuCommands.register("setbp", {
    "parent"      => "playermenu",
    "name"        => _INTL("Set Battle Points"),
    "description" => _INTL("Edit how many Battle Points you have."),
    "effect"      => proc {
      params = ChooseNumberParams.new
      params.setRange(0, Settings::MAX_BATTLE_POINTS)
      params.setDefaultValue($Trainer.battle_points)
      $Trainer.battle_points = pbMessageChooseNumber(_INTL("Set the player's BP amount."), params)
      pbMessage(_INTL("You now have {1} BP.", $Trainer.battle_points.to_s_formatted))
    }
  })
  
  DebugMenuCommands.register("toggleshoes", {
    "parent"      => "playermenu",
    "name"        => _INTL("Toggle Running Shoes"),
    "description" => _INTL("Toggle possession of running shoes."),
    "effect"      => proc {
      $Trainer.has_running_shoes = !$Trainer.has_running_shoes
      pbMessage(_INTL("Gave Running Shoes.")) if $Trainer.has_running_shoes
      pbMessage(_INTL("Lost Running Shoes.")) if !$Trainer.has_running_shoes
    }
  })
  
  DebugMenuCommands.register("togglepokegear", {
    "parent"      => "playermenu",
    "name"        => _INTL("Toggle Pokégear"),
    "description" => _INTL("Toggle possession of the Pokégear."),
    "effect"      => proc {
      $Trainer.has_pokegear = !$Trainer.has_pokegear
      pbMessage(_INTL("Gave Pokégear.")) if $Trainer.has_pokegear
      pbMessage(_INTL("Lost Pokégear.")) if !$Trainer.has_pokegear
    }
  })
  
  DebugMenuCommands.register("dexlists", {
    "parent"      => "playermenu",
    "name"        => _INTL("Toggle Pokédex and Dexes"),
    "description" => _INTL("Toggle possession of the Pokédex, and edit Regional Dex accessibility."),
    "effect"      => proc {
      dexescmd = 0
      loop do
        dexescmds = []
        dexescmds.push(_INTL("Have Pokédex: {1}", $Trainer.has_pokedex ? "[YES]" : "[NO]"))
        dex_names = Settings.pokedex_names
        for i in 0...dex_names.length
          name = (dex_names[i].is_a?(Array)) ? dex_names[i][0] : dex_names[i]
          unlocked = $Trainer.pokedex.unlocked?(i)
          dexescmds.push(_INTL("{1} {2}", unlocked ? "[Y]" : "[  ]", name))
        end
        dexescmd = pbShowCommands(nil, dexescmds, -1, dexescmd)
        break if dexescmd < 0
        dexindex = dexescmd - 1
        if dexindex < 0   # Toggle Pokédex ownership
          $Trainer.has_pokedex = !$Trainer.has_pokedex
        else   # Toggle Regional Dex accessibility
          if $Trainer.pokedex.unlocked?(dexindex)
            $Trainer.pokedex.lock(dexindex)
          else
            $Trainer.pokedex.unlock(dexindex)
          end
        end
      end
    }
  })
  
  DebugMenuCommands.register("setplayer", {
    "parent"      => "playermenu",
    "name"        => _INTL("Set Player Character"),
    "description" => _INTL("Edit the player's character, as defined in \"metadata.txt\"."),
    "effect"      => proc {
      limit = 0
      for i in 0...8
        meta = GameData::Metadata.get_player(i)
        next if meta
        limit = i
        break
      end
      if limit <= 1
        pbMessage(_INTL("There is only one player defined."))
      else
        params = ChooseNumberParams.new
        params.setRange(0, limit - 1)
        params.setDefaultValue($Trainer.character_ID)
        newid = pbMessageChooseNumber(_INTL("Choose the new player character."), params)
        if newid != $Trainer.character_ID
          pbChangePlayer(newid)
          pbMessage(_INTL("The player character was changed."))
        end
      end
    }
  })
  
  DebugMenuCommands.register("changeoutfit", {
    "parent"      => "playermenu",
    "name"        => _INTL("Set Player Outfit"),
    "description" => _INTL("Edit the player's outfit number."),
    "effect"      => proc {
      oldoutfit = $Trainer.outfit
      params = ChooseNumberParams.new
      params.setRange(0, 99)
      params.setDefaultValue(oldoutfit)
      $Trainer.outfit = pbMessageChooseNumber(_INTL("Set the player's outfit."), params)
      pbMessage(_INTL("Player's outfit was changed.")) if $Trainer.outfit != oldoutfit
    }
  })
  
  DebugMenuCommands.register("renameplayer", {
    "parent"      => "playermenu",
    "name"        => _INTL("Set Player Name"),
    "description" => _INTL("Rename the player."),
    "effect"      => proc {
      trname = pbEnterPlayerName("Your name?", 0, Settings::MAX_PLAYER_NAME_SIZE, $Trainer.name)
      if nil_or_empty?(trname) && pbConfirmMessage(_INTL("Give yourself a default name?"))
        trainertype = $Trainer.trainer_type
        gender      = pbGetTrainerTypeGender(trainertype)
        trname      = pbSuggestTrainerName(gender)
      end
      if nil_or_empty?(trname)
        pbMessage(_INTL("The player's name remained {1}.", $Trainer.name))
      else
        $Trainer.name = trname
        pbMessage(_INTL("The player's name was changed to {1}.", $Trainer.name))
      end
    }
  })
  
  DebugMenuCommands.register("randomid", {
    "parent"      => "playermenu",
    "name"        => _INTL("Randomize Player ID"),
    "description" => _INTL("Generate a random new ID for the player."),
    "effect"      => proc {
      $Trainer.id = rand(2 ** 16) | rand(2 ** 16) << 16
      pbMessage(_INTL("The player's ID was changed to {1} (full ID: {2}).", $Trainer.public_ID, $Trainer.id))
    }
  })

  DebugMenuCommands.register("cleardex", {
    "parent"      => "playermenu",
    "name"        => _INTL("Clear PokeDex"),
    "description" => _INTL("Clear all data from the player's pokedex."),
    "effect"      => proc {
      $Trainer.pokedex.clear
      pbMessage(_INTL("The PokeDex was cleared."))
    }
  })

  DebugMenuCommands.register("setmainqueststage", {
    "parent"      => "playermenu",
    "name"        => _INTL("Set Stage"),
    "description" => _INTL("Set which Main Quest Stage the player is considered to be on."),
    "effect"      => proc {
      commands = []
      MAIN_QUEST_STAGES.each_with_index do |key_value_pair, index|
        name = MainQuestTracker.getNiceNameForStageSymbol(key_value_pair[0])
        commands.push(_INTL("{1}: {2}", index, name))
      end
      stageCmd = pbShowCommands(nil, commands, -1)
      if stageCmd >= 0
        $main_quest_tracker.setMainQuestStage(stageCmd)
        pbMessage("Changed the player's main quest stage to #{MainQuestTracker.getNiceNameForStageSymbol(MAIN_QUEST_STAGES.keys[stageCmd])}.")
      end
    }
  })