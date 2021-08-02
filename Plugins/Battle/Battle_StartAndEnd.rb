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
	$game_switches[94] = true if $Trainer.able_pokemon_count == faintedBefore # Record if the fight was perfected
    return @decision
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
		  BattleHandlers.triggerAbilityOnSwitchOut(b.ability,b,true) if b.abilityActive?
		end
		pbParty(0).each_with_index do |pkmn,i|
		  next if !pkmn
		  @peer.pbOnLeavingBattle(self,pkmn,@usedInBattle[0][i],true)   # Reset form
		  pkmn.item = @initialItems[0][i]
		end
		return @decision
	end
end

