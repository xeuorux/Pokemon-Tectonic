class Game_Event < Game_Character
	attr_reader   :event
end

def loadBoxPokemonIntoPlaceholders
	echoln("Beginning to load box Pokemon.")

	unusedBoxPokes = []
	boxNum = 0 #rand(30)
	for index in 0...$PokemonStorage.maxPokemon(boxNum)
      pokemon = $PokemonStorage[boxNum][index]
	  next if pokemon.nil?
	  unusedBoxPokes.push(pokemon)
	  echoln("Needing to place Pokemon #{pokemon.name}")
    end

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
	echoln("Converting #{event.id} to #{pokemon.name}")
	
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
	push_script(firstPage.list,sprintf("pbMessage(\"#{pokemon.name} cries out!\")",))
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
      elsif Input.trigger?(Input::UP) && !party.nil? && @partyindex>0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && !party.nil? && @partyindex<@party.length-1
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