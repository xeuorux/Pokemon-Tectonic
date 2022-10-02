class PokeBattle_AI
	#=============================================================================
	# Get a score for the given move based on its effect
	#=============================================================================
	def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100,policies=[])		
		case move.function
		#---------------------------------------------------------------------------
		when "037" # Accupressure
			avgStat = 0; canChangeStat = false
			GameData::Stat.each_battle do |s|
				next if target.statStageAtMax?(s.id)
				avgStat -= target.stages[s.id]
				canChangeStat = true
			end
			if canChangeStat
				avgStat = avgStat/2 if avgStat<0	 # More chance of getting even better
				score += avgStat*10
			else
				score = 0
			end
		#---------------------------------------------------------------------------
		when "10A"
			score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
			score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect]>0
			score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen]>0
		#---------------------------------------------------------------------------
		when "10B"
			score += 10*(user.stages[:ACCURACY]-target.stages[:EVASION])
		#---------------------------------------------------------------------------
		when "10C"
			if user.effects[PBEffects::Substitute]>0
				score = 0
			elsif user.hp<=user.totalhp/4
				score = 0
			end
		#---------------------------------------------------------------------------
		when "10D"
			if user.pbHasTypeAI?(:GHOST)
				if target.effects[PBEffects::Curse]
					score = 0
				elsif user.hp<=user.totalhp/2
					if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
					score = 0
					else
					score -= 50
					score -= 30 if @battle.switchStyle
					end
				end
			else
				avg	= user.stages[:SPEED]*10
				avg -= user.stages[:ATTACK]*10
				avg -= user.stages[:DEFENSE]*10
				score += avg/3
			end
		#---------------------------------------------------------------------------
		when "10E"
			score -= 40
		#---------------------------------------------------------------------------
		when "10F"
			if target.effects[PBEffects::Nightmare] ||
			target.effects[PBEffects::Substitute]>0
				score = 0
			elsif !target.asleep?
				score = 0
			else
				score = 0 if target.statusCount<=1
				score += 50 if target.statusCount>3
			end
		#---------------------------------------------------------------------------
		when "110"
			score += 30 if user.effects[PBEffects::Trapping]>0
			score += 30 if user.effects[PBEffects::LeechSeed]>=0
			if @battle.pbAbleNonActiveCount(user.idxOwnSide)>0
				score += 80 if user.pbOwnSide.effects[PBEffects::Spikes]>0
				score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
				score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
			end
		#---------------------------------------------------------------------------
		when "111"
			if @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
				score = 0
			elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
			# Future Sight tends to be wasteful if down to last Pokemon
				score -= 70
			end
		#---------------------------------------------------------------------------
		when "112"
			avg = 0
			avg -= user.stages[:DEFENSE]*10
			avg -= user.stages[:SPECIAL_DEFENSE]*10
			score += avg/2
			if user.effects[PBEffects::Stockpile]>=3
				score -= 80
			else
				# More preferable if user also has Spit Up/Swallow
				score += 20 if user.pbHasMoveFunction?("113","114")	 # Spit Up, Swallow
			end
		#---------------------------------------------------------------------------
		when "113"
			score = 0 if user.effects[PBEffects::Stockpile]==0
		#---------------------------------------------------------------------------
		when "114"
			if user.effects[PBEffects::Stockpile]==0
				score = 0
			elsif user.hp==user.totalhp
				score = 0
			else
				mult = [0,25,50,100][user.effects[PBEffects::Stockpile]]
				score += mult
				score -= user.hp*mult*2/user.totalhp
			end
		#---------------------------------------------------------------------------
		when "115"
			score += 50 if target.effects[PBEffects::HyperBeam]>0
			score -= 35 if target.hp<=target.totalhp/2	 # If target is weak, no
			score -= 70 if target.hp<=target.totalhp/4	 # need to risk this move
		#---------------------------------------------------------------------------
		when "116"
		#---------------------------------------------------------------------------
		when "117"
			score = 0 if !user.hasAlly?
		#---------------------------------------------------------------------------
		when "118"
			if @battle.field.effects[PBEffects::Gravity]>0
				score = 0
			else
				score -= 30
				score -= 20 if user.effects[PBEffects::SkyDrop]>=0
				score -= 20 if user.effects[PBEffects::MagnetRise]>0
				score -= 20 if user.effects[PBEffects::Telekinesis]>0
				score -= 20 if user.pbHasTypeAI?(:FLYING)
				score -= 20 if user.hasLevitate?(true)
				score -= 20 if user.hasActiveItem?(:AIRBALLOON)
				score += 20 if target.effects[PBEffects::SkyDrop]>=0
				score += 20 if target.effects[PBEffects::MagnetRise]>0
				score += 20 if target.effects[PBEffects::Telekinesis]>0
				score += 20 if target.inTwoTurnAttack?("0C9","0CC","0CE")	 # Fly, Bounce, Sky Drop
				score += 20 if target.pbHasTypeAI?(:FLYING)
				score += 20 if target.hasLevitate?(true)
				score += 20 if target.hasActiveItem?(:AIRBALLOON)
			end
		#---------------------------------------------------------------------------
		when "119"
			if user.effects[PBEffects::MagnetRise]>0 ||
			user.effects[PBEffects::Ingrain] ||
			user.effects[PBEffects::SmackDown]
				score = 0
			end
		#---------------------------------------------------------------------------
		when "11A"
			if target.effects[PBEffects::Telekinesis]>0 ||
			target.effects[PBEffects::Ingrain] ||
			target.effects[PBEffects::SmackDown]
				score = 0
			end
		#---------------------------------------------------------------------------
		when "11C"
			score += 20 if target.effects[PBEffects::MagnetRise]>0
			score += 20 if target.effects[PBEffects::Telekinesis]>0
			score += 20 if target.inTwoTurnAttack?("0C9","0CC")	 # Fly, Bounce
			score += 20 if target.pbHasTypeAI?(:FLYING)
			score += 20 if target.hasLevitate?(true)
			score += 20 if target.hasActiveItem?(:AIRBALLOON)
		#---------------------------------------------------------------------------
		when "123"
			if !target.pbHasTypeAI?(user.type1) &&
			!target.pbHasTypeAI?(user.type2)
				score = 0
			end
		#---------------------------------------------------------------------------
		when "126"
			score += 20	 # Shadow moves are more preferable
		#---------------------------------------------------------------------------
		when "127"
			score += 20	 # Shadow moves are more preferable
			if target.pbCanParalyze?(user,false)
				score += 30
				aspeed = pbRoughStat(user,:SPEED,skill)
				ospeed = pbRoughStat(target,:SPEED,skill)
				if aspeed<ospeed
					score += 30
				elsif aspeed>ospeed
					score -= 40
				end
				score -= 40 if target.hasActiveAbilityAI?([:GUTS,:MARVELSCALE,:QUICKFEET])
			end
		#---------------------------------------------------------------------------
		when "128"
			score += 20	 # Shadow moves are more preferable
			if target.pbCanBurn?(user,false)
				score += 30
				score -= 40 if target.hasActiveAbilityAI?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
			end
		#---------------------------------------------------------------------------
		when "129"
			score += 20	 # Shadow moves are more preferable
			if target.pbCanFreeze?(user,false)
				score += 30
				score -= 20 if target.hasActiveAbilityAI?(:MARVELSCALE)
			end
		#---------------------------------------------------------------------------
		when "12A"
			score += 20	 # Shadow moves are more preferable
			if target.pbCanConfuse?(user,false)
				score += 30
			else
				score = 0
			end
		#---------------------------------------------------------------------------
		when "12D"
			score += 20	 # Shadow moves are more preferable
		#---------------------------------------------------------------------------
		when "12E"
			score += 20	 # Shadow moves are more preferable
			score += 20 if target.hp>=target.totalhp/2
			score -= 20 if user.hp<user.hp/2
		#---------------------------------------------------------------------------
		when "12F"
			score += 20	 # Shadow moves are more preferable
			score -= 110 if target.effects[PBEffects::MeanLook]>=0
		#---------------------------------------------------------------------------
		when "130"
			score += 20	 # Shadow moves are more preferable
			score -= 40
		#---------------------------------------------------------------------------
		when "131"
			score += 20	 # Shadow moves are more preferable
			if @battle.pbCheckGlobalAbility(:AIRLOCK) || @battle.pbCheckGlobalAbility(:CLOUDNINE)
				score = 0
			elsif @battle.pbWeather == :ShadowSky
				score = 0
			end
		#---------------------------------------------------------------------------
		when "132"
			score += 20	 # Shadow moves are more preferable
			if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
			target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
			target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
			target.pbOwnSide.effects[PBEffects::Safeguard]>0
				score += 30
				score = 0 if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
							user.pbOwnSide.effects[PBEffects::Reflect]>0 ||
							user.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
							user.pbOwnSide.effects[PBEffects::Safeguard]>0
			else
				score -= 110
			end
		#---------------------------------------------------------------------------
		when "133", "134" # Move that do literally nothing
		#---------------------------------------------------------------------------
		when "136"
			score += 20 if user.stages[:DEFENSE]<0
		#---------------------------------------------------------------------------
		when "137"
			hasEffect = (user.statStageAtMax?(:DEFENSE) && user.statStageAtMax?(:SPECIAL_DEFENSE))
			user.eachAlly do |b|
				next if b.statStageAtMax?(:DEFENSE) && b.statStageAtMax?(:SPECIAL_DEFENSE)
				hasEffect = true
				score -= b.stages[:DEFENSE]*10
				score -= b.stages[:SPECIAL_DEFENSE]*10
			end
			if hasEffect
				score -= 40 if user.paralyzed?
				score -= user.stages[:DEFENSE]*10
				score -= user.stages[:SPECIAL_DEFENSE]*10
			else
				score = 0
			end
		#---------------------------------------------------------------------------
		when "138"
			if target.statStageAtMax?(:SPECIAL_DEFENSE)
				score = 0
			else
				score -= 40 if target.paralyzed?
				score -= target.stages[:SPECIAL_DEFENSE]*10
			end
		#---------------------------------------------------------------------------
		when "13A"
			avg	= target.stages[:ATTACK] * 10
			avg += target.stages[:SPECIAL_ATTACK] * 10
			score += avg/2
		#---------------------------------------------------------------------------
		when "13B"
			if !user.isSpecies?(:HOOPA) || user.form != 1
				score = 0
			else
				score += 20 if target.stages[:DEFENSE]>0
			end
		#---------------------------------------------------------------------------
		when "13E"
			count = 0
			@battle.eachBattler do |b|
				if b.pbHasTypeAI?(:GRASS) && !b.airborne? &&
					(!b.statStageAtMax?(:ATTACK) || !b.statStageAtMax?(:SPECIAL_ATTACK))
					count += 1
					if user.opposes?(b)
						score -= 20
					else
						score -= user.stages[:ATTACK]*10
						score -= user.stages[:SPECIAL_ATTACK]*10
					end
				end
			end
			score = 0 if count==0
		#---------------------------------------------------------------------------
		when "13F"
			count = 0
			@battle.eachBattler do |b|
			if b.pbHasTypeAI?(:GRASS) && !b.statStageAtMax?(:DEFENSE)
				count += 1
				if user.opposes?(b)
				score -= 20
				else
				score -= user.stages[:DEFENSE]*10
				end
			end
			end
			score = 0 if count==0
		#---------------------------------------------------------------------------
		when "140"
			count=0
			@battle.eachBattler do |b|
				if b.poisoned? &&
						(!b.statStageAtMin?(:ATTACK) ||
						!b.statStageAtMin?(:SPECIAL_ATTACK) ||
						!b.statStageAtMin?(:SPEED))
					count += 1
					if user.opposes?(b)
						score += user.stages[:ATTACK]*10
						score += user.stages[:SPECIAL_ATTACK]*10
						score += user.stages[:SPEED]*10
					else
						score -= 20
					end
				end
			end
			score = 0 if count==0
		#---------------------------------------------------------------------------
		when "141"
			if target.effects[PBEffects::Substitute]>0
				score = 0
			else
				numpos = 0; numneg = 0
				GameData::Stat.each_battle do |s|
					numpos += target.stages[s.id] if target.stages[s.id] > 0
					numneg += target.stages[s.id] if target.stages[s.id] < 0
				end
				if numpos!=0 || numneg!=0
					score += (numpos-numneg)*10
				else
					score = 0
				end
			end
		#---------------------------------------------------------------------------
		when "142"
			score = 0 if target.pbHasTypeAI?(:GHOST)
		#---------------------------------------------------------------------------
		when "143"
			score = 0 if target.pbHasTypeAI?(:GRASS)
		#---------------------------------------------------------------------------
		when "144"
		#---------------------------------------------------------------------------
		when "145"
			aspeed = pbRoughStat(user,:SPEED,skill)
			ospeed = pbRoughStat(target,:SPEED,skill)
			score = 0 if aspeed>ospeed
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
					score -= 40 if target.effects[PBEffects::Yawn]>0
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