module GameData
	class Policy
		attr_reader :id

		DATA = {}
		DATA_FILENAME = "policies.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
		end
	end
end
