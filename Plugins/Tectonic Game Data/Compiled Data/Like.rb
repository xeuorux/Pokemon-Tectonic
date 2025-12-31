module Compiler
	module_function
  
	def compile_likes(path = "PBS/likes.txt")
		GameData::Like::DATA.clear
		likeNames = []
		likeNumber = 0
		baseFiles = [path]
		likeTextFiles = []
		likeTextFiles.concat(baseFiles)
		likeExtensions = Compiler.get_extensions("likes")
		likeTextFiles.concat(likeExtensions)
		likeTextFiles.each do |path|
			baseFile = baseFiles.include?(path)
			pbCompilerEachCommentedLine(path) { |line, line_no|
				line = pbGetCsvRecord(line, line_no, [0, "*ns"])
				like_symbol = line[0].to_sym
				if GameData::Like::DATA[like_symbol]
					if !baseFile
						# Back up base entry for writing base PBS later (only if not already backed up)
						unless GameData::Like::BASE_DATA[like_symbol]
							old_like = GameData::Like::DATA[like_symbol]
							backup_hash = {
								:id          => old_like.id,
								:id_number   => old_like.id_number,
								:real_name   => old_like.real_name,
								:defined_in_extension => old_like.instance_variable_get(:@defined_in_extension)
							}
							GameData::Like::BASE_DATA[like_symbol] = GameData::Like.new(backup_hash)
						end
						# Extension is modifying an existing like, so we'll modify in-place
						existing_like = GameData::Like::DATA[like_symbol]
						existing_like.instance_variable_set(:@real_name, line[1])
						likeNames[existing_like.id_number] = line[1]
						next
					else
						raise _INTL("Pokemon like ID '{1}' is used twice.\r\n{2}", like_symbol, FileLineData.linereport)
					end
				end
				like_hash = {
					:id          => like_symbol,
					:id_number	 => likeNumber,
					:real_name	 => line[1],
					:defined_in_extension => !baseFile
				}
				GameData::Like.register(like_hash)
				likeNames[likeNumber]        = like_hash[:real_name]
				likeNumber += 1
			}
		end
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
		attr_reader :defined_in_extension

		DATA = {}
		BASE_DATA = {} # Data that hasn't been extended
		DATA_FILENAME = "likes.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
			@real_name = hash[:real_name]
			@defined_in_extension = hash[:defined_in_extension] || false
		end

		def name
			pbGetMessage(MessageTypes::Likes, @id_number)
		end

		def self.getRandomLike
			like = DATA.values.sample
			return like if $DEBUG
			while like.id.start_with?("DEBUG_") do
				like = DATA.values.sample
			end
			return like
		end
	end
end
