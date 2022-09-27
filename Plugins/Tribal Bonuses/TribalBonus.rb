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

        # Map tribe names to their bonuses
        @bonusDescriptions = {
            :Monster => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Water1 => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Bug => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Flying => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Field => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Fairy => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Grass => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Humanlike => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Water3 => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Mineral => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Amorphous => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Water2 => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Ditto => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Dragon => "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD.",
            :Undiscovered =>  "2 Pokémon of this type will give +3 ATK, +3 DEF, +3 SP. ATK, +3 SP. DEF, and +3 SPD."
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
            if compatibility == :Monster && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Water1 && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Bug && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Flying && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Field && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Fairy && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Grass && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Humanlike && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Water3 && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Mineral && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Amorphous && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Water2 && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Ditto && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Dragon && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
            elsif compatibility == :Undiscovered && @tribes[compatibility] >= 2
                tribeBonuses[:ATTACK] += 3
                tribeBonuses[:DEFENSE] += 3
                tribeBonuses[:SPECIAL_ATTACK] += 3
                tribeBonuses[:SPECIAL_DEFENSE] += 3
                tribeBonuses[:SPEED] += 3
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

    def bonusDescriptions
        return @bonusDescriptions
    end
end
