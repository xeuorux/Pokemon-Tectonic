# Trainer dialogue events!

class TrainerDialogueHandlerHash < HandlerHash2
end

class PokeBattle_AI
	TrainerChoseMoveDialogue                    = TrainerDialogueHandlerHash.new
	PlayerChoseMoveDialogue						= TrainerDialogueHandlerHash.new
	TrainerPokemonFaintedDialogue				= TrainerDialogueHandlerHash.new
	PlayerPokemonFaintedDialogue				= TrainerDialogueHandlerHash.new
	
	def self.triggerTrainerChoseMoveDialogue(policy,battler,move,target,trainer_name,dialogue_array)
		ret = TrainerChoseMoveDialogue.trigger(policy,battler,move,target,trainer_name,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerChoseMoveDialogue(policy,battler,move,target,dialogue_array)
		ret = PlayerChoseMoveDialogue.trigger(policy,battler,move,target,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerTrainerPokemonFaintedDialogue(policy,battler,dialogue_array)
		ret = TrainerPokemonFaintedDialogue.trigger(policy,battler,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerPokemonFaintedDialogue(policy,battler,dialogue_array)
		ret = PlayerPokemonFaintedDialogue.trigger(policy,battler,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
end