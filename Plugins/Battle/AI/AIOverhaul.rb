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
    trueWildBattler = wildBattler && !user.boss?
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
    logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
    choices.each_with_index do |c,i|
      logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
      logMsg += " (target #{c[2]})" if c[2]>=0
      logMsg += ", " if i<choices.length-1
    end
    PBDebug.log(logMsg)
	  
    if !wildBattler && maxScore <= 40 && pbEnemyShouldWithdrawEx?(idxBattler,true)
      if $INTERNAL
        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will try to switch due to terrible moves")
      end
      return
    end
	
    # If there are valid choices, pick among them
	  if choices.length > 0
      # Determine the most preferred move
      preferredChoice = nil

		  if trueWildBattler
        preferredChoice = choices[pbAIRandom(choices.length)]
        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) chooses #{user.moves[preferredChoice[0]].name} at random")
      elsif user.boss?
        choices.reject!{|choice| choice[1] <= 0}
        guaranteedChoices, regularChoices = choices.partition {|choice| choice[1] >= 5000}
        if guaranteedChoices.length == 0
          if user.lastMoveChosen.nil?
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) won't try to exlude any moves based on last move chosen, because thats nil")
          elsif regularChoices.length >= 2
            regularChoices.reject!{|regular_choice| user.moves[regular_choice[0]].id == user.lastMoveChosen}
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will try not to pick #{user.lastMoveChosen} this turn since that was the last move it chose")
          else
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) only has one valid choice, so it won't exclude #{user.lastMoveChosen} (its last chosen move)")
          end
          sortedChoices = regularChoices.sort_by{|choice| -choice[1]}
          preferredChoice = sortedChoices[0]
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) thinks #{user.moves[preferredChoice[0]].name} is the highest rated of its remaining choices")
        else
          preferredChoice = guaranteedChoices[0]
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) chooses #{user.moves[preferredChoice[0]].name}, since is the first listed among its guaranteed moves")
        end
      else
        sortedChoices = choices.sort_by{|choice| -choice[1]}
        preferredChoice = sortedChoices[0]
        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) thinks #{user.moves[preferredChoice[0]].name} is the highest rated choice")
      end
      @battle.pbRegisterMove(idxBattler,preferredChoice[0],false)
      @battle.pbRegisterTarget(idxBattler,preferredChoice[2]) if preferredChoice[2]>=0
    elsif !user.boss? # If there are no calculated choices, create a list of the choices all scored the same, to be chosen between randomly later on
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
    if !@battle.choices[idxBattler][2]
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
	
    move = @battle.choices[idxBattler][2]
    target = @battle.choices[idxBattler][3]
    
    PokeBattle_AI.triggerBossDecidedOnMove(user.species,move,user,target) if user.boss?
  end
  
  # Trainer Pokémon calculate how much they want to use each of their moves.
  def pbEvaluateMoveTrainer(user,move,skill,policies=[])
    target_data = move.pbTarget(user)
	  newChoice = nil
    if target_data.num_targets > 1
      # If move affects multiple battlers and you don't choose a particular one
      totalScore = 0
	    targets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
		    targets.push(b)
        score = pbGetMoveScore(move,user,b,skill,policies)
        totalScore += ((user.opposes?(b)) ? score : -score)
      end
      if targets.length > 1
        totalScore *= targets.length / (targets.length.to_f + 1.0)
        totalScore = totalScore.floor
      end
      newChoice = [totalScore,-1] if totalScore>0
    elsif target_data.num_targets == 0
      # If move has no targets, affects the user, a side or the whole field
      score = pbGetMoveScore(move,user,user,skill,policies)
      newChoice = [score,-1] if score>0
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        next if target_data.targets_foe && !user.opposes?(b)
        score = pbGetMoveScore(move,user,b,skill,policies)
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
			  
        if user.pbSpeed > target.pbSpeed
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
      echoln("#{user.pbThis} scores the move #{move.id} differently #{target.pbThis(false)} due to gavubg a choice item.")
      if move.baseDamage>=60;     score += 60
				elsif move.damagingMove?;   score += 30
				elsif move.function=="0F2"; score += 70   # Trick
				else;                       score -= 60
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

  
  def pbRegisterMoveWild(user,idxMove,choices)
    move = user.moves[idxMove]
	  return if move.isEmpowered? # Never ever use empowered moves normally

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
          if user.boss?
            score = pbGetMoveScoreBoss(move,user,b)
            targetPercent = b.hp.to_f / b.totalhp.to_f
            score = (score*(1.0 + 0.5 * targetPercent)).floor
          else
            score = 100
          end
          totalScore += score
        end
        if targets.length() != 0
          totalScore = totalScore / targets.length().to_f
        else
          totalScore = 0
        end
      else
        if user.boss?
          totalScore = pbGetMoveScoreBoss(move,user,nil)
        else
          totalScore = 100
        end
      end
      choices.push([idxMove,totalScore,-1]) if totalScore > 0
    elsif target_data.num_targets == 0
      # If move has no targets, affects the user, a side or the whole field
      if user.boss
        score = pbGetMoveScoreBoss(move,user,user)
      else
        score = 100
      end
      choices.push([idxMove,score,-1])
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        next if target_data.targets_foe && !user.opposes?(b)
		    
        if user.boss?
          score = pbGetMoveScoreBoss(move,user,b)
          if move.damagingMove?
            targetPercent = b.hp.to_f / b.totalhp.to_f
            score = (score*(1.0 + 0.5 * targetPercent)).floor
          end
        else
          score = 100
        end
        scoresAndTargets.push([score,b.index]) if score > 0
      end
      if scoresAndTargets.length>0
        # Get the one best target for the move
        scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
        choices.push([idxMove,scoresAndTargets[0][0],scoresAndTargets[0][1]])
      end
    end
  end
     
  def pbEnemyShouldWithdrawEx?(idxBattler,forceSwitch)
    return false if @battle.wildBattle?
    shouldSwitch = forceSwitch
    batonPass = -1
    skill = @battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
    battler = @battle.battlers[idxBattler]
    owner = @battle.pbGetOwnerFromBattlerIndex(idxBattler)
    policies = owner.policies || []

  	PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) is determining whether it should swap (Defaulting to #{forceSwitch}).")
    
	  target = battler.pbDirectOpposing(true)
    moveType = nil
    if !target.fainted? && target.lastMoveUsed
      moveData = GameData::Move.get(target.lastMoveUsed)
      moveType = moveData.type
    end

	  # Switch if previously hit hard by a super effective move
    if !shouldSwitch && battler.turnCount > 1
      if !moveType.nil?
        typeMod = pbCalcTypeMod(moveType,target,battler)
        if Effectiveness.super_effective?(typeMod)
          #If the foe's last move was substantial for the level we're at
          powerfulBP = 99999
          case battler.level
          when 1..15
          powerfulBP = 30
          when 16..30
          powerfulBP = 50
          when 31..45
          powerfulBP = 70
          when 46..70
          powerfulBP = 90
          end
          shouldSwitch = true if moveData.base_damage >= powerfulBP
          PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) is anxious about being hit last turn by a high BP super-effective move and may try to swap.")
        end
      end
    end
    # Pokémon can't do anything
    if !@battle.pbCanChooseAnyMove?(idxBattler)
      shouldSwitch = true
    end
    # Pokémon is Encored into an unfavourable move
    if battler.effects[PBEffects::Encore] > 0
      idxEncoredMove = battler.pbEncoredMoveIndex
      if idxEncoredMove>=0
        scoreSum   = 0
        scoreCount = 0
        battler.eachOpposing do |b|
          scoreSum += pbGetMoveScore(battler.moves[idxEncoredMove],battler,b,skill)
          scoreCount += 1
        end
        if scoreCount>0 && scoreSum/scoreCount<=20
          shouldSwitch = true
        end
      end
    end
    # If there is a single foe and it is resting after Hyper Beam or is
    # Truanting (i.e. free turn)
    if @battle.pbSideSize(battler.index+1)==1 &&
       !battler.pbDirectOpposing.fainted?
      opp = battler.pbDirectOpposing
      if opp.effects[PBEffects::HyperBeam]>0 ||
         (opp.hasActiveAbility?(:TRUANT) && opp.effects[PBEffects::Truant])
        shouldSwitch = true
      end
    end
    matchups = []
    battler.eachOpposing do |opposingBattler|
      matchup = rateMatchup(battler,battler.pokemon,opposingBattler,getRoughAttackingTypes(opposingBattler))
      matchups.push(matchup)
    end
    currentMatchupRating = matchups.min
    # Don't swap for any above reason if we're in a good matchup
    PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) thinks its current matchup is rated: #{currentMatchupRating}")
    if currentMatchupRating >= 2
      PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) decides to ignore low level swapping concerns due to being in a good matchup.")
      shouldSwitch = false
    elsif currentMatchupRating <= -2 && policies.include?(:PROACTIVE_MATCHUP_SWAPPER)
      PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) decides to swap due to being in a bad matchup (Proactive Matchup Swapper Policy).")
      shouldSwitch = true
    end
    # Pokémon is about to faint because of Perish Song
    if battler.effects[PBEffects::PerishSong]==1
      shouldSwitch = true
    end
    # Should swap when confusion self-damage is likely to kill it
    if battler.effects[PBEffects::ConfusionChance] >= 1
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
      
      shouldSwitch = true if damage >= (battler.hp * 0.5).floor
    end
	  # Should swap when charm self-damage is likely to kill it
    if battler.effects[PBEffects::CharmChance] >= 1
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
      
      shouldSwitch = true if damage >= (battler.hp * 0.5).floor
    end

    # Determine who to swap into if at all
    if shouldSwitch
      PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) is trying to find a teammate to swap into.")
      list = pbGetPartyWithSwapRatings(idxBattler)
      listSwapOutCandidates(battler,list)
      list.delete_if {|val| !@battle.pbCanSwitch?(idxBattler,val[0]) || (val[1] - currentMatchupRating < 2)}
	  
      if list.length > 0
        partySlotNumber = list[0][0]
        if @battle.pbRegisterSwitch(idxBattler,partySlotNumber)
          PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will switch with " +
                      "#{@battle.pbParty(idxBattler)[partySlotNumber].name} due to it being rated at least 2 higher")
          return true
        end
      else
        PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) fails to find any swap candidates.")
      end
    end
    return false
  end

  def getRoughAttackingTypes(battler)
    return nil if battler.fainted?
    attackingTypes = [battler.pokemon.type1,battler.pokemon.type2]
    if !battler.lastMoveUsed.nil?
      moveData = GameData::Move.get(battler.lastMoveUsed)
      attackingTypes.push(moveData.type)
    end
    attackingTypes.uniq!
    attackingTypes.compact!
    return attackingTypes
  end

  def getPartyMemberAttackingTypes(pokemon)
    attackingTypes = []

    pokemon.moves.each do |move|
      next if move.category == 2 # Status
      attackingTypes.push(move.type)
    end

    attackingTypes.uniq!
    attackingTypes.compact!
    return attackingTypes
  end

  def listSwapOutCandidates(battler,list)
    PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) swap out candidates are:")
    list.each do |listEntry|
      enemyTrainer = @battle.pbGetOwnerFromBattlerIndex(battler.index)
      allyPokemon = enemyTrainer.party[listEntry[0]]
      next if allyPokemon.nil?
      PBDebug.log("#{allyPokemon.name || "Party member #{listEntry[0]}"}: #{listEntry[1]}")
    end
  end

  def pbDefaultChooseNewEnemy(idxBattler,party)
    list = pbGetPartyWithSwapRatings(idxBattler)
    list.delete_if {|val| !@battle.pbCanSwitchLax?(idxBattler,val[0])}
    if list.length != 0
      listSwapOutCandidates(@battle.battlers[idxBattler],list)
      return list[0][0]
    end
    return -1 
  end

  # Rates every other Pokemon in the trainer's party and returns a sorted list of the indices and swap in rating
  def pbGetPartyWithSwapRatings(idxBattler)
    list = []
    battler = @battle.battlers[idxBattler]
    @battle.pbParty(idxBattler).each_with_index do |pkmn,i|
      # Will contain effects that recommend against switching
      spikes = battler.pbOwnSide.effects[PBEffects::Spikes]
      # Don't switch to this if too little HP
      if spikes > 0
        spikesDmg = [8,6,4][spikes-1]
        if pkmn.hp <= pkmn.totalhp / spikesDmg
          if !pkmn.hasType?(:FLYING) && !pkmn.hasAbility?(:LEVITATE)
            list.push([i,-10])
            next
          end
        end
      end
      matchups = []
      battler.eachOpposing do |opposingBattler|
        matchup = rateMatchup(battler,pkmn,opposingBattler,getRoughAttackingTypes(opposingBattler))
        matchups.push(matchup)
      end
      list.push([i,matchups.min])
    end
    list.sort_by!{|entry| -entry[1]}
    return list
  end

  # Battler is the battler object for the slot being analyzed
  def rateMatchup(battler,partyPokemon,opposingBattler,attackingtypes=nil)
    typeModDefensive = Effectiveness::NORMAL_EFFECTIVE
    typeModOffensive = Effectiveness::NORMAL_EFFECTIVE

    # Get the worse defensive type mod among any of the player pokemon's attacking types
    if !attackingtypes.nil?
      typeModDefensive = pbCalcMaxOffensiveTypeMod(attackingtypes,partyPokemon)
    end
    
    # Get the best offensive type mod among any of the party pokemon's attacking types
    if !opposingBattler.nil?
      typeModOffensive = pbCalcMaxOffensiveTypeMod(getPartyMemberAttackingTypes(partyPokemon),opposingBattler)
    end
    
    typeMatchupScore = 0
    # Modify the type matchup score based on the defensive matchup
    if Effectiveness.ineffective?(typeModDefensive)
      typeMatchupScore += 4
    elsif Effectiveness.not_very_effective?(typeModDefensive)
      typeMatchupScore += 2
    elsif Effectiveness.hyper_effective?(typeModDefensive)
      typeMatchupScore -= 4
    elsif Effectiveness.super_effective?(typeModDefensive)
      typeMatchupScore -= 2
    end
    # Modify the type matchup score based on the offensive matchup
    if Effectiveness.ineffective?(typeModOffensive)
      typeMatchupScore -= 2
    elsif Effectiveness.not_very_effective?(typeModOffensive)
      typeMatchupScore -= 1
    elsif Effectiveness.hyper_effective?(typeModOffensive)
      typeMatchupScore += 2
    elsif Effectiveness.super_effective?(typeModOffensive)
      typeMatchupScore += 1
    end
    return typeMatchupScore
  end
  
  def pbCalcMaxOffensiveTypeMod(attackingTypes,victimPokemon)
    victimPokemon = victimPokemon.effects[PBEffects::Illusion] if victimPokemon.is_a?(PokeBattle_Battler) && victimPokemon.effects[PBEffects::Illusion]
    maxTypeMod = 0
    attackingTypes.each do |attackingType|
      mod = Effectiveness.calculate(attackingType,victimPokemon.type1,victimPokemon.type2)
      maxTypeMod = mod if mod > maxTypeMod
    end
    return maxTypeMod
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
    atkStat, atkStage = move.pbGetAttackStats(user,target)
    atk = pbRoughStatCalc(atkStat,atkStage)
    ##### Calculate target's defense stat #####
    defStat, defStage = move.pbGetDefenseStats(user,target)
    defense = pbRoughStatCalc(defStat,defStage)
    ##### Calculate all multiplier effects #####
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    # Ability effects that alter damage
    moldBreaker = false
    if target.hasMoldBreaker?
      moldBreaker = true
    end
    if user.abilityActive?
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
    if !moldBreaker
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if !moldBreaker && target.abilityActive?
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
    if !moldBreaker
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    # Item effects that alter damage
    # NOTE: Type-boosting gems aren't suitable for checking at the start of the
    #       round.
    if user.itemActive?
      # NOTE: These items aren't suitable for checking at the start of the
      #       round.
      itemBlacklist = [:EXPERTBELT,:LIFEORB]
      if !itemBlacklist.include?(user.item_id) && user.item && !user.item.is_gem? && !user.item.is_berry?
        BattleHandlers.triggerDamageCalcUserItem(user.item,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if target.itemActive?
      # NOTE: Type-weakening berries aren't suitable for checking at the start
      #       of the round.
      if target.item && !target.item.is_berry?
        BattleHandlers.triggerDamageCalcTargetItem(target.item,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    # Global abilities
      if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
         (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
        if @battle.pbCheckGlobalAbility(:AURABREAK)
          multipliers[:base_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:base_damage_multiplier] *= 4 / 3.0
        end
      end
    # Parental Bond
    if user.hasActiveAbility?(:PARENTALBOND)
      multipliers[:base_damage_multiplier] *= 1.25
    end
    # Me First
    # TODO
    # Helping Hand - n/a
    # Charge
	if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
		multipliers[:base_damage_multiplier] *= 2
	end
    # Terrain moves
	case @battle.field.terrain
	when :Electric
		multipliers[:base_damage_multiplier] *= 1.3 if type == :ELECTRIC && user.affectedByTerrain?
	when :Grassy
		multipliers[:base_damage_multiplier] *= 1.3 if type == :GRASS && user.affectedByTerrain?
	when :Psychic
		multipliers[:base_damage_multiplier] *= 1.3 if type == :PSYCHIC && user.affectedByTerrain?
	when :Misty
		multipliers[:base_damage_multiplier] *= 1.3 if type == :FAIRY && target.affectedByTerrain?
	end
    # Multi-targeting attacks
	if pbTargetsMultiple?(move,user)
		multipliers[:final_damage_multiplier] *= 0.75
	end
    # Weather
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
		if target.pbHasTypeAI?(:ROCK) && move.specialMove?(type)
		  multipliers[:defense_multiplier] *= 1.5
		end
	when :Hail
		if target.pbHasTypeAI?(:ICE) && move.physicalMove?(type)
		  multipliers[:defense_multiplier] *= 1.5
		end
	end
    # Critical hits - n/a
    # Random variance - n/a
    # STAB
	if type && user.pbHasTypeAI?(type)
		if user.hasActiveAbility?(:ADAPTABILITY)
			multipliers[:final_damage_multiplier] *= 2
		else
			multipliers[:final_damage_multiplier] *= 1.5
		end
	end
    # Type effectiveness
    typemod = pbCalcTypeMod(type,user,target)
    multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
    # Burn
	if user.status == :BURN && move.physicalMove?(type) &&
	 !user.hasActiveAbility?(:GUTS) && !move.damageReducedByBurn?
		if !user.boss
			multipliers[:final_damage_multiplier] *= 2.0/3.0
		else
			multipliers[:final_damage_multiplier] *= 4.0/5.0
		end
	end
	# Poison
	if user.status == :POISON && move.specialMove?(type) &&
	 !user.hasActiveAbility?(:AUDACITY) && !move.damageReducedByBurn?
		if !user.boss
			multipliers[:final_damage_multiplier] *= 2.0/3.0
		else
			multipliers[:final_damage_multiplier] *= 4.0/5.0
		end
	end
    # Aurora Veil, Reflect, Light Screen
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
    c = 0
    # Ability effects that alter critical hit rate
    if c>=0 && user.abilityActive?
      c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
    end
    if c>=0 && !moldBreaker && target.abilityActive?
      c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
    end
    # Item effects that alter critical hit rate
    if c>=0 && user.itemActive?
      c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
    end
    if c>=0 && target.itemActive?
      c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
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
	  
    return damage.floor
  end
  
  # For switching. Determines the effectiveness of a potential switch-in against
  # an opposing battler.
  def pbCalcTypeModPokemon(battlerThis,_battlerOther)
    mod1 = Effectiveness.calculate(battlerThis.type1,_battlerOther.type1,_battlerOther.type2)
    mod2 = Effectiveness::NORMAL_EFFECTIVE
    if battlerThis.type1!=battlerThis.type2
      mod2 = Effectiveness.calculate(battlerThis.type2,_battlerOther.type1,_battlerOther.type2)
      mod2 = mod2.to_f / Effectiveness::NORMAL_EFFECTIVE
    end
    return mod1*mod2
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
   #===========================================================================
  # Accura calculation
  #===========================================================================
  def pbRoughAccuracy(move,user,target,skill)
    return 100 if target.effects[PBEffects::Telekinesis] > 0
    baseAcc = move.accuracy
	  return 100 if baseAcc == 0
    baseAcc = move.pbBaseAccuracy(user,target)
	  return 100 if baseAcc == 0
    # Get the move's type
    type = pbRoughType(move,user,skill)
    # Calculate all modifier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user,target,modifiers,move,type,skill)
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion<1
    # Value always hit moves if otherwise would be hard to hit here
    if modifiers[:base_accuracy] == 0
      return (accuracy / evasion < 1) ? 125 : 100
    end
	  return modifiers[:base_accuracy] * accuracy / evasion
  end

  def pbCalcTypeMod(moveType,user,target)
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
       target.pbHasTypeAI?(:FLYING) && target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = target.pbTypesAI(true)
    # Get effectivenesses
    typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    if moveType == :SHADOW
      if target.shadowPokemon?
        typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      else
        typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    else
      tTypes.each_with_index do |type,i|
        typeMods[i] = pbCalcTypeModSingle(moveType,type,user,target)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
    return ret
  end

  def moveFailureAlert(move,user,target,failureMessage)
    echoln("#{user.pbThis(true)} thinks that move #{move.id} against target #{target.pbThis(true)} will fail due to #{failureMessage}")
  end
  
  #=============================================================================
  # Immunity to a move because of the target's ability, item or other effects
  #=============================================================================
  def pbCheckMoveImmunity(score,move,user,target,skill)
    type = pbRoughType(move,user,skill)
    typeMod = pbCalcTypeMod(type,user,target)
    # Type effectiveness
    if (Effectiveness.ineffective?(typeMod) && !move.statusMove?)
      moveFailureAlert(move,user,target,"inneffective type mod")
      return true
    end
    # Immunity due to ability/item/other effects
    case type
    when :GROUND
      if target.airborne? && !move.hitsFlyingTargets?
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    when :FIRE
      if target.hasActiveAbility?(:FLASHFIRE)
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    when :WATER
      if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB])
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    when :GRASS
      if target.hasActiveAbility?(:SAPSIPPER)
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    when :ELECTRIC
      if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB])
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    when :ICE
      if target.hasActiveAbility?(:COLDPROOF)
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    when :FLYING
      if target.hasActiveAbility?(:AERODYNAMIC)
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    when :POISON
      if target.hasActiveAbility?(:POISONABSORB)
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    when :FIGHTING
      if target.hasActiveAbility?(:CHALLENGER)
        moveFailureAlert(move,user,target,"immunity ability")
        return true 
      end
    when :DARK
      if target.hasActiveAbility?(:HEARTOFJUSTICE)
        moveFailureAlert(move,user,target,"immunity ability")
        return true
      end
    end
    if Effectiveness.not_very_effective?(typeMod) && target.hasActiveAbility?(:WONDERGUARD)
      moveFailureAlert(move,user,target,"wonder guard immunity")
      return true
    end
    if move.damagingMove? && user.index!=target.index && !target.opposes?(user) && target.hasActiveAbility?(:TELEPATHY)
      moveFailureAlert(move,user,target,"telepathy ally immunity")
      return true
    end
    if move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) && target.opposes?(user)
      moveFailureAlert(move,user,target,"magic coat/bounce immunity")
      return true
    end
    # Account for magic bounc bouncing back side-effecting moves
    if move.canMagicCoat? && target == user
      user.eachOpposing do |b|
        if b.hasActiveAbility?(:MAGICBOUNCE)
          moveFailureAlert(move,user,target,"magic bounce whole side immunity")
          return true
        end
      end
    end
    if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
      moveFailureAlert(move,user,target,"soundproof immunity")
      return true
    end
    if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
      moveFailureAlert(move,user,target,"bulletproof immunity")
      return true
    end
    if move.powderMove?
      if target.pbHasTypeAI?(:GRASS)
        moveFailureAlert(move,user,target,"grass powder immunity")
        return true
      end
      if target.hasActiveAbility?(:OVERCOAT)
        moveFailureAlert(move,user,target,"overcoat powder immunity")
        return true
      end
      if target.hasActiveItem?(:SAFETYGOGGLES)
        moveFailureAlert(move,user,target,"safety-goggles powder immunity")
        return true
      end
    end
    if target.effects[PBEffects::Substitute]>0 && move.statusMove? && !move.ignoresSubstitute?(user) && user.index!=target.index
      moveFailureAlert(move,user,target,"substitute immunity to most status moves")
      return true
    end
    if user.hasActiveAbility?(:PRANKSTER) && target.pbHasTypeAI?(:DARK) && target.opposes?(user) && move.statusMove?
      moveFailureAlert(move,user,target,"dark immunity to prankster boosted status moves")
      return true
    end
    if move.priority > 0 && @battle.field.terrain == :Psychic && target.affectedByTerrain? && target.opposes?(user)
      moveFailureAlert(move,user,target,"psychic terrain prevention of priority")
      return true
    end
    return false
  end

  def pbRoughType(move,user,skill)
    return move.pbCalcType(user)
  end

  def pbRoughStatCalc(atkStat,atkStage)
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    return (atkStat.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
  end

  def pbRoughStat(battler,stat,skill)
    castBattler = (battler.effects[PBEffects::Illusion] && battler.pbOwnedByPlayer?) ? battler.effects[PBEffects::Illusion] : battler
    return battler.pbSpeed if stat==:SPEED && !battler.effects[PBEffects::Illusion]
    
    stage = battler.stages[stat]+6
    value = 0
    case stat
    when :ATTACK          then value = castBattler.attack
    when :DEFENSE         then value = castBattler.defense
    when :SPECIAL_ATTACK  then value = castBattler.spatk
    when :SPECIAL_DEFENSE then value = castBattler.spdef
    when :SPEED           then value = castBattler.speed
    end
    return pbRoughStatCalc(value,stage)
  end
end