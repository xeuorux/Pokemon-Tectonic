VALID_FORMS = [
    [:DARMANITAN,1],
    [:GDARMANITAN,1],
    [:LYCANROC,2],
    [:ROTOM,1],
    [:ROTOM,2],
    [:ROTOM,3],
    [:ROTOM,4],
    [:ROTOM,5],
    [:SAWSBUCK,1],
    [:SAWSBUCK,2],
    [:SAWSBUCK,3],
]

FLOOR_MAP_IDS = [
    425,
    426,
    427,
    428,
]

STARTING_TRAINER_HEALTH = 20

##############################################################
# Game mode class
##############################################################
class TectonicRogueGameMode
    attr_reader :speciesForms

    ##############################################################
    # Initialization
    ##############################################################

    def initialize
        @active = false
        @currentFloorTrainers = []
        @currentFloorMapID = -1
        @currentFloorDepth = 0
        @trainerHealth = STARTING_TRAINER_HEALTH
    end
    
    def loadValidSpecies
        @speciesForms = []
        GameData::Species.each do |speciesData|
            next if speciesData.form != 0 && !VALID_FORMS.include?([speciesData.id,speciesData.form])
            next unless speciesData.get_evolutions(true).empty?
            next if isLegendary?(speciesData.species)
            @speciesForms.push([speciesData.id,speciesData.form])
        end
    end

    def beginRun
        @active = true
        loadValidSpecies

        $TectonicRogue.moveToNextFloor

        chooseStartingPokemon
        giveStartingItems
    end

    def giveStartingItems
        # Nothing yet
        pbReceiveItem(:SITRUSBERRY)
        pbReceiveItem(:STRENGTHHERB)
        pbReceiveItem(:INTELLECTHERB)
    end

    def active?
        return @active
    end

    ##############################################################
    # Health and losing
    ##############################################################
    def removeTrainerHealth(amount = 1)
        @trainerHealth -= amount
        if amount == 1
            pbMessage(_INTL("You lost a health point!"))
        else
            pbMessage(_INTL("You lost #{amount} health points!"))
        end
        if @trainerHealth <= 0
            loseRun
        else
            pbMessage(_INTL("You have #{@trainerHealth} remaining."))
        end
    end

    def loseRun
        pbMessage(_INTL("You've lost this run."))
        PokemonPartyShowcase_Scene.new($Trainer.party,true) # Take party snapshot

        # Delete the current save
        SaveData.delete_file($storenamefilesave)

        pbCallTitle # Reset the game
    end

    ##############################################################
    # Pokemon selection
    ##############################################################

    def chooseStartingPokemon
        chooseGiftPokemon(2)
        chooseGiftPokemon(3)
        chooseGiftPokemon(4)
    end

    def chooseGiftPokemon(numberOfChoices = 3)
        speciesFormChoices = getSpeciesFormChoices(numberOfChoices)
        displayChoices = []
        speciesFormChoices.each do |speciesFormArray|
            speciesID = speciesFormArray[0]
            formNumber = speciesFormArray[1]

            speciesFormData = GameData::Species.get_species_form(speciesID,formNumber)
            speciesFormName = speciesFormData.name
            speciesFormName = _INTL("#{speciesFormName} (#{speciesFormData.form_name})") if formNumber != 0
            displayChoices.push(speciesFormName)
        end

        while true
            result = pbShowCommands(nil,displayChoices)
    
            chosenDisplayName = displayChoices[result]
            speciesFormChosen = speciesFormChoices[result]

            pkmn = Pokemon.new(speciesFormChosen[0], getLevelCap)
            pkmn.form = speciesFormChosen[1]
            pkmn.reset_moves(50,true)

            choicesArray = [_INTL("View MasterDex"), _INTL("Take Pokemon"), _INTL("Cancel")]
            secondResult = pbShowCommands(nil,choicesArray,3)
            case secondResult
            when 1
                pbAddPokemon(pkmn)
                break
            when 0
                openSingleDexScreen(pkmn)
            end
            next
        end
    end

    # TODO: Extend with the ability to pass in restrictions
    def getSpeciesFormChoices(numberOfChoices = 3)
        speciesFormChoices = []
        numberOfChoices.times do
            speciesFormChoices.push(getRandomSpeciesForm(speciesFormChoices))
        end
        return speciesFormChoices
    end

    ##############################################################
    # Pokemon generation
    ##############################################################
    def getRandomSpeciesForm(existingChoices = [])
        newChoice = nil
        while newChoice.nil? || existingChoices.include?(newChoice)
            newChoice = @speciesForms.sample
        end
        return newChoice
    end

    ##############################################################
    # Trainer generation
    ##############################################################
    def resetFloorTrainers
        @currentFloorTrainers.clear
    end
    
    def initializeNextTrainer
        partySize = getRandomTrainerPartySize
        randomTrainer = getRandomTrainer(partySize)
        @currentFloorTrainers.push(randomTrainer)
        return randomTrainer,@currentFloorTrainers.length-1
    end

    def trainersAssigned?
        return !@currentFloorTrainers.empty?
    end

    def getTrainerByLevelID(idNumber)
        return @currentFloorTrainers[idNumber]
    end

    def getRandomTrainer(partySize = 3)
        trainerData = GameData::Trainer.randomMonumentTrainer
        actualTrainer = trainerData.to_trainer

        # Select only some of the party members of the given trainer
        newParty = []
        newParty.push(actualTrainer.party[0])
        until newParty.length == partySize
            newPartyMember = actualTrainer.party.sample
            newParty.push(newPartyMember) unless newParty.include?(newPartyMember)
        end

        # Remove all items
        newParty.each do |partyMember|
            partyMember.removeItems
        end
        
        actualTrainer.party = newParty
        return actualTrainer
    end

    def startTrainerBattle(idNumber)
        trainer = getTrainerByLevelID(idNumber)
        
        setBattleRule("canLose")
        pbTrainerBattleCore(trainer)
    end

    def floorDifficulty
        return 1 + (@currentFloorDepth / 3)
    end

    def getRandomTrainerPartySize
        partySize = 2
        partySize += floorDifficulty / 2
        partySize += 1 if rand(3) == 0 # A third of the time
        partySize = 6 if partySize > 6
        return partySize
    end

    ##############################################################
    # Floor selection and movement
    ##############################################################
    def moveToNextFloor
        resetFloorTrainers
        @currentFloorDepth += 1

        pbSEPlay("Battle flee")
        pbCaveEntrance
        nextFloorMapID = chooseNextFloor
        transferPlayerToEvent(2,Up,nextFloorMapID)
        @currentFloorMapID = nextFloorMapID
    end

    def chooseNextFloor
        newFloor = nil
        while newFloor.nil? || newFloor == @currentFloorMapID
            newFloor = getRandomFloorMapID
        end
        return newFloor
    end

    def getRandomFloorMapID
        return FLOOR_MAP_IDS.sample
    end
