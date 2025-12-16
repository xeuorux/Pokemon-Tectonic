module GameData
  class SpeciesOld < Species
    DATA = {}
    DATA_FILENAME = "species_old.dat"

    def legalityChecks; end;

    $loaded = false
    def self.loaded?
      return $loaded
    end

    def self.load
      super
      $loaded = true
    end

    # @param species [Symbol, self, String, Integer]
    # @param form [Integer]
    # @return [self, nil]
    def self.get_species_form(species, form)
      return nil if !species || !form
      validate species => [Symbol, self, String, Integer]
      validate form => Integer
      species = species.species if species.is_a?(self)
      species = DATA[species].species if species.is_a?(Integer)
      species = species.to_sym if species.is_a?(String)
      trial = format("%s_%d", species, form).to_sym
      species_form = DATA[trial].nil? ? species : trial
      return DATA.has_key?(species_form) ? DATA[species_form] : nil
    end
  end
end