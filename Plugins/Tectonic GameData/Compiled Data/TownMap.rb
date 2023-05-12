module Compiler
    module_function
  
    #=============================================================================
    # Compile Town Map data
    #=============================================================================
    def compile_town_map(path = "PBS/townmap.txt")
      nonglobaltypes = {
        "Name"     => [0, "s"],
        "Filename" => [1, "s"],
        "Point"    => [2, "uussUUUU"]
      }
      currentmap = -1
      rgnnames   = []
      placenames = []
      placedescs = []
      sections   = []
      pbCompilerEachCommentedLine(path) { |line,lineno|
        if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
          currentmap = $~[1].to_i
          sections[currentmap] = []
        else
          if currentmap<0
            raise _INTL("Expected a section at the beginning of the file\r\n{1}",FileLineData.linereport)
          end
          if !line[/^\s*(\w+)\s*=\s*(.*)$/]
            raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}",FileLineData.linereport)
          end
          settingname = $~[1]
          schema = nonglobaltypes[settingname]
          if schema
            record = pbGetCsvRecord($~[2],lineno,schema)
            if settingname=="Name"
              rgnnames[currentmap] = record
            elsif settingname=="Point"
              placenames.push(record[2])
              placedescs.push(record[3])
              sections[currentmap][schema[0]] = [] if !sections[currentmap][schema[0]]
              sections[currentmap][schema[0]].push(record)
            else   # Filename
              sections[currentmap][schema[0]] = record
            end
          end
        end
      }
      save_data(sections,"Data/town_map.dat")
      MessageTypes.setMessages(MessageTypes::RegionNames,rgnnames)
      MessageTypes.setMessagesAsHash(MessageTypes::PlaceNames,placenames)
      MessageTypes.setMessagesAsHash(MessageTypes::PlaceDescriptions,placedescs)
    end

    #=============================================================================
    # Save Town Map data to PBS file
    #=============================================================================
    def write_town_map
      mapdata = pbLoadTownMapData
      return if !mapdata
      File.open("PBS/townmap.txt","wb") { |f|
        add_PBS_header_to_file(f)
        for i in 0...mapdata.length
          map = mapdata[i]
          next if !map
          f.write("\#-------------------------------\r\n")
          f.write(sprintf("[%d]\r\n",i))
          rname = pbGetMessage(MessageTypes::RegionNames,i)
          f.write(sprintf("Name = %s\r\nFilename = %s\r\n",
            (rname && rname!="") ? rname : _INTL("Unnamed"),
            csvQuote((map[1].is_a?(Array)) ? map[1][0] : map[1])))
          for loc in map[2]
            f.write("Point = ")
            pbWriteCsvRecord(loc,f,[nil,"uussUUUU"])
            f.write("\r\n")
          end
        end
      }
      Graphics.update
    end
end

#===============================================================================
# Method to get Town Map data.
#===============================================================================
def pbLoadTownMapData
    $PokemonTemp = PokemonTemp.new if !$PokemonTemp
    if !$PokemonTemp.townMapData
      $PokemonTemp.townMapData = load_data("Data/town_map.dat")
    end
    return $PokemonTemp.townMapData
end