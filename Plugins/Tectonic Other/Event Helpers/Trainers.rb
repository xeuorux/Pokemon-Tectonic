def perfectTrainer(maxTrainerLevel=15,giveDrop=true)
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone
	}
	pbTrainerDropsItem(maxTrainerLevel) if giveDrop
end

def perfectAncientTrainer
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone
	}
	pbMessage(_INTL("The fleeing trainer dropped some food!"))
	pbReceiveItem(:VANILLATULUMBA)
end

def perfectDittoTrainer(maxTrainerLevel=15)
	blackFadeOutIn() {
		setMySwitch('D',true)
		pbSEPlay("Cries/DITTO",50,50)
		setFollowerGone
	}
	pbTrainerDropsItem(maxTrainerLevel)
end


def perfectAceTrainer(maxTrainerLevel=15)
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone
	}
	pbTrainerDropsItem(maxTrainerLevel,4)
end

def perfectDoubleTrainer(event1,event2,maxTrainerLevel = 15)
	blackFadeOutIn() {
		setMySwitch('D',true)
		pbSetSelfSwitch(event1,'D',true)
		pbSetSelfSwitch(event2,'D',true)
		setFollowerGone(event1)
		setFollowerGone(event2)
	}
	pbTrainerDropsItem(maxTrainerLevel,2,true)
end

def perfectDoubleAncientTrainer(event1,event2)
	blackFadeOutIn() {
		setMySwitch('D',true)
		pbSetSelfSwitch(event1,'D',true)
		pbSetSelfSwitch(event2,'D',true)
		setFollowerGone(event1)
		setFollowerGone(event2)
	}

	pbMessage(_INTL("The fleeing trainers dropped some food!"))
	pbReceiveItem(:VANILLATULUMBA,2)
end

def pbTrainerDropsItem(maxTrainerLevel = 15,multiplier=1,plural=false)
	itemsGiven = candiesForLevel(maxTrainerLevel)
	
	total = 0
	for i in 0...itemsGiven.length/2
		itemsGiven[i*2 + 1] *= multiplier
		total += itemsGiven[i*2 + 1]
	end
	if total == 1
		if plural
			pbMessage(_INTL("One of the fleeing trainers dropped a candy!"))
		else
			pbMessage(_INTL("The fleeing trainer dropped a candy!"))
		end
	else
		if plural
			pbMessage(_INTL("The fleeing trainers dropped some candies!"))
		else
			pbMessage(_INTL("The fleeing trainer dropped some candies!"))
		end
	end
	
	for i in 0...itemsGiven.length/2
		pbReceiveItem(itemsGiven[i*2],itemsGiven[i*2 + 1])
	end
end

def candiesForLevel(level)
  # For a medium slow pokemon (e.g. starters):
  # 10: 200, 15: 500, 20: 1000
  # 25: 1700, 30: 2500, 35: 3500
  # 40: 4800, 45: 6200, 50: 7800
  # 55: 9500, 60: 11,500, 65: 13,500
  itemsGiven = []
  case level
  when 0..10
	itemsGiven = [:EXPCANDYXS,3] # 750
  when 11..15
	itemsGiven = [:EXPCANDYS,1,:EXPCANDYXS,1] # 1250
  when 16..20
	itemsGiven = [:EXPCANDYS,2,:EXPCANDYXS,1] # 2250
  when 21..25
	itemsGiven = [:EXPCANDYS,4] # 4000
  when 26..30
	itemsGiven = [:EXPCANDYM,1,:EXPCANDYS,2] # 6000
  when 31..35
	itemsGiven = [:EXPCANDYM,2] # 8000
  when 36..40
	itemsGiven = [:EXPCANDYM,3] # 12_000
  when 41..45
	itemsGiven = [:EXPCANDYM,4] # 16_000
  when 46..50
	itemsGiven = [:EXPCANDYL,1,:EXPCANDYM,1] # 20_000
  when 51..55
	itemsGiven = [:EXPCANDYL,1,:EXPCANDYM,2] # 24_000
  when 56..60
	itemsGiven = [:EXPCANDYL,1,:EXPCANDYM,3] # 28_000
  when 61..65
	itemsGiven = [:EXPCANDYL,2] # 32_000
  when 65..70
	itemsGiven = [:EXPCANDYL,2,:EXPCANDYM,2] # 40_000
  when 71..100
	itemsGiven = [:EXPCANDYXL,1] # 64_000
  else
	pbMessage(_INTL("Unassigned level passed to pbTrainerDropsItem: #{maxTrainerLevel}")) if $DEBUG
	itemsGiven = [:EXPCANDYXS,2] # 500
  end
  return itemsGiven
end

def defeatTrainer()
	setMySwitch('A',true)
	setFollowerInactive()
end

