class PokeBattle_Battle
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
    return true if @battlers[idxBattler].fainted?
    return !pbIsTrapped?(idxBattler,partyScene)
  end
  
  def pbIsTrapped?(idxBattler,partyScene=nil)
	  battler = @battlers[idxBattler]
	  # Ability effects that allow switching no matter what
    if battler.abilityActive?
      if BattleHandlers.triggerCertainSwitchingUserAbility(battler.ability,battler,self)
        return false
      end
    end
	  # Item effects that allow switching no matter what
    if battler.itemActive?
      if BattleHandlers.triggerCertainSwitchingUserItem(battler.item,battler,self)
        return false
      end
    end
	  # Other certain switching effects
    if battler.effects[PBEffects::OctolockUser]>=0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return true
    end
    if battler.effects[PBEffects::Trapping]>0 ||
       battler.effects[PBEffects::MeanLook]>=0 ||
       battler.effects[PBEffects::Ingrain] ||
       battler.effects[PBEffects::GivingDragonRideTo] != -1 ||
       @field.effects[PBEffects::FairyLock]>0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return true
    end
    # Trapping abilities/items
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.abilityActive?
      if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.abilityName)) if partyScene
        return true
      end
    end
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.itemActive?
      if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.itemName)) if partyScene
        return true
      end
    end
	return false
  end


  #=============================================================================
  # Switching Pokémon
  #=============================================================================
  # General switching method that checks if any Pokémon need to be sent out and,
  # if so, does. Called at the end of each round.
  def pbEORSwitch(favorDraws=false)
    return if @decision > 0 && !favorDraws
    return if @decision == 5 && favorDraws
    pbJudge
    return if @decision>0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      @battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          next if wildBattle? && opposes?(idxBattler)   # Wild Pokémon can't switch
          idxPartyNew = pbSwitchInBetween(idxBattler)
          pbRecallAndReplace(idxBattler,idxPartyNew)
          switched.push(idxBattler)
        elsif trainerBattle? || bossBattle?   # Player switches in in a trainer battle or boss battle
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
          switched.push(idxBattler)
		    else # Player's Pokémon has fainted in a wild battle
          switch = false
          if !bossBattle? && !pbDisplayConfirm(_INTL("Use next Pokémon?"))
            switch = (pbRun(idxBattler,true)<=0)
          else
            switch = true
          end
          if switch
            idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
            pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
            switched.push(idxBattler)
          end
        end
      end
      break if switched.length==0
      pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if switched.include?(b.index)
      end
    end
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
  # Effects upon a Pokémon entering battle
  #=============================================================================
  # Called at the start of battle only.
  def pbOnActiveAll
    # Neutralizing Gas activates before anything. 
    pbPriorityNeutralizingGas
    # Weather-inducing abilities, Trace, Imposter, etc.
    pbCalculatePriority(true)
    pbPriority(true).each do |b|
      b.pbEffectsOnSwitchIn(true)
      triggerBattlerEnterDialogue(b)
    end
    pbCalculatePriority
    # Check forms are correct
    eachBattler { |b| b.pbCheckForm }
  end

  def getStealthRockHPRatio(type1,type2=nil,type3=nil)
    eff = Effectiveness.calculate(:ROCK,type1,type2,type3)
    effectivenessMult = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
    return effectivenessMult / 8.0
  end
  
  # Called when a Pokémon switches in (entry effects, entry hazards).
  def pbOnActiveOne(battler)
    return false if battler.fainted?
    # Introduce Shadow Pokémon
    if battler.opposes? && battler.shadowPokemon?
      pbCommonAnimation("Shadow",battler)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!"))
    end
    # Trigger enter the field curses
    curses.each do |curse|
      triggerBattlerEnterCurseEffect(curse,battler,self)
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
      healingMessage = _INTL("The healing wish came true for {1}!",battler.pbThis(true))
      battler.pbRecoverHP(battler.totalhp,true,true,true,healingMessage)
      battler.pbCureStatus(false)
      @positions[battler.index].effects[PBEffects::HealingWish] = false
    end
    # Lunar Dance
    if @positions[battler.index].effects[PBEffects::LunarDance]
      pbCommonAnimation("LunarDance",battler)
      healingMessage = _INTL("{1} became cloaked in mystical moonlight!",battler.pbThis)
      battler.pbRecoverHP(battler.totalhp,true,true,true,healingMessage)
      battler.pbCureStatus(false)
      battler.eachMove { |m| m.pp = m.total_pp }
      @positions[battler.index].effects[PBEffects::LunarDance] = false
    end
    # Refuge
    if @positions[battler.index].effects[PBEffects::Refuge] && battler.hasAnyStatusNoTrigger()
      pbCommonAnimation("HealingWish",battler)
      refugeMaker = pbThisEx(battler.index,@positions[battler.index].effects[PBEffects::RefugeMaker])
      pbDisplay(_INTL("{1} refuge comforts {2}!",refugeMaker,battler.pbThis(true)))
      battler.pbCureStatus()
      @positions[battler.index].effects[PBEffects::Refuge] = false
      @positions[battler.index].effects[PBEffects::RefugeMaker] = -1
    end
    # Entry hazards
    # Stealth Rock
    if battler.pbOwnSide.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? && !battler.immuneToHazards? && GameData::Type.exists?(:ROCK)
      bTypes = battler.pbTypes(true)
      stealthRockHPRatio = getStealthRockHPRatio(bTypes[0], bTypes[1], bTypes[2])
      if stealthRockHPRatio > 0
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis(true)))
        if battler.applyFractionalDamage(stealthRockHPRatio,true,false,true)
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    # Spikes
    if battler.pbOwnSide.effects[PBEffects::Spikes] > 0 && battler.takesIndirectDamage? && !battler.immuneToHazards? && !battler.airborne?
      spikesIndex = battler.pbOwnSide.effects[PBEffects::Spikes] - 1
      spikesDiv = [8,6,4][spikesIndex]
      spikesHPRatio = 1.0 / spikesDiv.to_f
      layerLabel = ["layer","2 layers","3 layers"][spikesIndex]
      pbDisplay(_INTL("{1} is hurt by the {2} of spikes!",battler.pbThis,layerLabel))
      battler.pbItemHPHealCheck
      if battler.applyFractionalDamage(spikesHPRatio,true,false,true)
        return pbOnActiveOne(battler)   # For replacement battler
      end
    end
    # Poison Spikes
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 && !battler.fainted? && !battler.immuneToHazards? && !battler.airborne?
      if battler.pbHasType?(:POISON)
        battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the poison spikes!",battler.pbThis))
      elsif battler.pbCanPoison?(nil,false)
        if battler.pbOwnSide.effects[PBEffects::ToxicSpikes] >= 2
          battler.pbPoison(nil,_INTL("{1} was poisoned by the poison spikes!",battler.pbThis))
        else
          pbDisplay(_INTL("{1} was hurt by the thin layer of poison spikes!",battler.pbThis))
          if battler.applyFractionalDamage(1.0/16.0,true,false,true)
            return pbOnActiveOne(battler)   # For replacement battler
          end
        end
      else
        pbDisplay(_INTL("{1} was unaffected by the poison spikes.",battler.pbThis))
      end
    end
	  # Flame Spikes
    if battler.pbOwnSide.effects[PBEffects::FlameSpikes] > 0 && !battler.fainted? && !battler.immuneToHazards? && !battler.airborne?
      if battler.pbHasType?(:FIRE)
        battler.pbOwnSide.effects[PBEffects::FlameSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the flame spikes!",battler.pbThis))
      elsif battler.pbCanBurn?(nil,false)
        if battler.pbOwnSide.effects[PBEffects::FlameSpikes] >= 2
          battler.pbBurn(nil,_INTL("{1} was burned by the flame spikes!",battler.pbThis))
        else
          pbDisplay(_INTL("{1} was hurt by the thin layer of flame spikes!",battler.pbThis))
          if battler.applyFractionalDamage(1.0/16.0,true,false,true)
            return pbOnActiveOne(battler)   # For replacement battler
          end
        end
      else
        pbDisplay(_INTL("{1} was unaffected by the flame spikes.",battler.pbThis))
      end
    end
    # Frost Spikes
    if battler.pbOwnSide.effects[PBEffects::FrostSpikes] > 0 && !battler.fainted? && !battler.immuneToHazards? && !battler.airborne?
      if battler.pbHasType?(:ICE)
        battler.pbOwnSide.effects[PBEffects::FrostSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the frost spikes!",battler.pbThis))
      elsif battler.pbCanFrostbite?(nil,false)
        if battler.pbOwnSide.effects[PBEffects::FrostSpikes] >= 2
          battler.pbFrostbite(nil,_INTL("{1} was frostbitten by the frost spikes!",battler.pbThis))
        else
          pbDisplay(_INTL("{1} was hurt by the thin layer of frost spikes!",battler.pbThis))
          if battler.applyFractionalDamage(1.0/16.0,true,false,true)
            return pbOnActiveOne(battler)   # For replacement battler
          end
        end
      else
        pbDisplay(_INTL("{1} was unaffected by the frost spikes.",battler.pbThis))
      end
   end
    # Sticky Web
    if battler.pbOwnSide.effects[PBEffects::StickyWeb] && !battler.fainted? && !battler.immuneToHazards? && !battler.airborne?
      pbDisplay(_INTL("{1} was caught in a sticky web!",battler.pbThis))
      if battler.pbCanLowerStatStage?(:SPEED)
        battler.pbLowerStatStage(:SPEED,1,nil)
        battler.pbItemStatRestoreCheck
      end
    end
	  # Proudfire and similar abilities
    if @turnCount > 0
      eachOtherSideBattler(battler.index) do |enemy|
        if enemy.abilityActive?
          BattleHandlers.triggerAbilityOnEnemySwitchIn(enemy.ability,battler,enemy,self)
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
	  triggerBattlerEnterDialogue(battler)
    return true
  end
end
