# Trainer dialogue events!

class TrainerDialogueHandlerHash < HandlerHash2
end

class PokeBattle_AI
	TrainerChoseMoveDialogue                    = TrainerDialogueHandlerHash.new
	PlayerChoseMoveDialogue						= TrainerDialogueHandlerHash.new
	TrainerIsUsingMoveDialogue					= TrainerDialogueHandlerHash.new
	PlayerIsUsingMoveDialogue					= TrainerDialogueHandlerHash.new
	TrainerPokemonFaintedDialogue				= TrainerDialogueHandlerHash.new
	PlayerPokemonFaintedDialogue				= TrainerDialogueHandlerHash.new
	TrainerSendsOutPokemonDialogue				= TrainerDialogueHandlerHash.new
	PlayerSendsOutPokemonDialogue				= TrainerDialogueHandlerHash.new
	TrainerPokemonTookMoveDamageDialogue		= TrainerDialogueHandlerHash.new
	PlayerPokemonTookMoveDamageDialogue			= TrainerDialogueHandlerHash.new
	TrainerPokemonImmuneDialogue				= TrainerDialogueHandlerHash.new
	PlayerPokemonImmuneDialogue					= TrainerDialogueHandlerHash.new
	TrainerPokemonDiesToDOTDialogue				= TrainerDialogueHandlerHash.new
	PlayerPokemonDiesToDOTDialogue				= TrainerDialogueHandlerHash.new
	WeatherChangeDialogue						= TrainerDialogueHandlerHash.new
	TerrainChangeDialogue						= TrainerDialogueHandlerHash.new
	BattleSurvivedDialogue						= TrainerDialogueHandlerHash.new
	TrainerPokemonConsumesItemDialogue			= TrainerDialogueHandlerHash.new
	PlayerPokemonConsumesItemDialogue			= TrainerDialogueHandlerHash.new
	
	def self.triggerTrainerChoseMoveDialogue(policy,battler,move,target,trainer_speaking,dialogue_array)
		ret = TrainerChoseMoveDialogue.trigger(policy,battler,move,target,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerChoseMoveDialogue(policy,battler,move,target,trainer_speaking,dialogue_array)
		ret = PlayerChoseMoveDialogue.trigger(policy,battler,move,target,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerTrainerIsUsingMoveDialogue(policy,battler,move,target,trainer_speaking,dialogue_array)
		ret = TrainerIsUsingMoveDialogue.trigger(policy,battler,move,target,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end

	def self.triggerPlayerIsUsingMoveDialogue(policy,battler,move,target,trainer_speaking,dialogue_array)
		ret = PlayerIsUsingMoveDialogue.trigger(policy,battler,move,target,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerTrainerPokemonFaintedDialogue(policy,battler,trainer_speaking,dialogue_array)
		ret = TrainerPokemonFaintedDialogue.trigger(policy,battler,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerPokemonFaintedDialogue(policy,battler,trainer_speaking,dialogue_array)
		ret = PlayerPokemonFaintedDialogue.trigger(policy,battler,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerTrainerSendsOutPokemonDialogue(policy,battler,trainer_speaking,dialogue_array)
		ret = TrainerSendsOutPokemonDialogue.trigger(policy,battler,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerSendsOutPokemonDialogue(policy,battler,trainer_speaking,dialogue_array)
		ret = PlayerSendsOutPokemonDialogue.trigger(policy,battler,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerTrainerPokemonTookMoveDamageDialogue(policy,dealer,taker,trainer_speaking,dialogue_array)
		ret = TrainerPokemonTookMoveDamageDialogue.trigger(policy,dealer,taker,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerPokemonTookMoveDamageDialogue(policy,dealer,taker,trainer_speaking,dialogue_array)
		ret = PlayerPokemonTookMoveDamageDialogue.trigger(policy,dealer,taker,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerTrainerPokemonImmuneDialogue(policy,attacker,target,isImmunityAbility,trainer_speaking,dialogue_array)
		ret = TrainerPokemonImmuneDialogue.trigger(policy,attacker,target,isImmunityAbility,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerPokemonImmuneDialogue(policy,attacker,target,isImmunityAbility,trainer_speaking,dialogue_array)
		ret = PlayerPokemonImmuneDialogue.trigger(policy,attacker,target,isImmunityAbility,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerTrainerPokemonDiesToDOTDialogue(policy,pokemon,trainer_speaking,dialogue_array)
		ret = TrainerPokemonDiesToDOTDialogue.trigger(policy,pokemon,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerPokemonDiesToDOTDialogue(policy,pokemon,trainer_speaking,dialogue_array)
		ret = PlayerPokemonDiesToDOTDialogue.trigger(policy,pokemon,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end

	def self.triggerWeatherChangeDialogue(policy,old_weather,new_weather,trainer_speaking,dialogue_array)
		ret = WeatherChangeDialogue.trigger(policy,old_weather,new_weather,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerTerrainChangeDialogue(policy,old_terrain,new_terrain,trainer_speaking,dialogue_array)
		ret = TerrainChangeDialogue.trigger(policy,old_terrain,new_terrain,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end

	def self.triggerBattleSurvivedDialogue(policy,trainer_speaking,dialogue_array)
		ret = BattleSurvivedDialogue.trigger(policy,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end

	def self.triggerTrainerPokemonConsumesItemDialogue(policy,battler,item,trainer_speaking,dialogue_array)
		ret = TrainerChoseMoveDialogue.trigger(policy,battler,item,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
	
	def self.triggerPlayerPokemonConsumesItemDialogue(policy,battler,item,trainer_speaking,dialogue_array)
		ret = PlayerChoseMoveDialogue.trigger(policy,battler,item,trainer_speaking,dialogue_array)
		return (ret!=nil) ? ret : dialogue_array
	end
end

class PokeBattle_Battle
	#####################################################
	## Dialogue triggering helper method helper methods (yo dawg)
	#####################################################
	def triggerDialogueOnBattlerAction(battler)
		if @opponent
			if pbOwnedByPlayer?(battler.index)
				@opponent.each_with_index do |trainer_speaking,idxTrainer|
					@scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
						yield true,policy,trainer_speaking,dialogue
					}
				end
			else
				idxTrainer = pbGetOwnerIndexFromBattlerIndex(battler.index)
				trainer_speaking = @opponent[idxTrainer]
				@scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
					yield false,policy,trainer_speaking,dialogue
				}
			end
		end
	end

	def triggerDialogueForEachOpponent
		if @opponent
			@opponent.each_with_index do |trainer_speaking,idxTrainer|
				@scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
					yield policy,trainer_speaking,dialogue
				}
			end
		end
	end

	#####################################################
	## Dialogue triggering helper methods
	#####################################################
	def triggerTerrainChangeDialogue(old_terrain,new_terrain)
		triggerDialogueForEachOpponent() { |policy,trainer_speaking,dialogue|
			PokeBattle_AI.triggerTerrainChangeDialogue(policy,old_terrain,new_terrain,trainer_speaking,dialogue)
		}
	end

	def triggerWeatherChangeDialogue(old_weather,new_weather)
		triggerDialogueForEachOpponent() { |policy,trainer_speaking,dialogue|
			PokeBattle_AI.triggerWeatherChangeDialogue(policy,old_weather,new_weather,trainer_speaking,dialogue)
		}
	end

	def triggerBattlerConsumedItemDialogue(battler,item)
		triggerDialogueOnBattlerAction() { |isTrainer,policy,trainer_speaking,dialogue|
			if isTrainer
				PokeBattle_AI.triggerTrainerPokemonConsumesItemDialogue(policy,battler,item,trainer_speaking,dialogue)
			else
				PokeBattle_AI.triggerPlayerPokemonConsumesItemDialogue(policy,battler,item,trainer_speaking,dialogue)
			end
		}
	end
end