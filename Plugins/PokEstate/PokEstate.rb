class Game_Event < Game_Character
	attr_reader   :event
end

class PokemonGlobalMetadata
	attr_accessor   :estate_box
	attr_accessor   :estate_teleport
end

def estate_box()
	$PokemonGlobal.estate_box = 0 if !$PokemonGlobal.estate_box
	return $PokemonGlobal.estate_box
end

ESTATE_MAP_IDS 				= [148,150,151,152,153,154,160,161]
FALLBACK_MAP_ID				= 149
ESTATE_MAP_ENTRANCES	= [[20,30,8],[31,18,4],[8,18,6]] # S, E, W

def isInEstate?
	return $game_map.map_id == FALLBACK_MAP_ID || ESTATE_MAP_IDS.include?($game_map.map_id)
end

def transferToEstate(boxNum = 0,entrance=0)
	$PokemonGlobal.estate_box = boxNum
	background = $PokemonStorage[boxNum].background
	newMap = ESTATE_MAP_IDS[background] || FALLBACK_MAP_ID
	
	# Notate the current location if outside the estate
	if !isInEstate?
		$PokemonGlobal.estate_teleport = [$game_map.map_id,$game_player.x,$game_player.y,$game_player.direction]
	end

	# Transfer the player to the new spot
	echoln("Transferring player to estate or box number #{boxNum}")
	$game_temp.player_transferring = true
	$game_temp.setup_sames = true
	$game_temp.player_new_map_id    = 	newMap
	position = ESTATE_MAP_ENTRANCES[entrance]
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
	if $PokemonGlobal.estate_teleport.nil?
		pbMessage("ERROR: Cannot find location to teleport you back to.")
		pbMessage("Bringing you to Casaba Villa instead.")
		$game_temp.player_transferring = true
		$game_temp.player_new_map_id    = 	33
		$game_temp.player_new_x         =	20
		$game_temp.player_new_y         = 	38
		$game_temp.player_new_direction = 	Up
	else
		tele = $PokemonGlobal.estate_teleport
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

def truckChoices()
	commandLeaveEstate = -1
	commandGoToOtherPlot = -1
	commandCancel = -1
	commands = []
	commands[commandGoToOtherPlot = commands.length] = "Drive To Plot"
	commands[commandLeaveEstate = commands.length] = "Leave PokÉstate"
	commands[commandCancel = commands.length] = "Cancel"
	
	command = pbMessage(_INTL("What would you like to do?"),commands,commandCancel)
	
	if commandLeaveEstate > -1 && command == commandLeaveEstate
		teleportPlayerBack()
	elsif commandGoToOtherPlot > -1 && command == commandGoToOtherPlot
		transferToEstateOfChoice()
	end
end

Events.onMapSceneChange += proc { |_sender, e|
	scene      = e[0]
	mapChanged = e[1]
	next if !scene || !scene.spriteset
	next unless isInEstate?()
	label = _INTL("PokÉstate #{estate_box +  1}")
	scene.spriteset.addUserSprite(LocationWindow.new(label))
}

def loadBoxPokemonIntoPlaceholders
	echoln("Beginning to load box Pokemon.")
	
	# Find all the pokemon that need to be represented
	unusedBoxPokes = []
	boxNum = estate_box
	for index in 0...$PokemonStorage.maxPokemon(boxNum)
      pokemon = $PokemonStorage[boxNum][index]
	  next if pokemon.nil?
	  unusedBoxPokes.push(pokemon)
    end

	# Load all the pokemon into the placeholders
	events = $game_map.events.values.shuffle()
	for event in events
		next unless event.name.downcase.include?("boxplaceholder")
		break if unusedBoxPokes.length == 0
		pokemon = unusedBoxPokes.delete_at(rand(unusedBoxPokes.length))
		convertEventToPokemon(event,pokemon)
    end
end

def convertEventToPokemon(event,pokemon)
	actualEvent = event.event
	
	species = pokemon.species
	form = pokemon.form
	speciesData = GameData::Species.get(species)
	
	# Create the first page, where the cry happens
	firstPage = RPG::Event::Page.new
	wasCustom = actualEvent.pages[0].move_type == 3
	actualEvent.pages[0] = firstPage
	fileName = species.to_s
	fileName += "_" + form.to_s if form != 0
	firstPage.graphic.character_name = "Followers/#{fileName}"
	firstPage.graphic.direction = 2 + rand(4) * 2
	firstPage.step_anime = true # Animate while still
	firstPage.trigger = 0 # Action button
	firstPage.move_type = 1 if !wasCustom # Random
	firstPage.move_frequency = [[speciesData.base_stats[:SPEED] / 25,0].max,5].min
	firstPage.list = []
	push_script(firstPage.list,sprintf("Pokemon.play_cry(:%s, %d)",speciesData.id,form))
	push_script(firstPage.list,sprintf("ranchChoices(#{pokemon.personalID})",))
	firstPage.list.push(RPG::EventCommand.new(0,0,[]))
	
	event.refresh()
end

def push_script(list,script,indent=0)
    return if !script
    first = true
    textsplit2 = script.split(/\n/)
    for i in 0...textsplit2.length
		textchunk = textsplit2[i].gsub(/\s+$/,"")
		if textchunk && textchunk!=""
			list.push(RPG::EventCommand.new((first) ? 355 : 655,indent,[textchunk]))
			first = false
		end
    end
end

