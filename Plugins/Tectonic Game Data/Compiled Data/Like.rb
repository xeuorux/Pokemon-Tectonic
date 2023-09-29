module Compiler
	module_function
  
	def compile_likes(path = "PBS/likes.txt")
		GameData::Like::DATA.clear
		likeNames = []
		likeNumber = 0
		pbCompilerEachCommentedLine(path) { |line, line_no|
			line = pbGetCsvRecord(line, line_no, [0, "*ns"])
			like_symbol = line[0].to_sym
			if GameData::Like::DATA[like_symbol]
				raise _INTL("Pokemon like ID '{1}' is used twice.\r\n{2}", like_symbol, FileLineData.linereport)
			end
			like_hash = {
				:id          => like_symbol,
				:id_number	 => likeNumber,
				:real_name	 => line[1],
			}
			GameData::Like.register(like_hash)
			likeNames[likeNumber]        = like_hash[:real_name]
			likeNumber += 1
		}
		# Save all data
		GameData::Like.save
		MessageTypes.setMessages(MessageTypes::Likes, likeNames)
		Graphics.update
	end
end

module GameData
	class Like
		attr_reader :id
		attr_reader :id_number
		attr_reader :real_name

		DATA = {}
		DATA_FILENAME = "likes.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
			@real_name = hash[:real_name]
		end

		def name
			pbGetMessage(MessageTypes::Likes, @id_number)
		end

		def self.getRandomLike
			return DATA.values.sample
		end
	end
end
