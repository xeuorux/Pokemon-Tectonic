class MoveScoringHandlerHash < HandlerHash2
end

class BossBehaviourHash < HandlerHash2
end

class PokeBattle_AI
	BossGetMoveIDScore					= MoveScoringHandlerHash.new
	BossGetMoveCodeScore				= MoveScoringHandlerHash.new
	BossSpeciesGetMoveScore				= MoveScoringHandlerHash.new

	def self.triggerBossGetMoveIDScore(moveId,move,user,target,score)
		ret = BossGetMoveIDScore.trigger(moveId,move,user,target,score)
		return (ret!=nil) ? ret : score
	end
	
	def self.triggerBossGetMoveCodeScore(moveCode,move,user,target,score)
		ret = BossGetMoveCodeScore.trigger(moveCode,move,user,target,score)
		return (ret!=nil) ? ret : score
	end
	
	def self.triggerBossSpeciesGetMoveScore(bossSpecies,move,user,target,score)
		ret = BossSpeciesGetMoveScore.trigger(bossSpecies,move,user,target,score)
		return (ret!=nil) ? ret : score
	end
	
	BossRejectMoveID					= MoveScoringHandlerHash.new
	BossRejectMoveCode					= MoveScoringHandlerHash.new
	BossSpeciesRejectMove				= MoveScoringHandlerHash.new
	
	def self.triggerBossRejectMoveID(moveId,move,user,target)
		ret = BossRejectMoveID.trigger(moveId,move,user,target)
		return (ret!=nil) ? ret : false
	end
	
	def self.triggerBossRejectMoveCode(moveCode,move,user,target)
		ret = BossRejectMoveCode.trigger(moveCode,move,user,target)
		return (ret!=nil) ? ret : false
	end
	
	def self.triggerBossSpeciesRejectMove(species,move,user,target)
		ret = BossSpeciesRejectMove.trigger(species,move,user,target)
		return (ret!=nil) ? ret : false
	end
	
	BossRequireMoveID					= MoveScoringHandlerHash.new
	BossRequireMoveCode					= MoveScoringHandlerHash.new
	BossSpeciesRequireMove				= MoveScoringHandlerHash.new
	
	def self.triggerBossRequireMoveID(moveId,move,user,target)
		ret = BossRequireMoveID.trigger(moveId,move,user,target)
		return (ret!=nil) ? ret : false
	end
	
	def self.triggerBossRequireMoveCode(moveCode,move,user,target)
		ret = BossRequireMoveCode.trigger(moveCode,move,user,target)
		return (ret!=nil) ? ret : false
	end
	
	def self.triggerBossSpeciesRequireMove(species,move,user,target)
		ret = BossSpeciesRequireMove.trigger(species,move,user,target)
		return (ret!=nil) ? ret : false
	end
	
	BossSpeciesUseMoveCodeIfAndOnlyIf			= MoveScoringHandlerHash.new
	BossSpeciesUseMoveIDIfAndOnlyIf				= MoveScoringHandlerHash.new
	
	def self.triggerBossSpeciesUseMoveCodeIfAndOnlyIf(speciesAndMoveCode,user,target,move)
		ret = BossSpeciesUseMoveCodeIfAndOnlyIf.trigger(speciesAndMoveCode,user,target,move)
		return ret
	end
	
	def self.triggerBossSpeciesUseMoveIDIfAndOnlyIf(speciesAndMoveID,user,target,move)
		ret = BossSpeciesUseMoveIDIfAndOnlyIf.trigger(speciesAndMoveID,user,target,move)
		return ret
	end
	
	BossDecidedOnMove				 	= BossBehaviourHash.new
	BossBeginTurn						= BossBehaviourHash.new
	
	def self.triggerBossDecidedOnMove(species,move,user,target)
		return BossDecidedOnMove.trigger(species,move,user,target)
	end
	
	def self.triggerBossBeginTurn(species,battler)
		return BossBeginTurn.trigger(species,battler)
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
			score = 99999
			score = 0 if (user.hp.to_f/user.totalhp.to_f) > 0.25
			score = 0 if user.battle.commandPhasesThisRound != 0
		end
		
		if !move.damagingMove? && move.is_a?(PokeBattle_TargetStatDownMove)
			statDown = move.statDown[0]
			maxStat = -99999
			maxStater = nil
			@battle.battlers.each do |b|
				next if !b || !user.opposes?(b)
				stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
				stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
				stat      = b.plainStats[statDown]
				statStage = b.stages[statDown]+6
				stat = (stat.to_f*stageMul[statStage]/stageDiv[statStage]).floor
				if stat > maxStat
					maxStat = stat
					maxStater = b
				end
			end
			score = target == maxStater ? 130 : 0
		end
		
		# More likely to use damaging moves the more damage they do, and the less current HP you have
		if move.damagingMove?
			damageRatio = pbGetRealDamageBoss(move,user,target).to_f / user.hp.to_f
			score = (score * (damageRatio+1.0)/2).floor
		end
		
		# Much more likely to use priority moves/flinching moves when that stuff can actually matter
		if move.priority > 0 || move.flinchingMove?
			if user.battle.commandPhasesThisRound == 0
				score *= 2
			else
				score *= 0.5
			end
		end
		
		# Nearly guarantee certain moves
		score = 99999 if PokeBattle_AI.triggerBossRequireMoveCode(move.function,move,user,target)
		score = 99999 if PokeBattle_AI.triggerBossRequireMoveID(move.id,move,user,target)
		score = 99999 if PokeBattle_AI.triggerBossSpeciesRequireMove(user.species,move,user,target)
		
		# Rejecting moves out of hand
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
			score = 0
		end
		
		# Status inducing move and is a status move
		# Check for specific target failure condition
		if ["003","005","006","007","00A","00C"].include?(move.function) && move.statusMove?
			score = 0 if move.pbFailsAgainstTarget?(user,target)
		end
		
		score = 99999 if 
		
		@battle.messagesBlocked = false
		
		return score
	end
end