class MoveScoringHandlerHash < HandlerHash2
end

class BossBehaviourHash < HandlerHash2
end

class PokeBattle_AI
	def self.AIErrorRecovered(error)
		pbMessage(_INTL("A recoverable AI error has occured. Please report the following to a programmer."))
		pbPrintException(error)
	end

	BossGetMoveIDScore					= MoveScoringHandlerHash.new
	BossGetMoveCodeScore				= MoveScoringHandlerHash.new
	BossSpeciesGetMoveScore				= MoveScoringHandlerHash.new

	def self.triggerBossGetMoveIDScore(moveId,move,user,target,score)
		ret = nil
		begin
			ret = BossGetMoveIDScore.trigger(moveId,move,user,target,score)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : score
	end
	
	def self.triggerBossGetMoveCodeScore(moveCode,move,user,target,score)
		ret = nil
		begin
			ret = BossGetMoveCodeScore.trigger(moveCode,move,user,target,score)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : score
	end
	
	def self.triggerBossSpeciesGetMoveScore(bossSpecies,move,user,target,score)
		ret = nil
		begin
			ret = BossSpeciesGetMoveScore.trigger(bossSpecies,move,user,target,score)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : score
	end
	
	BossRejectMoveID					= MoveScoringHandlerHash.new
	BossRejectMoveCode					= MoveScoringHandlerHash.new
	BossSpeciesRejectMove				= MoveScoringHandlerHash.new
	
	def self.triggerBossRejectMoveID(moveId,move,user,target)
		ret = nil
		begin
			ret = BossRejectMoveID.trigger(moveId,move,user,target)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : false
	end
	
	def self.triggerBossRejectMoveCode(moveCode,move,user,target)
		ret = nil
		begin
			ret = BossRejectMoveCode.trigger(moveCode,move,user,target)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : false
	end
	
	def self.triggerBossSpeciesRejectMove(species,move,user,target)
		ret = nil
		begin
			ret = BossSpeciesRejectMove.trigger(species,move,user,target)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : false
	end
	
	BossRequireMoveID					= MoveScoringHandlerHash.new
	BossRequireMoveCode					= MoveScoringHandlerHash.new
	BossSpeciesRequireMove				= MoveScoringHandlerHash.new
	
	def self.triggerBossRequireMoveID(moveId,move,user,target)
		ret = nil
		begin
			ret = BossRequireMoveID.trigger(moveId,move,user,target)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : false
	end
	
	def self.triggerBossRequireMoveCode(moveCode,move,user,target)
		ret = nil
		begin
			ret = BossRequireMoveCode.trigger(moveCode,move,user,target)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : false
	end
	
	def self.triggerBossSpeciesRequireMove(species,move,user,target)
		ret = nil
		begin
			ret = BossSpeciesRequireMove.trigger(species,move,user,target)
		rescue
			AIErrorRecovered($!)
		end
		return (ret!=nil) ? ret : false
	end
	
	BossSpeciesUseMoveCodeIfAndOnlyIf			= MoveScoringHandlerHash.new
	BossSpeciesUseMoveIDIfAndOnlyIf				= MoveScoringHandlerHash.new
	
	def self.triggerBossSpeciesUseMoveCodeIfAndOnlyIf(speciesAndMoveCode,user,target,move)
		ret = nil
		begin
			ret = BossSpeciesUseMoveCodeIfAndOnlyIf.trigger(speciesAndMoveCode,user,target,move)
		rescue
			AIErrorRecovered($!)
		end
		return ret
	end
	
	def self.triggerBossSpeciesUseMoveIDIfAndOnlyIf(speciesAndMoveID,user,target,move)
		ret = nil
		begin
			ret = BossSpeciesUseMoveIDIfAndOnlyIf.trigger(speciesAndMoveID,user,target,move)
		rescue
			AIErrorRecovered($!)
		end
		return ret
	end
	
	BossDecidedOnMove				 	= BossBehaviourHash.new
	BossBeginTurn						= BossBehaviourHash.new
	
	def self.triggerBossDecidedOnMove(species,move,user,targets)
		ret = nil
		begin
			return BossDecidedOnMove.trigger(species,move,user,targets)
		rescue
			AIErrorRecovered($!)
		end
	end
	
	def self.triggerBossBeginTurn(species,battler)
		ret = nil
		begin
			return BossBeginTurn.trigger(species,battler)
		rescue
			AIErrorRecovered($!)
		end
	end

	def pbGetRealDamageBoss(move,user,target)
		# Calculate how much damage the move will do (roughly)
		baseDmg = pbMoveBaseDamage(move,user,target,0)
		# Account for accuracy of move
		accuracy = pbRoughAccuracy(move,user,target,0)
		realDamage = baseDmg * accuracy/100.0
		# Two-turn attacks waste 2 turns to deal one lot of damage
		if move.chargingTurnMove? || move.function=="0C2"   # Hyper Beam
		  realDamage *= 2/3   # Not halved because semi-invulnerable during use or hits first turn
		end
		return realDamage
	end

	def pbGetMoveScoreBoss(move,user,target)
		score = 100
		
		score = PokeBattle_AI.triggerBossGetMoveCodeScore(move.id,move,user,target,score)
		score = PokeBattle_AI.triggerBossGetMoveIDScore(move.function,move,user,target,score)
		score = PokeBattle_AI.triggerBossSpeciesGetMoveScore(user.species,move,user,target,score)
		
		# Use protect exactly every three turns, and as the first move of that turn
		if move.is_a?(PokeBattle_ProtectMove)
			score = user.battle.commandPhasesThisRound == 0 ? (@battle.turnCount % 3 == 0 ? 99999 : 0) : 0
		end
		
		# Use healing moves guarenteed if low on health and its not the first move of the turn
		if move.is_a?(PokeBattle_HealingMove)
			if (user.hp.to_f/user.totalhp.to_f) > 0.25 || user.battle.commandPhasesThisRound != 0
				score = 0
			else
				score = 99999
			end 
		end
		
		# Guarantee certain moves
		score = 99999 if PokeBattle_AI.triggerBossRequireMoveCode(move.function,move,user,target)
		score = 99999 if PokeBattle_AI.triggerBossRequireMoveID(move.id,move,user,target)
		score = 99999 if PokeBattle_AI.triggerBossSpeciesRequireMove(user.species,move,user,target)
		
		# Rejecting moves
		@battle.messagesBlocked = true
		score = 0 if PokeBattle_AI.triggerBossRejectMoveCode(move.function,move,user,target)
		score = 0 if PokeBattle_AI.triggerBossRejectMoveID(move.id,move,user,target)
		score = 0 if PokeBattle_AI.triggerBossSpeciesRejectMove(user.species,move,user,target)
		
		useMoveIFF = PokeBattle_AI.triggerBossSpeciesUseMoveCodeIfAndOnlyIf([user.species,move.function],user,target,move)
		if !(useMoveIFF.nil?)
			score = useMoveIFF ? 99999 : 0
		end
		useMoveIFF = PokeBattle_AI.triggerBossSpeciesUseMoveIDIfAndOnlyIf([user.species,move.id],user,target,move)
		if !(useMoveIFF.nil?)
			score = useMoveIFF ? 99999 : 0
		end

		# Never use a move that would fail outright
		if move.pbMoveFailed?(user,[target])
			echoln("Scoring #{move.name} a 0 due to being predicted to fail entirely")
			return 0
		end
		
		# Status inducing move and is a status move
		# Check for specific target failure condition
		if !target.nil? && move.pbFailsAgainstTarget?(user,target)
			echoln("Scoring #{move.name} a 0 due to being predicted to fail against the target")
			return 0
		end

		# Try very hard not to attack targets which are protected
		if !target.nil? && target.protected?
			echoln("Scoring #{move.name} a 1 due to the target being protected this turn")
			return 1
		end

		@battle.messagesBlocked = false
		
		return score
	end
end