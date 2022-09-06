class TribalBonus
    def initialize()
        #initializes all tribes based on compatability tags
        @tribes = {
            :Monster => 0,
            :Water1 => 0,
            :Bug => 0,
            :Flying => 0,
            :Field => 0,
            :Fairy => 0,
            :Grass => 0,
            :Humanlike => 0,
            :Water3 => 0,
            :Mineral => 0,
            :Amorphous => 0,
            :Water2 => 0,
            :Ditto => 0,
            :Dragon => 0,
            :Undiscovered => 0
        }

        # Map tribe symbols to their user-friendly name
        @tribeNames = {
            :Monster => "Monster",
            :Water1 => "Sea Creature",
            :Bug => "Bug",
            :Flying => "Flying",
            :Field => "Field",
            :Fairy => "Fairy",
            :Grass => "Grass",
            :Humanlike => "Humanlike",
            :Water3 => "Shellfish",
            :Mineral => "Mineral",
            :Amorphous => "Amorphus",
            :Water2 => "Fish",
            :Ditto => "Ditto",
            :Dragon => "Dragon",
            :Undiscovered => "Undiscovered"
        }

        updateTribeCount()
    end

    def updateTribeCount()
        #counts all tribes that exist for pokemon in player's party
        $Trainer.party.each {|pokemon|
            form = pokemon.form
            species = pokemon.species
            fSpecies = GameData::Species.get_species_form(species, form)
            compatibilities = fSpecies.compatibility
            compatibilities.each {|compatibility|
                @tribes[compatibility] += 1
            }
        }
    end

    def getTribeBonuses(pokemon)
        # Returns a hash of all bonuses given the current pokemon
        tribeBonuses = {
            :HP => 0,
            :ATTACK => 0,
            :DEFENSE => 0,
            :SPECIAL_ATTACK => 0,
            :SPECIAL_DEFENSE => 0,
            :SPEED => 0,
        }

        # Return early if the pokemon is the enemy pokemon. We assume no mirror matches in the battle
        if $Trainer.party.any?{|partyPokemon| partyPokemon.name == pokemon.name}
            return tribeBonuses
        end

        form = pokemon.form
        species = pokemon.species
        fSpecies = GameData::Species.get_species_form(species, form)
        compatibilities = fSpecies.compatibility
        compatibilities.each {|compatibility|
            # If there are 2+ pokemon of the same tribe, add 10 bonus attack
            if @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 10
            # TODO: Add all other tribe bonuses here
            end
        }

        # TODO: Remove
        echoln pokemon.name
        echoln tribeBonuses

        return tribeBonuses
    end

    def tribes
        return @tribes
    end

    def tribeNames
        return @tribeNames
    end
end