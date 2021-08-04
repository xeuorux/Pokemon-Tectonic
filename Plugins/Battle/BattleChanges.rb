class PokeBattle_Battle
	attr_accessor :ballsUsed       # Number of balls thrown without capture
	attr_accessor :messagesBlocked
	attr_accessor :commandPhasesThisRound
	attr_accessor :battleAI
	
  #=============================================================================
  # Creating the battle class
  #=============================================================================
  def initialize(scene,p1,p2,player,opponent)
    if p1.length==0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
    elsif p2.length==0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
    end
    @scene             = scene
    @peer              = PokeBattle_BattlePeer.create
    @battleAI          = PokeBattle_AI.new(self)
    @field             = PokeBattle_ActiveField.new    # Whole field (gravity/rooms)
    @sides             = [PokeBattle_ActiveSide.new,   # Player's side
                          PokeBattle_ActiveSide.new]   # Foe's side
    @positions         = []                            # Battler positions
    @battlers          = []
    @sideSizes         = [1,1]   # Single battle, 1v1
    @backdrop          = ""
    @backdropBase      = nil
    @time              = 0
    @environment       = :None   # e.g. Tall grass, cave, still water
    @turnCount         = 0
    @decision          = 0
    @caughtPokemon     = []
    player   = [player] if !player.nil? && !player.is_a?(Array)
    opponent = [opponent] if !opponent.nil? && !opponent.is_a?(Array)
    @player            = player     # Array of Player/NPCTrainer objects, or nil
    @opponent          = opponent   # Array of NPCTrainer objects, or nil
    @items             = nil
    @endSpeeches       = []
    @endSpeechesWin    = []
    @party1            = p1
    @party2            = p2
    @party1order       = Array.new(@party1.length) { |i| i }
    @party2order       = Array.new(@party2.length) { |i| i }
    @party1starts      = [0]
    @party2starts      = [0]
    @internalBattle    = true
    @debug             = false
    @canRun            = true
    @canLose           = false
    @switchStyle       = true
    @showAnims         = true
    @controlPlayer     = false
    @expGain           = true
    @moneyGain         = true
    @rules             = {}
    @priority          = []
    @priorityTrickRoom = false
    @choices           = []
    @megaEvolution     = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @initialItems      = [
       Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item_id : nil },
       Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item_id : nil }
    ]
    @recycleItems      = [Array.new(@party1.length, nil),   Array.new(@party2.length, nil)]
    @belch             = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @battleBond        = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @usedInBattle      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @successStates     = []
    @lastMoveUsed      = nil
    @lastMoveUser      = -1
    @switching         = false
    @futureSight       = false
    @endOfRound        = false
    @moldBreaker       = false
    @runCommand        = 0
    @nextPickupUse     = 0
	@ballsUsed		   = 0
	@messagesBlocked   = false
	@commandPhasesThisRound = 0
    if GameData::Move.exists?(:STRUGGLE)
      @struggle = PokeBattle_Move.from_pokemon_move(self, Pokemon::Move.new(:STRUGGLE))
    else
      @struggle = PokeBattle_Struggle.new(self, nil)
    end
  end
  
  def pbCheckNeutralizingGas(battler=nil)
    # Battler = the battler to switch out. 
	# Should be specified when called from pbAttackPhaseSwitch
	# Should be nil when called from pbEndOfRoundPhase
    return if !@field.effects[PBEffects::NeutralizingGas]
    return if battler && (battler.ability != :NEUTRALIZINGGAS || 
		battler.effects[PBEffects::GastroAcid])
    hasabil=false
    eachBattler {|b|
      next if !b || b.fainted?
	  next if battler && b.index == battler.index 
	  # if specified, the battler will switch out, so don't consider it.
      # neutralizing gas can be blocked with gastro acid, ending the effect.
      if b.ability == :NEUTRALIZINGGAS && !b.effects[PBEffects::GastroAcid]
        hasabil=true; break
      end
    }
    if !hasabil
      @field.effects[PBEffects::NeutralizingGas] = false
      pbPriority(true).each { |b| 
	    next if battler && b.index == battler.index
	    b.pbEffectsOnSwitchIn
	  }
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
	# Proudfire
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
	
	# Check whether the currently active Pokémon (at battler index idxBattler) can
  # switch out (and that its replacement at party index idxParty can switch in).
  # NOTE: Messages are only shown while in the party screen when choosing a
  #       command for the next round.
  def pbCanSwitch?(idxBattler,idxParty=-1,partyScene=nil)
    # Check whether party Pokémon can switch in
    return false if !pbCanSwitchLax?(idxBattler,idxParty,partyScene)
    # Make sure another battler isn't already choosing to switch to the party
    # Pokémon
    eachSameSideBattler(idxBattler) do |b|
      next if choices[b.index][0]!=:SwitchOut || choices[b.index][1]!=idxParty
      partyScene.pbDisplay(_INTL("{1} has already been selected.",
         pbParty(idxBattler)[idxParty].name)) if partyScene
      return false
    end
    # Check whether battler can switch out
    battler = @battlers[idxBattler]
    return true if battler.fainted?
    # Ability/item effects that allow switching no matter what
    if battler.abilityActive?
      if BattleHandlers.triggerCertainSwitchingUserAbility(battler.ability,battler,self)
        return true
      end
    end
    if battler.itemActive?
      if BattleHandlers.triggerCertainSwitchingUserItem(battler.item,battler,self)
        return true
      end
    end
    #return true if Settings::MORE_TYPE_EFFECTS && battler.pbHasType?(:GHOST)
	
	# Other certain switching effects
    if battler.effects[PBEffects::OctolockUser]>=0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return false
    end
    if battler.effects[PBEffects::Trapping]>0 ||
       battler.effects[PBEffects::MeanLook]>=0 ||
       battler.effects[PBEffects::Ingrain] ||
       @field.effects[PBEffects::FairyLock]>0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return false
    end
    # Trapping abilities/items
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.abilityActive?
      if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.abilityName)) if partyScene
        return false
      end
    end
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.itemActive?
      if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.itemName)) if partyScene
        return false
      end
    end
    return true
  end
  
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
  
  #=============================================================================
  # Messages and animations
  #=============================================================================
  def pbDisplay(msg,&block)
    @scene.pbDisplayMessage(msg,&block) if !messagesBlocked
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg,true) if !messagesBlocked
  end

  def pbDisplayPaused(msg,&block)
    @scene.pbDisplayPausedMessage(msg,&block) if !messagesBlocked
  end

  def pbDisplayConfirm(msg)
    return @scene.pbDisplayConfirmMessage(msg) if !messagesBlocked
  end
  
  def pbCanMegaEvolve?(idxBattler)
    return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    return false if !@battlers[idxBattler].hasMega?
    return false if wildBattle? && opposes?(idxBattler) && !@battlers[idxBattler].boss
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
    return false if !pbHasMegaRing?(idxBattler) && !@battlers[idxBattler].boss
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==-1
  end
