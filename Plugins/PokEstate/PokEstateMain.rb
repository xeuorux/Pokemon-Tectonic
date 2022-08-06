SaveData.register(:pokestate_tracker) do
	ensure_class :PokEstate
	save_value { $PokEstate }
	load_value { |value| $PokEstate = value }
	new_game_value { PokEstate.new }
end

class DexCompletionAwardHandlerHash < HandlerHash2
	def trigger(symbols, newAwardsArray)
		handlers = @hash.reject{|key,value| symbols.include?(key)}
		handlers.each do |handlerID,handler|
			next if handler.nil?
			begin
				newAward = handler.call($Trainer.pokedex)
				if !newAward.nil?
					newAward.push(handlerID)
					newAwardsArray.push(newAward)
				end
			rescue
				pbMessage(_INTL("A recoverable error has occured. Please report the following to a programmer."))
				pbPrintException($!)
			end
		end

		return newAwardsArray
	end
end

class PokEstate
	attr_reader   :estate_box
	attr_reader   :estate_teleport
	attr_reader   :stories_progress
	attr_reader   :stories_count

	GrantAwards 			= DexCompletionAwardHandlerHash.new
	LoadDataDependentAwards = Event.new

	def initialize()
		@estate_box = 0
		@estate_teleport = nil
		@stories_progress = 0
		@stories_count = [1] * Settings::NUM_STORAGE_BOXES
		@awardsGranted = []
	end

	def awardsGranted()
		@awardsGranted = [] if @awardsGranted.nil?
		return @awardsGranted
	end

	def isInEstate?
		return $game_map.map_id == FALLBACK_MAP_ID || ESTATE_MAP_IDS.include?($game_map.map_id)
	end

	def transferToEstate(boxNum = 0,entrance=-1)
		@estate_box = boxNum
		background = $PokemonStorage[boxNum].background
		newMap = ESTATE_MAP_IDS[background] || FALLBACK_MAP_ID
		
		# Notate the current location if outside the estate
		if !isInEstate?
			@estate_teleport = [$game_map.map_id,$game_player.x,$game_player.y,$game_player.direction]
		end
	
		# Transfer the player to the new spot
		echoln("Transferring player to estate or box number #{boxNum}")
		$game_temp.player_transferring = true
		$game_temp.setup_sames = true
		$game_temp.player_new_map_id    = 	newMap
		if entrance == -1
			position = [$game_player.x, $game_player.y, $game_player.direction]
		else
			position = ESTATE_MAP_ENTRANCES[entrance]
		end
		position = position || ESTATE_MAP_ENTRANCES[entrance]
		$game_temp.player_new_x         =	position[0]
		$game_temp.player_new_y         = 	position[1]
		$game_temp.player_new_direction = 	position[2]
		Graphics.freeze
		$game_temp.transition_processing = true
		$game_temp.transition_name       = ""
	end
	
	def transferToWesterEstate()
		westerBox = estate_box - 1
		westerBox = Settings::NUM_STORAGE_BOXES-1 if westerBox < 0
		transferToEstate(westerBox,1)
	end
	
	def transferToEasterEstate()
		easterValue = estate_box + 1
		easterValue = 0 if easterValue >= Settings::NUM_STORAGE_BOXES
		transferToEstate(easterValue,2)
	end
	
	def teleportPlayerBack()
		if @estate_teleport.nil?
			pbMessage("ERROR: Cannot find location to teleport you back to.")
			pbMessage("Bringing you to the fallback return position.")
			$game_temp.player_transferring = true
			$game_temp.player_new_map_id    =  FALLBACK_RETURN_POSION[0]
			$game_temp.player_new_x         =	FALLBACK_RETURN_POSION[1]
			$game_temp.player_new_y         = 	FALLBACK_RETURN_POSION[2]
			$game_temp.player_new_direction = 	Up
		else
			tele = @estate_teleport
			$game_temp.player_transferring = true
			$game_temp.player_new_map_id    = 	tele[0]
			$game_temp.player_new_x         =	tele[1]
			$game_temp.player_new_y         = 	tele[2]
			$game_temp.player_new_direction = 	tele[3]
		end
		Graphics.freeze
		$game_temp.transition_processing = true
		$game_temp.transition_name       = ""
	end
	
	def transferToEstateOfChoice()
		params = ChooseNumberParams.new
		params.setRange(1, Settings::NUM_STORAGE_BOXES)
		params.setDefaultValue(estate_box+1)
		params.setCancelValue(0)
		boxChoice = pbMessageChooseNumber(_INTL("Which plot would you like to visit?"),params)
		boxChoice -= 1
		return false if boxChoice <= -1
		return false if isInEstate?() && boxChoice == estate_box
		transferToEstate(boxChoice,0)
		return true
	end
	
	def changeLandscape()
		papers = $PokemonStorage.availableWallpapers
		index = 0
		for i in 0...papers[1].length
			if papers[1][i]==$PokemonStorage[estate_box].background
				index = i; break
			end
		end
		papers[0].push(_INTL("Cancel"))
		chosenPaper = pbMessage(_INTL("Pick the landscape you'd like for this plot."),papers[0],papers[0].length,nil,index)
		return if chosenPaper == papers[0].length - 1 || chosenPaper == index
		$PokemonStorage[estate_box].background = chosenPaper
		transferToEstate(estate_box,3)
	end
	
	def truckChoices()
		commandLeaveEstate = -1
		commandGoToOtherPlot = -1
		commandCancel = -1
		commands = []
		commands[commandGoToOtherPlot = commands.length] = _INTL("Drive To Plot")
		commands[commandLeaveEstate = commands.length] = _INTL("Leave PokÉstate")
		commands[commandCancel = commands.length] = _INTL("Cancel")
		
		command = pbMessage(_INTL("What would you like to do?"),commands,commandCancel+1)
		
		if commandLeaveEstate > -1 && command == commandLeaveEstate
			teleportPlayerBack()
		elsif commandGoToOtherPlot > -1 && command == commandGoToOtherPlot
			transferToEstateOfChoice()
		end
	end

	def careTakerInteraction
		if COMPLETION_AWARDS_FEATURE_AVAILABLE
			newAwards = findNewAwards()
			if newAwards.length != 0
				if newAwards.length == 1
					pbMessage(_INTL("You've earned a new PokéDex completion reward!"))
				else
					pbMessage(_INTL("You've earned #{newAwards.length} new PokéDex completion rewards!"))
				end
				if newAwards.length < 5
					newAwards.each do |newAwardInfo|
						awardReward = newAwardInfo[0]
						awardDescription = newAwardInfo[1]
						pbMessage(_INTL("For collecting #{awardDescription}, please take this."))
						if awardReward.is_a?(Array)
							pbReceiveItem(awardReward[0],awardReward[1])
						else
							pbReceiveItem(awardReward)
						end
						awardsGranted.push(newAwardInfo[2])
					end
				else
					pbMessage(_INTL("That's so many! I'll just give you all the rewards at once."))
					itemsToGrantHash = {}
					newAwards.each do |newAwardInfo|
						awardReward = newAwardInfo[0]
						awardDescription = newAwardInfo[1]
						itemCount = 1
						if awardReward.is_a?(Array)
							itemGrant = awardReward[0]
							itemCount = awardReward[1]
						else
							itemGrant = awardReward
						end
						awardsGranted.push(newAwardInfo[2])
						if !itemsToGrantHash.has_key?(itemGrant)
							itemsToGrantHash[itemGrant] = itemCount
						else
							itemsToGrantHash[itemGrant] += itemCount
						end
					end
					itemsToGrantHash.each do |item,count|
						pbReceiveItem(item,count)
					end
				end
			end
		end
		caretakerChoices()
	end

	def awardGranted?(awardID)
		return awardsGranted.include?(awardID)
	end

	def findNewAwards
		newAwardsArray = []
		$Trainer.pokedex.resetOwnershipCache()
		newAwardsArray = GrantAwards.trigger(awardsGranted,newAwardsArray)
		return newAwardsArray
	end
	
	def caretakerChoices()
		commandLandscape = -1
		commandReceiveUpdate = -1
		commandCancel = -1
		commandScrubAwards = -1
		commands = []
		commands[commandLandscape = commands.length] = _INTL("Landscape")
		commands[commandScrubAwards = commands.length] = _INTL("Scrub Awards") if COMPLETION_AWARDS_FEATURE_AVAILABLE && $DEBUG
		commands[commandReceiveUpdate = commands.length] = _INTL("Hear Story") if STORIES_FEATURE_AVAILABLE
		commands[commandCancel = commands.length] = _INTL("Cancel")
		
		command = pbMessage(_INTL("What would you like to do?"),commands,commandCancel+1)
		
		if commandLandscape > -1 && command == commandLandscape
			changeLandscape()
		elsif commandReceiveUpdate > -1 && command == commandReceiveUpdate
			tryHearStory()
		elsif commandScrubAwards > -1 && command == commandScrubAwards
			@awardsGranted.clear
			pbMessage(_INTL("Scrubbed awards."))
		end
	end

	def load_estate_box()
		# Find all the pokemon that need to be represented
		unusedBoxPokes = []
		boxNum = estate_box
		for index in 0...$PokemonStorage.maxPokemon(boxNum)
		  pokemon = $PokemonStorage[boxNum][index]
		  next if pokemon.nil?
		  unusedBoxPokes.push(pokemon)
		end
		
		# Find the feeding bowl, if  any
		feedingBowl = nil
		for event in $game_map.events.values
			if event.name.downcase.include?("feedingbowl")
				feedingBowl = event 
				break
			end
		end
	
		# Find the estate caretaker, if any
		for event in $game_map.events.values
			if event.name.downcase.include?("caretaker")
				convertEventToCaretaker(event,boxNum)
				break
			end
		end

		# Load all data dependent events
		LoadDataDependentAwards.trigger
	
		# Load all the pokemon into the placeholders
		events = $game_map.events.values.shuffle()
		for event in events
			next unless event.name.downcase.include?("boxplaceholder")
			if unusedBoxPokes.length != 0
				pokemon = unusedBoxPokes.delete_at(rand(unusedBoxPokes.length))
				convertEventToPokemon(event,pokemon)
			else
				# Scrub all others
				event.event.pages = [RPG::Event::Page.new]
				event.refresh
			end
		end
	end
	
	def convertEventToPokemon(event,pokemon)
		actualEvent = event.event
		
		species = pokemon.species
		form = pokemon.form
		speciesData = GameData::Species.get(species)
		
		originalPage = actualEvent.pages[0]
		
		displayedMessage = nil
	
		# Find a message comment, if present
		list = originalPage.list
		for i in 0...list.length
		  next if list[i].code!=108   # Comment (first line)
		  command = list[i].parameters[0]
		  for j in (i+1)...list.length
			break if list[j].code!=408   # Comment (continuation line)
			command += "\r\n"+list[j].parameters[0]
		  end
		  displayedMessage = command
		  displayedMessage.gsub!("\\P",pokemon.name)
		  break
		end
		
		# Create the first page, where the cry happens
		firstPage = RPG::Event::Page.new
		fileName = species.to_s
		fileName += "_" + form.to_s if form != 0
		firstPage.graphic.character_name = "Followers/#{fileName}"
		beginWandering(firstPage,pokemon,originalPage.step_anime)
		firstPage.move_type = originalPage.move_type
		if originalPage.move_type == 1 # Random
			firstPage.graphic.direction = 2 + rand(4) * 2
			firstPage.direction_fix = false
		else
			firstPage.graphic.direction = originalPage.graphic.direction
			firstPage.direction_fix = originalPage.direction_fix
		end
		firstPage.trigger = 0 # Action button
		firstPage.list = []
		push_text(firstPage.list,displayedMessage) if displayedMessage
		push_script(firstPage.list,sprintf("Pokemon.play_cry(:%s, %d)",speciesData.id,form))
		push_script(firstPage.list,sprintf("$PokEstate.estateChoices(#{event.id},#{pokemon.personalID})",))
		firstPage.list.push(RPG::EventCommand.new(0,0,[]))
		
		actualEvent.pages[0] = firstPage
		
		event.floats = floatingSpecies?(pokemon.species,pokemon.form)
		
		event.refresh()
	end
	
	def convertEventToCaretaker(event,boxID)
		# Create the first page, where the cry happens
		firstPage = RPG::Event::Page.new
		caretakerSprite = CARETAKER_SPRITES[boxID % CARETAKER_SPRITES.length]
		firstPage.graphic.character_name = caretakerSprite
		firstPage.trigger = 0 # Action button
		firstPage.list = []
		push_text(firstPage.list,"Hello, I am the caretaker of this plot.")
		push_script(firstPage.list,sprintf("$PokEstate.careTakerInteraction()",))
		firstPage.list.push(RPG::EventCommand.new(0,0,[]))
		
		event.event.pages[0] = firstPage
		event.refresh()
	end
	
	def estateChoices(eventID=-1,personalID = -1)
		return if personalID < 0 || eventID < 0
		
		pokemon = nil
		currentBox = -1
		currentSlot = -1
		for box in -1...$PokemonStorage.maxBoxes
			for slot in 0...$PokemonStorage.maxPokemon(box)
				pkmn = $PokemonStorage[box][slot]
				next if pkmn.nil?
				if pkmn.personalID == personalID
					pokemon = pkmn
					currentBox = box
					currentSlot = slot
					break
				end
			end
		end
	
		return if pokemon.nil?

		eventCalling = $game_system.map_interpreter.get_event(eventID)
		return if eventCalling.nil?
	
		commands = []
		cmdSummary = -1
		cmdTake = -1
		cmdInteract = -1
		cmdRename = -1
		cmdCancel = -1
		commands[cmdSummary = commands.length] = _INTL("View Summary")
		commands[cmdTake = commands.length] = _INTL("Take")
		commands[cmdInteract = commands.length] = _INTL("Interact")
		commands[cmdRename = commands.length] = _INTL("Rename")
		commands[cmdCancel = commands.length] = _INTL("Cancel")
		command = 0
		while true
			command = pbMessage(_INTL("What would you like to do with #{pokemon.name}?"),commands,commands.length,nil,command)
			if cmdSummary > -1 && command == cmdSummary
				pbFadeOutIn {
					scene = PokemonSummary_Scene.new
					screen = PokemonSummaryScreen.new(scene)
					screen.pbStartSingleScreen(pokemon)
				}
			elsif cmdRename > -1 && command == cmdRename
				currentName = pokemon.name
				pbTextEntry("#{currentName}'s nickname?",0,10,5)
				if pbGet(5)=="" || pbGet(5) == currentName
				  pokemon.name = currentName
				else
				  pokemon.name = pbGet(5)
				end
				convertEventToPokemon(eventCalling,pokemon)
			elsif cmdTake > -1 && command == cmdTake
				if $Trainer.party_full?
					pbPlayDecisionSE
					pbMessage(_INTL("Party is full, choose a Pokemon to swap out."))
					pbChooseNonEggPokemon(1,3)
					chosenIndex = pbGet(1)
					next if chosenIndex == -1
					chosenPokemon = $Trainer.party[chosenIndex]
					chosenPokemon.heal
					$PokemonStorage[currentBox][currentSlot] = chosenPokemon
					$Trainer.party[chosenIndex] = pokemon
					pbMessage(_INTL("You pick #{pokemon.name} up and add it to your party."))
					pbMessage(_INTL("And place #{chosenPokemon.name} down into the Estate."))
					convertEventToPokemon(eventCalling,chosenPokemon)
					break
				else  
					$PokemonStorage[currentBox][currentSlot] = nil
					$Trainer.party[$Trainer.party.length] = pokemon
					pbMessage(_INTL("You pick #{pokemon.name} up and add it to your party."))
					eventCalling.event.pages[0] = RPG::Event::Page.new
					eventCalling.refresh()
					break
				end
			elsif cmdInteract > -1 && command == cmdInteract
				prev_direction = eventCalling.direction
				eventCalling.direction_fix = false
				eventCalling.turn_toward_player
				if defined?(Events.OnTalkToFollower)
					Events.OnTalkToFollower.trigger(pokemon,eventCalling.x,eventCalling.y,rand(6))
				end
				if rand < 0.5
					beginWandering(eventCalling.event.pages[0],pokemon)
					eventCalling.refresh
				else
					eventCalling.turn_generic(prev_direction)
				end
			elsif cmdCancel > -1 && command == cmdCancel
				break
			end
		end
	end
	
	def beginWandering(page,pokemon,stepAnimation=false)
		speciesData = GameData::Species.get(pokemon.species)
		page.direction_fix = false
		page.move_type = 1 # Random
		page.step_anime = stepAnimation || floatingSpecies?(pokemon.species,pokemon.form)
		page.move_frequency = [[speciesData.base_stats[:SPEED] / 25,0].max,5].min
	end
	
	def setDownIntoEstate(pokemon)
		return unless isInEstate?()
		
		if $Trainer.able_pokemon_count == 1 && !pokemon.fainted?
			pbMessage("Can't set down your last able Pokemon!")
			return false
		end
	
		box = $PokemonStorage[@estate_box]
		if box.full?
			pbMessage("Can't set #{pokemon.name} down into the current Estate plot because it is full.")
			return false
		end
		
		dir = $game_player.direction
		x = $game_player.x
		y = $game_player.y
		case dir
		when Up
			y -= 1
		when Right
			x += 1
		when Left
			x -= 1
		when Down
			y += 1
		end
		
		if !$game_map.passableStrict?(x,y,dir)
			pbMessage("Can't set #{pokemon.name} down, the spot in front of you is blocked.")
			return false
		end
		
		pokemon.heal
		
		# Place the pokemon into the box
		for i in 0..box.length
			next if !box[i].nil?
			box[i] = pokemon
			break
		end
	
		if pokemon.hasItem?
			itemName = GameData::Item.get(pokemon.item).real_name
			if pbConfirmMessageSerious(_INTL("{1} is holding an {2}. Would you like to take it before transferring?", pokemon.name, itemName))
				pbTakeItemFromPokemon(pokemon)
			end
		end
		
		# Put the pokemon into an event on the current map
		events = $game_map.events.values.shuffle()
		for event in events
			next unless event.name.downcase.include?("boxplaceholder")
			convertEventToPokemon(event,pokemon)
			event.moveto(x,y)
			event.direction = dir
			break
		end
		return true
	end

	def currentEstateBox()
		return nil if !isInEstate?
		return $PokemonStorage[@estate_box]
	end

	def incrementStoriesProgress()
		@stories_progress += 1
		if @stories_progress > STEPS_TILL_NEW_STORY
			@stories_progress = 0
			for box in -1...$PokemonStorage.maxBoxes
				next if @stories_count[box] >= MAX_STORIES_STORAGE
				count = 0
				$PokemonStorage[box].each { |pkmn| count += 1 if !pkmn.nil? }
				chance = NEW_STORY_PERCENT_CHANCE_PER_POKEMON * count
				if rand(100) < chance
					@stories_count[box] += 1 
				end
			end
		end
	end
 
	def tryHearStory()
		if currentEstateBox().empty?
			pbMessage(_INTL("There are no Pokemon in this plot to share stories about."))
		elsif @stories_count[@estate_box] <= 0
			pbMessage(_INTL("I regret to say that I have no stories to share about this plot. Please come back later."))
		else
			@stories_count[@estate_box] -= 1
			shareStory()
		end
	end

	def shareStory()
		if currentEstateBox().empty?
			return
		end
		pbMessage(_INTL("Story here!"))
	end
end

Events.onMapSceneChange += proc { |_sender, e|
	scene      = e[0]
	mapChanged = e[1]
	next if !scene || !scene.spriteset
	next unless $PokEstate.isInEstate?
	boxName = $PokemonStorage[$PokEstate.estate_box].name
	label = _INTL("PokÉstate #{$PokEstate.estate_box +  1}")
	label += " - #{boxName}" if !boxName.eql?("Box #{$PokEstate.estate_box +  1}")
	scene.spriteset.addUserSprite(LocationWindow.new(label))
}

Events.onStepTaken += proc {
	$PokEstate.incrementStoriesProgress() if !$PokEstate.isInEstate?()
}

def transferToEasterEstate
	$PokEstate.transferToEasterEstate
end

def transferToWesterEstate
	$PokEstate.transferToWesterEstate
end