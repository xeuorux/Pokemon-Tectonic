def pbTrainerPC
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.",$Trainer.name))
  pbTrainerPCMenu
  pbSEPlay("PC close")
end

def pbTrainerPCMenu
    command = 0
    loop do
      command = pbMessage(_INTL("What do you want to do?"),[
         _INTL("Item Storage"),
         _INTL("Mailbox"),
         _INTL("Turn Off")
         ],-1,nil,command)
      case command
      when 0 then pbPCItemStorage
      when 1 then pbPCMailbox
      else        break
      end
    end
  end