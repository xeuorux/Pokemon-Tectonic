class PokeBattle_Battle
  #=============================================================================
  # Start a battle
  #=============================================================================
  def pbStartBattle
    PBDebug.log("")
    PBDebug.log("******************************************")
    logMsg = "[Started battle] "
    if @sideSizes[0]==1 && @sideSizes[1]==1
      logMsg += "Single "
    elsif @sideSizes[0]==2 && @sideSizes[1]==2
      logMsg += "Double "
    elsif @sideSizes[0]==3 && @sideSizes[1]==3
      logMsg += "Triple "
    else
      logMsg += "#{@sideSizes[0]}v#{@sideSizes[1]} "
    end
    logMsg += "wild " if wildBattle?
    logMsg += "trainer " if trainerBattle?
    logMsg += "battle (#{@player.length} trainer(s) vs. "
    logMsg += "#{pbParty(1).length} wild Pokémon)" if wildBattle?
    logMsg += "#{@opponent.length} trainer(s))" if trainerBattle?
    PBDebug.log(logMsg)
	$game_switches[94] = false
    faintedBefore = $Trainer.able_pokemon_count # Record the number of fainted
    pbEnsureParticipants
    begin
      pbStartBattleCore
    rescue BattleAbortedException
      @decision = 0
      @scene.pbEndBattle(@decision)
    end
	# Record if the fight was perfected
	if $Trainer.able_pokemon_count == faintedBefore
		$game_switches[94] = true 
		pbDisplayPaused(_INTL("You perfected the fight!"))
	end
    return @decision
  end
  
  #=============================================================================
  # End of battle
  #=============================================================================
  def pbGainMoney
    return if !@internalBattle || !@moneyGain
    # Money rewarded from opposing trainers
    if trainerBattle?
      tMoney = 0
      @opponent.each_with_index do |t,i|
		baseMoney = [t.base_money,100].min
		baseMoney = 10 + baseMoney / 2
        tMoney += pbMaxLevelInTeam(1, i) * baseMoney
      end
      tMoney *= 2 if @field.effects[PBEffects::AmuletCoin]
      tMoney *= 2 if @field.effects[PBEffects::HappyHour]
	  tMoney *= 2 if @field.effects[PBEffects::Fortune]
      oldMoney = pbPlayer.money
      pbPlayer.money += tMoney
      moneyGained = pbPlayer.money-oldMoney
      if moneyGained>0
        pbDisplayPaused(_INTL("You got ${1} for winning!",moneyGained.to_s_formatted))
      end
    end
    # Pick up money scattered by Pay Day
    if @field.effects[PBEffects::PayDay]>0
      @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::AmuletCoin]
      @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::HappyHour]
	  @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::Fortune]
      oldMoney = pbPlayer.money
      pbPlayer.money += @field.effects[PBEffects::PayDay]
      moneyGained = pbPlayer.money-oldMoney
      if moneyGained>0
        pbDisplayPaused(_INTL("You picked up ${1}!",moneyGained.to_s_formatted))
      end
    end
  end
  
  def pbStartBattleSendOut(sendOuts)
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
        pbDisplayPaused(_INTL("Oh! A wild {1} appeared!",foeParty[0].name))
		if bossBattle?
          pbDisplayPaused("Actually, it's a powerful avatar!")
        end
      when 2
        pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!",foeParty[0].name,
           foeParty[1].name))
		if bossBattle?
          pbDisplayPaused("Actually, they're both powerful avatars!")
        end
      when 3
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!",foeParty[0].name,
           foeParty[1].name,foeParty[2].name))
		if bossBattle?
          pbDisplayPaused("Actually, they're all powerful avatars!")
        end
      end
    else   # Trainer battle
      case @opponent.length
      when 1
        pbDisplayPaused(_INTL("You are challenged by {1}!",@opponent[0].full_name))
      when 2
        pbDisplayPaused(_INTL("You are challenged by {1} and {2}!",@opponent[0].full_name,
           @opponent[1].full_name))
      when 3
        pbDisplayPaused(_INTL("You are challenged by {1}, {2} and {3}!",
           @opponent[0].full_name,@opponent[1].full_name,@opponent[2].full_name))
      end
    end
    # Send out Pokémon (opposing trainers first)
    for side in [1,0]
      next if side==1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side==0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t,i|
        next if side==0 && i==0   # The player's message is shown last
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][i]
        case sent.length
        when 1
          msg += _INTL("{1} sent out {2}!",t.full_name,@battlers[sent[0]].name)
        when 2
          msg += _INTL("{1} sent out {2} and {3}!",t.full_name,
             @battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("{1} sent out {2}, {3} and {4}!",t.full_name,
             @battlers[sent[0]].name,@battlers[sent[1]].name,@battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      # The player's message about sending out Pokémon
      if side==0
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][0]
        case sent.length
        when 1
          msg += _INTL("Go! {1}!",@battlers[sent[0]].name)
        when 2
          msg += _INTL("Go! {1} and {2}!",@battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("Go! {1}, {2} and {3}!",@battlers[sent[0]].name,
             @battlers[sent[1]].name,@battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      pbDisplayBrief(msg) if msg.length>0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler,@battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts,true)
    end
  end
  
  #=============================================================================
  # Main battle loop
  #=============================================================================
  def pbBattleLoop
    @turnCount = 0
    loop do   # Now begin the battle loop
      PBDebug.log("")
      PBDebug.log("***Round #{@turnCount+1}***")
      if @debug && @turnCount>=100
        @decision = pbDecisionOnTime
        PBDebug.log("")
        PBDebug.log("***Undecided after 100 rounds, aborting***")
        pbAbort
        break
      end
      PBDebug.log("")
	  
	  # Allow bosses to set various things about themselves before their turn
	  @battlers.each do |b|
		next if !b || b.fainted || !b.boss
		PokeBattle_AI.triggerBossBeginTurn(b.species,b)
	  end
	  
	  @commandPhasesThisRound = 0
	  
      # Command phase
      PBDebug.logonerr { pbCommandPhase }
      break if @decision>0
      # Attack phase
      PBDebug.logonerr { pbAttackPhase }
      break if @decision>0
	  
	  @commandPhasesThisRound = 1
	  
	  # Boss phases after main phases
	  if @numBossOnlyTurns > 0
		for i in 1..@numBossOnlyTurns do
		  @battlers.each do |b|
			next if !b
			if b.boss
			  @lastRoundMoved = 0
			end
		  end
		  # Command phase
		  PBDebug.logonerr { pbExtraBossCommandPhase() }
		  break if @decision>0
		  
		  @commandPhasesThisRound += 1
		  
		  # Attack phase
		  PBDebug.logonerr { pbExtraBossAttackPhase() }
		  break if @decision>0
		end
	  end
	  
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      break if @decision>0
      @turnCount += 1
	  @commandPhasesThisRound = 0
    end
    pbEndOfBattle
  end
  
  def pbEndOfBattle
		oldDecision = @decision
		@decision = 4 if @decision==1 && wildBattle? && @caughtPokemon.length>0
		case oldDecision
		##### WIN #####
		when 1
		  PBDebug.log("")
		  PBDebug.log("***Player won***")
		  if trainerBattle?
			@scene.pbTrainerBattleSuccess
			case @opponent.length
			when 1
			  pbDisplayPaused(_INTL("You defeated {1}!",@opponent[0].full_name))
			when 2
			  pbDisplayPaused(_INTL("You defeated {1} and {2}!",@opponent[0].full_name,
				 @opponent[1].full_name))
			when 3
			  pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!",@opponent[0].full_name,
				 @opponent[1].full_name,@opponent[2].full_name))
			end
			@opponent.each_with_index do |_t,i|
			  if @endSpeeches[i] && @endSpeeches[i] != "" && @endSpeeches[i] != "..."
				@scene.pbShowOpponent(i)
				pbDisplayPaused(@endSpeeches[i].gsub(/\\[Pp][Nn]/,pbPlayer.name))
			  end
			end
		  end
		  # Gain money from winning a trainer battle, and from Pay Day
		  pbGainMoney if @decision!=4
		  # Hide remaining trainer
		  @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length>0
		##### LOSE, DRAW #####
		when 2, 5
		  PBDebug.log("")
		  PBDebug.log("***Player lost***") if @decision==2
		  PBDebug.log("***Player drew with opponent***") if @decision==5
		  if @internalBattle
			if trainerBattle?
			  case @opponent.length
			  when 1
				pbDisplayPaused(_INTL("You lost against {1}!",@opponent[0].full_name))
			  when 2
				pbDisplayPaused(_INTL("You lost against {1} and {2}!",
				   @opponent[0].full_name,@opponent[1].full_name))
			  when 3
				pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
				   @opponent[0].full_name,@opponent[1].full_name,@opponent[2].full_name))
			  end
			end
		  elsif @decision==2
			if @opponent
			  @opponent.each_with_index do |_t,i|
				@scene.pbShowOpponent(i)
				msg = (@endSpeechesWin[i] && @endSpeechesWin[i]!="") ? @endSpeechesWin[i] : "..."
				pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
			  end
			end
		  end
		##### CAUGHT WILD POKÉMON #####
		when 4
		  @scene.pbWildBattleSuccess if !Settings::GAIN_EXP_FOR_CAPTURE
		end
		# Register captured Pokémon in the Pokédex, and store them
		pbRecordAndStoreCaughtPokemon
		# Collect Pay Day money in a wild battle that ended in a capture
		pbGainMoney if @decision==4
		# Pass on Pokérus within the party
		if @internalBattle
		  infected = []
		  $Trainer.party.each_with_index do |pkmn,i|
			infected.push(i) if pkmn.pokerusStage==1
		  end
		  infected.each do |idxParty|
			strain = $Trainer.party[idxParty].pokerusStrain
			if idxParty>0 && $Trainer.party[idxParty-1].pokerusStage==0
			  $Trainer.party[idxParty-1].givePokerus(strain) if rand(3)==0   # 33%
			end
			if idxParty<$Trainer.party.length-1 && $Trainer.party[idxParty+1].pokerusStage==0
			  $Trainer.party[idxParty+1].givePokerus(strain) if rand(3)==0   # 33%
			end
		  end
		end
		# Clean up battle stuff
		@scene.pbEndBattle(@decision)
		@battlers.each do |b|
		  next if !b
		  pbCancelChoice(b.index)   # Restore unused items to Bag
		  BattleHandlers.triggerAbilityOnSwitchOut(b.ability,b,true,self) if b.abilityActive?
		end
		pbParty(0).each_with_index do |pkmn,i|
		  next if !pkmn
		  @peer.pbOnLeavingBattle(self,pkmn,@usedInBattle[0][i],true)   # Reset form
		  pkmn.item = @initialItems[0][i]
		end
		return @decision
	end
end

