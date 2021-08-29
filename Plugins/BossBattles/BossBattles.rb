Events.onWildPokemonCreate += proc {| sender, e |
  pkmn = e[0]
  
  # If this is a boss fight...
  if $game_switches[95]
    pkmn.boss = true
	
	#Setting the boss's move set
	if $game_variables[99].is_a?(Hash)
	  moves = $game_variables[99][pkmn.species]
	  pkmn.forget_all_moves()
      moves.each do |move|
        pkmn.learn_move(move)
      end
    elsif $game_variables[99].is_a?(Array)
      pkmn.forget_all_moves()
      $game_variables[99].each do |move|
        pkmn.learn_move(move)
      end
    end
	
	# Setting the boss's item
    if $game_variables[100]
		if $game_variables[100].is_a?(Hash)
			pkmn.item = $game_variables[100][pkmn.species]
		else
			pkmn.item = $game_variables[100]
		end
    end
	
	# Setting boss's ability
    if $game_variables[94]
		if $game_variables[94].is_a?(Hash)
			abilityIndex = $game_variables[94][pkmn.species]
			pkmn.ability = (pkmn.getAbilityList()[abilityIndex][0])
		else
			abilityIndex = $game_variables[94]
			pkmn.ability = (pkmn.getAbilityList()[abilityIndex][0])
		end
    else
      pkmn.ability = (pkmn.getAbilityList()[0][0])
    end
	
	pkmn.calc_stats()
  end
}

def scrubBossBattleSettings
  $game_variables[94] = nil
  $game_variables[95] = 1
  $game_variables[96] = 1
  $game_variables[97] = 1
  $game_variables[98] = 1 # XP mult
  $game_variables[99] = nil
  $game_variables[100] = nil
end

def pbPlayCrySpecies(species, form = 0, volume = 90, pitch = nil)
  GameData::Species.play_cry_from_species(species, form, volume, pitch)
end

class Pokemon
	attr_accessor :boss
	
	# @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
	  def gender
		return 2 if boss?
		if !@gender
		  gender_ratio = species_data.gender_ratio
		  case gender_ratio
		  when :AlwaysMale   then @gender = 0
		  when :AlwaysFemale then @gender = 1
		  when :Genderless   then @gender = 2
		  else
			female_chance = GameData::GenderRatio.get(gender_ratio).female_chance
			@gender = ((@personalID & 0xFF) < female_chance) ? 1 : 0
		  end
		end
		return @gender
	  end
	  
	def boss?
		return boss
	end
end

class PokeBattle_Battle
	def pbStartBattleSendOut(sendOuts)
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
        pbDisplayPaused(_INTL("Oh! A wild {1} appeared!",foeParty[0].name))
		if $game_switches[95]
          pbDisplayPaused("Actually, it's a powerful avatar!")
        end
      when 2
        pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!",foeParty[0].name,
           foeParty[1].name))
		if $game_switches[95]
          pbDisplayPaused("Actually, they're both powerful avatars!")
        end
      when 3
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!",foeParty[0].name,
           foeParty[1].name,foeParty[2].name))
		if $game_switches[95]
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
	  
	  if $game_switches[95]
		  # Boss phases after main phases
		  extra = $game_variables[95] - 1
		  if extra > 0
			for i in 1..extra do
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
	  end
	  
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      break if @decision>0
      @turnCount += 1
	  @commandPhasesThisRound = 0
    end
    pbEndOfBattle
  end

  
  def pbSetBossItem(pkmn)
	if pkmn.species == :GENESECT && pkmn.turnCount == 0
		pbDisplay(_INTL("The avatar of Genesect is analyzing your team for weaknesses..."))
		weakToElectric 	= 0
		weakToFire 		= 0
		weakToIce 		= 0
		weakToWater 	= 0
		maxValue = 0

		$Trainer.party.each do |b|
			next if !b
			type1 = b.type1
			type2 = nil
			type2 = b.type2 if b.type2 != b.type1
			weakToElectric += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:ELECTRIC,type1,type2,nil))
			maxValue = weakToElectric if weakToElectric > maxValue
			weakToFire += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:FIRE,type1,type2,nil))
			maxValue = weakToElectric if weakToFire > maxValue
			weakToIce += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:ICE,type1,type2,nil))
			maxValue = weakToElectric if weakToIce > maxValue
			weakToWater += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:WATER,type1,type2,nil))
			maxValue = weakToElectric if weakToWater > maxValue
		end
		
		chosenItem = nil
		if maxValue > 0
			results = {SHOCKDRIVE: weakToElectric, BURNDRIVE: weakToFire, CHILLDRIVE: weakToIce, DOUSEDRIVE: weakToWater}
			results = results.sort_by{|k, v| v}.to_h
			results.delete_if{|k, v| v < maxValue}
			chosenItem = results.keys.sample
		end
		
		if !chosenItem
			pbDisplay(_INTL("The avatar of Genesect can't find any!"))
		else
			pbDisplay(_INTL("The avatar of Genesect loads a {1}!",GameData::Item.get(chosenItem).real_name))
			pkmn.item = chosenItem
		end
	end
  end
  
  def pbExtraBossCommandPhase()
    @scene.pbBeginCommandPhase
    # Reset choices if commands can be shown
    @battlers.each_with_index do |b,i|
      next if !b
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    # Reset choices to perform Mega Evolution if it wasn't done somehow
    for side in 0...2
      @megaEvolution[side].each_with_index do |megaEvo,i|
        @megaEvolution[side][i] = -1 if megaEvo>=0
      end
    end
    pbCommandPhaseLoop(false)
  end
  
  #=============================================================================
  # Attack phase
  #=============================================================================
  def pbExtraBossAttackPhase
    @scene.pbBeginAttackPhase
    # Reset certain effects
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")   # Rage
    end
    PBDebug.log("")
    # Calculate move order for this round
    pbCalculatePriority(true)
    # Perform actions
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision>0
    pbAttackPhaseItems
    return if @decision>0
    pbAttackPhaseMegaEvolution
    
	
	pbPriority.each do |b|
        next if b.fainted?
        next unless @choices[b.index][0]==:UseMove
        if b.boss
          b.pbProcessTurn(@choices[b.index])
        end
      end
  end
end

def pbPlayerPartyMaxLevel(countFainted = false)
  maxPlayerLevel = -100
  $Trainer.party.each do |pkmn|
    maxPlayerLevel = pkmn.level if pkmn.level > maxPlayerLevel && (!pkmn.fainted? || countFainted)
  end
  return maxPlayerLevel
end