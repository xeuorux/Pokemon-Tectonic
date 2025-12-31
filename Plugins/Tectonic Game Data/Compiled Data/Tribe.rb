module Compiler
	module_function

	def compile_tribes(path = "PBS/tribes.txt")
		tribe_names        = []
    tribe_descriptions = []
		GameData::Tribe::DATA.clear
		tribe_number = 0
		baseFiles = [path]
		tribeTextFiles = []
		tribeTextFiles.concat(baseFiles)
		policyExtensions = Compiler.get_extensions("tribes")
		tribeTextFiles.concat(policyExtensions)
		tribeTextFiles.each do |path|
			baseFile = baseFiles.include?(path)
			# Read each line of tribes.txt at a time and compile it
			pbCompilerEachCommentedLine(path) { |line, line_no|
				tribeSchema = [0, "*niss"]
				line = pbGetCsvRecord(line, line_no, tribeSchema)
				tribe_symbol = line[0].to_sym
				tribe_threshold = line[1].to_i
				tribe_name = line[2]
				tribe_description = line[3]
				if GameData::Tribe::DATA[tribe_symbol]
					if !baseFile
						# Back up base entry for writing base PBS later (only if not already backed up)
						unless GameData::Tribe::BASE_DATA[tribe_symbol]
							old_tribe = GameData::Tribe::DATA[tribe_symbol]
							backup_hash = {
								:id          => old_tribe.id,
								:id_number   => old_tribe.id_number,
								:threshold   => old_tribe.threshold,
								:description => old_tribe.real_description,
								:name        => old_tribe.real_name,
								:defined_in_extension => old_tribe.defined_in_extension
							}
							GameData::Tribe::BASE_DATA[tribe_symbol] = GameData::Tribe.new(backup_hash)
						end
						# Extension is modifying an existing tribe, so we'll modify in-place
						existing_tribe = GameData::Tribe::DATA[tribe_symbol]
						existing_tribe.instance_variable_set(:@threshold, tribe_threshold)
						existing_tribe.instance_variable_set(:@real_name, tribe_name)
						existing_tribe.instance_variable_set(:@real_description, tribe_description)
						tribe_names[existing_tribe.id_number] = tribe_name
						tribe_descriptions[existing_tribe.id_number] = tribe_description
						next
					else
						raise _INTL("Tribe ID '{1}' is used twice.\r\n{2}", tribe_symbol, FileLineData.linereport)
					end
				end
				# Construct tribe hash
				tribe_hash = {
					:id          => tribe_symbol,
					:id_number   => tribe_number,
					:threshold   => tribe_threshold,
					:description => tribe_description,
					:name		 => tribe_name,
					:defined_in_extension => !baseFile
				}
				# Add tribe's data to records
				GameData::Tribe.register(tribe_hash)
				tribe_names[tribe_number]        = tribe_name
				tribe_descriptions[tribe_number] = tribe_hash[:description]

				tribe_number += 1
			}
		end
		# Save all data
		GameData::Tribe.save
		Graphics.update

		MessageTypes.setMessages(MessageTypes::Tribes, tribe_names)
		MessageTypes.setMessages(MessageTypes::TribeDescriptions, tribe_descriptions)
	end
end

module GameData
	class Tribe
		attr_reader :id
		attr_reader :id_number
		attr_reader :threshold
		attr_reader :real_description
		attr_reader :real_name
		attr_reader :defined_in_extension

		DATA = {}
		BASE_DATA = {} # Data that hasn't been extended
		DATA_FILENAME = "tribes.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
			@threshold = hash[:threshold]
			@real_description = hash[:description]
			@real_name = hash[:name]
			@defined_in_extension = hash[:defined_in_extension] || false
		end

		def name
			pbGetMessage(MessageTypes::Tribes, @id_number)
		end

		def description
			pbGetMessage(MessageTypes::TribeDescriptions, @id_number)
		end
	end
end
