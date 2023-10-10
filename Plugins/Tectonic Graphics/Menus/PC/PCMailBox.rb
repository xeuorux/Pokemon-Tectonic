def pbPCMailbox
    if !$PokemonGlobal.mailbox || $PokemonGlobal.mailbox.length==0
      pbMessage(_INTL("There's no Mail here."))
    else
      loop do
        command = 0
        commands=[]
        for mail in $PokemonGlobal.mailbox
          commands.push(mail.sender)
        end
        commands.push(_INTL("Cancel"))
        command = pbShowCommands(nil,commands,-1,command)
        if command>=0 && command<$PokemonGlobal.mailbox.length
          mailIndex = command
          commandMail = pbMessage(_INTL("What do you want to do with {1}'s Mail?",
             $PokemonGlobal.mailbox[mailIndex].sender),[
             _INTL("Read"),
             _INTL("Move to Bag"),
             _INTL("Give"),
             _INTL("Cancel")
             ],-1)
          case commandMail
          when 0   # Read
            pbFadeOutIn {
              pbDisplayMail($PokemonGlobal.mailbox[mailIndex])
            }
          when 1   # Move to Bag
            if pbConfirmMessage(_INTL("The message will be lost. Is that OK?"))
              if $PokemonBag.pbStoreItem($PokemonGlobal.mailbox[mailIndex].item)
                pbMessage(_INTL("The Mail was returned to the Bag with its message erased."))
                $PokemonGlobal.mailbox.delete_at(mailIndex)
              else
                pbMessage(_INTL("The Bag is full."))
              end
            end
          when 2   # Give
            pbFadeOutIn {
              sscene = PokemonParty_Scene.new
              sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
              sscreen.pbPokemonGiveMailScreen(mailIndex)
            }
          end
        else
          break
        end
      end
    end
  end