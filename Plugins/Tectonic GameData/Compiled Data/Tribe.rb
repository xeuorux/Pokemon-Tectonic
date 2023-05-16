module Compiler
	module_function

	def compile_tribes(path = "PBS/tribes.txt")
		GameData::Tribe::DATA.clear
		# Read each line of tribes.txt at a time and compile it
		pbCompilerEachCommentedLine(path) { |line, line_no|
			tribeSchema = [0, "*nis"]
			tribe_number = 1
			line = pbGetCsvRecord(line, line_no, tribeSchema)
			tribe_symbol = line[0].to_sym
			tribe_threshold = line[1].to_i
			tribe_description = line[2]
			if GameData::Tribe::DATA[tribe_symbol]
			raise _INTL("Tribe ID '{1}' is used twice.\r\n{2}", tribe_symbol, FileLineData.linereport)
			end
			tribe_number += 1
			# Construct trainer type hash
			tribe_hash = {
			:id          => tribe_symbol,
			:id_number   => tribe_number,
			:threshold   => tribe_threshold,
			:description => tribe_description,
			}
			# Add trainer policy's data to records
			GameData::Tribe.register(tribe_hash)
		}
		# Save all data
		GameData::Tribe.save
		Graphics.update
	end

	# TODO: Write tribes
end

module GameData
	class Tribe
		attr_reader :id
		attr_reader :id_number
		attr_reader :threshold
		attr_reader :description

		DATA = {}
		DATA_FILENAME = "tribes.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
			@threshold = hash[:threshold]
			@description = hash[:description]
		end
	end
end
