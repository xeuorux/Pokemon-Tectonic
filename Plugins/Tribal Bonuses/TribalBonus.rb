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
        updateTribeCount()
    end

    def updateTribeCount()
        #counts all tribes that exist for pokemon in player's party
        $Trainer.party.each {|pokemon|
            form = pokemon.form
            species = pokemon.species
            fSpecies = GameData::Species.get_species_form(species,form)
            compatibilities = fSpecies.compatibility
            compatibilities.each {|compatibility|
                @tribes[compatibility] += 1
            }
        }
    end
end