end

class PokeBattle_Move
	# Checks whether the move should have modified priority
	def priorityModification(user,target); return 0; end
	
	# Returns whether the move will be a critical hit.
	def pbIsCritical?(user,target)
		return false if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
		# Set up the critical hit ratios
		ratios = [16,8,4,2,1]
		c = 0
		# Ability effects that alter critical hit rate
		if c>=0 && user.abilityActive?
		  c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
		end
		if c>=0 && target.abilityActive? && !@battle.moldBreaker
		  c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
		end
		# Item effects that alter critical hit rate
		if c>=0 && user.itemActive?
		  c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
		end
		if c>=0 && target.itemActive?
		  c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
		end
		return false if c<0
		# Move-specific "always/never a critical hit" effects
		case pbCritialOverride(user,target)
		when 1  then return true
		when -1 then return false
		end
		# Other effects
		return true if c>50   # Merciless
		return true if user.effects[PBEffects::LaserFocus]>0
		c += 1 if highCriticalRate?
		c += user.effects[PBEffects::FocusEnergy]
		c += 1 if user.effects[PBEffects::LuckyStar]
		c += 1 if user.inHyperMode? && @type == :SHADOW
		c = ratios.length-1 if c>=ratios.length
		# Calculation
		return @battle.pbRandom(ratios[c])==0
    end
  
  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
	return 0 if target.effects[PBEffects::Enlightened]
    ret = (effectChance>0) ? effectChance : @addlEffect
    if Settings::MECHANICS_GENERATION >= 6 || @function != "0A4"   # Secret Power
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                  user.pbOwnSide.effects[PBEffects::Rainbow]>0
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end
  
  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user,target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
	return 0 if target.effects[PBEffects::Enlightened]
    ret = 0
    if user.hasActiveAbility?(:STENCH,true)
      ret = 10
    elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow]>0
    return ret
  end
  
  def pbGetAttackStats(user,target)
    if specialMove? || (user.hasActiveAbility?(:MYSTICFIST) && punchingMove?)
      return user.spatk, user.stages[:SPECIAL_ATTACK]+6
    end
    return user.attack, user.stages[:ATTACK]+6
  end

  def pbGetDefenseStats(user,target)
    if specialMove? || (user.hasActiveAbility?(:MYSTICFIST) && punchingMove?)
      return target.spdef, target.stages[:SPECIAL_DEFENSE]+6
    end
    return target.defense, target.stages[:DEFENSE]+6
  end
  
  def pbCalcDamage(user,target,numTargets=1)
    return if statusMove?
    if target.damageState.disguise
      target.damageState.calcDamage = 1
      return
    end
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    # Get the move's type
    type = @calcType   # nil is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user,target)
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@baseDamage,user,target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user,target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = 6 if target.damageState.critical && atkStage<6
	  calc = stageMul[atkStage].to_f/stageDiv[atkStage].to_f
	  calc = (calc.to_f + 1.0)/2.0 if user.boss
      atk = (atk.to_f*calc).floor
    end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user,target)
    if !user.hasActiveAbility?(:UNAWARE)
      defStage = 6 if target.damageState.critical && defStage>6
	  defStage = 6 if user.hasActiveAbility?(:INFILTRATOR) && defStage>6
	  calc = stageMul[defStage].to_f/stageDiv[defStage].to_f
	  calc = (calc.to_f + 1.0)/2.0 if target.boss
      defense = (defense.to_f*calc).floor
    end
    # Calculate all multiplier effects
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
    target.damageState.calcDamage = damage
  end

  
	def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
		# Global abilities
		if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
		   (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
		  if @battle.pbCheckGlobalAbility(:AURABREAK)
			multipliers[:base_damage_multiplier] *= 2 / 3.0
		  else
			multipliers[:base_damage_multiplier] *= 4 / 3.0
		  end
		end
		# Ability effects that alter damage
		if user.abilityActive?
		  BattleHandlers.triggerDamageCalcUserAbility(user.ability,
			 user,target,self,multipliers,baseDmg,type)
		end
		if !@battle.moldBreaker
		  # NOTE: It's odd that the user's Mold Breaker prevents its partner's
		  #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
		  #       how it works.
		  user.eachAlly do |b|
			next if !b.abilityActive?
			BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
			   user,target,self,multipliers,baseDmg,type)
		  end
		  if target.abilityActive?
			BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
			   user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
			BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
			   user,target,self,multipliers,baseDmg,type)
		  end
		  target.eachAlly do |b|
			next if !b.abilityActive?
			BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
			   user,target,self,multipliers,baseDmg,type)
		  end
		end
		# Item effects that alter damage
		if user.itemActive?
		  BattleHandlers.triggerDamageCalcUserItem(user.item,
			 user,target,self,multipliers,baseDmg,type)
		end
		if target.itemActive?
		  BattleHandlers.triggerDamageCalcTargetItem(target.item,
			 user,target,self,multipliers,baseDmg,type)
		end
		# Parental Bond's second attack
		if user.effects[PBEffects::ParentalBond]==1
		  multipliers[:base_damage_multiplier] /= 4
		end
		# Other
		if user.effects[PBEffects::MeFirst]
		  multipliers[:base_damage_multiplier] *= 1.5
		end
		if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
		  multipliers[:base_damage_multiplier] *= 1.5
		end
		if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
		  multipliers[:base_damage_multiplier] *= 2
		end
		# Mud Sport
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
		# Water Sport
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
		# Terrain moves
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
		# Multi-targeting attacks
		if numTargets>1
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
		  if target.pbHasType?(:ROCK) && specialMove? && @function != "122"   # Psyshock
			multipliers[:defense_multiplier] *= 1.5
		  end
		when :Hail
		  if target.pbHasType?(:ICE) && physicalMove?
			multipliers[:defense_multiplier] *= 1.5
		  end
		end
		# Critical hits
		if target.damageState.critical
		  if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
			multipliers[:final_damage_multiplier] *= 1.5
		  else
			multipliers[:final_damage_multiplier] *= 2
		  end
		end
		
		# STAB
		if type && user.pbHasType?(type)
		  stab = 1
		  if (user.pbTypes(true).length > 1)
			stab = 4.0/3.0
		  else
			stab = 1.5
		  end
		  
		  if user.hasActiveAbility?(:ADAPTED)
			stab *= 4.0/3.0
		  end
		  
		  multipliers[:final_damage_multiplier] *= stab
		end
		
		# Type effectiveness
		typeEffect = target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
		typeEffect = ((typeEffect+1.0)/2.0) if target.boss || user.boss
		multipliers[:final_damage_multiplier] *= typeEffect
		# Burn
		if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
		   !user.hasActiveAbility?(:GUTS)
		  if !user.boss
			multipliers[:final_damage_multiplier] *= 2.0/3.0
		  else
			multipliers[:final_damage_multiplier] *= 4.0/5.0
		  end
		end
		# Poison
		if user.status == :POISON && user.statusCount == 0 && specialMove? && damageReducedByBurn? &&
		   !user.hasActiveAbility?(:AUDACITY)
		  if !user.boss
			multipliers[:final_damage_multiplier] *= 2.0/3.0
		  else
			multipliers[:final_damage_multiplier] *= 4.0/5.0
		  end
		end
		# Chill
		if target.status == :FROZEN
		  if !target.boss
			multipliers[:final_damage_multiplier] *= 4.0/3.0
		  else
			multipliers[:final_damage_multiplier] *= 5.0/4.0
		  end
		end
		# Aurora Veil, Reflect, Light Screen
		if !ignoresReflect? && !target.damageState.critical &&
		   !user.hasActiveAbility?(:INFILTRATOR)
		  if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
			if @battle.pbSideBattlerCount(target)>1
			  multipliers[:final_damage_multiplier] *= 2 / 3.0
			else
			  multipliers[:final_damage_multiplier] /= 2
			end
		  elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
			if @battle.pbSideBattlerCount(target)>1
			  multipliers[:final_damage_multiplier] *= 2 / 3.0
			else
			  multipliers[:final_damage_multiplier] /= 2
			end
		  elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
			if @battle.pbSideBattlerCount(target) > 1
			  multipliers[:final_damage_multiplier] *= 2 / 3.0
			else
			  multipliers[:final_damage_multiplier] /= 2
			end
		  end
		end
		# Minimize
		if target.effects[PBEffects::Minimize] && tramplesMinimize?(2)
		  multipliers[:final_damage_multiplier] *= 2
		end
		# Move-specific base damage modifiers
		multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
		# Move-specific final damage modifiers
		multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
    end
  
  #=============================================================================
  # Type effectiveness calculation
  #=============================================================================
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = Effectiveness.calculate_one(moveType, defType)
    # Ring Target
    if target.hasActiveItem?(:RINGTARGET)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.ineffective_type?(moveType, defType)
    end
    # Foresight
    if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Miracle Eye
    if target.effects[PBEffects::MiracleEye]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
	#Creep Out
	if target.effects[PBEffects::CreepOut]
		ret *= 2 if moveType == :BUG
	end
    # Delta Stream's weather
    if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne?
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING && moveType == :GROUND
    end
	
	# Inured
	if target.effects[PBEffects::Inured]
		ret /= 2 if Effectiveness.super_effective_type?(moveType, defType)
	end
	
	# Tar Shot
	if target.effects[PBEffects::TarShot] && moveType == :FIRE
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if Effectiveness.normal_type?(moveType,target.type1,target.type2)
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.not_very_effective_type?(moveType,target.type1,target.type2)
    end
	
	# Corrosion
	if user.hasActiveAbility?(:CORROSION)
		ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :STEEL && Effectiveness.ineffective_type?(moveType, defType)
	end
	
    return ret
  end
  
  # Accuracy calculations for one-hit KO moves and "always hit" moves are
  # handled elsewhere.
  def pbAccuracyCheck(user,target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis]>0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
    baseAcc = pbBaseAccuracy(user,target)
    return true if baseAcc==0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user,target,modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage].to_f / stageDiv[accStage].to_f
    evasion  = 100.0 * stageMul[evaStage].to_f / stageDiv[evaStage].to_f
    accuracy = (accuracy.to_f * modifiers[:accuracy_multiplier].to_f).round
    evasion  = (evasion.to_f  * modifiers[:evasion_multiplier].to_f).round
    evasion = 1 if evasion < 1
    # Calculation
	calc = accuracy.to_f / evasion.to_f
    if user.boss || target.boss
      calc = (calc.to_f + 1.0) / 2.0
    end
    return @battle.pbRandom(100) < modifiers[:base_accuracy] * calc
  end
