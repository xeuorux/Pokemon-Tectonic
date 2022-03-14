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
          if pbBoxCommands
			@scene.pbCloseBox
			return true
		  end
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
			cmdPokedex  = -1
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
			commands[cmdPokedex = commands.length]  = _INTL("Pokédex") if $Trainer.has_pokedex
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
			elsif cmdPokedex>=0 && command==cmdPokedex #Pokedex
				if @heldpkmn
					$Trainer.pokedex.register_last_seen(@heldpkmn)
					pbFadeOutIn {
						scene = PokemonPokedexInfo_Scene.new
						screen = PokemonPokedexInfoScreen.new(scene)
						screen.pbStartSceneSingle(@heldpkmn.species)
								}			
				else
					$Trainer.pokedex.register_last_seen(pokemon)
					pbFadeOutIn {
						scene = PokemonPokedexInfo_Scene.new
						screen = PokemonPokedexInfoScreen.new(scene)
						screen.pbStartSceneSingle(pokemon.species)
								}
				end
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
            if pbBoxCommands
				@scene.pbCloseBox
				return true
		    end
          end
          pokemon = @storage[selected[0],selected[1]]
          next if !pokemon
          cmdWithdraw = -1
		  cmdSummary = -1
		  cmdPokedex = -1
		  cmdMark = -1
		  cmdRelease = -1
		  cmdZoo = -1
		  commands = []
		  commands[cmdWithdraw = commands.length] = _INTL("Withdraw")
		  commands[cmdSummary = commands.length] = _INTL("Summary")
		  commands[cmdPokedex = commands.length] = _INTL("Pokedex") if $Trainer.has_pokedex
		  commands[cmdMark = commands.length] = _INTL("Mark")
		  
		  zoo = canBeSentToZoo(pokemon) && $PokemonGlobal.zooSeen
		  if pbAbleCount<=1 && pbAble?(pokemon)
			  zoo = false
		  end
		  commands[cmdDonate = commands.length] = _INTL("Donate") if zoo && $PokemonGlobal.zooSeen
		  commands[cmdRelease = commands.length] = _INTL("Release")
		  commands.push(_INTL("Cancel"))
          command = pbShowCommands(_INTL("{1} is selected.",pokemon.name),commands)
          if cmdWithdraw > -1 && command == cmdWithdraw
			pbWithdraw(selected, nil)
		  elsif cmdSummary > -1 && command == cmdSummary
			pbSummary(selected, nil)
          elsif cmdMark > -1 && command == cmdMark
			pbMark(selected, nil)
          elsif	cmdRelease > -1 && command == cmdRelease
			pbRelease(selected, nil)
		  elsif	cmdZoo > -1 && command == cmdZoo
			pbDonate(selected, nil)
		  elsif	cmdPokedex > -1 && command == cmdPokedex
			$Trainer.pokedex.register_last_seen(pokemon)
			pbFadeOutIn {
			  scene = PokemonPokedexInfo_Scene.new
			  screen = PokemonPokedexInfoScreen.new(scene)
			  screen.pbStartSceneSingle(pokemon.species)
			}
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
          cmdStore = -1
		  cmdSummary = -1
		  cmdPokedex = -1
		  cmdMark = -1
		  cmdRelease = -1
		  cmdZoo = -1
		  commands = []
		  commands[cmdStore = commands.length] = _INTL("Store")
		  commands[cmdSummary = commands.length] = _INTL("Summary")
		  commands[cmdPokedex = commands.length] = _INTL("Pokedex") if $Trainer.has_pokedex
		  commands[cmdMark = commands.length] = _INTL("Mark")
		  
		  zoo = canBeSentToZoo(pokemon) && $PokemonGlobal.zooSeen
		  if pbAbleCount<=1 && pbAble?(pokemon)
			  zoo = false
		  end
		  commands[cmdDonate = commands.length] = _INTL("Donate") if zoo && $PokemonGlobal.zooSeen
		  commands[cmdRelease = commands.length] = _INTL("Release")
		  commands.push(_INTL("Cancel"))
          command = pbShowCommands(_INTL("{1} is selected.",pokemon.name),commands)
          if cmdStore > -1 && command == cmdStore
			pbStore([-1, selected], nil)
		  elsif cmdSummary > -1 && command == cmdSummary
			pbSummary([-1, selected], nil)
          elsif cmdMark > -1 && command == cmdMark
			pbMark([-1, selected], nil)
          elsif	cmdRelease > -1 && command == cmdRelease
			pbRelease([-1, selected], nil)
		  elsif	cmdZoo > -1 && command == cmdZoo
			pbDonate([-1, selected], nil)
		  elsif	cmdPokedex > -1 && command == cmdPokedex
			$Trainer.pokedex.register_last_seen(pokemon)
			pbFadeOutIn {
			  scene = PokemonPokedexInfo_Scene.new
			  screen = PokemonPokedexInfoScreen.new(scene)
			  screen.pbStartSceneSingle(pokemon.species)
			}
          end
        end
      end
      @scene.pbCloseBox
    elsif command==3
      @scene.pbStartBox(self,command)
      @scene.pbCloseBox
    end
	return false
  end
  
  def pbBoxCommands
    commands = [
       _INTL("Jump"),
       _INTL("Wallpaper"),
       _INTL("Name"),
	   _INTL("Visit PokÉstate"),
       _INTL("Cancel"),
    ]
    command = pbShowCommands(
       _INTL("What do you want to do?"),commands)
    case command
    when 0
      destbox = @scene.pbChooseBox(_INTL("Jump to which Box?"))
      if destbox>=0
        @scene.pbJumpToBox(destbox)
      end
    when 1
      papers = @storage.availableWallpapers
      index = 0
      for i in 0...papers[1].length
        if papers[1][i]==@storage[@storage.currentBox].background
          index = i; break
        end
      end
      wpaper = pbShowCommands(_INTL("Pick the wallpaper."),papers[0],index)
      if wpaper>=0
        @scene.pbChangeBackground(papers[1][wpaper])
      end
    when 2
		@scene.pbBoxName(_INTL("Box name?"),0,12)
	when 3
		if heldpkmn
			pbDisplay("Can't Visit the PokÉstate while you have a Pokémon in your hand!")
			return false
		end
		transferToEstate(@storage.currentBox)
		return true
    end
	return false
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
      else
        @heldpkmn = nil
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