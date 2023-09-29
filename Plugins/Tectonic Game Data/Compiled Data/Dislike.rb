module Compiler
	module_function
  
	def compile_dislikes(path = "PBS/dislikes.txt")
		GameData::Dislike::DATA.clear
		dislikeNames = []
		dislikeNumber = 0
		pbCompilerEachCommentedLine(path) { |line, line_no|
			line = pbGetCsvRecord(line, line_no, [0, "*ns"])
			dislike_symbol = line[0].to_sym
			if GameData::Dislike::DATA[dislike_symbol]
				raise _INTL("Pokemon dislike ID '{1}' is used twice.\r\n{2}", dislike_symbol, FileLineData.linereport)
			end
			dislike_hash = {
				:id          => dislike_symbol,
				:id_number	 => dislikeNumber,
				:real_name	 => line[1],
			}
			GameData::Dislike.register(dislike_hash)
			dislikeNames[dislikeNumber]        = dislike_hash[:real_name]
			dislikeNumber += 1
		}
		# Save all data
		GameData::Dislike.save
		MessageTypes.setMessages(MessageTypes::Dislikes, dislikeNames)
		Graphics.update
	end
end

module GameData
	class Dislike
		attr_reader :id
		attr_reader :id_number
		attr_reader :real_name

		DATA = {}
		DATA_FILENAME = "dislikes.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
			@real_name = hash[:real_name]
		end

		def name
			pbGetMessage(MessageTypes::Dislikes, @id_number)
		end

		def self.getRandomDislike
			return DATA.values.sample
		end
	end
end
