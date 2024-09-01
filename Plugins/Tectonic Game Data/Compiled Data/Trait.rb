module Compiler
	module_function
  
	def compile_traits(path = "PBS/traits.txt")
		GameData::Trait::DATA.clear
		traitNames = []
		traitNumber = 0

		baseFiles = [path]
		traitTextFiles = []
		traitTextFiles.concat(baseFiles)
		traitExtensions = Compiler.get_extensions("traits")
		traitTextFiles.concat(traitExtensions)
		traitTextFiles.each do |path|
			baseFile = baseFiles.includes?(path)
			pbCompilerEachCommentedLine(path) { |line, line_no|
				line = pbGetCsvRecord(line, line_no, [0, "*ns"])
				trait_symbol = line[0].to_sym
				if GameData::Trait::DATA[trait_symbol]
					raise _INTL("Pokemon trait ID '{1}' is used twice.\r\n{2}", trait_symbol, FileLineData.linereport)
				end
				trait_hash = {
					:id          => trait_symbol,
					:id_number	 => traitNumber,
					:real_name	 => line[1],
					:defined_in_extension => !baseFile,
				}
				GameData::Trait.register(trait_hash)
				traitNames[traitNumber] = trait_hash[:real_name]
				traitNumber += 1
			}
		# Save all data
		GameData::Trait.save
		MessageTypes.setMessages(MessageTypes::Traits, traitNames)
		Graphics.update
	end
end

module GameData
	class Trait
		attr_reader :id
		attr_reader :id_number
		attr_reader :real_name

		DATA = {}
		DATA_FILENAME = "traits.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
			@real_name = hash[:real_name]
			@defined_in_extension = hash[:defined_in_extension]
		end

		def name
			pbGetMessage(MessageTypes::Traits, @id_number)
		end

		def self.getRandomTrait
			return DATA.values.sample
		end
	end
end
