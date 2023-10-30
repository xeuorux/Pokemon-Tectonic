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

##############################################################
# Game mode class
##############################################################
class TectonicRogueGameMode
    attr_reader :speciesForms

    ##############################################################
    # Initialization
    ##############################################################

    def initialize
        loadValidSpecies
        @currentFloorTrainers = []
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

    ##############################################################
    # Pokemon selection
    ##############################################################

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
        randomTrainer = getRandomTrainer
        @currentFloorTrainers.push(randomTrainer)
        return randomTrainer,@currentFloorTrainers.length-1
    end

    def getTrainerByLevelID(idNumber)
        return @currentFloorTrainers[idNumber]
    end

    def getRandomTrainer
        trainerData = GameData::Trainer.randomMonumentTrainer
        actualTrainer = trainerData.to_trainer
        actualTrainer.party = actualTrainer.party[0..2]
        return actualTrainer
    end

    def startTrainerBattle(idNumber)
        trainer = getTrainerByLevelID(idNumber)
        
        setBattleRule("canLose")
        pbTrainerBattleCore(trainer)
    end

    ##############################################################
    # Floor selection and movement
    ##############################################################
    def moveToNextFloor
        pbSEPlay("Battle flee")
        pbCaveEntrance
        transferPlayerToEvent(2,Up,getRandomFloorMapID)
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
            followerEvent.refresh

            # Reset the follower's flag
            pbSetSelfSwitch(event.id,"D",false)
        end
    end
}

##############################################################
# Helper methods
##############################################################
def enterRogueMode
    setLevelCap(70,false)
    $TectonicRogue = TectonicRogueGameMode.new
    3.times do
        chooseGiftPokemon
    end
    $TectonicRogue.moveToNextFloor
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
    return !$TectonicRogue.nil? || false
end