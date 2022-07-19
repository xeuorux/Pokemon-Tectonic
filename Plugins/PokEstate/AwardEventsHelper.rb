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
        def ownedFromGeneration(generationNumber)
            count = 0
            GameData::Species.each do |speciesData|
                next if speciesData.form != 0
                next if speciesData.generationNumber() != generationNumber
                next if !@owned[speciesData.species]
                count += 1
            end
            return count
        end

        def ownedOfType(type)
            count = 0
            GameData::Species.each do |speciesData|
                next if speciesData.form != 0
                next if speciesData.type1 != type && speciesData.type2 != type
                next if !@owned[speciesData.species]
                count += 1
            end
            return count
        end
    end
end