end

##############################################################
# Floor generation
##############################################################
Events.onMapChange += proc { |_sender,_e|
    next unless rogueModeActive?
    next if $TectonicRogue.trainersAssigned?
    mapID = $game_map.map_id
    for event in $game_map.events.values
		match = event.name.match(/roguetrainer/)
        next unless match
        # Reset the trainer's flag
        pbSetSelfSwitch(event.id,"A",false)

        trainer,trainerID = $TectonicRogue.initializeNextTrainer

        # Construct the first page, in which the battle takes place
        firstPage = RPG::Event::Page.new
		firstPage.graphic.character_name = trainer.trainer_type.to_s
        firstPage.graphic.direction = event.event.pages[0].graphic.direction
		firstPage.trigger = 2 # event touch
		firstPage.list = []
        push_script(firstPage.list,sprintf("noticePlayer"))
		push_script(firstPage.list,sprintf("$TectonicRogue.startTrainerBattle(#{trainerID})"))
        push_script(firstPage.list,sprintf("defeatRogueTrainer"))
        push_script(firstPage.list,sprintf("$Trainer.heal_party"))
		firstPage.list.push(RPG::EventCommand.new(0,0,[]))
		
        # Construct the second page (trainer gone)
        secondPage = RPG::Event::Page.new
        secondPage.condition.self_switch_valid = true
        secondPage.condition.self_switch_ch = "A"

        # Set the pages
		event.event.pages[0] = firstPage
        event.event.pages[1] = secondPage
		event.refresh

        # Modify the follower pokemon
        followers = getFollowerPokemon(event.id)
        followers.each do |followerEvent|
            firstFollowerPage = createPokemonInteractionEventPage(trainer.party[0],followerEvent.event.pages[0])
            secondFollowerPage = RPG::Event::Page.new
            secondFollowerPage.condition.self_switch_valid = true
            secondFollowerPage.condition.self_switch_ch = "D"

            followerEvent.event.pages[0] = firstFollowerPage
            followerEvent.event.pages[1] = secondFollowerPage

            # Reset the follower's flag
            pbSetSelfSwitch(followerEvent.id,"D",false)

            followerEvent.refresh
        end
    end
}

##############################################################
# Helper methods
##############################################################
def enterRogueMode
    # Setup various data
    setLevelCap(70,false)
    $Trainer.party.clear
    $PokemonBag.clear
    $game_switches[ESTATE_DISABLED_SWITCH] = true

    # Create the roguelike run
    $TectonicRogue = TectonicRogueGameMode.new
    $TectonicRogue.beginRun
end

def promptMoveToNextFloor
    $TectonicRogue.moveToNextFloor if pbConfirmMessage(_INTL("Drop down to the next floor?"))
end

def reloadValidSpecies
    $TectonicRogue.loadValidSpecies
end

def chooseGiftPokemon(numberOfChoices = 3)
    $TectonicRogue.chooseGiftPokemon(numberOfChoices)
end

def rogueModeActive?
    return $TectonicRogue.active? || false
end

##############################################################
# Save registration
##############################################################
SaveData.register(:tectonic_rogue_mode) do
	ensure_class :TectonicRogueGameMode
	save_value { $TectonicRogue }
	load_value { |value| $TectonicRogue = value }
	new_game_value { TectonicRogueGameMode.new }
end