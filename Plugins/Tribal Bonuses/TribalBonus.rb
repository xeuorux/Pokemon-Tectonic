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

        form = pokemon.form
        species = pokemon.species
        fSpecies = GameData::Species.get_species_form(species, form)
        compatibilities = fSpecies.compatibility
        compatibilities.each {|compatibility|
            # NOTE: We intentionally do not affect the HP stat due to its technical complexity
            # TODO: Fix bonuses
            if compatibility == :Monster && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 1
            elsif compatibility == :Water1 && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 2
            elsif compatibility == :Bug && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
            elsif compatibility == :Flying && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 4
            elsif compatibility == :Field && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 5
            elsif compatibility == :Fairy && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 6
            elsif compatibility == :Grass && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 7
            elsif compatibility == :Humanlike && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 8
            elsif compatibility == :Water3 && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 9
            elsif compatibility == :Mineral && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 10
            elsif compatibility == :Amorphous && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 11
            elsif compatibility == :Water2 && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 12
            elsif compatibility == :Ditto && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 13
            elsif compatibility == :Dragon && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 14
            elsif compatibility == :Undiscovered && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 15
            end
        }

        return tribeBonuses
    end

    def tribes
        return @tribes
    end

    def tribeNames
        return @tribeNames
    end
end