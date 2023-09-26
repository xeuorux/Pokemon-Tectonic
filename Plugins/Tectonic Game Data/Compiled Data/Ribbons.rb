module GameData
    class Ribbon
      attr_reader :id
      attr_reader :id_number
      attr_reader :real_name
      attr_reader :real_description
  
      DATA = {}
      DATA_FILENAME = "ribbons.dat"
  
      extend ClassMethods
      include InstanceMethods
  
      def initialize(hash)
        @id               = hash[:id]
        @id_number        = hash[:id_number]   || -1
        @real_name        = hash[:name]        || "Unnamed"
        @real_description = hash[:description] || "???"
      end
  
      # @return [String] the translated name of this ribbon
      def name
        return pbGetMessage(MessageTypes::RibbonNames, @id_number)
      end
  
      # @return [String] the translated description of this ribbon
      def description
        return pbGetMessage(MessageTypes::RibbonDescriptions, @id_number)
      end
    end
end

module Compiler
    module_function
  
    #=============================================================================
    # Compile ribbon data
    #=============================================================================
    def compile_ribbons(path = "PBS/ribbons.txt")
      GameData::Ribbon::DATA.clear
      ribbon_names        = []
      ribbon_descriptions = []
      pbCompilerEachPreppedLine(path) { |line, line_no|
        line = pbGetCsvRecord(line, line_no, [0, "vnss"])
        ribbon_number = line[0]
        ribbon_symbol = line[1].to_sym
        if GameData::Ribbon::DATA[ribbon_number]
          raise _INTL("Ribbon ID number '{1}' is used twice.\r\n{2}", ribbon_number, FileLineData.linereport)
        elsif GameData::Ribbon::DATA[ribbon_symbol]
          raise _INTL("Ribbon ID '{1}' is used twice.\r\n{2}", ribbon_symbol, FileLineData.linereport)
        end
        # Construct ribbon hash
        ribbon_hash = {
          :id          => ribbon_symbol,
          :id_number   => ribbon_number,
          :name        => line[2],
          :description => line[3]
        }
        # Add ribbon's data to records
        GameData::Ribbon.register(ribbon_hash)
        ribbon_names[ribbon_number]        = ribbon_hash[:name]
        ribbon_descriptions[ribbon_number] = ribbon_hash[:description]
      }
      # Save all data
      GameData::Ribbon.save
      MessageTypes.setMessages(MessageTypes::RibbonNames, ribbon_names)
      MessageTypes.setMessages(MessageTypes::RibbonDescriptions, ribbon_descriptions)
      Graphics.update
    end

    #=============================================================================
    # Save ability data to PBS file
    #=============================================================================
    def write_ribbons
        File.open("PBS/ribbons.txt", "wb") { |f|
        add_PBS_header_to_file(f)
        f.write("\#-------------------------------\r\n")
        GameData::Ribbon.each do |r|
            f.write(sprintf("%d,%s,%s,%s\r\n",
            r.id_number,
            csvQuote(r.id.to_s),
            csvQuote(r.real_name),
            csvQuoteAlways(r.real_description)
            ))
        end
        }
        Graphics.update
    end
end