module Compiler
    module_function
  
    #=============================================================================
    # Compile map connections
    #=============================================================================
    def compile_connections(path = "PBS/connections.txt")
      records   = []
      pbCompilerEachPreppedLine(path) { |line,lineno|
        hashenum = {
          "N" => "N","North" => "N",
          "E" => "E","East"  => "E",
          "S" => "S","South" => "S",
          "W" => "W","West"  => "W"
        }
        record = []
        thisline = line.dup
        record.push(csvInt!(thisline,lineno))
        record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
        record.push(csvInt!(thisline,lineno))
        record.push(csvInt!(thisline,lineno))
        record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
        record.push(csvInt!(thisline,lineno))
        if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[0]))
          print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}",record[0],FileLineData.linereport)
        end
        if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[3]))
          print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}",record[3],FileLineData.linereport)
        end
        case record[1]
        when "N"
          raise _INTL("North side of first map must connect with south side of second map\r\n{1}", FileLineData.linereport) if record[4] != "S"
        when "S"
          raise _INTL("South side of first map must connect with north side of second map\r\n{1}", FileLineData.linereport) if record[4] != "N"
        when "E"
          raise _INTL("East side of first map must connect with west side of second map\r\n{1}", FileLineData.linereport) if record[4] != "W"
        when "W"
          raise _INTL("West side of first map must connect with east side of second map\r\n{1}", FileLineData.linereport) if record[4] != "E"
        end
        records.push(record)
      }
      save_data(records,"Data/map_connections.dat")
      Graphics.update
    end

    #=============================================================================
    # Save map connections to PBS file
    #=============================================================================
    def normalize_connection(conn)
      ret = conn.clone
      if conn[1] < 0 && conn[4] < 0
      elsif conn[1] < 0 || conn[4] < 0
        ret[4] = -conn[1]
        ret[1] = -conn[4]
      end
      if conn[2] < 0 && conn[5] < 0
      elsif conn[2] < 0 || conn[5] < 0
        ret[5] = -conn[2]
        ret[2] = -conn[5]
      end
      return ret
    end

    def get_connection_text(map1, x1, y1, map2, x2, y2)
      dims1 = MapFactoryHelper.getMapDims(map1)
      dims2 = MapFactoryHelper.getMapDims(map2)
      if x1 == 0 && x2 == dims2[0]
        return sprintf("%d,West,%d,%d,East,%d", map1, y1, map2, y2)
      elsif y1 == 0 && y2 == dims2[1]
        return sprintf("%d,North,%d,%d,South,%d", map1, x1, map2, x2)
      elsif x1 == dims1[0] && x2 == 0
        return sprintf("%d,East,%d,%d,West,%d", map1, y1, map2, y2)
      elsif y1 == dims1[1] && y2 == 0
        return sprintf("%d,South,%d,%d,North,%d", map1, x1, map2, x2)
      end
      return sprintf("%d,%d,%d,%d,%d,%d", map1, x1, y1, map2, x2, y2)
    end

    def write_connections
      conndata = load_data("Data/map_connections.dat")
      return if !conndata
      mapinfos = pbLoadMapInfos
      File.open("PBS/connections.txt","wb") { |f|
        add_PBS_header_to_file(f)
        f.write("\#-------------------------------\r\n")
        for conn in conndata
          if mapinfos
            # Skip if map no longer exists
            next if !mapinfos[conn[0]] || !mapinfos[conn[3]]
            f.write(sprintf("# %s (%d) - %s (%d)\r\n",
            (mapinfos[conn[0]]) ? mapinfos[conn[0]].name : "???", conn[0],
            (mapinfos[conn[3]]) ? mapinfos[conn[3]].name : "???", conn[3]))
          end
          if conn[1].is_a?(String) || conn[4].is_a?(String)
            f.write(sprintf("%d,%s,%d,%d,%s,%d", conn[0], conn[1], conn[2],
              conn[3], conn[4], conn[5]))
          else
            ret = normalize_connection(conn)
            f.write(get_connection_text(ret[0], ret[1], ret[2], ret[3], ret[4], ret[5]))
          end
          f.write("\r\n")
        end
      }
      Graphics.update
    end
end