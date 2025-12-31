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
			baseFile = baseFiles.include?(path)
			pbCompilerEachCommentedLine(path) { |line, line_no|
				line = pbGetCsvRecord(line, line_no, [0, "*ns"])
				trait_symbol = line[0].to_sym
				if GameData::Trait::DATA[trait_symbol]
					if !baseFile
						# Back up base entry for writing base PBS later (only if not already backed up)
						unless GameData::Trait::BASE_DATA[trait_symbol]
							old_trait = GameData::Trait::DATA[trait_symbol]
							backup_hash = {
								:id          => old_trait.id,
								:id_number   => old_trait.id_number,
								:real_name   => old_trait.real_name,
								:defined_in_extension => old_trait.instance_variable_get(:@defined_in_extension)
							}
							GameData::Trait::BASE_DATA[trait_symbol] = GameData::Trait.new(backup_hash)
						end
						# Extension is modifying an existing trait, so we'll modify in-place
						existing_trait = GameData::Trait::DATA[trait_symbol]
						existing_trait.instance_variable_set(:@real_name, line[1])
						traitNames[existing_trait.id_number] = line[1]
						next
					else
						raise _INTL("Pokemon trait ID '{1}' is used twice.\r\n{2}", trait_symbol, FileLineData.linereport)
					end
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
		end
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
		BASE_DATA = {} # Data that hasn't been extended
		DATA_FILENAME = "traits.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
			@real_name = hash[:real_name]
			@defined_in_extension = hash[:defined_in_extension] || false
		end

		def name
			pbGetMessage(MessageTypes::Traits, @id_number)
		end

		def self.getRandomTrait
			trait = DATA.values.sample
			return trait if $DEBUG
			while trait.id.start_with?("DEBUG_") do
				trait = DATA.values.sample
			end
			return trait
		end
	end
end
