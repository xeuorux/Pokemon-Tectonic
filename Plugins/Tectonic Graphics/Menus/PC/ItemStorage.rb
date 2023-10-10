def pbPCItemStorage
    pbSEPlay("Door enter",60,130)
    window = pbCreateMessageWindow()
    command = 0
    loop do
      command = pbShowCommandsWithHelp(window,
         [_INTL("Withdraw Item"),
         _INTL("Deposit Item"),
         _INTL("Toss Item"),
         _INTL("Exit")],
         [_INTL("Take out items from storage."),
         _INTL("Store items in the safe."),
         _INTL("Throw away items stored in the safe."),
         _INTL("Do nothing.")],-1,command
      )
      case command
      when 0   # Withdraw Item
        if !$PokemonGlobal.pcItemStorage
          $PokemonGlobal.pcItemStorage = PCItemStorage.new
        end
        if $PokemonGlobal.pcItemStorage.empty?
          pbMessage(_INTL("There are no items."))
        else
          pbFadeOutIn {
            scene = WithdrawItemScene.new
            screen = PokemonBagScreen.new(scene,$PokemonBag)
            screen.pbWithdrawItemScreen
          }
        end
      when 1   # Deposit Item
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          screen.pbDepositItemScreen
        }
      when 2   # Toss Item
        if !$PokemonGlobal.pcItemStorage
          $PokemonGlobal.pcItemStorage = PCItemStorage.new
        end
        if $PokemonGlobal.pcItemStorage.empty?
          pbMessage(_INTL("There are no items."))
        else
          pbFadeOutIn {
            scene = TossItemScene.new
            screen = PokemonBagScreen.new(scene,$PokemonBag)
            screen.pbTossItemScreen
          }
        end
      else
        break
      end
    end
    pbDisposeMessageWindow(window)
    pbSEPlay("Door enter",60,115)
end