module GameData
    class SpeciesMetrics
      attr_reader   :id
      attr_reader   :species
      attr_reader   :form
      attr_accessor :back_sprite
      attr_accessor :front_sprite
      attr_accessor :front_sprite_altitude
      attr_accessor :shadow_x
      attr_accessor :shadow_size
      attr_reader   :pbs_file_suffix
  
      DATA = {}
      DATA_FILENAME = "species_metrics.dat"
      PBS_BASE_FILENAME = "pokemon_metrics"
  
      SCHEMA = {
        "SectionName" => [:id,           "eV", :Species],
        "BackSprite"  => [:back_sprite,  "ii"],
        "FrontSprite" => [:front_sprite, "ii"],
        "ShadowX"     => [:shadow_x,     "i"],
        "ShadowSize"  => [:shadow_size,  "u"],
      }
  
      extend ClassMethodsSymbols
      include InstanceMethods
  
      # @param species [Symbol, String]
      # @param form [Integer]
      # @return [self, nil]
      def self.get_species_form(species, form)
        return nil if !species || !form
        validate species => [Symbol, String]
        validate form => Integer
        raise _INTL("Undefined species {1}.", species) unless GameData::Species.exists?(species)
        species = species.to_sym if species.is_a?(String)
        if form > 0
          trial = format("%s_%d", species, form).to_sym
          unless DATA.has_key?(trial)
            register({ :id => species }) unless DATA[species]
            register({
              :id                    => trial,
              :species               => species,
              :form                  => form,
              :back_sprite           => DATA[species].back_sprite.clone,
              :front_sprite          => DATA[species].front_sprite.clone,
              :front_sprite_altitude => DATA[species].front_sprite_altitude,
              :shadow_x              => DATA[species].shadow_x,
              :shadow_size           => DATA[species].shadow_size,
            })
          end
          return DATA[trial]
        end
        register({ :id => species }) unless DATA[species]
        return DATA[species]
      end
  
      def initialize(hash)
        @id                    = hash[:id]
        @species               = hash[:species]               || @id
        @form                  = hash[:form]                  || 0
        @back_sprite           = hash[:back_sprite]           || [0, 0]
        @front_sprite          = hash[:front_sprite]          || [0, 0]
        @front_sprite_altitude = hash[:front_sprite_altitude] || 0
        @shadow_x              = hash[:shadow_x]              || 0
        @shadow_size           = hash[:shadow_size]           || 2
        @pbs_file_suffix       = hash[:pbs_file_suffix]       || ""
        @defined_in_extension  = hash[:defined_in_extension]  || false
      end
  
      def apply_metrics_to_sprite(sprite, index, shadow = false)
        if shadow
          sprite.x += @shadow_x * 2 if (index & 1) == 1 # Foe Pokémon
        elsif (index & 1) == 0   # Player's Pokémon
          sprite.x += @back_sprite[0] * 2
          sprite.y += @back_sprite[1] * 2
        else           # Foe Pokémon
          sprite.x += @front_sprite[0] * 2
          sprite.y += @front_sprite[1] * 2
          sprite.y -= @front_sprite_altitude * 2
        end
      end
  
      def shows_shadow?
        return true
        #    return @front_sprite_altitude > 0
      end
    end
  end
  
  module Compiler
    module_function
  
    #=============================================================================
    # Compile Pokémon metrics data
    #=============================================================================
    def compile_pokemon_metrics
      schema = GameData::SpeciesMetrics::SCHEMA
      # Read from PBS file
      baseFiles = ["PBS/pokemon_metrics.txt"]
      metricsTextFiles = []
      metricsTextFiles.concat(baseFiles)
      metricsExtensions = Compiler.get_extensions("pokemon_metrics")
      metricsTextFiles.concat(metricsExtensions)
      metricsTextFiles.each do |path|
        File.open(path, "rb") do |f|
          baseFile = baseFiles.include?(path)
          FileLineData.file = path # For error reporting
          # Read a whole section's lines at once, then run through this code.
          # contents is a hash containing all the XXX=YYY lines in that section, where
          # the keys are the XXX and the values are the YYY (as unprocessed strings).
          idx = 0
          pbEachFileSection3(f) do |contents, section_name|
            echo "." if idx % 50 == 0
            idx += 1
            Graphics.update if idx % 250 == 0
            FileLineData.setSection(section_name, "header", nil) # For error reporting
            # Split section_name into a species number and form number
            split_section_name = section_name.split(/[-,\s]/)
            if split_section_name.length == 0 || split_section_name.length > 2
              raise _INTL("Section name {1} is invalid ({2}). Expected syntax like [XXX] or [XXX,Y] (XXX=species ID, Y=form number).", section_name, path)
            end
            species_symbol = csvEnumField!(split_section_name[0], :Species, nil, nil)
            form       = (split_section_name[1]) ? csvPosInt!(split_section_name[1]) : 0
            # Go through schema hash of compilable data and compile this section
            schema.each_key do |key|
              # Skip empty properties (none are required)
              if nil_or_empty?(contents[key])
                contents[key] = nil
                next
              end
              FileLineData.setSection(section_name, key, contents[key]) # For error reporting
              # Compile value for key
              value = pbGetCsvRecord(contents[key], key, schema[key])
              value = nil if value.is_a?(Array) && value.length == 0
              contents[key] = value
            end
            # Construct species hash
            form_symbol = (form > 0) ? format("%s_%d", species_symbol.to_s, form).to_sym : species_symbol
            species_hash = {
              :id           => form_symbol,
              :species      => species_symbol,
              :form         => form,
              :back_sprite  => contents["BackSprite"],
              :front_sprite => contents["FrontSprite"],
              :shadow_x     => contents["ShadowX"],
              :shadow_size  => contents["ShadowSize"],
              :defined_in_extension  => !baseFile,
            }
            # Add form's data to records
            GameData::SpeciesMetrics.register(species_hash)
          end
        end
      end
      # Save all data
      GameData::SpeciesMetrics.save
      Graphics.update
    end
  
    #=============================================================================
    # Write species metrics
    #=============================================================================
    def write_pokemon_metrics(path = "PBS/pokemon_metrics.txt")
      # Get in species order then in form order
      sort_array = []
      dex_numbers = {}
      i = 0
      GameData::SpeciesMetrics.each do |metrics|
        next if metrics.defined_in_extension
        dex_numbers[metrics.species] = i unless dex_numbers[metrics.species]
        sort_array.push([dex_numbers[metrics.species], metrics.id, metrics.species, metrics.form])
        i += 1
      end
      sort_array.sort! { |a, b| (a[0] == b[0]) ? a[3] <=> b[3] : a[0] <=> b[0] }
      # Write file
      File.open(path, "wb") do |f|
        idx = 0
        add_PBS_header_to_file(f)
        sort_array.each do |val|
          echo "." if idx % 50 == 0
          idx += 1
          Graphics.update if idx % 250 == 0
          species = GameData::SpeciesMetrics.get(val[1])
          if species.form > 0
            base_species = GameData::SpeciesMetrics.get(val[2])
            next if species.back_sprite == base_species.back_sprite &&
                species.front_sprite == base_species.front_sprite &&
                species.front_sprite_altitude == base_species.front_sprite_altitude &&
                species.shadow_x == base_species.shadow_x &&
                species.shadow_size == base_species.shadow_size
          elsif species.back_sprite == [0, 0] && species.front_sprite == [0, 0] &&
              species.front_sprite_altitude == 0 &&
              species.shadow_x == 0 && species.shadow_size == 2
            next
          end
          species.front_sprite_altitude == 0 &&
            species.shadow_x == 0 && species.shadow_size == 2
          f.write("\#-------------------------------\r\n")
          if species.form > 0
            f.write(format("[%s,%d]\r\n", species.species, species.form))
          else
            f.write(format("[%s]\r\n", species.species))
          end
          f.write(format("BackSprite = %s\r\n", species.back_sprite.join(",")))
          f.write(format("FrontSprite = %s\r\n", species.front_sprite.join(",")))
          f.write(format("ShadowX = %d\r\n", species.shadow_x))
          f.write(format("ShadowSize = %d\r\n", species.shadow_size))
        end
      end
          pbSetWindowText(nil)
      Graphics.update
    end
  end
  