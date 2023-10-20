#===============================================================================
#
#===============================================================================
class StorageSystemPC
    def shouldShow?
      return true
    end
  
    def name
        return _INTL("Pokémon Storage PC")
    end
  
    def access
      pbMessage(_INTL("\\se[PC access]The Pokémon Storage System was opened."))
      command = 0
      loop do
        command = pbShowCommandsWithHelp(nil,
           [_INTL("Organize Boxes"),
           _INTL("Withdraw Pokémon"),
           _INTL("Deposit Pokémon"),
           _INTL("See ya!")],
           [_INTL("Organize the Pokémon in Boxes and in your party."),
           _INTL("Move Pokémon stored in Boxes to your party."),
           _INTL("Store Pokémon in your party in Boxes."),
           _INTL("Return to the previous menu.")],-1,command
        )
        if command>=0 && command<3
          if command==1   # Withdraw
            if $PokemonStorage.party_full?
              pbMessage(_INTL("Your party is full!"))
              next
            end
          elsif command==2   # Deposit
            count=0
            for p in $PokemonStorage.party
              count += 1 if p && !p.egg? && p.hp>0
            end
            if count<=1
              pbMessage(_INTL("Can't deposit the last Pokémon!"))
              next
            end
          end
          pbFadeOutIn {
            scene = PokemonStorageScene.new
            screen = PokemonStorageScreen.new(scene,$PokemonStorage)
            screen.pbStartScreen(command)
          }
        else
          break
        end
      end
    end
  end
  
  PokemonPCList.registerPC(StorageSystemPC.new)