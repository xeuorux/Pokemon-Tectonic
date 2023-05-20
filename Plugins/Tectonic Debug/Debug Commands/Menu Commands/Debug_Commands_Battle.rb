DebugMenuCommands.register("testwildbattle", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Test Wild Battle"),
    "description" => _INTL("Start a single battle against a wild Pokémon. You choose the species/level."),
    "effect"      => proc {
      species = pbChooseSpeciesList
      if species
        params = ChooseNumberParams.new
        params.setRange(1, GameData::GrowthRate.max_level)
        params.setInitialValue(5)
        params.setCancelValue(0)
        level = pbMessageChooseNumber(_INTL("Set the wild {1}'s level.",
           GameData::Species.get(species).name), params)
        if level > 0
          $PokemonTemp.encounterType = nil
          pbWildBattle(species, level)
        end
      end
      next false
    }
  })
  
  DebugMenuCommands.register("testwildbattleadvanced", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Test Wild Battle Advanced"),
    "description" => _INTL("Start a battle against 1 or more wild Pokémon. Battle size is your choice."),
    "effect"      => proc {
      pkmn = []
      size0 = 1
      pkmnCmd = 0
      loop do
        pkmnCmds = []
        pkmn.each { |p| pkmnCmds.push(sprintf("%s Lv.%d", p.name, p.level)) }
        pkmnCmds.push(_INTL("[Add Pokémon]"))
        pkmnCmds.push(_INTL("[Set player side size]"))
        pkmnCmds.push(_INTL("[Start {1}v{2} battle]", size0, pkmn.length))
        pkmnCmd = pbShowCommands(nil, pkmnCmds, -1, pkmnCmd)
        break if pkmnCmd < 0
        if pkmnCmd == pkmnCmds.length - 1      # Start battle
          if pkmn.length == 0
            pbMessage(_INTL("No Pokémon were chosen, cannot start battle."))
            next
          end
          setBattleRule(sprintf("%dv%d", size0, pkmn.length))
          $PokemonTemp.encounterType = nil
          pbWildBattleCore(*pkmn)
          break
        elsif pkmnCmd == pkmnCmds.length - 2   # Set player side size
          if !pbCanDoubleBattle?
            pbMessage(_INTL("You only have one Pokémon."))
            next
          end
          maxVal = (pbCanTripleBattle?) ? 3 : 2
          params = ChooseNumberParams.new
          params.setRange(1, maxVal)
          params.setInitialValue(size0)
          params.setCancelValue(0)
          newSize = pbMessageChooseNumber(
             _INTL("Choose the number of battlers on the player's side (max. {1}).", maxVal), params)
          size0 = newSize if newSize > 0
        elsif pkmnCmd == pkmnCmds.length - 3   # Add Pokémon
          species = pbChooseSpeciesList
          if species
            params = ChooseNumberParams.new
            params.setRange(1, GameData::GrowthRate.max_level)
            params.setInitialValue(5)
            params.setCancelValue(0)
            level = pbMessageChooseNumber(_INTL("Set the wild {1}'s level.",
               GameData::Species.get(species).name), params)
            pkmn.push(Pokemon.new(species, level)) if level > 0
          end
        else                                   # Edit a Pokémon
          if pbConfirmMessage(_INTL("Change this Pokémon?"))
            scr = PokemonDebugPartyScreen.new
            scr.pbPokemonDebug(pkmn[pkmnCmd], -1, nil, true)
            scr.pbEndScreen
          elsif pbConfirmMessage(_INTL("Delete this Pokémon?"))
            pkmn[pkmnCmd] = nil
            pkmn.compact!
          end
        end
      end
      next false
    }
  })
  
  DebugMenuCommands.register("testtrainerbattle", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Test Trainer Battle"),
    "description" => _INTL("Start a single battle against a trainer of your choice."),
    "effect"      => proc {
      trainerdata = pbListScreen(_INTL("SINGLE TRAINER"), TrainerBattleLister.new(0, false))
      if trainerdata
        pbTrainerBattle(trainerdata[0], trainerdata[1], nil, false, trainerdata[2], true)
      end
      next false
    }
  })
  
  DebugMenuCommands.register("testtrainerbattleadvanced", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Test Trainer Battle Advanced"),
    "description" => _INTL("Start a battle against 1 or more trainers with a battle size of your choice."),
    "effect"      => proc {
      trainers = []
      size0 = 1
      size1 = 1
      trainerCmd = 0
      loop do
        trainerCmds = []
        trainers.each { |t| trainerCmds.push(sprintf("%s x%d", t[1].full_name, t[1].party_count)) }
        trainerCmds.push(_INTL("[Add trainer]"))
        trainerCmds.push(_INTL("[Set player side size]"))
        trainerCmds.push(_INTL("[Set opponent side size]"))
        trainerCmds.push(_INTL("[Start {1}v{2} battle]", size0, size1))
        trainerCmd = pbShowCommands(nil, trainerCmds, -1, trainerCmd)
        break if trainerCmd < 0
        if trainerCmd == trainerCmds.length - 1      # Start battle
          if trainers.length == 0
            pbMessage(_INTL("No trainers were chosen, cannot start battle."))
            next
          elsif size1 < trainers.length
            pbMessage(_INTL("Opposing side size is invalid. It should be at least {1}.", trainers.length))
            next
          elsif size1 > trainers.length && trainers[0][1].party_count == 1
            pbMessage(
               _INTL("Opposing side size cannot be {1}, as that requires the first trainer to have 2 or more Pokémon, which they don't.",
               size1))
            next
          end
          setBattleRule(sprintf("%dv%d", size0, size1))
          battleArgs = []
          trainers.each { |t| battleArgs.push(t[1]) }
          pbTrainerBattleCore(*battleArgs)
          break
        elsif trainerCmd == trainerCmds.length - 2   # Set opponent side size
          if trainers.length == 0 || (trainers.length == 1 && trainers[0][1].party_count == 1)
            pbMessage(_INTL("No trainers were chosen or trainer only has one Pokémon."))
            next
          end
          maxVal = 2
          maxVal = 3 if trainers.length >= 3 ||
                        (trainers.length == 2 && trainers[0][1].party_count >= 2) ||
                        trainers[0][1].party_count >= 3
          params = ChooseNumberParams.new
          params.setRange(1, maxVal)
          params.setInitialValue(size1)
          params.setCancelValue(0)
          newSize = pbMessageChooseNumber(
             _INTL("Choose the number of battlers on the opponent's side (max. {1}).", maxVal), params)
          size1 = newSize if newSize > 0
        elsif trainerCmd == trainerCmds.length - 3   # Set player side size
          if !pbCanDoubleBattle?
            pbMessage(_INTL("You only have one Pokémon."))
            next
          end
          maxVal = (pbCanTripleBattle?) ? 3 : 2
          params = ChooseNumberParams.new
          params.setRange(1, maxVal)
          params.setInitialValue(size0)
          params.setCancelValue(0)
          newSize = pbMessageChooseNumber(
             _INTL("Choose the number of battlers on the player's side (max. {1}).", maxVal), params)
          size0 = newSize if newSize > 0
        elsif trainerCmd == trainerCmds.length - 4   # Add trainer
          trainerdata = pbListScreen(_INTL("CHOOSE A TRAINER"), TrainerBattleLister.new(0, false))
          if trainerdata
            tr = pbLoadTrainer(trainerdata[0], trainerdata[1], trainerdata[2])
            trainers.push([0, tr])
          end
        else                                         # Edit a trainer
          if pbConfirmMessage(_INTL("Change this trainer?"))
            trainerdata = pbListScreen(_INTL("CHOOSE A TRAINER"),
               TrainerBattleLister.new(trainers[trainerCmd][0], false))
            if trainerdata
              tr = pbLoadTrainer(trainerdata[0], trainerdata[1], trainerdata[2])
              trainers[trainerCmd] = [0, tr]
            end
          elsif pbConfirmMessage(_INTL("Delete this trainer?"))
            trainers[trainerCmd] = nil
            trainers.compact!
          end
        end
      end
      next false
    }
  })
  
  DebugMenuCommands.register("togglelogging", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Toggle Battle Logging"),
    "description" => _INTL("Record debug logs for battles in Data/debuglog.txt."),
    "effect"      => proc {
      $INTERNAL = !$INTERNAL
      pbMessage(_INTL("Debug logs for battles will be made in the Data folder.")) if $INTERNAL
      pbMessage(_INTL("Debug logs for battles will not be made.")) if !$INTERNAL
    }
  })
  
  DebugMenuCommands.register("resettrainers", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Reset Map's Trainers"),
    "description" => _INTL("Turn off Self Switches A and B for all events with \"Trainer\" in their name."),
    "effect"      => proc {
      if $game_map
        for event in $game_map.events.values
          if event.name[/trainer/i]
            $game_self_switches[[$game_map.map_id, event.id, "A"]] = false
            $game_self_switches[[$game_map.map_id, event.id, "B"]] = false
          end
        end
        $game_map.need_refresh = true
        pbMessage(_INTL("All Trainers on this map were reset."))
      else
        pbMessage(_INTL("This command can't be used here."))
      end
    }
  })
  
  DebugMenuCommands.register("readyrematches", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Ready All Phone Rematches"),
    "description" => _INTL("Make all trainers in the phone ready for rematches."),
    "effect"      => proc {
      if !$PokemonGlobal.phoneNumbers || $PokemonGlobal.phoneNumbers.length == 0
        pbMessage(_INTL("There are no trainers in the Phone."))
      else
        for i in $PokemonGlobal.phoneNumbers
          next if i.length != 8   # Isn't a trainer with an event
          i[4] = 2
          pbSetReadyToBattle(i)
        end
        pbMessage(_INTL("All trainers in the Phone are now ready to rebattle."))
      end
    }
  })
  
  DebugMenuCommands.register("roamers", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Roaming Pokémon"),
    "description" => _INTL("Toggle and edit all roaming Pokémon."),
    "effect"      => proc {
      pbDebugRoamers
    }
  })
  
  DebugMenuCommands.register("encounterversion", {
    "parent"      => "battlemenu",
    "name"        => _INTL("Set Encounters Version"),
    "description" => _INTL("Choose which version of wild encounters should be used."),
    "effect"      => proc {
      params = ChooseNumberParams.new
      params.setRange(0, 99)
      params.setInitialValue($PokemonGlobal.encounter_version)
      params.setCancelValue(-1)
      value = pbMessageChooseNumber(_INTL("Set encounters version to which value?"), params)
      if value >= 0
        $PokemonGlobal.encounter_version = value
      end
    }
  })