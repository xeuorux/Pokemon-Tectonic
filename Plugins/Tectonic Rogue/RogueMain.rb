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

class TectonicRogueGameMode
    attr_reader :speciesForms

    def initialize
        loadValidSpecies
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

    def getRandomSpeciesForm(existingChoices = [])
        newChoice = nil
        while newChoice.nil? || existingChoices.include?(newChoice)
            newChoice = @speciesForms.sample
        end
        return newChoice
    end
end

def enterRogueMode
    setLevelCap(70,false)
    $TectonicRogue = TectonicRogueGameMode.new
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