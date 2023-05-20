#===============================================================================
#
#===============================================================================
module DebugMenuCommands
    @@commands = HandlerHashBasic.new
  
    def self.register(option, hash)
      @@commands.add(option, hash)
    end
  
    def self.registerIf(condition, hash)
      @@commands.addIf(condition, hash)
    end
  
    def self.copy(option, *new_options)
      @@commands.copy(option, *new_options)
    end
  
    def self.each
      @@commands.each { |key, hash| yield key, hash }
    end
  
    def self.hasFunction?(option, function)
      option_hash = @@commands[option]
      return option_hash && option_hash.keys.include?(function)
    end
  
    def self.getFunction(option, function)
      option_hash = @@commands[option]
      return (option_hash && option_hash[function]) ? option_hash[function] : nil
    end
  
    def self.call(function, option, *args)
      option_hash = @@commands[option]
      return nil if !option_hash || !option_hash[function]
      return (option_hash[function].call(*args) == true)
    end
end