#===============================================================================
#
#===============================================================================
class TilingCardsStorageInteractionMenu_Scene < TilingCardsMenu_Scene
	attr_reader :party

    def cursorFileLocation
		return addLanguageSuffix(("Graphics/Pictures/Party/cursor_pokemon"))
	end

	def tileFileLocation
		path = "Graphics/Pictures/Party/pokemon_menu_tile"
		path += "_dark" if darkMode?
		return _INTL(path)
	end

	def backgroundFadeFileLocation
		return addLanguageSuffix(("Graphics/Pictures/Party/background_fade"))
	end
  
    def initialize(command,pkmn,selected,heldpoke,storageScreen,storageScene,retValWrapper=[false])
		super()
		@command = command
		@pkmn = pkmn
		@selected = selected
		@heldpoke = heldpoke
		@storageScreen = storageScreen
		@storageScene = storageScene
		@buttonRowHeight = 68
		@retValWrapper = retValWrapper
		@xOffset = 204
		@yOffset = 48
    end
  
	def initializeMenuButtons
		super
      	canEditTeam = teamEditingAllowed?
		inDonationBox = !@heldpoke && @selected[0] > -1 && @storageScreen.storage.boxes[@selected[0]].isDonationBox?
		lastPokemonInParty = @pkmn && @selected[0] == -1 && @storageScreen.pbAbleCount <= 1 && @storageScreen.pbAble?(@pkmn)

		case @command
		when 0
			if @heldpoke
				if @storageScreen.storage[@selected[0], @selected[1]] # Is there a pokemon in the spot?
					@cardButtons[:SHIFT] = {
						:label => _INTL("Shift"),
						:active_proc => Proc.new {
							next canEditTeam && !inDonationBox
						},
						:press_proc => Proc.new { |scene|
							@storageScreen.pbSwap(@selected)
							next true
						},
					}
				else
					@cardButtons[:PLACE] = {
						:label => _INTL("Place"),
						:active_proc => Proc.new {
							next canEditTeam
						},
						:press_proc => Proc.new { |scene|
							@storageScreen.pbPlace(@selected)
							next true
						},
					}
				end
			elsif @pkmn
				@cardButtons[:MOVE] = {
					:label => _INTL("Move"),
					:active_proc => Proc.new {
						next canEditTeam && !inDonationBox && !lastPokemonInParty
					},
					:press_proc => Proc.new { |scene|
						@storageScreen.pbHold(@selected)
						next true
					},
				}
			end
		when 1
			@cardButtons[:WITHDRAW] = {
					:label => _INTL("Withdraw"),
					:active_proc => Proc.new {
						next canEditTeam && !inDonationBox
					},
					:press_proc => Proc.new { |scene|
						@storageScreen.pbWithdraw(@selected, @heldpoke)
						next true
					},
				}
		when 2
			@cardButtons[:STORE] = {
					:label => _INTL("Store"),
					:active_proc => Proc.new {
						next canEditTeam && !lastPokemonInParty
					},
					:press_proc => Proc.new { |scene|
						@storageScreen.pbStore(@selected, nil)
						next true
					},
				}
		when 5
			@cardButtons[:SELECT] = {
				:label => _INTL("Select"),
				:active_proc => Proc.new {
						next canEditTeam && !inDonationBox
					},
				:press_proc => Proc.new { |scene|
					@retValWrapper[0] = true
					next true
				},
			}
		end

		@cardButtons[:MASTERDEX] = {
				:label => _INTL("MasterDex"),
				:active_proc => Proc.new {
					$Trainer.has_pokedex
				},
				:press_proc => Proc.new { |scene|
					openSingleDexScreen(@pkmn)
				},
			}

		@cardButtons[:SUMMARY] = {
				:label => _INTL("Summary"),
				:press_proc => Proc.new { |scene|
					@storageScreen.pbSummary(@selected,@heldpoke)
				},
			}

		@cardButtons[:ITEM] = {
				:label => _INTL("Item"),
				:active_proc => Proc.new {
					canEditTeam && !inDonationBox
				},
				:press_proc => Proc.new { |scene|
					next true if itemCommandMenu
				},
			}

		@cardButtons[:MODIFY] = {
				:label => _INTL("Modify"),
				:active_proc => Proc.new {
					canEditTeam && !@pkmn.egg? && !inDonationBox
				},
				:press_proc => Proc.new { |scene|
					next true if modifyCommandMenu
				},
			}

		@cardButtons[:RELEASE] = {
				:label => _INTL("Release"),
				:active_proc => Proc.new {
					canEditTeam && !@pkmn.egg? && !lastPokemonInParty
				},
				:press_proc => Proc.new { |scene|
					@storageScreen.pbRelease(@selected, @heldpoke)
					next true
				},
			}

		if $DEBUG
			@yOffset -= 16
			@cardButtons[:DEBUG] = {
				:label => _INTL("Debug"),
				:press_proc => Proc.new { |scene|
					pbPokemonDebug(@pkmn,@selected,@heldpoke)
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
			end
		end
		itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
		itemcommands[itemcommands.length]             = _INTL("Cancel")
		command = pbShowCommands(_INTL("Do what with an item?"),itemcommands)
		if cmdUseItem>=0 && command==cmdUseItem   # Use
			item = selectItemForUseOnPokemon($PokemonBag,@pkmn)
			if item
				used = pbUseItemOnPokemon(item,@pkmn,self)
				pbRefreshSingle(@selected)
				return true if used
			end
		elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
			item = @storageScene.pbChooseItem($PokemonBag)
			if item
				if pbGiveItemToPokemon(item,@pkmn,self)
					pbRefreshSingle(@selected)
				end
			end
		elsif cmdTakeItems>=0 && command==cmdTakeItems   # Take/ Take All
			if pbTakeItemsFromPokemon(@pkmn) > 0
				pbRefreshSingle(@selected)
			end
		elsif cmdTakeOneItem >= 0 && command == cmdTakeOneItem # Take One
			if pbTakeOneItemFromPokemon(@pkmn)
				pbRefreshSingle(@selected)
			end
		elsif cmdSwapItemOrder >= 0 && command == cmdSwapItemOrder # Swap Item Order
			@pkmn.setItems(@pkmn.items.reverse)
			firstItemName = getItemName(@pkmn.items[0])
			secondItemName = getItemName(@pkmn.items[1])
			pbDisplay(_INTL("{1}'s {2} and {3} swapped order.",@pkmn.name,firstItemName,secondItemName))
			pbRefreshSingle(@selected)
		elsif cmdSetItemType >= 0 && command == cmdSetItemType
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
		chosenNumber = pbShowCommands(_INTL("What type should #{@pkmn.name} become?"),typeCommands,existingIndex)
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
		cmdOmnitutor = -1
	
		# Build the commands
		commands[cmdStyle = commands.length]        = _INTL("Set Style") if pbHasItem?(:STYLINGKIT)
		if $PokemonGlobal.omnitutor_active && !getOmniMoves(@pkmn).empty?
			commands[cmdOmnitutor = commands.length]	= _INTL("OmniTutor")
		end
		commands[cmdRename = commands.length]       = _INTL("Rename")
		newspecies = @pkmn.check_evolution_on_level_up(false)
		commands[cmdEvolve = commands.length]       = _INTL("Evolve") if newspecies
		commands[commands.length]                   = _INTL("Cancel")
		modifyCommand = pbShowCommands(_INTL("Do what with {1}?",@pkmn.name),commands)
		if cmdRename >= 0 && modifyCommand == cmdRename
			currentName = @pkmn.name
			pbTextEntry("#{currentName}'s nickname?",0,Pokemon::MAX_NAME_SIZE,5)
			if pbGet(5) == "" || pbGet(5) == currentName
				@pkmn.name = currentName
			else
				@pkmn.name = pbGet(5)
			end
		elsif cmdEvolve >= 0 && modifyCommand == cmdEvolve
			newspecies = @pkmn.check_evolution_on_level_up(true)
			return false if newspecies.nil?
			pbFadeOutInWithMusic do
				evo = PokemonEvolutionScene.new
				evo.pbStartScreen(@pkmn, newspecies)
				evo.pbEvolution
				evo.pbEndScreen
				pbRefreshSingle(@selected)
			end
			return true
		elsif cmdStyle >= 0 && modifyCommand == cmdStyle
			pbStyleValueScreen(@pkmn)
		elsif cmdOmnitutor >= 0 && modifyCommand == cmdOmnitutor
			omniTutorScreen(@pkmn)
		end
	
		return false
    end
  
	# Interface methods
	def pbUpdate
		@storageScreen.pbUpdate
	end

	def pbHardRefresh
		@storageScreen.pbHardRefresh
	end

	def pbRefresh
		@storageScreen.pbHardRefresh
	end

	def pbRefreshSingle(i)
		@storageScreen.pbRefreshSingle(i)
	end

	def pbDisplay(string)
		@storageScreen.pbDisplay(string)
	end

	def pbConfirm(text)
		return @storageScreen.pbConfirm(text)
	end

	def pbShowCommands(helptext,commands,index=0)
		return @storageScreen.pbShowCommands(helptext,commands,index)
	end

	def pbRefreshAnnotations(ableProc)   # For after using an evolution stone
	end

	def pbClearAnnotations
	end

	def pbSetHelpText(helptext)
	end
end
  
class TilingCardsStorageInteractionMenu < TilingCardsMenu_Screen
end