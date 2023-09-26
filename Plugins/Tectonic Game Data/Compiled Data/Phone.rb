module Compiler
    module_function
  
    #=============================================================================
    # Compile phone messages
    #=============================================================================
    def compile_phone(path = "PBS/phone.txt")
      return if !safeExists?(path)
      database = PhoneDatabase.new
      sections = []
      File.open(path, "rb") { |f|
        pbEachSection(f) { |section,name|
          case name
          when "<Generics>"
            database.generics=section
            sections.concat(section)
          when "<BattleRequests>"
            database.battleRequests=section
            sections.concat(section)
          when "<GreetingsMorning>"
            database.greetingsMorning=section
            sections.concat(section)
          when "<GreetingsEvening>"
            database.greetingsEvening=section
            sections.concat(section)
          when "<Greetings>"
            database.greetings=section
            sections.concat(section)
          when "<Bodies1>"
            database.bodies1=section
            sections.concat(section)
          when "<Bodies2>"
            database.bodies2=section
            sections.concat(section)
          end
        }
      }
      MessageTypes.setMessagesAsHash(MessageTypes::PhoneMessages,sections)
      save_data(database,"Data/phone.dat")
    end

    #=============================================================================
    # Save phone messages to PBS file
    #=============================================================================
    def write_phone
      data = load_data("Data/phone.dat") rescue nil
      return if !data
      File.open("PBS/phone.txt", "wb") { |f|
        add_PBS_header_to_file(f)
        f.write("\#-------------------------------\r\n")
        f.write("[<Generics>]\r\n")
        f.write(data.generics.join("\r\n") + "\r\n")
        f.write("\#-------------------------------\r\n")
        f.write("[<BattleRequests>]\r\n")
        f.write(data.battleRequests.join("\r\n") + "\r\n")
        f.write("\#-------------------------------\r\n")
        f.write("[<GreetingsMorning>]\r\n")
        f.write(data.greetingsMorning.join("\r\n") + "\r\n")
        f.write("\#-------------------------------\r\n")
        f.write("[<GreetingsEvening>]\r\n")
        f.write(data.greetingsEvening.join("\r\n") + "\r\n")
        f.write("\#-------------------------------\r\n")
        f.write("[<Greetings>]\r\n")
        f.write(data.greetings.join("\r\n") + "\r\n")
        f.write("\#-------------------------------\r\n")
        f.write("[<Bodies1>]\r\n")
        f.write(data.bodies1.join("\r\n") + "\r\n")
        f.write("\#-------------------------------\r\n")
        f.write("[<Bodies2>]\r\n")
        f.write(data.bodies2.join("\r\n") + "\r\n")
      }
      Graphics.update
    end
end

#===============================================================================
# Phone data
#===============================================================================
class PhoneDatabase
    attr_accessor :generics
    attr_accessor :greetings
    attr_accessor :greetingsMorning
    attr_accessor :greetingsEvening
    attr_accessor :bodies1
    attr_accessor :bodies2
    attr_accessor :battleRequests
    attr_accessor :trainers
  
    def initialize
      @generics         = []
      @greetings        = []
      @greetingsMorning = []
      @greetingsEvening = []
      @bodies1          = []
      @bodies2          = []
      @battleRequests   = []
      @trainers         = []
    end
end
  
module PhoneMsgType
    Generic       = 0
    Greeting      = 1
    Body          = 2
    BattleRequest = 3
end

#===============================================================================
# Method to get phone call data.
#===============================================================================
def pbLoadPhoneData
    $PokemonTemp = PokemonTemp.new if !$PokemonTemp
    if !$PokemonTemp.phoneData
      if pbRgssExists?("Data/phone.dat")
        $PokemonTemp.phoneData = load_data("Data/phone.dat")
      end
    end
    return $PokemonTemp.phoneData
end