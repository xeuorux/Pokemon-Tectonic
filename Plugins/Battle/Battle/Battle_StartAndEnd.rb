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
    ableBeforeFight = $Trainer.able_pokemon_count # Record the number of fainted
    $Tribal_Bonuses.updateTribeCount()
    pbEnsureParticipants
    begin
      pbStartBattleCore
    rescue BattleAbortedException
      @decision = 0
      @scene.pbEndBattle(@decision)
    rescue StandardError
      pbMessage(_INTL("\\wmA major error has occured! Please screen-shot the following error message and share it in our bug channel."))
      pbPrintException($!)
      pbMessage(_INTL("\\wmRather than crashing, we will give the victory to you."))
      pbMessage(_INTL("\\wmPlease don't abuse this functionality."))
      @decision = 1
      @scene.pbEndBattle(@decision)
    end
    # End the effect of all curses
    curses.each do |curse_policy|
      triggerBattleEndCurse(curse_policy,self)
    end
    # Record if the fight was perfected
    if $Trainer.able_pokemon_count >= ableBeforeFight
      $game_switches[94] = true 
      pbMessage(_INTL("\\me[Battle perfected]You perfected the fight!")) if trainerBattle? && @decision == 1
    end
    # Update each of the player's pokemon's battling streak
    if trainerBattle? || bossBattle?
      pbParty(0).each_with_index do |pkmn,i|
        wasOnStreak = pkmn.onHotStreak?
        if pkmn.fainted? || [2,3].include?(@decision)
          pkmn.battlingStreak = 0
          pbMessage("#{pkmn.name}'s Hot Streak is now over.") if wasOnStreak
        elsif @usedInBattle[0][i]
          pkmn.battlingStreak += 1
          pbMessage("#{pkmn.name} is on a Hot Streak!") if pkmn.onHotStreak? && !wasOnStreak
        end
      end
    end
    return @decision
  end
  
  def pbStartBattleCore
    # Set up the battlers on each side
    sendOuts = pbSetUpSides
    # Create all the sprites and play the battle intro animation
    @scene.pbStartBattle(self)
    # Show trainers on both sides sending out Pokémon
    pbStartBattleSendOut(sendOuts)
    # Curses apply if at all
    if @opponent && $PokemonGlobal.tarot_amulet_active
      @opponent.each do |opponent|
        opponent.policies.each do |policy|
          cursesToAdd = triggerBattleStartApplyCurse(policy,self,[])
          curses.concat(cursesToAdd)
        end
      end
    end
    # Weather announcement
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
    when :Rain        then pbDisplay(_INTL("It is raining."))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("Hail is falling."))
    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The sky is shadowy."))
    end
    # Terrain announcement
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass is covering the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Fae mist swirls about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield is weird!"))
    end
    # Abilities upon entering battle
    pbOnActiveAll
    # Main battle loop
    pbBattleLoop
  end

  #=============================================================================
  # Set up all battlers
  #=============================================================================
  def pbCreateBattler(idxBattler,pkmn,idxParty)
    if !@battlers[idxBattler].nil?
      raise _INTL("Battler index {1} already exists",idxBattler)
    end
    @battlers[idxBattler] = PokeBattle_Battler.new(self,idxBattler)
    @positions[idxBattler] = PokeBattle_ActivePosition.new(self,idxBattler)
    pbClearChoice(idxBattler)
    @successStates[idxBattler] = PokeBattle_SuccessState.new
    @battlers[idxBattler].pbInitialize(pkmn,idxParty)
  end
  
  #=============================================================================
  # End of battle
  #=============================================================================
  def pbGainMoney
    return if !@internalBattle || !@moneyGain
  
    moneyMult = 1
    moneyMult *= 2 if @field.effectActive?(:AmuletCoin)
    moneyMult *= 2 if @field.effectActive?(:HappyHour)
    moneyMult *= 2 if @field.effectActive?(:Fortune)

    # Money rewarded from opposing trainers
    if trainerBattle?
      tMoney = 0
      @opponent.each_with_index do |t,i|
		  baseMoney = [t.base_money,100].min
		  baseMoney = 10 + baseMoney / 2
        tMoney += pbMaxLevelInTeam(1, i) * baseMoney
      end
      tMoney *= moneyMult
      oldMoney = pbPlayer.money
      pbPlayer.money += tMoney
      moneyGained = pbPlayer.money-oldMoney
      if moneyGained>0
        pbDisplayPaused(_INTL("You got ${1} for winning!",moneyGained.to_s_formatted))
      end
    end
    # Pick up money scattered by Pay Day
    if @field.effectActive?(:PayDay)
      paydayMoney = @field.effects[:PayDay]
      paydayMoney *= moneyMult
      oldMoney = pbPlayer.money
      pbPlayer.money += paydayMoney
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
          if isLegendary?(foeParty[0].species)
			pbDisplayPaused("Actually, it's a powerful legendary avatar!")
		  else
			pbDisplayPaused("Actually, it's an avatar!")
		  end
        end
      when 2
        pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!",foeParty[0].name,
           foeParty[1].name))
		if bossBattle?
          pbDisplayPaused("Actually, they're both avatars!")
        end
      when 3
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!",foeParty[0].name,
           foeParty[1].name,foeParty[2].name))
		if bossBattle?
          pbDisplayPaused("Actually, they're all avatars!")
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
        if !t.wild?
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
        else
          msg += _INTL("The {1} joined in!",t.full_name)
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

      # The battle is a draw if the player survives a certain number of turns
      # In survival battles
      if @turnsToSurvive > 0 && @turnCount > @turnsToSurvive
        triggerBattleSurvivedDialogue()
        @decision = 6
        break
      end
	  
      # Allow bosses to set various things about themselves before their turn
      @battlers.each do |b|
      next if !b || b.fainted || !b.boss
        PokeBattle_AI.triggerBossBeginTurn(b.species,b)
      end
      
      @commandPhasesThisRound = 0
      
      # Curses effects here
      @curses.each do |curse_policy|
        triggerBeginningOfTurnCurseEffect(curse_policy,self)
      end
	  
      # Command phase
      PBDebug.logonerr { pbCommandPhase }
      break if @decision > 0

      @commandPhasesThisRound = 1

      # Attack phase
      PBDebug.logonerr { pbAttackPhase }
      break if @decision > 0
	  
      numExtraPhasesThisTurn = 0
      @battlers.each do |b|
        next if !b
        numExtraPhasesThisTurn = b.extraMovesPerTurn if b.extraMovesPerTurn > numExtraPhasesThisTurn
      end

      echoln("There should be #{numExtraPhasesThisTurn} extra command attack phases this turn.")
      
      # Boss phases after main phases
      if numExtraPhasesThisTurn > 0
        for i in 1..numExtraPhasesThisTurn do
          echoln("Extra phase begins")
          @battlers.each do |b|
            next if !b
            @lastRoundMoved = 0
          end
          # Command phase
          PBDebug.logonerr { pbExtraCommandPhase() }
          break if @decision>0
          
          @commandPhasesThisRound += 1
          
          # Attack phase
          PBDebug.logonerr { pbExtraAttackPhase() }
          break if @decision > 0
        end
      end
	  
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      break if @decision>0
      @commandPhasesThisRound = 0
      
      useEmpoweredStatusMoves()
      
      @turnCount += 1
    end
    pbEndOfBattle
  end
  
  def useEmpoweredStatusMoves()
	  # Have bosses use empowered moves if appropriate
	  @battlers.each do |b|
      next if !b
      next unless b.boss?
      avatarData = GameData::Avatar.get(b.species.to_sym)
      next if b.avatarPhase == avatarData.num_phases
      hpFraction = 1 - (b.avatarPhase.to_f / avatarData.num_phases.to_f)
      next if b.hp > b.totalhp * hpFraction
      usedEmpoweredMove = false
      b.eachMoveWithIndex do |move,index|
        next if move.damagingMove?
        next if !move.isEmpowered?
        next if move.pp < 1
        pbDisplayPaused(_INTL("A great energy rises up from inside {1}!", b.pbThis(true)))
        b.lastRoundMoved = 0
        b.pbUseMove([:UseMove,index,move,-1,0])
        usedEmpoweredMove = true
      end
      # Swap to post-empowerment moveset
      if usedEmpoweredMove
        b.avatarPhase += 1
        movesetToAssign = [avatarData.moves1,avatarData.moves2,avatarData.moves3][b.avatarPhase-1]
        if movesetToAssign.nil?
          echoln("ERROR: Unable to change moveset.")
        end
        b.assignMoveset(movesetToAssign)
        b.primevalTimer = 0
        @scene.pbRefresh
      end
	  end
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
    #### WIN FROM TIMEOUT ####
    when 6
      PBDebug.log("")
		  PBDebug.log("***Player won from time***")
		  if trainerBattle?
			  @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("You outlasted {1}.",@opponent[0].full_name))
        when 2
          pbDisplayPaused(_INTL("You outlasted {1} and {2}.",@opponent[0].full_name,
          @opponent[1].full_name))
        when 3
          pbDisplayPaused(_INTL("You outlasted {1}, {2} and {3}.",@opponent[0].full_name,
          @opponent[1].full_name,@opponent[2].full_name))
        end
        @opponent.each_with_index do |_t,i|
          if @endSpeeches[i] && @endSpeeches[i] != "" && @endSpeeches[i] != "..."
            @scene.pbShowOpponent(i)
            pbDisplayPaused(@endSpeeches[i].gsub(/\\[Pp][Nn]/,pbPlayer.name))
          end
        end
		  end
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
		pbDisplayPaused(_INTL("{1} exp was stored in the EXP-EZ Dispenser this battle.",@expStored)) if @expStored > 0
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