def ranchChoices(personalID = -1)
	return if personalID < 0
	
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

	commands = []
	cmdSummary = -1
	cmdTake = -1
	cmdRename = -1
	cmdCancel = -1
	commands[cmdSummary = commands.length] = _INTL("View Summary")
	commands[cmdTake = commands.length] = _INTL("Take")
	commands[cmdRename = commands.length] = _INTL("Rename")
	commands[cmdCancel = commands.length] = _INTL("Cancel")
	while true
		command = pbMessage(_INTL("What would you like to do with #{pokemon.name}?"),commands,commands.length)
		if command > -1 && command == cmdSummary
			pbFadeOutIn {
				scene = PokemonSummary_Scene.new
				screen = PokemonSummaryScreen.new(scene)
				screen.pbStartSingleScreen(pokemon)
			}
		elsif command > -1 && command == cmdRename
			currentName = pokemon.name
			pbTextEntry("#{currentName}'s nickname?",0,10,5)
			if pbGet(5)=="" || pbGet(5) == currentName
			  pokemon.name = currentName
			else
			  pokemon.name = pbGet(5)
			end
			convertEventToPokemon(get_self,pokemon)
		elsif command > -1 && command == cmdTake
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
				convertEventToPokemon(get_self,chosenPokemon)
				break
			else  
				$PokemonStorage[currentBox][currentSlot] = nil
				$Trainer.party[$Trainer.party.length] = pokemon
				pbMessage(_INTL("You pick #{pokemon.name} up and add it to your party."))
				get_self().event.pages[0] = RPG::Event::Page.new
				get_self().refresh()
				break
			end
		elsif command > -1 && command == cmdCancel
			break
		end
	end
end

def setDownIntoEstate(pokemon)
	return unless isInEstate?()
	
	if $Trainer.able_pokemon_count == 1 && !pokemon.fainted?
		pbMessage("Can't set down your last able Pokemon!")
		return false
	end

	box = $PokemonStorage[$PokemonGlobal.estate_box]
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

class PokemonSummaryScreen
  def pbStartSingleScreen(pokemon)
    @scene.pbStartSingleScene(pokemon)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end
end

class PokemonSummary_Scene
  def pbStartSingleScene(pokemon)
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @party      = nil
    @partyindex = -1
    @pokemon    = pokemon
    @inbattle   = false
    @page = 1
    @typebitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Summary/markings")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 206
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon,@viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::Center)
    @sprites["pokeicon"].x       = 46
    @sprites["pokeicon"].y       = 92
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"] = ItemIconSprite.new(30,320,@pokemon.item_id,@viewport)
    @sprites["itemicon"].blankzero = true
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible     = false
    @sprites["movepresel"].preselected = true
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible = false
    @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonpresel"].visible     = false
    @sprites["ribbonpresel"].preselected = true
    @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonsel"].visible = false
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = 350
    @sprites["uparrow"].y = 56
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = 350
    @sprites["downarrow"].y = 260
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["markingbg"] = IconSprite.new(260,88,@viewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Summary/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["markingsel"] = IconSprite.new(0,0,@viewport)
    @sprites["markingsel"].setBitmap("Graphics/Pictures/Summary/cursor_marking")
    @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height/2
    @sprites["markingsel"].visible = false
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"],2)
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def pbScene
    @pokemon.play_cry
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        @pokemon.play_cry
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page==4
          pbPlayDecisionSE
          pbMoveSelection
          dorefresh = true
        elsif @page==5
          pbPlayDecisionSE
          pbRibbonSelection
          dorefresh = true
        elsif !@inbattle
          pbPlayDecisionSE
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && !@party.nil? && @partyindex>0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && !@party.nil? && @partyindex<@party.length-1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = 5 if @page>5
        if @page!=oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = 5 if @page>5
        if @page!=oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
end

class Game_Temp
	attr_accessor :setup_sames
	
	#-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @message_window_showing = false
    @common_event_id        = 0
    @in_battle              = false
    @battle_abort           = false
    @battleback_name        = ''
    @in_menu                = false
    @menu_beep              = false
    @menu_calling           = false
    @debug_calling          = false
    @player_transferring    = false
    @player_new_map_id      = 0
    @player_new_x           = 0
    @player_new_y           = 0
    @player_new_direction   = 0
    @transition_processing  = false
    @transition_name        = ""
    @to_title               = false
    @fadestate              = 0
    @background_bitmap      = nil
    @message_window_showing = false
    @transition_processing  = false
    @mart_prices            = {}
	@setup_sames			= false
  end
end

class Scene_Map
	def transfer_player(cancelVehicles=true)
		$game_temp.player_transferring = false
		pbCancelVehicles($game_temp.player_new_map_id) if cancelVehicles
		autofade($game_temp.player_new_map_id)
		pbBridgeOff
		@spritesetGlobal.playersprite.clearShadows
		if $game_map.map_id != $game_temp.player_new_map_id || $game_temp.setup_sames
		  $MapFactory.setup($game_temp.player_new_map_id)
		end
		$game_temp.setup_sames = false
		$game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
		case $game_temp.player_new_direction
		when 2 then $game_player.turn_down
		when 4 then $game_player.turn_left
		when 6 then $game_player.turn_right
		when 8 then $game_player.turn_up
		end
		$game_player.straighten
		$game_map.update
		disposeSpritesets
		RPG::Cache.clear
		createSpritesets
		if $game_temp.transition_processing
		  $game_temp.transition_processing = false
		  Graphics.transition(20)
		end
		$game_map.autoplay
		Graphics.frame_reset
		Input.update
	end
end

def pbPokeCenterPC
	pbMessage(_INTL("\\se[PC open]The Pokémon Storage System was opened."))
    command = 0
    loop do
		commands = [_INTL("Organize Boxes"),
			_INTL("Withdraw Pokémon"),
			_INTL("Deposit Pokémon"),
			_INTL("Visit PokÉstate"),
			_INTL("Log Out")]
		command = pbShowCommands(nil,commands,-1)
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
		elsif command == 3 # Estate
			break if transferToEstateOfChoice()
		else
			break
		end
    end
	pbSEPlay("PC close")
end