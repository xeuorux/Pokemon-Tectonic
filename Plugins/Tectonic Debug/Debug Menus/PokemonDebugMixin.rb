#===============================================================================
  #
  #===============================================================================
  module PokemonDebugMixin
    def pbPokemonDebug(pkmn, pkmnid, heldpoke = nil, settingUpBattle = false)
      command = 0
      commands = CommandMenuList.new
      PokemonDebugMenuCommands.each do |option, hash|
        commands.add(option, hash) if !settingUpBattle || hash["always_show"]
      end
      loop do
        command = pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands.list, command)
        if command < 0
          parent = commands.getParent
          if parent
            commands.currentList = parent[0]
            command = parent[1]
          else
            break
          end
        else
          cmd = commands.getCommand(command)
          if commands.hasSubMenu?(cmd)
            commands.currentList = cmd
            command = 0
          elsif PokemonDebugMenuCommands.call("effect", cmd, pkmn, pkmnid, heldpoke, settingUpBattle, self)
            break
          end
        end
      end
    end
  end

  class PokemonPartyScreen
    include PokemonDebugMixin
  end

  class PokemonStorageScreen
    include PokemonDebugMixin
  end

  class PokemonDebugPartyScreen
    include PokemonDebugMixin
  end