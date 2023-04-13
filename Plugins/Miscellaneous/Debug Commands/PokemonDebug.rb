PokemonDebugMenuCommands.register("setitem", {
    "parent"      => "main",
    "name"        => _INTL("Set item"),
    "always_show" => true,
    "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
      cmd = 0
      commands = [
        _INTL("Replace items"),
        _INTL("Remove items"),
        _INTL("Add item"),
      ]
      loop do
        msg = (pkmn.hasItem?) ? _INTL("{1}: {2}.", pkmn.itemCountD(true), pkmn.itemsName) : _INTL("No item.")
        cmd = screen.pbShowCommands(msg, commands, cmd)
        break if cmd < 0
        case cmd
        when 0   # Replace items
          item = pbChooseItemList
          if item && !pkmn.hasItem?(item)
            pkmn.removeItems
            pkmn.giveItem(item)
            screen.pbRefreshSingle(pkmnid)
          end
        when 1   # Remove items
          if pkmn.hasItem?
            pkmn.removeItems
            screen.pbRefreshSingle(pkmnid)
          end
        when 2  # Add item
          item = pbChooseItemList
          if item && !pkmn.hasItem?(item)
            pkmn.giveItem(item)
            screen.pbRefreshSingle(pkmnid)
          end
        else
          break
        end
      end
      next false
    }
  })