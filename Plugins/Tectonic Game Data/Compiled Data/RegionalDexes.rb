module Compiler
    module_function

    #=============================================================================
    # Compile Regional Dexes
    #=============================================================================
    def compile_regional_dexes
        dex_lists = []
        base_dex_lists = {} # Data that hasn't been extended
        section = nil
        baseFiles = ["PBS/regionaldexes.txt"]
        regionalDexTextFiles = []
        regionalDexTextFiles.concat(baseFiles)
        regionalDexExtensions = Compiler.get_extensions("regionaldexes")
        regionalDexTextFiles.concat(regionalDexExtensions)
        regionalDexTextFiles.each do |path|
          baseFile = baseFiles.include?(path)
          pbCompilerEachPreppedLine(path) { |line, line_no|
            Graphics.update if line_no % 200 == 0
            if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
                section = $~[1].to_i
                if dex_lists[section]
                  if !baseFile
                    # Back up base entry for writing base PBS later (only if not already backed up)
                    unless base_dex_lists[section]
                      base_dex_lists[section] = dex_lists[section].clone
                    end
                    # Extension is modifying an existing dex list, so clear it to replace
                    dex_lists[section] = []
                  else
                    raise _INTL("Dex list number {1} is defined at least twice.\r\n{2}", section, FileLineData.linereport)
                  end
                else
                  dex_lists[section] = []
                end
                pbSetWindowText(_INTL("Processing {1} section [{2}]", FileLineData.file, section))
            else
                raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport) if !section
                species_list = line.split(",")
                for species in species_list
                  next if !species || species.empty?
                  s = parseSpecies(species)
                  dex_lists[section].push(s)
                end
            end
          }
        end
        # Check for duplicate species in a Regional Dex
        dex_lists.each_with_index do |list, index|
          unique_list = list.uniq
          next if list == unique_list
          list.each_with_index do |s, i|
              next if unique_list[i] == s
              raise _INTL("Dex list number {1} has species {2} listed twice.\r\n{3}", index, s, FileLineData.linereport)
          end
        end
        # Save all data
        save_data(dex_lists, "Data/regional_dexes.dat")
        save_data(base_dex_lists, "Data/regional_dexes_base.dat")
        Graphics.update
    end
  
    #=============================================================================
    # Save Regional Dexes to PBS file
    #=============================================================================
    def write_regional_dexes
      dex_lists = pbLoadRegionalDexes
      # Load base data if it exists
      base_dex_lists = {}
      if FileTest.exist?("Data/regional_dexes_base.dat")
        base_dex_lists = load_data("Data/regional_dexes_base.dat")
      end
      File.open("PBS/regionaldexes.txt", "wb") { |f|
        add_PBS_header_to_file(f)
        # Write each Dex list in turn
        dex_lists.each_with_index do |list, index|
          # Use backed-up base data if it exists (i.e., if an extension modified this dex list)
          list_to_write = base_dex_lists[index] || list
          f.write("\#-------------------------------\r\n")
          f.write("[#{index}]")
          comma = false
          current_family = nil
          list_to_write.each do |species|
            next if !species
            next if GameData::Species.get(species).defined_in_extension
            if current_family && current_family.include?(species)
              f.write(",") if comma
            else
              current_family = GameData::Species.get(species).get_related_species
              comma = false
              f.write("\r\n")
            end
            f.write(species)
            comma = true
          end
          f.write("\r\n")
        end
      }
      Graphics.update
    end
end

#===============================================================================
# Method to get Regional Dexes data.
#===============================================================================
def pbLoadRegionalDexes
    $PokemonTemp = PokemonTemp.new if !$PokemonTemp
    if !$PokemonTemp.regionalDexes
      $PokemonTemp.regionalDexes = load_data("Data/regional_dexes.dat")
    end
    return $PokemonTemp.regionalDexes
end