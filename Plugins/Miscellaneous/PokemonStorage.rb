class PokemonStorageScreen
  def pbStartScreen(command)
    @heldpkmn = nil
    if command==0   # Organise
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected==nil
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        elsif selected[0]==-3   # Close box
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          if pbConfirm(_INTL("Exit from the Box?"))
            pbSEPlay("PC close")
            break
          end
          next
        elsif selected[0]==-4   # Box name
          pbBoxCommands
        else
          pokemon = @storage[selected[0],selected[1]]
          heldpoke = pbHeldPokemon
          next if !pokemon && !heldpoke
          if @scene.quickswap
            if @heldpkmn
              (pokemon) ? pbSwap(selected) : pbPlace(selected)
            else
              pbHold(selected)
            end
          else
            commands = []
            cmdMove     = -1
            cmdSummary  = -1
            cmdWithdraw = -1
            cmdItem     = -1
            cmdMark     = -1
            cmdRelease  = -1
            cmdDebug    = -1
			cmdZoo		= -1
            cmdCancel   = -1
            if heldpoke
              helptext = _INTL("{1} is selected.",heldpoke.name)
              commands[cmdMove=commands.length]   = (pokemon) ? _INTL("Shift") : _INTL("Place")
            elsif pokemon
              helptext = _INTL("{1} is selected.",pokemon.name)
              commands[cmdMove=commands.length]   = _INTL("Move")
            end
            commands[cmdSummary=commands.length]  = _INTL("Summary")
            commands[cmdWithdraw=commands.length] = (selected[0]==-1) ? _INTL("Store") : _INTL("Withdraw")
            commands[cmdItem=commands.length]     = _INTL("Item")
            commands[cmdMark=commands.length]     = _INTL("Mark")
            commands[cmdRelease=commands.length]  = _INTL("Release")
            commands[cmdDebug=commands.length]    = _INTL("Debug") if $DEBUG
			commands[cmdZoo=commands.length]	  = _INTL("Donate") if canBeSentToZoo((@heldpkmn) ? @heldpkmn : pokemon) && $PokemonGlobal.zooSeen
            commands[cmdCancel=commands.length]   = _INTL("Cancel")
            command=pbShowCommands(helptext,commands)
            if cmdMove>=0 && command==cmdMove   # Move/Shift/Place
              if @heldpkmn
                (pokemon) ? pbSwap(selected) : pbPlace(selected)
              else
                pbHold(selected)
              end
            elsif cmdSummary>=0 && command==cmdSummary   # Summary
              pbSummary(selected,@heldpkmn)
            elsif cmdWithdraw>=0 && command==cmdWithdraw   # Store/Withdraw
              (selected[0]==-1) ? pbStore(selected,@heldpkmn) : pbWithdraw(selected,@heldpkmn)
            elsif cmdItem>=0 && command==cmdItem   # Item
              pbItem(selected,@heldpkmn)
            elsif cmdMark>=0 && command==cmdMark   # Mark
              pbMark(selected,@heldpkmn)
            elsif cmdRelease>=0 && command==cmdRelease   # Release
              pbRelease(selected,@heldpkmn)
			elsif cmdZoo>=0 && command==cmdZoo # Donate to zoo
			  pbDonate(selected,@heldpkmn)
            elsif cmdDebug>=0 && command==cmdDebug   # Debug
              pbPokemonDebug((@heldpkmn) ? @heldpkmn : pokemon,selected,heldpoke)
            end
          end
        end
      end
      @scene.pbCloseBox
    elsif command==1   # Withdraw
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected==nil
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          case selected[0]
          when -2   # Party Pokémon
            pbDisplay(_INTL("Which one will you take?"))
            next
          when -3   # Close box
            if pbConfirm(_INTL("Exit from the Box?"))
              pbSEPlay("PC close")
              break
            end
            next
          when -4   # Box name
            pbBoxCommands
            next
          end
          pokemon = @storage[selected[0],selected[1]]
          next if !pokemon
		  commands = [
             _INTL("Store"),
             _INTL("Summary"),
             _INTL("Mark"),
             _INTL("Release")
          ]
		  zoo = canBeSentToZoo(pokemon) && $PokemonGlobal.zooSeen
		  
		  commands.push(_INTL("Donate")) if zoo
		  commands.push(_INTL("Cancel"))
          command = pbShowCommands(_INTL("{1} is selected.",pokemon.name),commands)
          case command
          when 0 then pbWithdraw(selected, nil)
          when 1 then pbSummary(selected, nil)
          when 2 then pbMark(selected, nil)
          when 3 then pbRelease(selected, nil)
		  when 4 then pbDonate(selected, nil) if zoo
          end
        end
      end
      @scene.pbCloseBox
    elsif command==2   # Deposit
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectParty(@storage.party)
        if selected==-3   # Close box
          if pbConfirm(_INTL("Exit from the Box?"))
            pbSEPlay("PC close")
            break
          end
          next
        elsif selected<0
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          pokemon = @storage[-1,selected]
          next if !pokemon
		  commands = [
             _INTL("Store"),
             _INTL("Summary"),
             _INTL("Mark"),
             _INTL("Release")
          ]
		  zoo = canBeSentToZoo(pokemon) && $PokemonGlobal.zooSeen
		  if pbAbleCount<=1 && pbAble?(pokemon)
			  zoo = false
		  end
		  
		  commands.push(_INTL("Donate")) if zoo && $PokemonGlobal.zooSeen
		  commands.push(_INTL("Cancel"))
          command = pbShowCommands(_INTL("{1} is selected.",pokemon.name),commands)
          case command
          when 0 then pbStore([-1, selected], nil)
          when 1 then pbSummary([-1, selected], nil)
          when 2 then pbMark([-1, selected], nil)
          when 3 then pbRelease([-1, selected], nil)
		  when 4 then pbDonate([-1, selected], nil) if zoo
          end
        end
      end
      @scene.pbCloseBox
    elsif command==3
      @scene.pbStartBox(self,command)
      @scene.pbCloseBox
    end
  end
  
  def pbDonate(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box,index]
    return if !pokemon
    if pokemon.egg?
      pbDisplay(_INTL("You can't donate an Egg."))
      return false
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box==-1 && pbAbleCount<=1 && pbAble?(pokemon) && !heldpoke
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
	zooMap = sendToZoo(pokemon,false)
    if zooMap
      pkmnname = pokemon.name
      @scene.pbRelease(selected,heldpoke)
      if heldpoke
        @heldpkmn = nil
      else
        @storage.pbDelete(box,index)
      end
      @scene.pbRefresh
      pbDisplay(_INTL("{1} was donated, and placed in {2}.",pkmnname,zooMap))
      pbDisplay(_INTL("Bye-bye, {1}!",pkmnname))
      @scene.pbRefresh
    end
    return
  end
end