class NPCTrainer < Trainer
	attr_accessor :policies
	attr_accessor :policyStates
	
	def initialize(name, trainer_type)
		super
		@items     = []
		@lose_text = nil
		@policies  = []
		#@policies.push(:Debug)
		@policyStates = {}
		addPoliciesBasedOnTrainerClass(trainer_type)
	end
	
	def addPoliciesBasedOnTrainerClass(trainer_type)
		case trainer_type
			when :LEADER_Lambert
				@policies.push(:Lambert)
		end
	end
end