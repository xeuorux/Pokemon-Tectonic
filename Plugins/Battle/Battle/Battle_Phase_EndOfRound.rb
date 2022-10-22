class PokeBattle_Battle

  #=============================================================================
  # End Of Round phase
  #=============================================================================
  def pbEndOfRoundPhase
    PBDebug.log("")
    PBDebug.log("[End of round]")
    @endOfRound = true

    checkForInvalidEffectStates

    @scene.pbBeginEndOfRoundPhase
    pbCalculatePriority           # recalculate speeds
    priority = pbPriority(true)   # in order of fastest -> slowest speeds only

    pbEORHealing(priority)

    pbEORWeather(priority)
    grassyTerrainEOR(priority)

    pbEORDamage(priority)

    countDownPerishSong(priority)

    # Check for end of battle
    if @decision > 0
      pbGainExp
      return
    end

    # Tick down or reset battle effects
    @field.processEffectsEOR(self)
    @sides.each do |side|
      if !side.effects[PBEffects::EchoedVoiceUsed]
        side.effects[PBEffects::EchoedVoiceCounter] = 0
      end
      side.processEffectsEOR(self)
    end
    @positions.each_with_index do |position,index|
      position.processEffectsEOR(self,index)
    end
    eachBattler do |b|
      b.processEffectsEOR
    end
    
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
      b.modifyTrackersEOR()
    end
	
	  # Neutralizing Gas
	  pbCheckNeutralizingGas

    checkForInvalidEffectStates()
	
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

  def grassyTerrainEOR(priority)
    return if @field.terrain != :Grassy
    # Status-curing effects/abilities and HP-healing items
    priority.each do |b|
      next if b.fainted?
       if b.affectedByTerrain?
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
    end
  end

  def pbEORHealing(priority)
    PBDebug.log("[DEBUG] Performing EoR healing effects")
    # Status-curing effects/abilities and HP-healing items
    priority.each do |b|
      next if b.fainted?
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
    # Damage from Hyper
    priority.each do |b|
      next if !b.inHyperMode? || @choices[b.index][0] != :UseMove
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

  def checkForInvalidEffectStates()
    @battlers.each do |battler|
      battler.effects.each do |effect,value|
        effectData = GameData::BattleEffect.try_get(effect)
        raise _INTL("Battler effect \"#{effectData.real_name}\" is not a defined effect.") if effectData.nil?
        next if effectData.valid_value?(self,value)
        raise _INTL("Battler effect \"#{effectData.real_name}\" is in invalid state: #{value}")
      end
    end

    @positions.each do |position|
      position.effects.each do |effect,value|
        effectData = GameData::BattleEffect.try_get(effect)
        raise _INTL("Position effect \"#{effectData.real_name}\" is not a defined effect.") if effectData.nil?
        next if effectData.valid_value?(self,value)
        raise _INTL("Position effect \"#{effectData.real_name}\" is in invalid state: #{value}")
      end
    end

    @sides.each do |side|
      side.effects.each do |effect,value|
        effectData = GameData::BattleEffect.try_get(effect)
        raise _INTL("Side effect \"#{effectData.real_name}\" is not a defined effect") if effectData.nil?
        next if effectData.valid_value?(self,value)
        raise _INTL("Side effect \"#{effectData.real_name}\" is in invalid state: #{value}")
      end
    end

    @field.effects.each do |effect,value|
      effectData = GameData::BattleEffect.try_get(effect)
      raise _INTL("Whole field effect \"#{effectData.real_name}\" is not a defined effect.") if effectData.nil?
      next if effectData.valid_value?(self,value)
      raise _INTL("Whole field effect \"#{effectData.real_name}\" is in invalid state: #{value}")
    end
  end
end