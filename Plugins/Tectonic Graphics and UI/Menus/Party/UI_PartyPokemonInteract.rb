class TilingCardsPokemonMenu_Scene < TilingCardsMenu_Scene
	attr_reader :party

    def cursorFileLocation
		return _INTL("Graphics/Pictures/Party/cursor_pokemon")
	end

	def tileFileLocation
		return _INTL("Graphics/Pictures/Party/pokemon_menu_tile")
	end

	def backgroundFadeFileLocation
		return _INTL("Graphics/Pictures/Party/background_fade")
	end
  
    def initialize(pkmnid,party,summaryScene)
		super()
		@pkmnid = pkmnid
		@pkmn = party[pkmnid]
		@party = party
		@summaryScene = summaryScene
		@buttonRowHeight = 68
    end
  
	def initializeMenuButtons
		super
      	canEditTeam = teamEditingAllowed?()

        @cardButtons = {
			:SUMMARY => {
				:label => _INTL("Summary"),
				:press_proc => Proc.new { |scene|
					@summaryScene.pbSummary(@pkmnid)
				},
			},
			:ITEM => {
				:label => _INTL("Item"),
				:active_proc => Proc.new {
					canEditTeam
				},
				:press_proc => Proc.new { |scene|
					next true if itemCommandMenu
				},
			},
			:SWITCH => {
				:label => inPokestate? ? _INTL("Set Down") : _INTL("Switch"),
				:active_proc => Proc.new {
					inPokestate? ? @party.length > 1 : canEditTeam
				},
				:press_proc => Proc.new { |scene|
					if 	inPokestate?
						if $PokEstate.setDownIntoEstate(@pkmn)
							@party[@pkmnid] = nil
							@party.compact!
							@summaryScene.pbHardRefresh
							next true
						end
					else
						hideTileMenu
						pbSetHelpText(_INTL("Move to where?"))
						newpkmnid = @summaryScene.pbChoosePokemon(true)
						if newpkmnid >= 0 && newpkmnid != @pkmnid
							pbSwitch(newpkmnid,@pkmnid)
						end
						next true
					end
				},
			},
			:MODIFY => {
				:label => _INTL("Modify"),
				:active_proc => Proc.new {
					canEditTeam && !@pkmn.egg?
				},
				:press_proc => Proc.new { |scene|
					next true if modifyCommandMenu
				},
			},
			:MASTERDEX => {
				:label => _INTL("MasterDex"),
				:active_proc => Proc.new {
					$Trainer.has_pokedex
				},
				:press_proc => Proc.new { |scene|
					openSingleDexScreen(@pkmn)
				},
			},
			:SEND_PC => {
				:label => _INTL("Send to PC"),
				:active_proc => Proc.new {
					@party.length > 1 && ($Trainer.able_pokemon_count > 1 || !@pkmn.able?)
				},
				:press_proc => Proc.new { |scene|
					if pbConfirm(_INTL("Are you sure you'd like to send back #{@pkmn.name}?"))
						promptToTakeItems(@pkmn)
						pbStorePokemonInPC(@pkmn)
						@party[@pkmnid] = nil
						@party.compact!
						pbSEPlay("PC close")
						@summaryScene.pbHardRefresh
						next true
					end
				},
			},
      	}

		if $DEBUG
			@yOffset -= 16
			@cardButtons[:DEBUG] = {
				:label => _INTL("Debug"),
				:press_proc => Proc.new { |scene|
					pbPokemonDebug(@pkmn,@pkmnid)
					next true
				},
			}
		end
    end
  
    def inPokestate?
      	return defined?($PokEstate.setDownIntoEstate) && $PokEstate.isInEstate?()
    end
  
    def itemCommandMenu
		itemcommands = []
		cmdUseItem   = -1
		cmdGiveItem  = -1
		cmdTakeItems  = -1
		cmdTakeOneItem = -1
		cmdSwapItemOrder = -1
		cmdMoveItem  = -1
		cmdSetItemType = -1
		# Build the commands
		itemcommands[cmdSetItemType=itemcommands.length] = _INTL("Set Item Type") if @pkmn.hasTypeSetterItem?
		itemcommands[cmdGiveItem=itemcommands.length] = _INTL("Give")
		if @pkmn.hasItem?
			if @pkmn.hasMultipleItems?
			itemcommands[cmdTakeOneItem=itemcommands.length] = _INTL("Take One")
			itemcommands[cmdTakeItems=itemcommands.length] = _INTL("Take All")
			itemcommands[cmdSwapItemOrder=itemcommands.length] = _INTL("Swap Order") if @pkmn.itemCount == 2
			else
			itemcommands[cmdTakeItems=itemcommands.length] = _INTL("Take")
			itemcommands[cmdMoveItem=itemcommands.length] = _INTL("Move")
			end
		end
		itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
		itemcommands[itemcommands.length]             = _INTL("Cancel")
		command = @summaryScene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
		if cmdUseItem>=0 && command==cmdUseItem   # Use
			item = selectItemForUseOnPokemon($PokemonBag,@pkmn) {
			@summaryScene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
			}
			if item
			used = pbUseItemOnPokemon(item,@pkmn,self)
			pbRefreshSingle(@pkmnid)
			return true if used
			end
		elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
			item = @summaryScene.pbChooseItem($PokemonBag) {
			pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
			}
			if item
			if pbGiveItemToPokemon(item,@pkmn,self)
				pbRefreshSingle(@pkmnid)
			end
			end
		elsif cmdTakeItems>=0 && command==cmdTakeItems   # Take/ Take All
			if pbTakeItemsFromPokemon(@pkmn) > 0
			pbRefreshSingle(@pkmnid)
			end
		elsif cmdTakeOneItem>=0 && command==cmdTakeOneItem # Take One
			if pbTakeOneItemFromPokemon(@pkmn)
			pbRefreshSingle(@pkmnid)
			end
		elsif cmdSwapItemOrder>=0 && command==cmdSwapItemOrder # Swap Item Order
			@pkmn.setItems(@pkmn.items.reverse)
			firstItemName = getItemName(@pkmn.items[0])
			secondItemName = getItemName(@pkmn.items[1])
			pbDisplay(_INTL("{1}'s {2} and {3} swapped order.",@pkmn.name,firstItemName,secondItemName))
			pbRefreshSingle(@pkmnid)
		elsif cmdMoveItem>=0 && command==cmdMoveItem   # Move
			hideTileMenu
			item = @pkmn.firstItem
			@summaryScene.pbSetHelpText(_INTL("Move {1} to where?",getItemName(item)))
			loop do
			@summaryScene.pbPreSelect(@pkmnid)
			newpkmnid = @summaryScene.pbChoosePokemon(true,@pkmnid)
			break if newpkmnid<0
			newpkmn = @party[newpkmnid]
			break if newpkmnid==@pkmnid
			if pbGiveItemToPokemon(item,newpkmn,self,false)
				@pkmn.removeItem(item)
				@summaryScene.pbClearSwitching
				pbRefresh
				break
			end
			end
			showTileMenu
		elsif cmdSetItemType>=0 && command==cmdSetItemType
			setItemType
		end
		return false
    end
  
    def setItemType
		typesArray = []
		typeCommands = []
		GameData::Type.each do |typeData|
			next if typeData.pseudo_type
			typesArray.push(typeData.id)
			typeCommands.push(typeData.name)
		end
		typeCommands.push("Cancel")
		existingIndex = typesArray.find_index(@pkmn.itemTypeChosen)
		chosenNumber = @summaryScene.pbShowCommands(_INTL("What type should #{@pkmn.name} become?"),typeCommands,existingIndex)
		if chosenNumber > -1 && chosenNumber < typeCommands.length - 1
			typeSettingItem = @pkmn.hasTypeSetterItem?
			pbDisplay(_INTL("#{@pkmn.name} changed its #{getItemName(typeSettingItem)} to #{typeCommands[chosenNumber]}-type!"))
			@pkmn.itemTypeChosen = typesArray[chosenNumber]
		end
    end
  
    def modifyCommandMenu
		commands   = []
		cmdRename  = -1
		cmdEvolve  = -1
		cmdStyle = -1
	
		# Build the commands
		commands[cmdRename = commands.length]       = _INTL("Rename")
		commands[cmdStyle = commands.length]        = _INTL("Set Style") if pbHasItem?(:STYLINGKIT)
		newspecies = @pkmn.check_evolution_on_level_up
		commands[cmdEvolve = commands.length]       = _INTL("Evolve") if newspecies
		commands[commands.length]                   = _INTL("Cancel")
		
		modifyCommand = @summaryScene.pbShowCommands(_INTL("Do what with {1}?",@pkmn.name),commands)
		if cmdRename >= 0 && modifyCommand == cmdRename
			currentName = @pkmn.name
			pbTextEntry("#{currentName}'s nickname?",0,10,5)
			if pbGet(5)=="" || pbGet(5)==currentName
				@pkmn.name = currentName
			else
				@pkmn.name = pbGet(5)
			return true
			end
		elsif cmdEvolve >= 0 && modifyCommand == cmdEvolve
			pbFadeOutInWithMusic do
				evo = PokemonEvolutionScene.new
				evo.pbStartScreen(@pkmn, newspecies)
				evo.pbEvolution
				evo.pbEndScreen
				@summaryScene.pbRefresh
			end
			return true
		elsif cmdStyle >= 0 && modifyCommand == cmdStyle
			pbStyleValueScreen(@pkmn)
		end
	
		return false
    end
  
    def pbSwitch(oldid,newid)
		if oldid!=newid
			@summaryScene.pbSwitchBegin(oldid,newid)
			tmp = @party[oldid]
			@party[oldid] = @party[newid]
			@party[newid] = tmp
			@summaryScene.pbSwitchEnd(oldid,newid)
		end
    end
  
	# Interface methods
	def pbUpdate
		@summaryScene.update
	end

	def pbHardRefresh
		@summaryScene.pbHardRefresh
	end

	def pbRefresh
		@summaryScene.pbRefresh
	end

	def pbRefreshSingle(i)
		@summaryScene.pbRefreshSingle(i)
	end

	def pbDisplay(string)
		@summaryScene.pbDisplay(string)
	end

	def pbConfirm(text)
		return @summaryScene.pbDisplayConfirm(text)
	end

	def pbShowCommands(helptext,commands,index=0)
		return @summaryScene.pbShowCommands(helptext,commands,index)
	end

	def pbRefreshAnnotations(ableProc)   # For after using an evolution stone
		return if !@summaryScene.pbHasAnnotations?
		annot = []
		for pkmn in @party
			elig = ableProc.call(pkmn)
			annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
		end
		@summaryScene.pbAnnotate(annot)
	end

	def pbClearAnnotations
		@summaryScene.pbAnnotate(nil)
	end

	def pbSetHelpText(helptext)
		@summaryScene.pbSetHelpText(helptext)
	end
  end
  
  class TilingCardsPokemonMenu < TilingCardsMenu_Screen
  end