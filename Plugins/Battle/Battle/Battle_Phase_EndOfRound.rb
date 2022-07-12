class PokeBattle_Battle
	#=============================================================================
	# Decrement effect counters
	#=============================================================================
  def pbEORCountDownFieldEffect(effect,msg)
    if @field.effects[effect]>0
      @field.effects[effect] -= 1
      if @field.effects[effect]==0
        pbDisplay(msg)
        if effect==PBEffects::MagicRoom
          pbPriority(true).each { |b| b.pbItemTerrainStatBoostCheck }
		  pbPriority(true).each { |b| b.pbItemFieldEffectCheck }
        end
      end
    end
  end

  #=============================================================================
  # End Of Round phase
  #=============================================================================
  def pbEndOfRoundPhase
    PBDebug.log("")
    PBDebug.log("[End of round]")
    @endOfRound = true
    @scene.pbBeginEndOfRoundPhase
    pbCalculatePriority           # recalculate speeds
    priority = pbPriority(true)   # in order of fastest -> slowest speeds only

    pbEORWeather(priority)

    processForetoldMovesEOR()
    
    pbEORHealing(priority)

    pbEORDamage(priority)

	  # Octolock
    priority.each do |b|
      next if !b.effects[PBEffects::Octolock]
	    octouser = @battlers[b.effects[PBEffects::OctolockUser]]
      if b.pbCanLowerStatStage?(:DEFENSE,octouser,self)
        b.pbLowerStatStage(:DEFENSE,1,octouser,true,false,true)
      end
      if b.pbCanLowerStatStage?(:SPECIAL_DEFENSE,octouser,self)
        b.pbLowerStatStage(:SPECIAL_DEFENSE,1,octouser,true,false,true)
      end
    end

    processTrappingDOTs(priority)
    
    countDownBattlerEffects(priority)

    countDownPerishSong(priority)

    # Check for end of battle
    if @decision > 0
      pbGainExp
      return
    end

    countDownSideEffects()

    countDownFieldEffects()
    
    # End of terrains
    pbEORTerrain

    processTriggersEOR(priority)

    pbGainExp

    return if @decision > 0

    # Form checks
    priority.each { |b| b.pbCheckForm(true) }

    # Switch Pokémon in if possible
    pbEORSwitch
    return if @decision > 0

    # In battles with at least one side of size 3+, move battlers around if none
    # are near to any foes
    pbEORShiftDistantBattlers

    # Try to make Trace work, check for end of primordial weather
    priority.each { |b| b.pbContinualAbilityChecks }
    
    # Decrement or reset various effects that don't show messages when they leave
    processBattlerEffectsEOR()
    processSideEffectsEOR()
    processFieldEffectsEOR()
	
	  # Neutralizing Gas
	  pbCheckNeutralizingGas
	
    @endOfRound = false
  end

  #=============================================================================
  # End Of Round weather
  #=============================================================================
  def pbEORWeather(priority)
    PBDebug.log("[DEBUG] Counting down weathers")

    # NOTE: Primordial weather doesn't need to be checked here, because if it
    #       could wear off here, it will have worn off already.
    # Count down weather duration
    @field.weatherDuration -= 1 if @field.weatherDuration>0
    # Weather wears off
    if @field.weatherDuration==0
      case @field.weather
      when :Sun       then pbDisplay(_INTL("The sunlight faded."))
      when :Rain      then pbDisplay(_INTL("The rain stopped."))
      when :Sandstorm then pbDisplay(_INTL("The sandstorm subsided."))
      when :Hail      then pbDisplay(_INTL("The hail stopped."))
      when :ShadowSky then pbDisplay(_INTL("The shadow sky faded."))
      when :Sandstorm then pbDisplay(_INTL("The acid rain stopped."))
      when :Swarm     then pbDisplay(_INTL("The swarm dissipates."))
      end
      @field.weather = :None
      # Check for form changes caused by the weather changing
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil,@field.defaultWeather) if @field.defaultWeather != :None
      return if @field.weather == :None
    end
    # Weather continues
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    # Effects due to weather
    curWeather = pbWeather
    priority.each do |b|
      # Weather-related abilities
      if b.abilityActive?
        BattleHandlers.triggerEORWeatherAbility(b.ability,curWeather,b,self)
        b.pbFaint if b.fainted?
      end
      # Weather damage
      # NOTE:
      case curWeather
      when :Sandstorm
        next if !b.takesSandstormDamage?
        pbDisplay(_INTL("{1} is buffeted by the sandstorm!",b.pbThis))
		    reduction = b.totalhp/16
		    reduction *= 2 if !pbCheckGlobalAbility(:SHRAPNELSTORM).nil?
		    reduction /= 4 if b.boss?
		    b.damageState.displayedDamage = reduction
		    @scene.pbDamageAnimation(b)
        b.pbReduceHP(reduction,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Hail
        next if !b.takesHailDamage?
        pbDisplay(_INTL("{1} is buffeted by the hail!",b.pbThis))
        reduction = b.totalhp/16
	    	reduction *= 2 if !pbCheckGlobalAbility(:BITTERCOLD).nil?
		    reduction /= 4 if b.boss?
		    b.damageState.displayedDamage = reduction
		    @scene.pbDamageAnimation(b)
        b.pbReduceHP(reduction,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :ShadowSky
        next if !b.takesShadowSkyDamage?
        pbDisplay(_INTL("{1} is hurt by the shadow sky!",b.pbThis))
        reduction = b.totalhp/16
		    reduction /= 4 if b.boss?
		    b.damageState.displayedDamage = reduction
		    @scene.pbDamageAnimation(b)
        b.pbReduceHP(reduction,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :AcidRain
        if !b.takesAcidRainDamage?
          pbDisplay(_INTL("{1} is hurt by the acid rain!",b.pbThis))
          reduction = b.totalhp/16
          reduction /= 4 if b.boss?
          b.damageState.displayedDamage = reduction
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(reduction,false)
          b.pbItemHPHealCheck
          b.pbFaint if b.fainted?
        elsif b.pbHasType?(:POISON) || b.hasActiveAbility?(:POISONHEAL)
          pbDisplay(_INTL("{1} absorbs the acid rain!",b.pbThis))
          heal = b.totalhp/16
          heal /= 4 if b.boss?
          b.pbRecoverHP(heal,true)
        end
      end
    end
  end

  def processForetoldMovesEOR()
    PBDebug.log("[DEBUG] Counting down/using foretold moves")

    # Future Sight/Doom Desire
    @positions.each_with_index do |pos,idxPos|
      next if !pos || pos.effects[PBEffects::FutureSightCounter]==0
      pos.effects[PBEffects::FutureSightCounter] -= 1
      next if pos.effects[PBEffects::FutureSightCounter]>0
      next if !@battlers[idxPos] || @battlers[idxPos].fainted?   # No target
      moveUser = nil
      eachBattler do |b|
        next if b.opposes?(pos.effects[PBEffects::FutureSightUserIndex])
        next if b.pokemonIndex!=pos.effects[PBEffects::FutureSightUserPartyIndex]
        moveUser = b
        break
      end
      next if moveUser && moveUser.index==idxPos   # Target is the user
      if !moveUser   # User isn't in battle, get it from the party
        party = pbParty(pos.effects[PBEffects::FutureSightUserIndex])
        pkmn = party[pos.effects[PBEffects::FutureSightUserPartyIndex]]
        if pkmn && pkmn.able?
          moveUser = PokeBattle_Battler.new(self,pos.effects[PBEffects::FutureSightUserIndex])
          moveUser.pbInitDummyPokemon(pkmn,pos.effects[PBEffects::FutureSightUserPartyIndex])
        end
      end
      next if !moveUser   # User is fainted
      move = pos.effects[PBEffects::FutureSightMove]
      pbDisplay(_INTL("{1} took the {2} attack!",@battlers[idxPos].pbThis,
         GameData::Move.get(move).name))
      # NOTE: Future Sight failing against the target here doesn't count towards
      #       Stomping Tantrum.
      userLastMoveFailed = moveUser.lastMoveFailed
      @futureSight = true
      moveUser.pbUseMoveSimple(move,idxPos)
      @futureSight = false
      moveUser.lastMoveFailed = userLastMoveFailed
      @battlers[idxPos].pbFaint if @battlers[idxPos].fainted?
      pos.effects[PBEffects::FutureSightCounter]        = 0
      pos.effects[PBEffects::FutureSightMove]           = nil
      pos.effects[PBEffects::FutureSightUserIndex]      = -1
      pos.effects[PBEffects::FutureSightUserPartyIndex] = -1
    end
  end

  def pbEORHealing(priority)
    PBDebug.log("[DEBUG] Performing EoR healing effects")
    # Wish
    @positions.each_with_index do |pos,idxPos|
      next if !pos || pos.effects[PBEffects::Wish]==0
      pos.effects[PBEffects::Wish] -= 1
      next if pos.effects[PBEffects::Wish]>0
      next if !@battlers[idxPos] || !@battlers[idxPos].canHeal?
      wishMaker = pbThisEx(idxPos,pos.effects[PBEffects::WishMaker])
      @battlers[idxPos].pbRecoverHP(pos.effects[PBEffects::WishAmount])
      pbDisplay(_INTL("{1}'s wish came true!",wishMaker))
    end
    # Status-curing effects/abilities and HP-healing items
    priority.each do |b|
      next if b.fainted?
      # Grassy Terrain (healing)
      if @field.terrain == :Grassy && b.affectedByTerrain? && b.canHeal?
        PBDebug.log("[Lingering effect] Grassy Terrain heals #{b.pbThis(true)}")
		    amount = b.totalhp/16
		    amount /= 4 if b.boss?
        b.pbRecoverHP(amount)
        pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      end
      # Healer, Hydration, Shed Skin
      BattleHandlers.triggerEORHealingAbility(b.ability,b,self) if b.abilityActive?
      # Black Sludge, Leftovers
      BattleHandlers.triggerEORHealingItem(b.item,b,self) if b.itemActive?
    end
    # Aqua Ring
    priority.each do |b|
      next if !b.effects[PBEffects::AquaRing]
      next if !b.canHeal?
      hpGain = b.totalhp/8
      hpGain /= 4 if b.boss?
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("Aqua Ring restored {1}'s HP!",b.pbThis(true)))
    end
    # Ingrain
    priority.each do |b|
      next if !b.effects[PBEffects::Ingrain]
      next if !b.canHeal?
      hpGain = b.totalhp/8
      hpGain /= 4 if b.boss?
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("{1} absorbed nutrients with its roots!",b.pbThis))
    end
  end

  def pbEORDamage(priority)
    PBDebug.log("[DEBUG] Dealing EoR damage effects")
    # Sea of Fire damage (Fire Pledge + Grass Pledge combination)
    curWeather = pbWeather
    for side in 0...2
      next if sides[side].effects[PBEffects::SeaOfFire]==0
      next if [:Rain, :HeavyRain].include?(curWeather)
      @battle.pbCommonAnimation("SeaOfFire") if side==0
      @battle.pbCommonAnimation("SeaOfFireOpp") if side==1
      priority.each do |b|
        next if b.opposes?(side)
        next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
        oldHP = b.hp
		    reduction = b.totalhp/8
		    reduction /= 4 if b.boss?
		    b.damageState.displayedDamage = reduction
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(reduction,false)
        pbDisplay(_INTL("{1} is hurt by the sea of fire!",b.pbThis))
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
    end
    # Leech Seed
    priority.each do |b|
      next if b.effects[PBEffects::LeechSeed]<0
      next if !b.takesIndirectDamage?
      recipient = @battlers[b.effects[PBEffects::LeechSeed]]
      next if !recipient || recipient.fainted?
      oldHP = b.hp
      oldHPRecipient = recipient.hp
      pbCommonAnimation("LeechSeed",recipient,b)
	    healthFraction = b.boss ? 64 : 8
      hpLost = b.pbReduceHP(b.totalhp/healthFraction)
      recipient.pbRecoverHPFromDrain(hpLost,b,
         _INTL("{1}'s health is sapped by Leech Seed!",b.pbThis))
      recipient.pbAbilitiesOnDamageTaken(oldHPRecipient) if recipient.hp<oldHPRecipient
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
      recipient.pbFaint if recipient.fainted?
    end
    # Damage from Hyper Mode (Shadow Pokémon)
    priority.each do |b|
      next if !b.inHyperMode? || @choices[b.index][0]!=:UseMove
      reduction = b.totalhp/24
	    reduction /= 4 if b.boss?
	    b.damageState.displayedDamage = reduction
      @scene.pbDamageAnimation(b)
      b.pbReduceHP(reduction,false)
      pbDisplay(_INTL("The Hyper Mode attack hurts {1}!",b.pbThis(true)))
      b.pbFaint if b.fainted?
    end
    # Damage from poisoning
    priority.each do |b|
      next if b.fainted?
      next if !b.poisoned?
      if b.hasActiveAbility?(:POISONHEAL)
        if b.canHeal?
          anim_name = GameData::Status.get(:POISON).animation
          pbCommonAnimation(anim_name, b) if anim_name
          recovery = b.totalhp/12
          recovery /= 4 if b.boss?
          if !defined?($PokemonSystem.status_effect_messages) || $PokemonSystem.status_effect_messages == 0
            pbShowAbilitySplash(b)
            b.pbRecoverHP(recovery)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
            else
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            end
            pbHideAbilitySplash(b)
          else
            b.pbRecoverHP(recovery)
          end
        end
      elsif b.takesIndirectDamage?
        oldHP = b.hp
        dmg = b.totalhp/12
		    dmg = (dmg/4.0).round if b.boss
        b.pbContinueStatus(:POISON) { b.pbReduceHP(dmg,false) }
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        if b.fainted?
          b.pbFaint 
          triggerDOTDeathDialogue(b)
        end
      end
    end
    # Damage from burn
    priority.each do |b|
	    next if b.fainted?
      next if !b.burned?
	    if b.hasActiveAbility?(:BURNHEAL)
        if b.canHeal?
          anim_name = GameData::Status.get(:BURN).animation
          pbCommonAnimation(anim_name, b) if anim_name
          recovery = b.totalhp/8
          recovery /= 4 if b.boss?
          if !defined?($PokemonSystem.status_effect_messages) || $PokemonSystem.status_effect_messages == 0
            pbShowAbilitySplash(b)
            b.pbRecoverHP(recovery)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
            else
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            end
            pbHideAbilitySplash(b)
          else
            b.pbRecoverHP(recovery)
          end
        end
	    elsif b.takesIndirectDamage?
        oldHP = b.hp
        dmg = b.totalhp/8
        dmg = (dmg/4.0).round if b.boss?
        b.pbContinueStatus(:BURN) { b.pbReduceHP(dmg,false) }
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        if b.fainted?
          b.pbFaint 
          triggerDOTDeathDialogue(b)
        end
      end
    end
    # Damage from fluster or mystified
    priority.each do |b|
      selfHitBasePower = (20 + b.level * (3.0/5.0))
      selfHitBasePower = selfHitBasePower.ceil
      if b.flustered?
        superEff = pbCheckOpposingAbility(:BRAINSCRAMBLE,b.index)
        b.pbContinueStatus(:FLUSTERED) { b.pbConfusionDamage(nil,false,superEff,selfHitBasePower) }
      end
      if b.mystified?
        superEff = pbCheckOpposingAbility(:BRAINJAMMED,b.index)
        b.pbContinueStatus(:MYSTIFIED) { b.pbConfusionDamage(nil,true,superEff,selfHitBasePower) }
      end
    end
    # Damage from sleep (Nightmare)
    priority.each do |b|
      b.effects[PBEffects::Nightmare] = false if !b.asleep?
      next if !b.effects[PBEffects::Nightmare] || !b.takesIndirectDamage?
      oldHP = b.hp
      if b.boss
        b.pbReduceHP(b.totalhp/16)
      else
        b.pbReduceHP(b.totalhp/4)
      end
      pbDisplay(_INTL("{1} is locked in a nightmare!",b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Curse
    priority.each do |b|
      next if !b.effects[PBEffects::Curse] || !b.takesIndirectDamage?
      oldHP = b.hp
      if b.boss
        b.pbReduceHP(b.totalhp/16)
      else
        b.pbReduceHP(b.totalhp/4)
      end
      pbDisplay(_INTL("{1} is afflicted by the curse!",b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
  end

  def countDownBattlerEffects(priority)
    PBDebug.log("[DEBUG] Counting down/ending battler effects")
    # Taunt
    pbEORCountDownBattlerEffect(priority,PBEffects::Taunt) { |battler|
      pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis))
    }
    # Encore
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Encore]==0
      idxEncoreMove = b.pbEncoredMoveIndex
      if idxEncoreMove>=0
        b.effects[PBEffects::Encore] -= 1
        if b.effects[PBEffects::Encore]==0 || b.moves[idxEncoreMove].pp==0
          b.effects[PBEffects::Encore] = 0
          pbDisplay(_INTL("{1}'s encore ended!",b.pbThis))
        end
      else
        PBDebug.log("[End of effect] #{b.pbThis}'s encore ended (encored move no longer known)")
        b.effects[PBEffects::Encore]     = 0
        b.effects[PBEffects::EncoreMove] = nil
      end
    end
    # Disable/Cursed Body
    pbEORCountDownBattlerEffect(priority,PBEffects::Disable) { |battler|
      battler.effects[PBEffects::DisableMove] = nil
      pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis))
    }
    # Magnet Rise
    pbEORCountDownBattlerEffect(priority,PBEffects::MagnetRise) { |battler|
      pbDisplay(_INTL("{1}'s electromagnetism wore off!",battler.pbThis))
    }
    # Telekinesis
    pbEORCountDownBattlerEffect(priority,PBEffects::Telekinesis) { |battler|
      pbDisplay(_INTL("{1} was freed from the telekinesis!",battler.pbThis))
    }
    # Heal Block
    pbEORCountDownBattlerEffect(priority,PBEffects::HealBlock) { |battler|
      pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis))
    }
    # Embargo
    pbEORCountDownBattlerEffect(priority,PBEffects::Embargo) { |battler|
      pbDisplay(_INTL("{1} can use items again!",battler.pbThis))
      battler.pbItemTerrainStatBoostCheck
	  battler.pbItemFieldEffectCheck
    }
    # Yawn
    pbEORCountDownBattlerEffect(priority,PBEffects::Yawn) { |battler|
      if battler.pbCanSleepYawn?
        PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
        battler.pbSleep
      end
    }
  end

  def processTrappingDOTs(priority)
    PBDebug.log("[DEBUG] Counting down/ending trapping DOTs")
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Trapping]==0
      b.effects[PBEffects::Trapping] -= 1
      moveName = GameData::Move.get(b.effects[PBEffects::TrappingMove]).name
      if b.effects[PBEffects::Trapping]==0
        pbDisplay(_INTL("{1} was freed from {2}!",b.pbThis,moveName))
      else
        case b.effects[PBEffects::TrappingMove]
        when :BIND        then pbCommonAnimation("Bind", b)
        when :CLAMP       then pbCommonAnimation("Clamp", b)
        when :FIRESPIN    then pbCommonAnimation("FireSpin", b)
        when :MAGMASTORM  then pbCommonAnimation("MagmaStorm", b)
        when :SANDTOMB    then pbCommonAnimation("SandTomb", b)
        when :WRAP        then pbCommonAnimation("Wrap", b)
        when :INFESTATION then pbCommonAnimation("Infestation", b)
	    	when :SNAPTRAP 	  then pbCommonAnimation("SnapTrap",b)
        when :THUNDERCAGE then pbCommonAnimation("ThunderCage",b)
        else                   pbCommonAnimation("Wrap", b)
        end
        if b.takesIndirectDamage?
          hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? b.totalhp/8 : b.totalhp/16
          if @battlers[b.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
            hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? b.totalhp/4 : b.totalhp/8
          end
		      hpLoss = (hpLoss/4.0).floor if b.boss
		      b.damageState.displayedDamage = hpLoss
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(hpLoss,false)
          pbDisplay(_INTL("{1} is hurt by {2}!",b.pbThis,moveName))
          b.pbItemHPHealCheck
          # NOTE: No need to call pbAbilitiesOnDamageTaken as b can't switch out.
          b.pbFaint if b.fainted?
        end
      end
    end
  end
  
  def countDownPerishSong(priority)
    PBDebug.log("[DEBUG] Counting down/ending perish song")
    # Perish Song
    perishSongUsers = []
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::PerishSong]==0
      b.effects[PBEffects::PerishSong] -= 1
      pbDisplay(_INTL("{1}'s perish count fell to {2}!",b.pbThis,b.effects[PBEffects::PerishSong]))
      if b.effects[PBEffects::PerishSong]==0
        perishSongUsers.push(b.effects[PBEffects::PerishSongUser])
        b.pbReduceHP(b.hp)
      end
      b.pbItemHPHealCheck
      b.pbFaint if b.fainted?
    end
    if perishSongUsers.length>0
      # If all remaining Pokemon fainted by a Perish Song triggered by a single side
      if (perishSongUsers.find_all { |idxBattler| opposes?(idxBattler) }.length==perishSongUsers.length) ||
         (perishSongUsers.find_all { |idxBattler| !opposes?(idxBattler) }.length==perishSongUsers.length)
        pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
      end
    end
  end

  def countDownSideEffects()
    PBDebug.log("[DEBUG] Counting down/ending side effects")
    for side in 0...2
      # Reflect
      pbEORCountDownSideEffect(side,PBEffects::Reflect,
         _INTL("{1}'s Reflect wore off!",@battlers[side].pbTeam))
      # Light Screen
      pbEORCountDownSideEffect(side,PBEffects::LightScreen,
         _INTL("{1}'s Light Screen wore off!",@battlers[side].pbTeam))
      # Safeguard
      pbEORCountDownSideEffect(side,PBEffects::Safeguard,
         _INTL("{1} is no longer protected by Safeguard!",@battlers[side].pbTeam))
      # Mist
      pbEORCountDownSideEffect(side,PBEffects::Mist,
         _INTL("{1} is no longer protected by mist!",@battlers[side].pbTeam))
      # Tailwind
      pbEORCountDownSideEffect(side,PBEffects::Tailwind,
         _INTL("{1}'s Tailwind petered out!",@battlers[side].pbTeam))
      # Lucky Chant
      pbEORCountDownSideEffect(side,PBEffects::LuckyChant,
         _INTL("{1}'s Lucky Chant wore off!",@battlers[side].pbTeam))
      # Pledge Rainbow
      pbEORCountDownSideEffect(side,PBEffects::Rainbow,
         _INTL("The rainbow on {1}'s side disappeared!",@battlers[side].pbTeam(true)))
      # Pledge Sea of Fire
      pbEORCountDownSideEffect(side,PBEffects::SeaOfFire,
         _INTL("The sea of fire around {1} disappeared!",@battlers[side].pbTeam(true)))
      # Pledge Swamp
      pbEORCountDownSideEffect(side,PBEffects::Swamp,
         _INTL("The swamp around {1} disappeared!",@battlers[side].pbTeam(true)))
      # Aurora Veil
      pbEORCountDownSideEffect(side,PBEffects::AuroraVeil,
         _INTL("{1}'s Aurora Veil wore off!",@battlers[side].pbTeam))
    end
  end

  def countDownFieldEffects()
    PBDebug.log("[DEBUG] Counting down/ending total field effects")
    # Trick Room
    pbEORCountDownFieldEffect(PBEffects::TrickRoom,
       _INTL("The twisted dimensions returned to normal!"))
    # Gravity
    pbEORCountDownFieldEffect(PBEffects::Gravity,
       _INTL("Gravity returned to normal!"))
    # Water Sport
    pbEORCountDownFieldEffect(PBEffects::WaterSportField,
       _INTL("The effects of Water Sport have faded."))
    # Mud Sport
    pbEORCountDownFieldEffect(PBEffects::MudSportField,
       _INTL("The effects of Mud Sport have faded."))
    # Wonder Room
    pbEORCountDownFieldEffect(PBEffects::WonderRoom,
       _INTL("Wonder Room wore off, and Defense and Sp. Def stats returned to normal!"))
    # Magic Room
    pbEORCountDownFieldEffect(PBEffects::MagicRoom,
       _INTL("Magic Room wore off, and held items' effects returned to normal!"))
  end

  def processTriggersEOR(priority)
    PBDebug.log("[DEBUG] Processing EoR Triggers")

    priority.each do |b|
      next if b.fainted?
      # Hyper Mode (Shadow Pokémon)
      if b.inHyperMode?
        if pbRandom(100)<10
          b.pokemon.hyper_mode = false
          b.pokemon.adjustHeart(-50)
          pbDisplay(_INTL("{1} came to its senses!",b.pbThis))
        else
          pbDisplay(_INTL("{1} is in Hyper Mode!",b.pbThis))
        end
      end
      # Uproar
      if b.effects[PBEffects::Uproar]>0
        b.effects[PBEffects::Uproar] -= 1
        if b.effects[PBEffects::Uproar]==0
          pbDisplay(_INTL("{1} calmed down.",b.pbThis))
        else
          pbDisplay(_INTL("{1} is making an uproar!",b.pbThis))
        end
      end
      # Slow Start's end message
      if b.effects[PBEffects::SlowStart]>0
        b.effects[PBEffects::SlowStart] -= 1
        if b.effects[PBEffects::SlowStart]==0
          pbDisplay(_INTL("{1} finally got its act together!",b.pbThis))
        end
      end
      # Bad Dreams, Moody, Speed Boost
      BattleHandlers.triggerEOREffectAbility(b.ability,b,self) if b.abilityActive?
      # Flame Orb, Sticky Barb, Toxic Orb
      BattleHandlers.triggerEOREffectItem(b.item,b,self) if b.itemActive?
      # Harvest, Pickup
      BattleHandlers.triggerEORGainItemAbility(b.ability,b,self) if b.abilityActive?
    end
  end

  def processBattlerEffectsEOR()
    PBDebug.log("[DEBUG] Processing EoR Battler Effects")
    # Reset/count down battler-specific effects (no messages)
    eachBattler do |b|
      b.effects[PBEffects::BanefulBunker]    = false
      b.effects[PBEffects::Charge]           -= 1 if b.effects[PBEffects::Charge]>0
      b.effects[PBEffects::Counter]          = -1
      b.effects[PBEffects::CounterTarget]    = -1
      b.effects[PBEffects::Electrify]        = false
      b.effects[PBEffects::Endure]           = false
      b.effects[PBEffects::FirstPledge]      = 0
      b.effects[PBEffects::Flinch]           = false
      b.effects[PBEffects::FocusPunch]       = false
      b.effects[PBEffects::FollowMe]         = 0
      b.effects[PBEffects::HelpingHand]      = false
      b.effects[PBEffects::HyperBeam]        -= 1 if b.effects[PBEffects::HyperBeam]>0
      b.effects[PBEffects::KingsShield]      = false
      b.effects[PBEffects::LaserFocus]       -= 1 if b.effects[PBEffects::LaserFocus]>0
      if b.effects[PBEffects::LockOn]>0   # Also Mind Reader
        b.effects[PBEffects::LockOn]         -= 1
        b.effects[PBEffects::LockOnPos]      = -1 if b.effects[PBEffects::LockOn]==0
      end
      b.effects[PBEffects::MagicBounce]      = false
      b.effects[PBEffects::MagicCoat]        = false
      b.effects[PBEffects::MirrorCoat]       = -1
      b.effects[PBEffects::MirrorCoatTarget] = -1
      b.effects[PBEffects::Powder]           = false
      b.effects[PBEffects::Prankster]        = false
      b.effects[PBEffects::PriorityAbility]  = false
      b.effects[PBEffects::PriorityItem]     = false
      b.effects[PBEffects::Protect]          = false
      b.effects[PBEffects::RagePowder]       = false
      b.effects[PBEffects::Roost]            = false
      b.effects[PBEffects::Snatch]           = 0
      b.effects[PBEffects::SpikyShield]      = false
      b.effects[PBEffects::Spotlight]        = 0
      b.effects[PBEffects::ThroatChop]       -= 1 if b.effects[PBEffects::ThroatChop]>0
	    b.effects[PBEffects::Assist]			     = false
	    b.effects[PBEffects::LashOut]			     = false
	    b.effects[PBEffects::StunningCurl]     = false
      b.effects[PBEffects::Sentry]           = false
      b.lastHPLost                           = 0
      b.lastHPLostFromFoe                    = 0
      b.tookDamage                           = false
      b.tookPhysicalHit                      = false
      b.lastRoundMoveFailed                  = b.lastMoveFailed
      b.lastAttacker.clear
      b.lastFoeAttacker.clear
    end
  end

  def processSideEffectsEOR()
    PBDebug.log("[DEBUG] Processing EoR Side-Specific Effects")
    # Reset/count down side-specific effects (no messages)
    for side in 0...2
      @sides[side].effects[PBEffects::CraftyShield]         = false
      if !@sides[side].effects[PBEffects::EchoedVoiceUsed]
        @sides[side].effects[PBEffects::EchoedVoiceCounter] = 0
      end
      @sides[side].effects[PBEffects::EchoedVoiceUsed]      = false
      @sides[side].effects[PBEffects::MatBlock]             = false
      @sides[side].effects[PBEffects::QuickGuard]           = false
      @sides[side].effects[PBEffects::Round]                = false
      @sides[side].effects[PBEffects::WideGuard]            = false
    end
  end

  def processFieldEffectsEOR()
    PBDebug.log("[DEBUG] Processing EoR Total Field Effects")
    # Reset/count down field-specific effects (no messages)
    @field.effects[PBEffects::IonDeluge]   = false
    @field.effects[PBEffects::FairyLock]   -= 1 if @field.effects[PBEffects::FairyLock]>0
    @field.effects[PBEffects::FusionBolt]  = false
    @field.effects[PBEffects::FusionFlare] = false
  end
  
  # Enemy dialogue for victims of poison/burn
  def triggerDOTDeathDialogue(pokemon)
    if @opponent
      if pbOwnedByPlayer?(pokemon.index)
        # Trigger dialogue for each opponent
        @opponent.each_with_index do |trainer_speaking,idxTrainer|
          @scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
            PokeBattle_AI.triggerPlayerPokemonDiesToDOTDialogue(policy,pokemon,trainer_speaking,dialogue)
          }
        end
      else
        # Trigger dialogue for the trainer whose pokemon died
        idxTrainer = pbGetOwnerIndexFromBattlerIndex(pokemon.index)
        trainer_speaking = @opponent[idxTrainer]
        @scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
          PokeBattle_AI.triggerTrainerPokemonDiesToDOTDialogue(policy,pokemon,trainer_speaking,dialogue)
        }
      end
    end
  end
end