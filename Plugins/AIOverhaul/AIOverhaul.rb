class PokeBattle_AI
  def pbDefaultChooseEnemyCommand(idxBattler)
    return if pbEnemyShouldWithdraw?(idxBattler)
    return if @battle.pbAutoFightMenu(idxBattler) #Battle palace shenanigans
	@battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    pbChooseMoves(idxBattler)
  end
  
  #=============================================================================
  # Decide whether the opponent should Mega Evolve their Pokémon
  #=============================================================================
  def pbEnemyShouldMegaEvolve?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanMegaEvolve?(idxBattler)   # Simple "always should if possible"
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Mega Evolve")
      return true
    end
    return false
  end
  
 #=============================================================================
  # Main move-choosing method (moves with higher scores are more likely to be
  # chosen)
  #=============================================================================
  def pbChooseMoves(idxBattler)
    user        = @battle.battlers[idxBattler]
    wildBattler = (@battle.wildBattle? && @battle.opposes?(idxBattler))
    skill       = 0
    if !wildBattler
      skill     = @battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
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
        newChoice = pbEvaluateMoveTrainer(user,user.moves[i],skill)
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
    logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
      choices.each_with_index do |c,i|
        logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
        logMsg += " (target #{c[2]})" if c[2]>=0
        logMsg += ", " if i<choices.length-1
      end
      PBDebug.log(logMsg)
	# Decide whether all choices are bad, and if so, try switching instead
    if !wildBattler && skill>=PBTrainerAI.mediumSkill
      badMoves = false
      if (maxScore<=20 && user.turnCount>2) ||
         (maxScore<=40 && user.turnCount>5)
        badMoves = true if pbAIRandom(100)<80
      end
      if !badMoves && totalScore<100
        badMoves = true
        choices.each do |c|
          next if !user.moves[c[0]].damagingMove?
          badMoves = false
          break
        end
        badMoves = false if badMoves && pbAIRandom(100)<10
      end
      if badMoves && pbEnemyShouldWithdrawEx?(idxBattler,true)
        if $INTERNAL
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves")
        end
        return
      end
    end
	
	if choices.length !=0
		# Determine the most preferred move
		preferredMove = nil
		preferredMoves = []
		choices.each do |c|
		  preferredMoves.push(c) if c[1]==maxScore
		end
		if preferredMoves.length>0
		  preferredMove = preferredMoves[pbAIRandom(preferredMoves.length)]
		end
		
		# Pick the most preferred move
		if skill>=PBTrainerAI.mediumSkill && preferredMove != nil
		  PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[preferredMove[0]].name}")
		  @battle.pbRegisterMove(idxBattler,preferredMove[0],false)
		  @battle.pbRegisterTarget(idxBattler,preferredMove[2]) if preferredMove[2]>=0
		else # Randomly choose a move from the choices (weighted by score) and register it
		  PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves in particular; picking one randomly weighted")
		  randNum = pbAIRandom(totalScore)
		  choices.each do |c|
			randNum -= c[1]
			next if randNum>=0
			@battle.pbRegisterMove(idxBattler,c[0],false)
			@battle.pbRegisterTarget(idxBattler,c[2]) if c[2]>=0
			break
		  end
		end
    else # If there are no calculated choices, pick one at random
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
      user.eachMoveWithIndex do |_m,i|
        next if !@battle.pbCanChooseMove?(idxBattler,i,false)
        choices.push([i,100,-1])   # Move index, score, target
      end
      if choices.length==0   # No moves are physically possible to use; use Struggle
        @battle.pbAutoChooseMove(user.index)
      end
    end
    # Randomly choose a move from the choices and register it
    randNum = pbAIRandom(totalScore)
    choices.each do |c|
      randNum -= c[1]
      next if randNum>=0
      @battle.pbRegisterMove(idxBattler,c[0],false)
      @battle.pbRegisterTarget(idxBattler,c[2]) if c[2]>=0
      break
    end
    # Log the result
    if @battle.choices[idxBattler][2]
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
    end
  end
  
    # Trainer Pokémon calculate how much they want to use each of their moves.
  def pbEvaluateMoveTrainer(user,move,skill)
    target_data = move.pbTarget(user)
	newChoice = nil
    if target_data.num_targets > 1
      # If move affects multiple battlers and you don't choose a particular one
      totalScore = 0
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        score = pbGetMoveScore(move,user,b,skill)
        totalScore += ((user.opposes?(b)) ? score : -score)
      end
	  newChoice = [totalScore,-1] if totalScore>0
    elsif target_data.num_targets == 0
      # If move has no targets, affects the user, a side or the whole field
      score = pbGetMoveScore(move,user,user,skill)
      newChoice = [score,-1] if score>0
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        next if target_data.targets_foe && !user.opposes?(b)
        score = pbGetMoveScore(move,user,b,skill)
        scoresAndTargets.push([score,b.index]) if score>0
      end
      if scoresAndTargets.length>0
        # Get the one best target for the move
        scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
        newChoice = [scoresAndTargets[0][0],scoresAndTargets[0][1]]
      end
    end
	return newChoice
  end
  
  #=============================================================================
  # Get a score for the given move being used against the given target
  #=============================================================================
  def pbGetMoveScore(move,user,target,skill=100)
    skill = PBTrainerAI.minimumSkill if skill<PBTrainerAI.minimumSkill
    score = 100
    score = pbGetMoveScoreFunctionCode(score,move,user,target,skill)
	
	# Never use a move that would fail outright
	@battle.messagesBlocked = true
	user.turnCount += 1
	if move.pbMoveFailed?(user,[target])
		score = 0
    end
	user.turnCount -= 1
	@battle.messagesBlocked = false
		
	# A score of 0 here means it absolutely should not be used
    return 0 if score == nil || score<=0
	
    if skill>=PBTrainerAI.mediumSkill
      # Prefer damaging moves if AI has no more Pokémon or AI is less clever
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        if !(skill>=PBTrainerAI.highSkill && @battle.pbAbleNonActiveCount(target.idxOwnSide)>0)
          if move.statusMove?
            score /= 1.5
          elsif target.hp<=target.totalhp/2
            score *= 1.5
          end
        end
      end
      # Don't prefer attacking the target if they'd be semi-invulnerable
      if skill>=PBTrainerAI.mediumSkill && move.accuracy>0 &&
         (target.semiInvulnerable? || target.effects[PBEffects::SkyDrop]>=0)
        miss = true
        miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
        if miss && pbRoughStat(user,:SPEED,skill)>pbRoughStat(target,:SPEED,skill)
          # Knows what can get past semi-invulnerability
          if target.effects[PBEffects::SkyDrop]>=0
            miss = false if move.hitsFlyingTargets?
          else
            if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
              miss = false if move.hitsFlyingTargets?
            elsif target.inTwoTurnAttack?("0CA")          # Dig
              miss = false if move.hitsDiggingTargets?
            elsif target.inTwoTurnAttack?("0CB")          # Dive
              miss = false if move.hitsDivingTargets?
            end
          end
        end
        score -= 80 if miss
      end
      # Pick a good move for the Choice items
      if user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
        if move.baseDamage>=60;     score += 60
        elsif move.damagingMove?;   score += 30
        elsif move.function=="0F2"; score += 70   # Trick
        else;                       score -= 60
        end
      end
      # If user is asleep, prefer moves that are usable while asleep
      if user.status == :SLEEP && !move.usableWhenAsleep?
        user.eachMove do |m|
          next unless m.usableWhenAsleep?
          score -= 60
          break
        end
      end
    end
    # Adjust score based on how much damage it can deal
    if move.damagingMove?
      score = pbGetMoveScoreDamage(score,move,user,target,skill)
    else   # Status moves
      # Don't prefer attacks which don't deal damage
      score -= 10
      # Account for accuracy of move
      accuracy = pbRoughAccuracy(move,user,target,skill)
      score *= accuracy/100.0
      score = 0 if score<=10 && skill>=PBTrainerAI.highSkill
    end
    score = score.to_i
    score = 0 if score<0
    return score
  end

  
  def pbRegisterMoveWild(user,idxMove,choices)
    move = user.moves[idxMove]
    target_data = move.pbTarget(user)
    if target_data.num_targets > 1
      # If move affects multiple battlers and you don't choose a particular one
      totalScore = 0
      
	  if move.damagingMove?
		targets = []
			@battle.eachBattler do |b|
				next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
				next if !user.opposes?(b)
				targets.push(b)
				score = 100
				score = pbGetMoveScoreBoss(move,user,b) if user.boss
				targetPercent = b.hp.to_f / b.totalhp.to_f
				score = (score*(1.0 + 0.4 * targetPercent)).floor
				totalScore += score
			end
		if targets.length() != 0
			totalScore = totalScore / targets.length().to_f
		else
			totalScore = 0
		end
	  else
	    totalScore = 100
		totalScore = pbGetMoveScoreBoss(move,user,nil) if user.boss
	  end
	  
      choices.push([idxMove,totalScore,-1]) if totalScore>0
    elsif target_data.num_targets == 0
      # If move has no targets, affects the user, a side or the whole field
      score = 100
      score = pbGetMoveScoreBoss(move,user,user) if user.boss
      choices.push([idxMove,score,-1])
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        next if target_data.targets_foe && !user.opposes?(b)
		score = 100
        score = pbGetMoveScoreBoss(move,user,b) if user.boss
        if move.damagingMove?
			targetPercent = b.hp.to_f / b.totalhp.to_f
            score = (score*(1.0 + 0.4 * targetPercent)).floor
		elsif
			mult = 1.0 + rand(10)/100.0
			score = (score * mult).floor
        end
        scoresAndTargets.push([score,b.index]) if score>0
      end
      if scoresAndTargets.length>0
        # Get the one best target for the move
        scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
        choices.push([idxMove,scoresAndTargets[0][0],scoresAndTargets[0][1]])
      end
    end
  end
  
  def pbGetMoveScoreBoss(move,user,target)
	score = 100
	
	if move.function == "09C" # Helping hand
		score = user.battle.commandPhasesThisRound == 0 ? 150 : 0
	elsif move.function == "0DF" # Heal Pulse
		if user.opposes?(target)
			score = 0
		else
			score += 50 if target.hp<target.totalhp/2 &&
                       target.effects[PBEffects::Substitute]==0
		end
	elsif move.function == "05E" || move.function == "05F" # Conversion and Conversion 2
		score = user.battle.commandPhasesThisRound == 0 ? 150 : 0
	elsif move.function == "OD9" # Rest
		if user.hp==user.totalhp || !user.pbCanSleep?(user,false,nil,true)
			score -= 90
		else
			score += 70
			score -= user.hp*140/user.totalhp
			score += 30 if user.status != :NONE
		end
	elsif user.species == :GOURGEIST && move.function != "142" && move.function != "00A" && user.battle.commandPhasesThisRound == 0 # Trick or treat, moves that burn
		score = 0
	elsif user.species == :GOURGEIST && (move.function == "142" || move.function == "00A") && user.battle.commandPhasesThisRound != 0
		score = 0
	elsif move.is_a?(PokeBattle_ProtectMove)
		score = user.battle.commandPhasesThisRound == 0 ? (@battle.turnCount % 3 == 0 ? 99999 : 0) : 0
	elsif move.is_a?(PokeBattle_HealingMove)
		score = 99999
		score = 0 if (user.hp.to_f/user.totalhp.to_f) > 0.25
		score = 0 if user.battle.commandPhasesThisRound != 0
	elsif move.function == "080" # Brine
		score = target.hp<target.totalhp/2 ? 250 : 0
	elsif user.species == :INCINEROAR && move.function != "041" && move.function != "0BA" && user.battle.commandPhasesThisRound == 0  # Swagger, Taunt
		score = 0
	elsif user.species == :INCINEROAR && (move.function == "041" || move.function == "0BA") && user.battle.commandPhasesThisRound != 0  # Swagger, Taunt
		score = 0
	elsif user.species == :DIALGA && move.function == "0C2" #Roar of time
		score = $game_variables[95] == 4 ? 150 : 0
	elsif user.species == :ARTICUNO && move.function == "070" # OHKO
		score = target.frozen? ? 99999 : 0
	elsif move.function == "073" #Metal Burst
		score = 99999
		score = 0 if (user.lastHPLostFromFoe/user.totalhp) < 0.1
		score = 0 if user.battle.commandPhasesThisRound != ($game_variables[95] - 1)
	elsif move.function == "098" # Flail/Reversal
		score = (user.hp.to_f/user.totalhp.to_f < 0.5) ? 200 : 0
	elsif move.function == "0A6" # Lock On, Mind Reader
		score = (user.battle.commandPhasesThisRound == $game_variables[95] - 1) ? 200 : 0
	elsif move.damagingMove? && move.accuracy < 70
		score = 0
		score = 99999 if user.effects[PBEffects::LockOnPos] == target.index # If locked on to the target
		score = 0 if user.battle.commandPhasesThisRound != 0
	elsif move.function == "118" # Gravity
		score = 200
	elsif move.function == "0A0" # Always crit move
		score = 0
		score = 200 if move.physicalMove? && (user.stages[:ATTACK] < 6 || target.stages[:DEFENSE] > 6)
		score = 400 if move.physicalMove? && (user.stages[:ATTACK] < 4 || target.stages[:DEFENSE] > 8)
		score = 200 if move.specialMove? && (user.stages[:SPECIAL_ATTACK] < 6 || target.stages[:SPECIAL_DEFENSE] > 6)
		score = 400 if move.specialMove? && (user.stages[:SPECIAL_ATTACK] < 4 || target.stages[:SPECIAL_DEFENSE] > 8)
	elsif move.function == "160" # Strength Sap
		maxHeal = -99999
		maxHealer = nil
		@battle.battlers.each do |b|
			next if !user.opposes?(b)
			stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
			stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
			atk      = b.attack
			atkStage = b.stages[:ATTACK]+6
			healAmt = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
			if healAmt > maxHeal
				maxHeal = healAmt
				maxHealer = b
			end
		end
		score = target == maxHealer ? 130 : 0
	elsif move.function == "08E" # Power Trip, Trained Outburst, Stored Power
		score = 0
		base = move.pbBaseDamage(nil,user,target)
		score = (base*5/2) if base >= 100
	elsif move.function == "099" #Electro Ball
		score = 0
		base = move.pbBaseDamage(nil,user,target)
		score = (base*5/2) if base >= 120
	elsif move.is_a?(PokeBattle_TargetStatDownMove)
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
	elsif move.function == "0CF" # Trap and damage moves
		score = 150 * user.hp.to_f/user.totalhp.to_f
		score = 0 if target.effects[PBEffects::Trapping] > 0 && target.effects[PBEffects::TrappingMove] == move.id
	elsif ["003","005","006","007","00A","00C"].include?(move.function) # Status inducing move
		score = 100
		@battle.messagesBlocked = true
		score = 0 if move.pbFailsAgainstTarget?(user,target)
		@battle.messagesBlocked = false
	elsif move.function == "08B" # Eruption, Water Spout, etc.
		score = @battle.turnCount == 0 ? 99999 : 0
	elsif move.id == :ORIGINPULSE || move.id == :PRECIPICEBLADES
		score = $game_variables[95] == 1 ? 99999 : 0
	elsif move.function == "14E" #Geomancy
		score = user.turnCount % 2 == 1 && (user.battle.commandPhasesThisRound == $game_variables[95] - 1) ? 99999 : 0
	elsif move.function == "124" #Wonder Room
		score = 0
		
		#Use wonder room if its not the first attack of the round, and if all the player's active pokemon
		#have higher special defense than physical defense
		if user.battle.commandPhasesThisRound != 0
			allSpecialFocused = true
			@battle.battlers.each do |b|
				next if !b || !user.opposes?(b)
				defense				= b.plainStats[:DEFENSE]
				specialDefense      = b.plainStats[:SPECIAL_DEFENSE]
				if defense > specialDefense
					allSpecialFocused = false
				end
			end
			
			if allSpecialFocused
				user.battle.pbDisplay(_INTL("{1} senses the powerful defensive auras of your Pokemon...",user.pbThis))
				score = 99999
			end
		end
	elsif move.function == "0F5" # Incinerate
		score = target.item && (target.item.is_berry? || target.item.is_gem?) ? 99999 : 0
	elsif move.function == "50E" # Flare Up
		score = target.burned? ? 200 : 0
	elsif move.function == "07B" # Venoshock
		score = target.poisoned? ? 200 : 0
	elsif move.function == "150" || move.function == "50B" # Fell Stinger, Slight
		baseDmg = pbMoveBaseDamage(move,user,target,100)
		realDamage = pbRoughDamage(move,user,target,100,baseDmg)
		score = 0
		if realDamage >= target.hp
			score = 300
		end
	elsif move.function == "019" # Heal Bell
		score = 99999
	elsif move.damagingMove? # More likely to use damaging moves the more damage they do, and the less current HP you have
		damageRatio = pbGetRealDamageBoss(move,user,target).to_f / user.hp.to_f
		score = (score * (damageRatio+1.0)/2).floor
    end
	
	if move.priority > 0 || move.flinchingMove?
		if user.battle.commandPhasesThisRound == 0
			score *= 2
		else
			score *= 0.5
		end
	end
	
	if move.function == "111" # Future Sight, etc.
		score = 0 if move.pbFailsAgainstTarget?(user,target)
	end
	
	# Never use a move that would fail outright
	@battle.messagesBlocked = true
	if move.pbMoveFailed?(user,[target])
		score = 0
    end
	@battle.messagesBlocked = false
	
	return score
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
  
  def pbEnemyShouldWithdrawEx?(idxBattler,forceSwitch)
    return false if @battle.wildBattle?
    shouldSwitch = forceSwitch
    batonPass = -1
    moveType = nil
    skill = @battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
    battler = @battle.battlers[idxBattler]
    # Switch if previously hit hard by a super effective move
    if !shouldSwitch && battler.turnCount>1 && skill>=PBTrainerAI.highSkill
      target = battler.pbDirectOpposing(true)
      if !target.fainted? && target.lastMoveUsed
        moveData = GameData::Move.get(target.lastMoveUsed)
        moveType = moveData.type
        typeMod = pbCalcTypeMod(moveType,target,battler)
        if Effectiveness.super_effective?(typeMod)
		  #If the foe's last move was substantial for the level we're at
		  powerfulBP = 99999
		  case battler.level
		  when 1..15
			powerfulBP = 30
		  when 16..30
			powerfulBP = 50
		  when 31..70
			powerfulBP = 70
		  end
          shouldSwitch = moveData.base_damage >= powerfulBP
        end
      end
    end
    # Pokémon can't do anything (must have been in battle for at least 2 rounds)
    if !@battle.pbCanChooseAnyMove?(idxBattler) &&
       battler.turnCount && battler.turnCount>=2
      shouldSwitch = true
    end
    # Pokémon is Perish Songed and has Baton Pass
    if skill>=PBTrainerAI.highSkill && battler.effects[PBEffects::PerishSong]==1
      battler.eachMoveWithIndex do |m,i|
        next if m.function!="0ED"   # Baton Pass
        next if !@battle.pbCanChooseMove?(idxBattler,i,false)
        batonPass = i
        break
      end
    end
    # Pokémon will faint because of bad poisoning at the end of this round, but
    # would survive at least one more round if it were regular poisoning instead
    if battler.status == :POISON && battler.statusCount > 0 &&
       skill>=PBTrainerAI.highSkill
      toxicHP = battler.totalhp/16
      nextToxicHP = toxicHP*(battler.effects[PBEffects::Toxic]+1)
      if battler.hp<=nextToxicHP && battler.hp>toxicHP*2
        shouldSwitch = true if pbAIRandom(100)<80
      end
    end
    # Pokémon is Encored into an unfavourable move
    if battler.effects[PBEffects::Encore]>0 && skill>=PBTrainerAI.mediumSkill
      idxEncoredMove = battler.pbEncoredMoveIndex
      if idxEncoredMove>=0
        scoreSum   = 0
        scoreCount = 0
        battler.eachOpposing do |b|
          scoreSum += pbGetMoveScore(battler.moves[idxEncoredMove],battler,b,skill)
          scoreCount += 1
        end
        if scoreCount>0 && scoreSum/scoreCount<=20
          shouldSwitch = true if pbAIRandom(100)<80
        end
      end
    end
    # If there is a single foe and it is resting after Hyper Beam or is
    # Truanting (i.e. free turn)
    if @battle.pbSideSize(battler.index+1)==1 &&
       !battler.pbDirectOpposing.fainted? && skill>=PBTrainerAI.highSkill
      opp = battler.pbDirectOpposing
      if opp.effects[PBEffects::HyperBeam]>0 ||
         (opp.hasActiveAbility?(:TRUANT) && opp.effects[PBEffects::Truant])
        shouldSwitch = false if pbAIRandom(100)<80
      end
    end
    # Sudden Death rule - I'm not sure what this means
    if @battle.rules["suddendeath"] && battler.turnCount>0
      if battler.hp<=battler.totalhp/4 && pbAIRandom(100)<30
        shouldSwitch = true
      elsif battler.hp<=battler.totalhp/2 && pbAIRandom(100)<80
        shouldSwitch = true
      end
    end
    # Pokémon is about to faint because of Perish Song
    if battler.effects[PBEffects::PerishSong]==1
      shouldSwitch = true
    end
    # Should swap when confusion self-damage is likely to kill it
    if skill>=PBTrainerAI.mediumSkill && battler.effects[PBEffects::ConfusionChance] >= 1
		#Calculate the damage the confusionMove would do
        confusionMove = PokeBattle_Confusion.new(@battle,nil)
		stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
		stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
		# Get the move's type
		type = confusionMove.calcType
		# Calcuate base power of move
		baseDmg = confusionMove.pbBaseDamage(confusionMove.baseDamage,battler,battler)
		# Calculate battler's attack stat
		atk, atkStage = confusionMove.pbGetAttackStats(battler,battler)
		if !battler.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
		  atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
		end
		# Calculate battler's defense stat
		defense, defStage = confusionMove.pbGetDefenseStats(battler,battler)
		if !battler.hasActiveAbility?(:UNAWARE)
		  defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
		end
		# Calculate all multiplier effects
		multipliers = {
		  :base_damage_multiplier  => 1.0,
		  :attack_multiplier       => 1.0,
		  :defense_multiplier      => 1.0,
		  :final_damage_multiplier => 1.0
		}
		confusionMove.pbCalcDamageMultipliers(battler,battler,1,type,baseDmg,multipliers)
		# Main damage calculation
		baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
		atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
		defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
		damage  = (((2.0 * battler.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
		damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
		
		shouldSwitch = true if damage >= battler.hp
		shouldSwitch = true if damage >= (battler.hp * 0.5).floor if skill>=PBTrainerAI.bestSkill
    end
	# Should swap when charm self-damage is likely to kill it
    if skill>=PBTrainerAI.mediumSkill && battler.effects[PBEffects::CharmChance] >= 1
		#Calculate the damage the charmMove would do
        charmMove = PokeBattle_Charm.new(@battle,nil)
		stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
		stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
		# Get the move's type
		type = charmMove.calcType
		# Calcuate base power of move
		baseDmg = charmMove.pbBaseDamage(charmMove.baseDamage,battler,battler)
		# Calculate battler's attack stat
		atk, atkStage = charmMove.pbGetAttackStats(battler,battler)
		if !battler.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
		  atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
		end
		# Calculate battler's defense stat
		defense, defStage = charmMove.pbGetDefenseStats(battler,battler)
		if !battler.hasActiveAbility?(:UNAWARE)
		  defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
		end
		# Calculate all multiplier effects
		multipliers = {
		  :base_damage_multiplier  => 1.0,
		  :attack_multiplier       => 1.0,
		  :defense_multiplier      => 1.0,
		  :final_damage_multiplier => 1.0
		}
		charmMove.pbCalcDamageMultipliers(battler,battler,1,type,baseDmg,multipliers)
		# Main damage calculation
		baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
		atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
		defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
		damage  = (((2.0 * battler.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
		damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
		
		shouldSwitch = true if damage >= battler.hp
		shouldSwitch = true if damage >= (battler.hp * 0.5).floor if skill>=PBTrainerAI.bestSkill
    end
    if shouldSwitch
      list = []
      @battle.pbParty(idxBattler).each_with_index do |pkmn,i|
        next if !@battle.pbCanSwitch?(idxBattler,i)
        # If perish count is 1, it may be worth it to switch
        # even with Spikes, since Perish Song's effect will end
        if battler.effects[PBEffects::PerishSong]!=1
          # Will contain effects that recommend against switching
          spikes = battler.pbOwnSide.effects[PBEffects::Spikes]
          # Don't switch to this if too little HP
          if spikes>0
            spikesDmg = [8,6,4][spikes-1]
            if pkmn.hp<=pkmn.totalhp/spikesDmg
              next if !pkmn.hasType?(:FLYING) && !pkmn.hasActiveAbility?(:LEVITATE)
            end
          end
        end
        # moveType is the type of the target's last used move
        if moveType != nil && Effectiveness.ineffective?(pbCalcTypeMod(moveType,battler,battler.pbDirectOpposing(true)))
          weight = 65
          typeMod = pbCalcTypeModPokemon(pkmn,battler.pbDirectOpposing(true))
          if Effectiveness.super_effective?(typeMod)
            # Greater weight if new Pokemon's type is effective against target
            weight = 100
          end
          list.unshift(i) if pbAIRandom(100)<weight   # Put this Pokemon first
        elsif moveType != nil && Effectiveness.resistant?(pbCalcTypeMod(moveType,battler,battler.pbDirectOpposing(true)))
          weight = 40
          typeMod = pbCalcTypeModPokemon(pkmn,battler.pbDirectOpposing(true))
          if Effectiveness.super_effective?(typeMod)
            # Greater weight if new Pokemon's type is effective against target
            weight = 100
          end
          list.unshift(i) if pbAIRandom(100)<weight   # Put this Pokemon first
        else
          list.push(i)   # put this Pokemon last
        end
      end
      if list.length>0
        if batonPass>=0 && @battle.pbRegisterMove(idxBattler,batonPass,false)
          PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use Baton Pass to avoid Perish Song")
          return true
        end
        if @battle.pbRegisterSwitch(idxBattler,list[0])
          PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will switch with " +
                      "#{@battle.pbParty(idxBattler)[list[0]].name}")
          return true
        end
      end
    end
    return false
  end
  
  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbRoughDamage(move,user,target,skill,baseDmg)
    # Fixed damage moves
    return baseDmg if move.is_a?(PokeBattle_FixedDamageMove)
    # Get the move's type
    type = pbRoughType(move,user,skill)
    ##### Calculate user's attack stat #####
    atk = pbRoughStat(user,:ATTACK,skill)
    if move.function=="121"   # Foul Play
      atk = pbRoughStat(target,:ATTACK,skill)
    elsif move.specialMove?(type)
      if move.function=="121"   # Foul Play
        atk = pbRoughStat(target,:SPECIAL_ATTACK,skill)
      else
        atk = pbRoughStat(user,:SPECIAL_ATTACK,skill)
      end
    end
    ##### Calculate target's defense stat #####
    defense = pbRoughStat(target,:DEFENSE,skill)
    if move.specialMove?(type) && move.function!="122"   # Psyshock
      defense = pbRoughStat(target,:SPECIAL_DEFENSE,skill)
    end
    ##### Calculate all multiplier effects #####
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    # Ability effects that alter damage
    moldBreaker = false
    if skill>=PBTrainerAI.highSkill && target.hasMoldBreaker?
      moldBreaker = true
    end
    if skill>=PBTrainerAI.mediumSkill && user.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:ANALYTIC,:SNIPER,:TINTEDLENS,:AERILATE,:PIXILATE,:REFRIGERATE]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.id != m
        canCheck = false
        break
      end
      if canCheck
        BattleHandlers.triggerDamageCalcUserAbility(user.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if skill>=PBTrainerAI.mediumSkill && !moldBreaker
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if skill>=PBTrainerAI.bestSkill && !moldBreaker && target.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:FILTER,:SOLIDROCK]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.id != m
        canCheck = false
        break
      end
      if canCheck
        BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if skill>=PBTrainerAI.bestSkill && !moldBreaker
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    # Item effects that alter damage
    # NOTE: Type-boosting gems aren't suitable for checking at the start of the
    #       round.
    if skill>=PBTrainerAI.mediumSkill && user.itemActive?
      # NOTE: These items aren't suitable for checking at the start of the
      #       round.
      itemBlacklist = [:EXPERTBELT,:LIFEORB]
      if !itemBlacklist.include?(user.item_id) && user.item && !user.item.is_gem?
        BattleHandlers.triggerDamageCalcUserItem(user.item,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if skill>=PBTrainerAI.bestSkill && target.itemActive?
      # NOTE: Type-weakening berries aren't suitable for checking at the start
      #       of the round.
      if target.item && !target.item.is_berry?
        BattleHandlers.triggerDamageCalcTargetItem(target.item,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    # Global abilities
    if skill>=PBTrainerAI.mediumSkill
      if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
         (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
        if @battle.pbCheckGlobalAbility(:AURABREAK)
          multipliers[:base_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:base_damage_multiplier] *= 4 / 3.0
        end
      end
    end
    # Parental Bond
    if skill>=PBTrainerAI.mediumSkill && user.hasActiveAbility?(:PARENTALBOND)
      multipliers[:base_damage_multiplier] *= 1.25
    end
    # Me First
    # TODO
    # Helping Hand - n/a
    # Charge
    if skill>=PBTrainerAI.mediumSkill
      if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
        multipliers[:base_damage_multiplier] *= 2
      end
    end
    # Mud Sport and Water Sport
    if skill>=PBTrainerAI.mediumSkill
      if type == :ELECTRIC
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::MudSport]
          multipliers[:base_damage_multiplier] /= 3
          break
        end
        if @battle.field.effects[PBEffects::MudSportField]>0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      if type == :FIRE
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::WaterSport]
          multipliers[:base_damage_multiplier] /= 3
          break
        end
        if @battle.field.effects[PBEffects::WaterSportField]>0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
    end
    # Terrain moves
    if skill>=PBTrainerAI.mediumSkill
      case @battle.field.terrain
      when :Electric
        multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
      when :Grassy
        multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
      when :Psychic
        multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
      when :Misty
        multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
      end
    end
    # Multi-targeting attacks
    if skill>=PBTrainerAI.highSkill
      if pbTargetsMultiple?(move,user)
        multipliers[:final_damage_multiplier] *= 0.75
      end
    end
    # Weather
    if skill>=PBTrainerAI.mediumSkill
      case @battle.pbWeather
      when :Sun, :HarshSun
        if type == :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        elsif type == :WATER
          multipliers[:final_damage_multiplier] /= 2
        end
      when :Rain, :HeavyRain
        if type == :FIRE
          multipliers[:final_damage_multiplier] /= 2
        elsif type == :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :Sandstorm
        if target.pbHasType?(:ROCK) && move.specialMove?(type) && move.function != "122"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
      end
    end
    # Critical hits - n/a
    # Random variance - n/a
    # STAB
    if skill>=PBTrainerAI.mediumSkill
      if type && user.pbHasType?(type)
        if user.hasActiveAbility?(:ADAPTABILITY)
          multipliers[:final_damage_multiplier] *= 2
        else
          multipliers[:final_damage_multiplier] *= 1.5
        end
      end
    end
    # Type effectiveness
    if skill>=PBTrainerAI.mediumSkill
      typemod = pbCalcTypeMod(type,user,target)
      multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
    end
    # Burn
    if skill>=PBTrainerAI.highSkill
      if user.status == :BURN && move.physicalMove?(type) &&
         !user.hasActiveAbility?(:GUTS) &&
         !(Settings::MECHANICS_GENERATION >= 6 && move.function == "07E")   # Facade
        if !user.boss
			multipliers[:final_damage_multiplier] *= 2.0/3.0
		else
			multipliers[:final_damage_multiplier] *= 4.0/5.0
		end
      end
    end
	# Burn
    if skill>=PBTrainerAI.highSkill
      if user.status == :POISON && move.specialMove?(type) &&
         !user.hasActiveAbility?(:AUDACITY) &&
         !(Settings::MECHANICS_GENERATION >= 6 && move.function == "07E")   # Facade
        if !user.boss
			multipliers[:final_damage_multiplier] *= 2.0/3.0
		else
			multipliers[:final_damage_multiplier] *= 4.0/5.0
		end
      end
    end
    # Aurora Veil, Reflect, Light Screen
    if skill>=PBTrainerAI.highSkill
      if !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
        if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
          if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?(type)
          if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.specialMove?(type)
          if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        end
      end
    end
    # Move-specific base damage modifiers
    # TODO
    # Move-specific final damage modifiers
    # TODO
    ##### Main damage calculation #####
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
    # "AI-specific calculations below"
    # Increased critical hit rates
    if skill>=PBTrainerAI.mediumSkill
      c = 0
      # Ability effects that alter critical hit rate
      if c>=0 && user.abilityActive?
        c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
      end
      if skill>=PBTrainerAI.bestSkill
        if c>=0 && !moldBreaker && target.abilityActive?
          c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
        end
      end
      # Item effects that alter critical hit rate
      if c>=0 && user.itemActive?
        c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
      end
      if skill>=PBTrainerAI.bestSkill
        if c>=0 && target.itemActive?
          c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
        end
      end
      # Other efffects
      c = -1 if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
      if c>=0
        c += 1 if move.highCriticalRate?
        c += user.effects[PBEffects::FocusEnergy]
        c += 1 if user.inHyperMode? && move.type == :SHADOW
      end
      if c>=0
        c = 4 if c>4
        damage += damage*0.1*c
      end
    end
    return damage.floor
  end
  
  def testAllScores(user)
	@battle.scene.pbDisplay("Testing all move scores...")
	scores = []
	target = []
	skipTheseMoves = [:SHEERCOLD,:GUILLOTINE,:FISSURE,:HORNDRILL]
	GameData::Move.each { |move|    # Get any one move
		score = 0
		next if skipTheseMoves.include?(move.id)
		begin
			moveObject = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(move.id))
			target = user.pbFindTargets([nil,nil,nil,-1],moveObject,user)
			newChoice = pbEvaluateMoveTrainer(user,moveObject,100)
			if newChoice
				score = newChoice[0]
				target = newChoice[1]
				targetName = target >= 0 ? @battle.battlers[target].name : "nothing"
				scores.push([move,targetName,score])
				#echo("#{move.real_name} (#{move.function_code}), targeting #{targetName}: #{score}\n")
			else
				#echo("#{move.real_name} (#{move.function_code}): No valid targets above score 0\n")
			end
		rescue
			echo("Exception encountered while evaluating move #{move.real_name} (#{move.function_code})\n")
		end
	}
	scores.sort_by!{ |score| -score[2]}
	echo("The best five moves in this situation:\n")
	for i in 0..4
		entry = scores[i]
		echo("#{i+1}: #{entry[0].id} #{entry[0].function_code} (targeting #{entry[1]}) -- #{entry[2]} \n")
	end
	echo("The five worst non-zero moves in this situation:\n")
	for i in 0..4
		entry = scores[scores.length-(5-i)]
		echo("#{i+1}: #{entry[0].id} #{entry[0].function_code} (targeting #{entry[1]}) -- #{entry[2]} \n")
	end
  end
end

class NPCTrainer < Trainer
	attr_accessor :policies
	
	def initialize(name, trainer_type)
		super
		@items     = []
		@lose_text = nil
		@policies  = [:TEST]
	end
end