def defeatDoubleTrainer(event1,event2)
	setMySwitch('A',true)
	pbSetSelfSwitch(event1,'A',true)
	pbSetSelfSwitch(event2,'A',true)
	setFollowerInactive(event1)
	setFollowerInactive(event2)
end

def rejectTooFewPokemon(dialogue,movePlayer=true)
	if $Trainer.able_pokemon_count <= 1
		dialogue = "Unable to start double battle with only 1 able Pokemon." unless dialogue
		pbMessage(dialogue)
		forcePlayerBackwards if movePlayer
		command_end # Exit event processing
	end
end

def forcePlayerBackwards
	new_move_route = RPG::MoveRoute.new
	new_move_route.repeat    = false
	new_move_route.skippable = false
	new_move_route.list.clear
	new_move_route.list.push(RPG::MoveCommand.new(13)) # Backwards
	new_move_route.list.push(RPG::MoveCommand.new(0)) # End
	get_player.force_move_route(new_move_route)
	@move_route_waiting = true if !$game_temp.in_battle # Wait for move route completion
end

def sendOutPokemon(eventID, switch_id = "A")
	showPokeballExit(eventID)
	pbSetSelfSwitch(eventID,switch_id,true)
end

def setFollowerInactive(eventId=0,switch='A')
	followers = getFollowerPokemon(eventId)
	if followers.nil? || followers.length == 0
		pbMessage(_INTL("ERROR: Could not find follower Pokemon!")) if $DEBUG
		return
	end
	followers.each do |follower|
		showBallReturn(follower.x,follower.y)
		pbWait(Graphics.frame_rate/10)
		pbSetSelfSwitch(follower.id,switch,true)
	end
end

def setFollowerGone(eventId=0)
	followers = getFollowerPokemon(eventId)
	if followers.nil? || followers.length == 0
		pbMessage(_INTL("ERROR: Could not find follower Pokemon!")) if $DEBUG
		return
	end
	followers.each do |follower|
		pbSetSelfSwitch(follower.id,'D',true,$game_map.map_id)
	end
end

def getFollowerPokemon(eventId=0)
	x = pbMapInterpreter.get_character(eventId).original_x
	y = pbMapInterpreter.get_character(eventId).original_y
	
	followers = []
	for event in $game_map.events.values
		next unless event.name.downcase.include?("follower")
		xDif = (event.x - x).abs
		yDif = (event.y - y).abs
		next unless xDif <= 1 && yDif <= 1 # Must be touching
		followers.push(event)
    end
	return followers
end

def allTrainersBeaten(events)
	events.each do |event_id|
		trainerAOn = $game_self_switches[[$game_map.map_id,event_id,"A"]]
		trainerDOn = $game_self_switches[[$game_map.map_id,event_id,"D"]]
		trainerBeaten = trainerAOn || trainerDOn
    	if !trainerBeaten
			return false
		end
	end
	return true
end

def allTrainersPerfected(events)
	events.each do |event_id|
		trainerDOn = $game_self_switches[[$game_map.map_id,event_id,"D"]]
    	if !trainerDOn
			return false
		end
	end
	return true
end

def allEventsExclaim(eventIDArray)
	eventIDArray.each do |id|
		showExclamation(id)
		pbWait(10)
	end
end

def wildBattlersFlee(eventIDArray,exclaim = true)
	if exclaim
		allEventsExclaim(eventIDArray)
		pbWait(20)
	end
	blackFadeOutIn {
		pbSEPlay('Battle flee')
		eventIDArray.each do |id|
			pbSetSelfSwitch(id,'D')
		end
	}
end

# Replace placeholder overworld follower sprites
Events.onMapChange += proc { |_sender,*args|
	followerEventGraphicSwap
}

# follower(:TRAINER_TYPE,"Trainer Name", VERSION_NUMBER, PARTY_INDEX*)
AUTO_FOLLOWER_NAME_FLAG_REGEX = /follower\(:([a-zA-Z0-9_]+),"(.+)"(?:,([0-9]+))?(?:,([0-9]+))?\)/

# villainfollower(VILLAIN_NUMBER, FIGHT_NUMBER, PARTY_INDEX*)
RANDOM_NPC_FOLLOWER_NAME_FLAG_REGEX = /randomnpcfollower\((?:([0-9]+)),(?:([0-9]+))(?:,([0-9]+))?\)/

# Followers where the trainer info is in the name
def eachAutoFollowerInMap
    for event in $game_map.events.values
		match = event.name.match(AUTO_FOLLOWER_NAME_FLAG_REGEX)
		next unless match
        yield event, match
    end
end

def eachRandomNPCAutoFollowerInMap
    for event in $game_map.events.values
		match = event.name.match(RANDOM_NPC_FOLLOWER_NAME_FLAG_REGEX)
		next unless match
        yield event, match
    end
end

