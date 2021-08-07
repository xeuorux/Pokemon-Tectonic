class PokeBattle_Battle
	#=============================================================================
  # Effects upon a Pokémon entering battle
  #=============================================================================
  # Called at the start of battle only.
  def pbOnActiveAll
	# Neutralizing Gas activates before anything. 
	pbPriorityNeutralizingGas
	# Weather-inducing abilities, Trace, Imposter, etc.
	pbCalculatePriority(true)
	pbPriority(true).each { |b| b.pbEffectsOnSwitchIn(true) }
	pbCalculatePriority
	# Check forms are correct
	eachBattler { |b| b.pbCheckForm }
  end
  
  # Called at the start of battle only; Neutralizing Gas activates before anything. 
  def pbPriorityNeutralizingGas
    eachBattler {|b|
      next if !b || b.fainted?
      # neutralizing gas can be blocked with gastro acid, ending the effect.
      if b.ability == :NEUTRALIZINGGAS && !b.effects[PBEffects::GastroAcid]
        BattleHandlers.triggerAbilityOnSwitchIn(:NEUTRALIZINGGAS,b,self)
		return 
      end
    }
  end 

	def pbPursuit(idxSwitcher)
		@switching = true
		pbPriority.each do |b|
		  next if b.fainted? || !b.opposes?(idxSwitcher)   # Shouldn't hit an ally
		  next if b.movedThisRound? || !pbChoseMoveFunctionCode?(b.index,"088")   # Pursuit
		  # Check whether Pursuit can be used
		  next unless pbMoveCanTarget?(b.index,idxSwitcher,@choices[b.index][2].pbTarget(b))
		  next unless pbCanChooseMove?(b.index,@choices[b.index][1],false)
		  next if b.status == :SLEEP
		  next if b.effects[PBEffects::SkyDrop]>=0
		  next if b.hasActiveAbility?(:TRUANT) && b.effects[PBEffects::Truant]
		  # Mega Evolve
		  if !wildBattle? || !b.opposes?
			owner = pbGetOwnerIndexFromBattlerIndex(b.index)
			pbMegaEvolve(b.index) if @megaEvolution[b.idxOwnSide][owner]==b.index
		  end
		  # Use Pursuit
		  @choices[b.index][3] = idxSwitcher   # Change Pursuit's target
		  if b.pbProcessTurn(@choices[b.index],false)
			b.effects[PBEffects::Pursuit] = true
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
	
	# Called when a Pokémon switches in (entry effects, entry hazards).
  def pbOnActiveOne(battler)
    return false if battler.fainted?
    # Introduce Shadow Pokémon
    if battler.opposes? && battler.shadowPokemon?
      pbCommonAnimation("Shadow",battler)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!"))
    end
    # Record money-doubling effect of Amulet Coin/Luck Incense
    if !battler.opposes? && [:AMULETCOIN, :LUCKINCENSE].include?(battler.item_id)
      @field.effects[PBEffects::AmuletCoin] = true
    end
	# Record money-doubling effect of Fortune ability
    if !battler.opposes? && battler.hasActiveAbility?(:FORTUNE)
      @field.effects[PBEffects::Fortune] = true
    end
    # Update battlers' participants (who will gain Exp/EVs when a battler faints)
    eachBattler { |b| b.pbUpdateParticipants }
    # Healing Wish
    if @positions[battler.index].effects[PBEffects::HealingWish]
      pbCommonAnimation("HealingWish",battler)
      pbDisplay(_INTL("The healing wish came true for {1}!",battler.pbThis(true)))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      @positions[battler.index].effects[PBEffects::HealingWish] = false
    end
    # Lunar Dance
    if @positions[battler.index].effects[PBEffects::LunarDance]
      pbCommonAnimation("LunarDance",battler)
      pbDisplay(_INTL("{1} became cloaked in mystical moonlight!",battler.pbThis))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      battler.eachMove { |m| m.pp = m.total_pp }
      @positions[battler.index].effects[PBEffects::LunarDance] = false
    end
    # Entry hazards
    # Stealth Rock
    if battler.pbOwnSide.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:ROCK)
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:ROCK, bTypes[0], bTypes[1], bTypes[2])
      if !Effectiveness.ineffective?(eff)
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    # Spikes
    if battler.pbOwnSide.effects[PBEffects::Spikes]>0 && battler.takesIndirectDamage? &&
       !battler.airborne?
      spikesDiv = [8,6,4][battler.pbOwnSide.effects[PBEffects::Spikes]-1]
      oldHP = battler.hp
      battler.pbReduceHP(battler.totalhp/spikesDiv,false)
      pbDisplay(_INTL("{1} is hurt by the spikes!",battler.pbThis))
      battler.pbItemHPHealCheck
      if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
        return pbOnActiveOne(battler)   # For replacement battler
      end
    end
    # Toxic Spikes
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 && !battler.fainted? &&
       !battler.airborne?
      if battler.pbHasType?(:POISON)
        battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the poison spikes!",battler.pbThis))
      elsif battler.pbCanPoison?(nil,false)
        if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
          battler.pbPoison(nil,_INTL("{1} was toxified by the poison spikes!",battler.pbThis),true)
        else
          battler.pbPoison(nil,_INTL("{1} was poisoned by the poison spikes!",battler.pbThis))
        end
      end
    end
    # Sticky Web
    if battler.pbOwnSide.effects[PBEffects::StickyWeb] && !battler.fainted? &&
       !battler.airborne?
      pbDisplay(_INTL("{1} was caught in a sticky web!",battler.pbThis))
      if battler.pbCanLowerStatStage?(:SPEED)
        battler.pbLowerStatStage(:SPEED,1,nil)
        battler.pbItemStatRestoreCheck
      end
    end
	# Proudfire and similar abilities
    if battler.battle.turnCount > 0
      battler.battle.eachOtherSideBattler(battler.index) do |enemy|
		  if enemy.abilityActive?
			BattleHandlers.triggerAbilityOnEnemySwitchIn(enemy.ability,battler,enemy,battler.battle)
		  end
	  end
    end
    # Battler faints if it is knocked out because of an entry hazard above
    if battler.fainted?
      battler.pbFaint
      pbGainExp
      pbJudge
      return false
    end
    battler.pbCheckForm
    return true
  end
  
  #=============================================================================
  # Attack phase
  #=============================================================================
  def pbAttackPhase
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
	  b.effects[PBEffects::Enlightened] = false if !pbChoseMoveFunctionCode?(i,"515")   # Rage
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
    pbAttackPhaseMoves
  end
end