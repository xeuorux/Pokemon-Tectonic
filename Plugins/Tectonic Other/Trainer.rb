class Trainer
	attr_reader   	:nameForHashing
	attr_accessor 	:policies
	attr_accessor	:tribalBonus

	def wild?;           return GameData::TrainerType.get(@trainer_type).wild?;     end

	def initialize(name, trainer_type)
		@trainer_type = trainer_type
		@name         = name
		@id           = rand(2 ** 16) | rand(2 ** 16) << 16
		@language     = pbGetLanguage
		@party        = []
		@policies 	  = []
		@tribalBonus  = TribalBonus.new(self)
	end
end

class NPCTrainer < Trainer
	attr_accessor :policyStates

	def initialize(name, trainer_type, nameForHashing = nil)
		super(name, trainer_type)
		@items     = []
		@lose_text = nil
		@policyStates = {}
		@nameForHashing = nameForHashing || name
	end

	def self.cloneFromPlayer(playerObject)
		trainerClone = NPCTrainer.new("Clone of " + playerObject.name, playerObject.trainer_type)
		trainerClone.id = playerObject.id

		playerObject.party.each do |partyMember|
			trainerClone.party.push(partyMember.clone)
		end

		return trainerClone
	end
end

class Pokemon
	attr_accessor :assignedPosition
end