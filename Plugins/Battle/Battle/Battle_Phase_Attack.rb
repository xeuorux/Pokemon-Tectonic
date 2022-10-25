class PokeBattle_Battle 

	def pbPursuit(idxSwitcher)
		@switching = true
		pbPriority.each do |b|
		  next if b.fainted? || !b.opposes?(idxSwitcher)   # Shouldn't hit an ally
		  next if b.movedThisRound? || !pbChoseMoveFunctionCode?(b.index,"088")   # Pursuit
		  # Check whether Pursuit can be used
		  next unless pbMoveCanTarget?(b.index,idxSwitcher,@choices[b.index][2].pbTarget(b))
		  next unless pbCanChooseMove?(b.index,@choices[b.index][1],false)
		  next if b.asleep?
		  next if b.effectActive?(:SkyDrop)
		  next if b.hasActiveAbility?(:TRUANT) && b.effectActive?(:Truant)
		  # Mega Evolve
		  if !wildBattle? || !b.opposes?
        owner = pbGetOwnerIndexFromBattlerIndex(b.index)
        pbMegaEvolve(b.index) if @megaEvolution[b.idxOwnSide][owner]==b.index
		  end
		  # Use Pursuit
		  @choices[b.index][3] = idxSwitcher # Change Pursuit's target
		  if b.pbProcessTurn(@choices[b.index],false)
			  b.applyEffect(:Pursuit)
		  end
		  break if @decision>0 || @battlers[idxSwitcher].fainted?
		end
		@switching = false
    end
	
	def pbAttackPhaseSwitch
		pbPriority.each do |b|
		  next unless @choices[b.index][0]==:SwitchOut && !b.fainted?
		  idxNewPkmn = @choices[b.index][1]   # Party index of Pokémon to switch to
		  b.lastMoveFailed = false   # Counts as a successful move for Stomping Tantrum
		  @lastMoveUser = b.index
		  # Switching message
		  pbMessageOnRecall(b)
		  # Pursuit interrupts switching
		  pbPursuit(b.index)
		  return if @decision>0
		  # Neutralizing Gas
		  pbCheckNeutralizingGas(b)
		  # Switch Pokémon
		  pbRecallAndReplace(b.index,idxNewPkmn)
		  b.pbEffectsOnSwitchIn(true)
		end
	end
  
  #=============================================================================
  # Attack phase
  #=============================================================================
  def pbAttackPhase
    @messagesBlocked = false
    @scene.pbBeginAttackPhase
    resetEffects
    PBDebug.log("")
    # Calculate move order for this round
    pbCalculatePriority(true)
    # Perform actions
    return if attackPhaseNonMoveActions()
    pbAttackPhaseMoves
  end

  def resetEffects()
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0] != :UseMove && @choices[i][0] != :Shift && @choices[i][0] != :SwitchOut
        b.disableEffect(:DestinyBond)
        b.disableEffect(:Grudge)
      end
      b.disableEffect(:Rage) if !pbChoseMoveFunctionCode?(i,"093")   # Rage
	    b.disableEffect(:Enlightened) if !pbChoseMoveFunctionCode?(i,"515")   # Enlightened Hit
      if @choices[i][0] == :UseMove && @choices[i][2]&.statusMove?
        b.applyEffect(:Sentry)
      end
      b.lastRoundHighestTypeModFromFoe = -1
    end
  end

  # Returns whether or not the battle has ended
  def attackPhaseNonMoveActions()
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return true if @decision > 0
    pbAttackPhaseItems
    return true if @decision > 0
    pbAttackPhaseMegaEvolution
    return false
  end

  #=============================================================================
  # Attack phase
  #=============================================================================
  def pbExtraAttackPhase
    @scene.pbBeginAttackPhase
    resetEffects
    PBDebug.log("")
    # Calculate move order for this round
    pbCalculatePriority(true)
    # Perform actions
    return if attackPhaseNonMoveActions()
    
	  pbPriority.each do |battler|
        next if battler.fainted?
        next unless @choices[battler.index][0] == :UseMove
        next if @commandPhasesThisRound - 1 > battler.extraMovesPerTurn
        battler.pbProcessTurn(@choices[battler.index])
      end
  end
end