end

# Sets up various battle parameters and applies special rules.
def pbPrepareBattle(battle)
  battleRules = $PokemonTemp.battleRules
  # The size of the battle, i.e. how many Pokémon on each side (default: "single")
  battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
  # Whether the game won't black out even if the player loses (default: false)
  battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
  # Whether the player can choose to run from the battle (default: true)
  battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
  # Whether wild Pokémon always try to run from battle (default: nil)
  battle.rules["alwaysflee"] = battleRules["roamerFlees"]
  # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
  battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
  # Whether the player gains/loses money at the end of the battle (default: true)
  battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
  # Whether the player is able to switch when an opponent's Pokémon faints
  battle.switchStyle = false
  # Whether battle animations are shown
  battle.showAnims = ($PokemonSystem.battlescene==0)
  battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
  # Terrain
  battle.defaultTerrain = battleRules["defaultTerrain"] if !battleRules["defaultTerrain"].nil?
  # Weather
  if battleRules["defaultWeather"].nil?
    case GameData::Weather.get($game_screen.weather_type).category
    when :Rain
      battle.defaultWeather = :Rain
    when :Hail
      battle.defaultWeather = :Hail
    when :Sandstorm
      battle.defaultWeather = :Sandstorm
    when :Sun
      battle.defaultWeather = :Sun
    end
  else
    battle.defaultWeather = battleRules["defaultWeather"]
  end
  # Environment
  if battleRules["environment"].nil?
    battle.environment = pbGetEnvironment
  else
    battle.environment = battleRules["environment"]
  end
  # Backdrop graphic filename
  if !battleRules["backdrop"].nil?
    backdrop = battleRules["backdrop"]
  elsif $PokemonGlobal.nextBattleBack
    backdrop = $PokemonGlobal.nextBattleBack
  elsif $PokemonGlobal.surfing
    backdrop = "water"   # This applies wherever you are, including in caves
  elsif GameData::MapMetadata.exists?($game_map.map_id)
    back = GameData::MapMetadata.get($game_map.map_id).battle_background
    backdrop = back if back && back != ""
  end
  backdrop = "indoor1" if !backdrop
  battle.backdrop = backdrop
  # Choose a name for bases depending on environment
  if battleRules["base"].nil?
    environment_data = GameData::Environment.try_get(battle.environment)
    base = environment_data.battle_base if environment_data
  else
    base = battleRules["base"]
  end
  battle.backdropBase = base if base
  # Time of day
  if GameData::MapMetadata.exists?($game_map.map_id) &&
     GameData::MapMetadata.get($game_map.map_id).battle_environment == :Cave
    battle.time = 2   # This makes Dusk Balls work properly in caves
  elsif Settings::TIME_SHADING
    timeNow = pbGetTimeNow
    if PBDayNight.isNight?(timeNow);      battle.time = 2
    elsif PBDayNight.isEvening?(timeNow); battle.time = 1
    else;                                 battle.time = 0
    end
  end
end