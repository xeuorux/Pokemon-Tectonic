def areaReward(routeID,reward)
    routeName = pbGetMapNameFromId(routeID)
    return {
        reward: reward,
        description: _INTL("all species in {1}",routeName),
        page: 1,
        threshold: $Trainer.pokedex.routeEncounterCount(routeID),
        amount: $Trainer.pokedex.getOwnedOnRoute(routeID),
    }
end

def typeReward(type,threshold,reward)
    typeName = GameData::Type.get(type).name
    return {
        reward: reward,
        description: _INTL("{1} {2}-type species",threshold,typeName),
        page: 2,
        threshold: threshold,
        amount: $Trainer.pokedex.getOwnedOfType(type),
    }
end

def tribeReward(tribe,threshold,reward)
    tribeName = GameData::Tribe.get(tribe).name
    return {
        reward: reward,
        description: _INTL("{1} species in the {2} tribe",threshold,tribeName),
        page: 3,
        threshold: threshold,
        amount: $Trainer.pokedex.getOwnedOfTribe(tribe),
    }
end

def generationReward(generation,threshold,reward)
    return {
        reward: reward,
        description: _INTL("{1} species from Generation {2}",threshold,generation),
        page: 4,
        threshold: threshold,
        amount: $Trainer.pokedex.getOwnedFromGeneration(generation),
    }
end

class Player < Trainer
    # Represents the player's Pokédex.
    class Pokedex
        attr_reader :ownedOfType
        attr_reader :ownedFromGeneration
        attr_reader :ownedOfTribe

        def resetOwnershipCache()
            @ownedFromGeneration = {}
            for generationNumber in 0..9 do
                @ownedFromGeneration[generationNumber] = 0
            end
            @ownedOfType = {}
            GameData::Type.each do |typeData|
                @ownedOfType[typeData.id] = 0
            end
            @ownedOfTribe = {}
            GameData::Tribe.each do |tribeData|
                @ownedOfTribe[tribeData.id] = 0
            end
            calculateOwnershipCache
        end

        def calculateOwnershipCache
            GameData::Species.each do |speciesData|
                next if speciesData.form != 0
                next if !@owned[speciesData.species]
                
                @ownedFromGeneration[speciesData.generationNumber] += 1 if speciesData.generationNumber > 0
                
                @ownedOfType[speciesData.type1] += 1
                @ownedOfType[speciesData.type2] += 1 if speciesData.type2 != speciesData.type1

                speciesData.tribes.each do |tribeID|
                    @ownedOfTribe[tribeID] += 1
                end
            end
        end

        def eachEncounterOnRoute(routeMapID,ignoreSpecial = true)
            encounterDataOnRoute = GameData::Encounter.get(routeMapID,$PokemonGlobal.encounter_version)
            encounterDataOnRoute.types.each do |key,slots|
                next if !slots
                next if key == :Special && ignoreSpecial
                slots.each { |slot|
                    species_data = GameData::Species.get(slot[1])
                    next if species_data.form != 0
                    yield species_data.id
                }
            end
        end

        def routeEncounterCount(routeMapID,ignoreSpecial = true)
            count = 0
            eachEncounterOnRoute(routeMapID,ignoreSpecial) do |speciesID|
                count += 1
            end
            return count
        end

        def getOwnedOnRoute(routeMapID,ignoreSpecial = true)
            count = 0
            eachEncounterOnRoute(routeMapID,ignoreSpecial) do |speciesID|
                count += 1 if @owned[speciesID]
            end
            return count
        end

        def getOwnedFromGeneration(generationNumber)
            return @ownedFromGeneration[generationNumber] if @ownedFromGeneration.has_key?(generationNumber)
            count = 0
            GameData::Species.each do |speciesData|
                next if speciesData.form != 0
                next unless @owned[speciesData.species]
                next if speciesData.generationNumber() != generationNumber
                count += 1
            end
            @ownedFromGeneration[generationNumber] = count
            return count
        end

        def getOwnedOfType(type)
            return @ownedOfType[type] if @ownedOfType.has_key?(type)
            count = 0
            GameData::Species.each do |speciesData|
                next if speciesData.form != 0
                next unless @owned[speciesData.species]
                next if speciesData.type1 != type && speciesData.type2 != type
                count += 1
            end
            @ownedOfType[type] = count
            return count
        end

        def getOwnedOfTribe(tribe)
            return @ownedOfTribe[tribe] if @ownedOfTribe.has_key?(tribe)
            count = 0
            GameData::Species.each do |speciesData|
                next if speciesData.form != 0
                next unless @owned[speciesData.species]
                next unless speciesData.tribes.include?(tribe)
                count += 1
            end
            @ownedOfTribe[tribe] = count
            return count
        end
    end
end