module GameData
    class TrainerType
      attr_reader :id
      attr_reader :id_number
      attr_reader :real_name
      attr_reader :base_money
      attr_reader :battle_BGM
      attr_reader :victory_ME
      attr_reader :intro_ME
      attr_reader :gender
      attr_reader :skill_level
      attr_reader :skill_code
      attr_reader :policies
  
      DATA = {}
      DATA_FILENAME = "trainer_types.dat"
  
      extend ClassMethods
      include InstanceMethods
  
      def self.check_file(tr_type, path, optional_suffix = "", suffix = "")
        tr_type_data = self.try_get(tr_type)
        return nil if tr_type_data.nil?
        # Check for files
        if optional_suffix && !optional_suffix.empty?
          ret = path + tr_type_data.id.to_s + optional_suffix + suffix
          return ret if pbResolveBitmap(ret)
          ret = path + sprintf("%03d", tr_type_data.id_number) + optional_suffix + suffix
          return ret if pbResolveBitmap(ret)
        end
        ret = path + tr_type_data.id.to_s + suffix
        return ret if pbResolveBitmap(ret)
        ret = path + sprintf("%03d", tr_type_data.id_number) + suffix
        return (pbResolveBitmap(ret)) ? ret : nil
      end
  
      def self.charset_filename(tr_type)
        return self.check_file(tr_type, "Graphics/Characters/trainer_")
      end
  
      def self.charset_filename_brief(tr_type)
        ret = self.charset_filename(tr_type)
        ret.slice!("Graphics/Characters/") if ret
        return ret
      end
  
      def self.front_sprite_filename(tr_type)
        return self.check_file(tr_type, "Graphics/Trainers/")
      end
  
      def self.player_front_sprite_filename(tr_type)
        outfit = ($Trainer) ? $Trainer.outfit : 0
        return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit))
      end
  
      def self.back_sprite_filename(tr_type)
        return self.check_file(tr_type, "Graphics/Trainers/", "", "_back")
      end
  
      def self.player_back_sprite_filename(tr_type)
        outfit = ($Trainer) ? $Trainer.outfit : 0
        return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit), "_back")
      end
  
      def self.map_icon_filename(tr_type)
        return self.check_file(tr_type, "Graphics/Pictures/mapPlayer")
      end
  
      def self.player_map_icon_filename(tr_type)
        outfit = ($Trainer) ? $Trainer.outfit : 0
        return self.check_file(tr_type, "Graphics/Pictures/mapPlayer", sprintf("_%d", outfit))
      end
  
      def initialize(hash)
        @id          = hash[:id]
        @id_number   = hash[:id_number]   || -1
        @real_name   = hash[:name]        || "Unnamed"
        @base_money  = hash[:base_money]  || 30
        @battle_BGM  = hash[:battle_BGM]
        @victory_ME  = hash[:victory_ME]
        @victory_ME  = hash[:victory_ME]
        @intro_ME    = hash[:intro_ME]
        @gender      = hash[:gender]      || 2
        @skill_level = hash[:skill_level] || @base_money
        @skill_code  = hash[:skill_code]
        @policies	   = hash[:policies]	|| []
      end
  
      # @return [String] the translated name of this trainer type
      def name
        return pbGetMessage(MessageTypes::TrainerTypes, @id_number)
      end
  
      def male?;   return @gender == 0; end
      def female?; return @gender == 1; end
      def wild?; return @gender == 3; end
    end
end
  

module Compiler
    module_function
  
    #=============================================================================
    # Compile trainer type data
    #=============================================================================
    def compile_trainer_types(path = "PBS/trainertypes.txt")
        GameData::TrainerType::DATA.clear
        tr_type_names = []
        # Read each line of trainertypes.txt at a time and compile it into a trainer type
        pbCompilerEachCommentedLine(path) { |line, line_no|
        line = pbGetCsvRecord(line, line_no, [0, "unsUSSSeUSs",
            nil, nil, nil, nil, nil, nil, nil, {
            "Male"   => 0, "M" => 0, "0" => 0,
            "Female" => 1, "F" => 1, "1" => 1,
            "Mixed"  => 2, "X" => 2, "2" => 2, "" => 2,
            "Wild"   => 3, "W" => 3, "3" => 3
            }, nil, nil, nil]
        )
        type_number = line[0]
        type_symbol = line[1].to_sym
        if GameData::TrainerType::DATA[type_number]
            raise _INTL("Trainer type ID number '{1}' is used twice.\r\n{2}", type_number, FileLineData.linereport)
        elsif GameData::TrainerType::DATA[type_symbol]
            raise _INTL("Trainer type ID '{1}' is used twice.\r\n{2}", type_symbol, FileLineData.linereport)
        end
        policies_array = []
        if line[10]
            policies_string_array = line[10].gsub('[','').gsub(']','').split(',')
            policies_string_array.each do |policy_string|
            policies_array.push(policy_string.to_sym)
            echoln("#{policy_string}")
            end
        end
        # Construct trainer type hash
        type_hash = {
            :id_number   => type_number,
            :id          => type_symbol,
            :name        => line[2],
            :base_money  => line[3],
            :battle_BGM  => line[4],
            :victory_ME  => line[5],
            :intro_ME    => line[6],
            :gender      => line[7],
            :skill_level => line[8],
            :skill_code  => line[9],
            :policies    => policies_array,
        }
        # Add trainer type's data to records
        GameData::TrainerType.register(type_hash)
        tr_type_names[type_number] = type_hash[:name]
        }
        # Save all data
        GameData::TrainerType.save
        MessageTypes.setMessages(MessageTypes::TrainerTypes, tr_type_names)
        Graphics.update
    end

    #=============================================================================
    # Save trainer type data to PBS file
    #=============================================================================
    def write_trainer_types
        File.open("PBS/trainertypes.txt", "wb") { |f|
        add_PBS_header_to_file(f)
        f.write("\#-------------------------------\r\n")
        GameData::TrainerType.each do |t|
            policiesString = ""
            if t.policies
            policiesString += "["
            t.policies.each_with_index do |policy_symbol,index|
                policiesString += policy_symbol.to_s
                policiesString += "," if index < t.policies.length - 1
            end
            policiesString += "]"
            end
        
            f.write(sprintf("%d,%s,%s,%d,%s,%s,%s,%s,%s,%s,%s\r\n",
            t.id_number,
            csvQuote(t.id.to_s),
            csvQuote(t.real_name),
            t.base_money,
            csvQuote(t.battle_BGM),
            csvQuote(t.victory_ME),
            csvQuote(t.intro_ME),
            ["Male", "Female", "Mixed", "Wild"][t.gender],
            (t.skill_level == t.base_money) ? "" : t.skill_level.to_s,
            csvQuote(t.skill_code),
            policiesString
            ))
        end
        }
        Graphics.update
    end
end