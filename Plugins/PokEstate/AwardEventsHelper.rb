def generationReward(generation,threshold,reward)
    if $Trainer.pokedex.ownedFromGeneration(generation) >= threshold
        return [reward,_INTL("#{threshold} species from Generation #{generation}")]
    end
    return nil
end

def typeReward(type,threshold,reward)
    if $Trainer.pokedex.ownedOfType(type) >= threshold
        typeName = GameData::Type.get(type).real_name
        return [reward,_INTL("#{threshold} #{typeName}-type species")]
    end
    return nil
end

class Player < Trainer
    # Represents the player's Pokédex.
    class Pokedex
        def resetOwnershipCache()
            @ownedFromGeneration = {}
            @ownedOfType = {}
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

        def ownedFromGeneration(generationNumber)
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

        def ownedOfType(type)
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