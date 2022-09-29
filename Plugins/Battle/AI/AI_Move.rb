class PokeBattle_AI
    def pbChooseMoves(idxBattler)
        user        = @battle.battlers[idxBattler]
        wildBattler = (@battle.wildBattle? && @battle.opposes?(idxBattler))
        skill       = 0
        policies    = []
        if !wildBattler
            owner = @battle.pbGetOwnerFromBattlerIndex(user.index)
            skill  = owner.skill_level || 0
            policies = owner.policies || []
        end
        # Get scores and targets for each move
        # NOTE: A move is only added to the choices array if it has a non-zero
        #       score.
        choices     = []
        user.eachMoveWithIndex do |_m,i|
          next if !@battle.pbCanChooseMove?(idxBattler,i,false)
          if wildBattler
            pbRegisterMoveWild(user,i,choices)
          else
            newChoice = pbEvaluateMoveTrainer(user,user.moves[i],skill,policies)
                choices.push([i].concat(newChoice)) if newChoice
          end
        end
        # Figure out useful information about the choices
        totalScore = 0
        maxScore   = 0
        choices.each do |c|
          totalScore += c[1]
          maxScore = c[1] if maxScore<c[1]
        end
        # Log the available choices
        logMoveChoices(user,choices)
          
        if !wildBattler && maxScore <= 40 && pbEnemyShouldWithdrawEx?(idxBattler,2)
          if $INTERNAL
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will try to switch due to terrible moves")
          end
          return
        end
        
        # If there are valid choices, pick among them
        if choices.length > 0
            # Determine the most preferred move
            preferredChoice = nil
            if wildBattler
                preferredChoice = choices[pbAIRandom(choices.length)]
                PBDebug.log("[AI] #{user.pbThis} (#{user.index}) chooses #{user.moves[preferredChoice[0]].name} at random")
            else
                sortedChoices = choices.sort_by{|choice| -choice[1]}
                preferredChoice = sortedChoices[0]
                PBDebug.log("[AI] #{user.pbThis} (#{user.index}) thinks #{user.moves[preferredChoice[0]].name} is the highest rated choice")
            end
            if preferredChoice != nil
                @battle.pbRegisterMove(idxBattler,preferredChoice[0],false)
                @battle.pbRegisterTarget(idxBattler,preferredChoice[2]) if preferredChoice[2]>=0
            end
        else # If there are no calculated choices, create a list of the choices all scored the same, to be chosen between randomly later on
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) scored no moves above a zero, resetting all choices to default")
          user.eachMoveWithIndex do |_m,i|
            next if !@battle.pbCanChooseMove?(idxBattler,i,false)
                next if _m.isEmpowered?
            choices.push([i,100,-1])   # Move index, score, target
          end
          if choices.length == 0   # No moves are physically possible to use; use Struggle
            @battle.pbAutoChooseMove(user.index)
          end
        end
        # if there is somehow still no choice, randomly choose a move from the choices and register it
        if @battle.choices[idxBattler][2].nil?
          echoln("All AI protocols have failed or fallen through, picking at random.")
          randNum = pbAIRandom(totalScore)
          choices.each do |c|
            randNum -= c[1]
            next if randNum >= 0
            @battle.pbRegisterMove(idxBattler,c[0],false)
            @battle.pbRegisterTarget(idxBattler,c[2]) if c[2]>=0
            break
          end
        end
        # Log the result
        if @battle.choices[idxBattler][2]
          user.lastMoveChosen = @battle.choices[idxBattler][2].id
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
        end
        
        choice = @battle.choices[idxBattler]
        move = choice[2]
        target = choice[3]
    end
  
    #=============================================================================
    # Get scores for the given move against each possible target
    #=============================================================================
    # Wild Pokémon choose their moves randomly.
    def pbRegisterMoveWild(_user,idxMove,choices)
      choices.push([idxMove,100,-1])   # Move index, score, target
    end
  
	#=============================================================================
	# Get a score for the given move being used against the given target
	#=============================================================================
	def pbGetMoveScore(move,user,target,skill=100,policies=[])
		score = 100
		score = pbGetMoveScoreFunctionCode(score,move,user,target,skill,policies)
		if score.nil?
			echoln("#{user.pbThis} unable to score #{move.id} against target #{target.pbThis(false)} assuming 50")
			return 50
		end
		
		# Never use a move that would fail outright
		@battle.messagesBlocked = true
		user.turnCount += 1
		if move.pbMoveFailed?(user,[target])
			score = 0
            echoln("#{user.pbThis} scores the move #{move.id} as 0 due to it being predicted to fail.")
		end
		
        if move.pbFailsAgainstTarget?(user,target)
            score = 0
            echoln("#{user.pbThis} scores the move #{move.id} as 0 against target #{target.pbThis(false)} due to it being predicted to fail against that target.")
        end

        user.turnCount -= 1
        @battle.messagesBlocked = false
            
        # Don't prefer moves that are ineffective because of abilities or effects
        if pbCheckMoveImmunity(score,move,user,target,skill)
            score = 0
            echoln("#{user.pbThis} scores the move #{move.id} as 0 due to it being ineffective against target #{target.pbThis(false)}.")
        end
		
		# If user is asleep, prefer moves that are usable while asleep
		if user.status == :SLEEP && !move.usableWhenAsleep?
            echoln("#{user.pbThis} scores the move #{move.id} differently against target #{target.pbThis(false)} due to the user being asleep.")
			user.eachMove do |m|
				next unless m.usableWhenAsleep?
				score = 0
				break
			end
		end
		# Don't prefer attacking the target if they'd be semi-invulnerable
		if move.accuracy > 0 && (target.semiInvulnerable? || target.effects[PBEffects::SkyDrop]>=0)
            echoln("#{user.pbThis} scores the move #{move.id} differently against target #{target.pbThis(false)} due to the target being semi-invulnerable.")
            canHitAnyways = false
            # Knows what can get past semi-invulnerability
            if target.effects[PBEffects::SkyDrop]>=0
                canHitAnyways = true if move.hitsFlyingTargets?
            else
                if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
                    canHitAnyways = true if move.hitsFlyingTargets?
                elsif target.inTwoTurnAttack?("0CA")          # Dig
                    canHitAnyways = true if move.hitsDiggingTargets?
                elsif target.inTwoTurnAttack?("0CB")          # Dive
                    canHitAnyways = true if move.hitsDivingTargets?
                end
            end
            canHitAnyways = true if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
			  
            if pbRoughStat(user,:SPEED,skill) > pbRoughStat(target,:SPEED,skill)
                if canHitAnyways
                    score *= 2
                else
                    score = 0
                end
            else
                score /= 2
            end
        end
		
		# A score of 0 here means it absolutely should not be used
		if score<=0
			echoln("#{user.pbThis} scores the move #{move.id} against target #{target.pbThis(false)} early: #{0}")
			return 0
		end
		
		# Pick a good move for the Choice items
        if user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
            echoln("#{user.pbThis} scores the move #{move.id} differently #{target.pbThis(false)} due to holding a choice item.")
            if move.damagingMove?
                score += 40
            elsif move.function=="0F2" # Trick
                score += 60
            else
                score -= 60
			end
		end
		
		# Adjust score based on how much damage it can deal
		if move.damagingMove?
		  score = pbGetMoveScoreDamage(score,move,user,target,skill)
		  score *= 0.75 if policies.include?(:DISLIKEATTACKING)
		end
	
		# Account for accuracy of move
		accuracy = pbRoughAccuracy(move,user,target,skill)
		score *= accuracy/100.0
		
		# Final adjustments t score
		score = score.to_i
		score = 0 if score<0
		echoln("#{user.pbThis} scores the move #{move.id} against target #{target.pbThis(false)}: #{score}")
		return score
	end
  
    #=============================================================================
    # Add to a move's score based on how much damage it will deal (as a percentage
    # of the target's current HP)
    #=============================================================================
    def pbGetMoveScoreDamage(score,move,user,target,skill)
        # Calculate how much damage the move will do (roughly)
        baseDmg = pbMoveBaseDamage(move,user,target,skill)
        realDamage = pbRoughDamage(move,user,target,skill,baseDmg)
        # Two-turn attacks waste 2 turns to deal one lot of damage
        if move.chargingTurnMove? || move.function=="0C2"   # Hyper Beam
            realDamage *= 2/3   # Not halved because semi-invulnerable during use or hits first turn
        end
        # Convert damage to percentage of target's remaining HP
        damagePercentage = realDamage*100.0/target.hp
        # Adjust score
        damagePercentage = 200 if damagePercentage >= 105   # Extremely prefer lethal damage
        score = (score * 0.75 + damagePercentage * 1.5).to_i
        return score
    end
end
  