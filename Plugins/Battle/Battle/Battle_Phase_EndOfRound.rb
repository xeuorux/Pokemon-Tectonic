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
    
    eachBattler do |b|
      b.processEffectsEOR()
      b.modifyTrackersEOR()
    end

    # Decrement or reset various effects that don't show messages when they leave
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
      endWeather()
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
    showWeatherMessages = $PokemonSystem.weather_messages == 0
    hailDamage = 0
    priority.each do |b|
      # Weather-related abilities
      if b.abilityActive?
        oldHP = b.hp
        BattleHandlers.triggerEORWeatherAbility(b.ability,curWeather,b,self)
        b.pbHealthLossChecks(oldHP)
      end
      # Weather damage
      # NOTE:
      case curWeather
      when :Sandstorm
        next if !b.takesSandstormDamage?
        damageDoubled = !pbCheckGlobalAbility(:SHRAPNELSTORM).nil?
        if showWeatherMessages
          if damageDoubled
            pbDisplay(_INTL("{1} is shredded by the razor-sharp shrapnel!",b.pbThis))
          else
            pbDisplay(_INTL("{1} is buffeted by the sandstorm!",b.pbThis))
          end
        end
        fraction = 1.0/16.0
        fraction *= 2 if damageDoubled
        b.applyFractionalDamage(fraction)
      when :Hail
        next if !b.takesHailDamage?
        damageDoubled = !pbCheckGlobalAbility(:BITTERCOLD).nil?
        if showWeatherMessages
          if damageDoubled
            pbDisplay(_INTL("{1} is pummeled by the bitterly cold hail!",b.pbThis))
          else
            pbDisplay(_INTL("{1} is buffeted by the hail!",b.pbThis))
          end
        end
        fraction = 1.0/16.0
        fraction *= 2 if damageDoubled
        hailDamage += b.applyFractionalDamage(fraction)
      when :ShadowSky
        next if !b.takesShadowSkyDamage?
        pbDisplay(_INTL("{1} is hurt by the shadow sky!",b.pbThis))if showWeatherMessages
        fraction = 1.0/16.0
        b.applyFractionalDamage(fraction)
      when :AcidRain
        if !b.takesAcidRainDamage?
          pbDisplay(_INTL("{1} is hurt by the acid rain!",b.pbThis)) if showWeatherMessages
          fraction = 1.0/16.0
          b.applyFractionalDamage(fraction)
        elsif b.pbHasType?(:POISON) || b.hasActiveAbility?(:POISONHEAL)
          heal = b.totalhp / 16.0
          heal /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if b.boss?
          if showWeatherMessages
            pbShowAbilitySplash(b) if b.hasActiveAbility?(:POISONHEAL)
            healingMessage = _INTL("{1} absorbs the acid rain!",b.pbThis)
            b.pbRecoverHP(heal,true,true,true,healingMessage)
            pbHideAbilitySplash(b) if b.hasActiveAbility?(:POISONHEAL)
          else
            b.pbRecoverHP(heal,true,true,false)
          end
        end
      end
    end
    # Ectoparticles
    if hailDamage > 0
      priority.each do |b|
        if b.hasActiveAbility?(:ECTOPARTICLES)
          pbShowAbilitySplash(b)
          healingMessage = _INTL("{1} absorbs the suffering from the hailstorm.",b.pbThis)
          b.pbRecoverHP(hailDamage,true,true,true,healingMessage)
          pbHideAbilitySplash(b)
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
      healingMessage = _INTL("{1}'s wish came true!",wishMaker)
      @battlers[idxPos].pbRecoverHP(pos.effects[PBEffects::WishAmount],true,true,true,healingMessage)
    end
    # Status-curing effects/abilities and HP-healing items
    priority.each do |b|
      next if b.fainted?
      # Grassy Terrain
      if @field.terrain == :Grassy && b.affectedByTerrain?
        PBDebug.log("[Lingering effect] Grassy Terrain affects #{b.pbThis(true)}")
        if pbCheckOpposingAbility(:SNAKEPIT)
          pbDisplay(_INTL("{1} is lashed at by the pit of snakes!",b.pbThis))
          b.applyFractionalDamage(1.0/16.0)
        elsif b.canHeal?
          amount = b.totalhp/16.0
          amount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if b.boss?
          healingMessage = _INTL("{1} is healed by the Grassy Terrain.",b.pbThis)
          if b.hasActiveAbility?(:NESTING)
            pbShowAbilitySplash(b)
            amount *= 4.0
            healingMessage = _INTL("{1} nests within the Grassy Terrain.",b.pbThis)
          end
          b.pbRecoverHP(amount,true,true,true,healingMessage)
          pbHideAbilitySplash(b) if b.hasActiveAbility?(:NESTING)
        end
      end
      # Healer, Hydration, Shed Skin
      BattleHandlers.triggerEORHealingAbility(b.ability,b,self) if b.abilityActive?
      # Black Sludge, Leftovers
      BattleHandlers.triggerEORHealingItem(b.item,b,self) if b.itemActive?
    end
  end

  def damageFromDOTStatus(battler,status)
    if battler.takesIndirectDamage?
      fraction = 1.0/8.0
      fraction *= 2 if battler.pbOwnedByPlayer? && curseActive?(:CURSE_STATUS_DOUBLED)
      battler.pbContinueStatus(status) { battler.applyFractionalDamage(fraction) }
      if battler.fainted?
        triggerDOTDeathDialogue(battler)
      end
    end
  end

  def healFromStatusAbility(battler,status)
    statusEffectMessages = !defined?($PokemonSystem.status_effect_messages) || $PokemonSystem.status_effect_messages == 0
    if battler.canHeal?
      anim_name = GameData::Status.get(status).animation
      pbCommonAnimation(anim_name, battler) if anim_name
      healAmount = battler.totalhp / 12.0
      healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
      if statusEffectMessages
        pbShowAbilitySplash(battler) 
        healingMessage = _INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName)
        battler.pbRecoverHP(healAmount,true,true,true,healingMessage)
        pbHideAbilitySplash(battler)
      else
        battler.pbRecoverHP(healAmount,true,true,false)
      end
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
        pbDisplay(_INTL("{1} is hurt by the sea of fire!",b.pbThis))
        b.applyFractionalDamage(1.0/8.0)
      end
    end
    # Damage from Hyper next if !b.takesIndirectDamage?
    priority.each do |b|
      next if !b.inHyperMode? || @choices[b.index][0]!=:UseMove
      pbDisplay(_INTL("The Hyper Mode attack hurts {1}!",b.pbThis(true)))
      b.applyFractionalDamage(1.0/24.0)
    end
    # Damage from poisoning
    priority.each do |b|
      next if b.fainted?
      next if !b.poisoned?
      if b.hasActiveAbility?(:POISONHEAL)
        healFromStatusAbility(b,:POISON)
      else
        damageFromDOTStatus(b,:POISON)
      end
    end
    # Damage from burn
    priority.each do |b|
	    next if b.fainted?
      next if !b.burned?
	    if b.hasActiveAbility?(:BURNHEAL)
        healFromStatusAbility(b,:BURN)
      else
        damageFromDOTStatus(b,:BURN)
      end
    end
    # Damage from frostbite
    priority.each do |b|
	    next if b.fainted?
      next if !b.frostbitten?
	    if b.hasActiveAbility?(:FROSTHEAL)
        healFromStatusAbility(b,:FROSTBITE)
	    else
        damageFromDOTStatus(b,:FROSTBITE)
      end
    end
    # Damage from fluster or mystified
    priority.each do |b|
      calcLevel = [b.level,50].min
      selfHitBasePower = (20 + calcLevel * (3.0/5.0))
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
    # Puzzle Room
    pbEORCountDownFieldEffect(PBEffects::PuzzleRoom,
       _INTL("Puzzle Room wore off, and Attack and Sp. Atk stats returned to normal!"))
	# Odd Room
    pbEORCountDownFieldEffect(PBEffects::OddRoom,
       _INTL("Odd Room wore off, and Offensive and Defensive stats returned to normal!"))
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
      # Bad Dreams, Moody, Speed Boost
      BattleHandlers.triggerEOREffectAbility(b.ability,b,self) if b.abilityActive?
      # Flame Orb, Sticky Barb, Toxic Orb
      BattleHandlers.triggerEOREffectItem(b.item,b,self) if b.itemActive?
      # Harvest, Pickup
      BattleHandlers.triggerEORGainItemAbility(b.ability,b,self) if b.abilityActive?
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
      @sides[side].effects[PBEffects::Bulwark]              = false
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

end