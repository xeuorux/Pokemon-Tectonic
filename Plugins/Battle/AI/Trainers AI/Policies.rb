class NPCTrainer < Trainer
	attr_accessor :policies, :policyStates

	def initialize(name, trainer_type)
		super
		@items     = []
		@lose_text = nil
		@policies  = []
		@policyStates = {}
	end
end

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
