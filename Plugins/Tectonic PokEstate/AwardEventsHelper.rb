def generationReward(generation,threshold,reward)
    if $Trainer.pokedex.getOwnedFromGeneration(generation) >= threshold
        return [reward,_INTL("#{threshold} species from Generation #{generation}")]
    end
    return nil
end

def typeReward(type,threshold,reward)
    if $Trainer.pokedex.getOwnedOfType(type) >= threshold
        typeName = GameData::Type.get(type).name
        return [reward,_INTL("#{threshold} #{typeName}-type species")]
    end
    return nil
end

class Player < Trainer
    # Represents the player's Pokédex.
    class Pokedex
        attr_reader :ownedOfType
        attr_reader :ownedFromGeneration

        def resetOwnershipCache()
            @ownedFromGeneration = {}
            for generationNumber in 0..9 do
                @ownedFromGeneration[generationNumber] = 0
            end
            @ownedOfType = {}
            GameData::Type.each do |typeData|
                @ownedOfType[typeData.id] = 0
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
            end
        end

        def allOwnedFromRoute?(routeMapID,ignoreSpecial = true)
            encounterDataOnRoute = GameData::Encounter.get(routeMapID,$PokemonGlobal.encounter_version)
            encounterDataOnRoute.types.each do |key,slots|
                next if !slots
                next if key == :Special && ignoreSpecial
                slots.each { |slot|
                    species_data = GameData::Species.get(slot[1])
                    next if species_data.form != 0
                    return false if !@owned[species_data.species]
                }
            end
            return true
        end

        def getOwnedFromGeneration(generationNumber)
            return @ownedFromGeneration[generationNumber] if @ownedFromGeneration.has_key?(generationNumber)
            count = 0
            GameData::Species.each do |speciesData|
                next if speciesData.form != 0
                next if speciesData.generationNumber() != generationNumber
                next if !@owned[speciesData.species]
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
                next if speciesData.type1 != type && speciesData.type2 != type
                next if !@owned[speciesData.species]
                count += 1
            end
            @ownedOfType[type] = count
            return count
        end
    end
end