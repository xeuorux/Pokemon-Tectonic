module GameData
	class Tribe
		attr_reader :id
		attr_reader :id_number

		DATA = {}
		DATA_FILENAME = "tribes.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@id_number = hash[:id_number]
		end
	end
end