def eachTrainerWithAutoFollowerInMap
    eachAutoFollowerInMap do |event, match|
        cursed = event.name.match(/cursedfollower/)

        # Parse the event name
        trainerClass = match[1].to_sym
        trainerName = match[2]
        trainerVersion = match[3].to_i || 0
        partyIndex = match[4].to_i || 0

        # Don't use the cursed version if it doesnt actually exist
        if cursed && tarotAmuletActive? && GameData::Trainer.try_get(trainerClass, trainerName, trainerVersion + 1)
            trainerVersion += 1
        end

        begin
            trainer = pbLoadTrainer(trainerClass, trainerName, trainerVersion)
            yield event, trainer, partyIndex
        rescue Exception
            pbPrintException($!)
        end
    end

    eachRandomNPCAutoFollowerInMap do |event, match|
        # Parse the event name
        villainNumber = match[1].to_i
        fightVersion = match[2].to_i || 0
        trainerClass, trainerName, trainerVersion = getRandomNPCTrainerDetails(villainNumber,fightVersion)
        partyIndex = match[3].to_i || 0

        begin
            trainer = pbLoadTrainer(trainerClass, trainerName, trainerVersion)
            yield event, trainer, partyIndex
        rescue Exception
            pbPrintException($!)
        end
    end
end

def followerEventGraphicSwap(reset = false)
    eachTrainerWithAutoFollowerInMap do |event, trainer, partyIndex|
		# Find the pokemon that the event represents
		pokemon = trainer.displayPokemonAtIndex(partyIndex)

		newPages = {}

		# Find all the pages that need to be replaced
		event.event.pages.each_with_index do |page,pageIndex|
			if reset
				next unless page.graphic.character_name.include?("Followers")
			else
				next unless page.graphic.character_name == "00Overworld Placeholder"
			end
			newPages[pageIndex] = createPokemonInteractionEventPage(pokemon,page)
		end

		# Actually replace those pages on the event
		newPages.each do |pageIndex,newPage|
			event.event.pages[pageIndex] = newPage
		end
		
		event.floats = floatingPokemon?(pokemon)
		
		event.refresh
    end

	# Followers where the trainer info is a comment on one or more of the pages
	for event in $game_map.events.values
		match = event.name.match(/pagedfollower/)
		next unless match

		newPages = {}
		
		# Go through each page
		event.event.pages.each_with_index do |page,pageIndex|
			next unless page.graphic.character_name == "00Overworld Placeholder"

			trainerInfo = pbEventCommentInput(page, 1, "Trainer")[0]

			# Parse the comment
			trainerInfoMatch = trainerInfo.match(/:([a-zA-Z0-9_]+),"(.+)"(?:,([0-9]+))?(?:,([0-9]+))?/)
			trainerClass = trainerInfoMatch[1].to_sym
			trainerName = trainerInfoMatch[2]
			trainerVersion = trainerInfoMatch[3].to_i || 0
			partyIndex = trainerInfoMatch[4].to_i || 0

			pokemon = pbLoadTrainer(trainerClass,trainerName,trainerVersion).displayPokemonAtIndex(partyIndex)
			newPages[pageIndex] = createPokemonInteractionEventPage(pokemon,page)
		end

		newPages.each do |pageIndex,newPage|
			event.event.pages[pageIndex] = newPage
		end

		event.refresh
    end
end

def createPokemonInteractionEventPage(pokemon,originalPage = nil)
	# Create the page where the cry happens
	newPage = originalPage ? originalPage.clone : RPG::Event::Page.new
	characterName = GameData::Species.ow_sprite_filename(pokemon.species,pokemon.form,pokemon.gender,pokemon.shiny?).gsub!("Graphics/Characters/","")
	newPage.graphic.character_name = characterName
	newPage.step_anime = true

	# Set the event interaction
	newPage.trigger = 0 # Action button
	newPage.list = []
	push_script(newPage.list,sprintf("Pokemon.play_cry(:%s, %d)",pokemon.species,pokemon.form))
	cryOutMessage = _INTL("{1} cries out!",pokemon.name)
	push_script(newPage.list,sprintf("pbMessage(\"#{cryOutMessage}\")"))

	if pokemon.itemCount == 2
		itemName1 = getItemName(pokemon.items[0])
		itemName2 = getItemName(pokemon.items[1])
		itemMessage = _INTL("It's holding a {1} and a {2}!", itemName1, itemName2)
		push_script(newPage.list,sprintf("pbMessage(\"#{itemMessage}\")"))
	elsif pokemon.itemCount == 1
		itemName = pokemon.firstItemData.name
		itemMessage = _INTL("It's holding a {1}!", itemName)
		push_script(newPage.list,sprintf("pbMessage(\"#{itemMessage}\")"))
	end
	
	push_end(newPage.list)

	return newPage
end