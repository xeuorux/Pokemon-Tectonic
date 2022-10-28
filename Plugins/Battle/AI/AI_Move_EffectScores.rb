class PokeBattle_AI
	#=============================================================================
	# Get a score for the given move based on its effect
	#=============================================================================
	def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100,policies=[])		
		case move.function
		#---------------------------------------------------------------------------
		when "13A" # Noble Roar
			avg	= target.stages[:ATTACK] * 10
			avg += target.stages[:SPECIAL_ATTACK] * 10
			score += avg/2
		#---------------------------------------------------------------------------
		when "151" # Parting Shot
			avg	= target.stages[:ATTACK]*10
			avg += target.stages[:SPECIAL_ATTACK]*10
			score += avg/2
		#---------------------------------------------------------------------------
		when "159" # Toxic Thread
			if !target.pbCanPoison?(user,false) && !target.pbCanLowerStatStage?(:SPEED,user)
				score = 0
			else
				if target.pbCanPoison?(user,false)
					score += 30
					score += 30 if target.hp<=target.totalhp/4
					score += 50 if target.hp<=target.totalhp/8
					score -= 40 if target.effectActive?(:Yawn)
					score += 10 if pbRoughStat(target,:DEFENSE,skill)>100
					score += 10 if pbRoughStat(target,:SPECIAL_DEFENSE,skill)>100
					score -= 40 if target.hasActiveAbilityAI?([:GUTS,:MARVELSCALE,:TOXICBOOST])
				end
				if target.pbCanLowerStatStage?(:SPEED,user)
					score += target.stages[:SPEED]*10
					aspeed = pbRoughStat(user,:SPEED,skill)
					ospeed = pbRoughStat(target,:SPEED,skill)
					score += 30 if aspeed<ospeed && aspeed*2>ospeed
				end
			end
		#---------------------------------------------------------------------------
		else
			begin
				score = move.getScore(score,user,target,skill=100)
			rescue
				echoln("FAILURE IN THE SCORING SYSTEM FOR MOVE #{move.name} #{move.function}")
				score = 100
			end
		end
		return score
	end
end