class PokeBattle_Battle
  def defaultWeather=(value)
    @field.defaultWeather  = value
    @field.weather         = value
    @field.weatherDuration = -1
  end

  # Returns the effective weather (note that weather effects can be negated)
  def pbWeather
    eachBattler { |b| return :None if b.hasActiveAbility?([:CLOUDNINE, :AIRLOCK]) }
    return @field.weather
  end

    # Used for causing weather by a move or by an ability.
    def pbStartWeather(user,newWeather,duration=-1,showAnim=true,ignoreFainted=false)
      oldWeather = @field.weather
  
      resetExisting = @field.weather == newWeather
      endWeather() if !resetExisting
  
      # Set the new weather and duration
      @field.weather = newWeather
      if duration>0 && user && user.itemActive?(ignoreFainted)
        duration = BattleHandlers.triggerWeatherExtenderItem(user.item,
          @field.weather,duration,user,self)
      end
  
      # If we're resetting an existing weather, don't set the duration to lower than it was before
      if resetExisting
        if duration > @field.weatherDuration
          @field.weatherDuration = duration
        end
      else
        @field.weatherDuration = duration
      end
  
      # Show animation, if desired
      weather_data = GameData::BattleWeather.try_get(@field.weather)
      pbCommonAnimation(weather_data.animation) if showAnim && weather_data   
  
      if resetExisting
        displayResetWeatherMessage()
      else
        displayFreshWeatherMessage()
        # Check for end of primordial weather, and weather-triggered form changes
        eachBattler { |b| b.pbCheckFormOnWeatherChange }
        pbEndPrimordialWeather
      end
      pbDisplay(_INTL("It'll last for {1} more turns!",@field.weatherDuration - 1)) if $PokemonSystem.weather_messages == 0
      pbHideAbilitySplash(user) if user
  
      triggerWeatherChangeDialogue(oldWeather,@field.weather) if !resetExisting
    end
  
    def displayResetWeatherMessage()
      case @field.weather
      when :Sun         then pbDisplay(_INTL("The sunshine continues!"))
      when :Rain        then pbDisplay(_INTL("The rain shows no sign of stopping!"))
      when :Sandstorm   then pbDisplay(_INTL("The sandstorm returns to full strength!"))
      when :Hail        then pbDisplay(_INTL("The hail keeps coming!"))
      when :ShadowSky   then pbDisplay(_INTL("The darkened sky darkens even further!"))
      when :AcidRain    then pbDisplay(_INTL("The acid rain won't quit!"))
      when :Swarm       then pbDisplay(_INTL("The bugs insatiable, and keep swarming!"))
      end
    end
    
    def displayFreshWeatherMessage()
      case @field.weather
      when :Sun         then pbDisplay(_INTL("The sun is shining in the sky!"))
      when :Rain        then pbDisplay(_INTL("It started to rain!"))
      when :Sandstorm   then pbDisplay(_INTL("A sandstorm brewed!"))
      when :Hail        then pbDisplay(_INTL("It started to hail!"))
      when :HarshSun    then pbDisplay(_INTL("The sunlight turned extremely harsh!"))
      when :HeavyRain   then pbDisplay(_INTL("A heavy rain began to fall!"))
      when :StrongWinds then pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
      when :ShadowSky   then pbDisplay(_INTL("A shadow sky appeared!"))
      when :AcidRain    then pbDisplay(_INTL("Acidic rain began to fall!"))
      when :Swarm       then pbDisplay(_INTL("A swarm of bugs gathers!"))
      end
    end
  
    def endWeather()
      return if @field.weather == :None
      case @field.weather
        when :Sun         then pbDisplay(_INTL("The sunshine faded."))
        when :Rain        then pbDisplay(_INTL("The rain stopped."))
        when :Sandstorm   then pbDisplay(_INTL("The sandstorm subsided."))
        when :Hail        then pbDisplay(_INTL("The hail stopped."))
        when :ShadowSky   then pbDisplay(_INTL("The shadow sky faded."))
        when :AcidRain    then pbDisplay(_INTL("The acid rain stopped."))
        when :Swarm       then pbDisplay(_INTL("The swarm dissipates."))
        when :HeavyRain   then pbDisplay(_INTL("The heavy rain has lifted!"))
        when :HarshSun    then pbDisplay(_INTL("The harsh sunlight faded!"))
        when :StrongWinds then pbDisplay(_INTL("The mysterious air current has dissipated!"))
      end
      oldWeather = @field.weather
      @field.weather 			= :None
      @field.weatherDuration  = 0
      triggerWeatherChangeDialogue(oldWeather,:None)
    end

  def pbEndPrimordialWeather
    oldWeather = @field.weather
    # End Primordial Sea, Desolate Land, Delta Stream
    case @field.weather
    when :HarshSun
      if !pbCheckGlobalAbility(:DESOLATELAND)
        @field.weather = :None
        pbDisplay("The harsh sunlight faded!")
      end
    when :HeavyRain
      if !pbCheckGlobalAbility(:PRIMORDIALSEA)
        @field.weather = :None
        pbDisplay("The heavy rain has lifted!")
      end
    when :StrongWinds
      if !pbCheckGlobalAbility(:DELTASTREAM)
        @field.weather = :None
        pbDisplay("The mysterious air current has dissipated!")
      end
    end
    if @field.weather!=oldWeather
      # Check for form changes caused by the weather changing
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil,@field.defaultWeather) if @field.defaultWeather != :None
    end
  end

  def defaultTerrain=(value)
    @field.defaultTerrain  = value
    @field.terrain         = value
    @field.terrainDuration = -1
  end

  def pbStartTerrain(user,newTerrain,fixedDuration=true)
    if @field.terrain == newTerrain
      pbHideAbilitySplash(user) if user
      return
    end
    old_terrain = @field.terrain
    @field.terrain = newTerrain
    duration = (fixedDuration) ? 5 : -1
    if duration>0 && user && user.itemActive?
      duration = BattleHandlers.triggerTerrainExtenderItem(user.item,newTerrain,duration,user,self)
    end
    @field.terrainDuration = duration
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
      pbDisplay(_INTL("Pokemon cannot fall asleep, be flustered or be mystified!"))
    when :Grassy
      pbDisplay(_INTL("Grass grew to cover the battlefield!"))
      pbDisplay(_INTL("All Pokemon are healed each turn!"))
    when :Misty
      pbDisplay(_INTL("Fae mist swirled about the battlefield!"))
      pbDisplay(_INTL("Pokemon cannot be burned or poisoned!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield got weird!"))
      pbDisplay(_INTL("Priority moves are prevented!"))
    end
    pbHideAbilitySplash(user) if user
    # Check for terrain seeds that boost stats in a terrain
    eachBattler { |b| b.pbItemTerrainStatBoostCheck }
    
    triggerTerrainChangeDialogue(old_terrain,newTerrain)
  end

  def endTerrain
    return if @field.terrain == :None
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("The grass disappeared from the battlefield!"))
    when :Misty
      pbDisplay(_INTL("The mist disappeared from the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
    end
    @field.terrain = :None
    # Start up the default terrain
    pbStartTerrain(nil, @field.defaultTerrain, false) if @field.defaultTerrain != :None
  end

  
  def pbChangeField(user,fieldEffect,modifier)
	  return
	  @field.effects[PBEffects:fieldEffect] = modifier
  end

  def primevalWeatherPresent?(showMessages=true)
    case @field.weather
    when :HarshSun
      battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!")) if showMessages
      return true
    when :HeavyRain
      battle.pbDisplay(_INTL("There is no relief from this heavy rain!")) if showMessages
      return true
    when :StrongWinds
      battle.pbDisplay(_INTL("The mysterious air current blows on regardless!")) if showMessages
      return true
    end
    return false
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

  #=============================================================================
  # End Of Round terrain
  #=============================================================================
  def pbEORTerrain
    # Count down terrain duration
    @field.terrainDuration -= 1 if @field.terrainDuration>0
    # Terrain wears off
    if @field.terrain != :None && @field.terrainDuration == 0
      endTerrain
      return if @field.terrain == :None
    end
    # Terrain continues
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric then pbDisplay(_INTL("An electric current is running across the battlefield."))
    when :Grassy   then pbDisplay(_INTL("Grass is covering the battlefield."))
    when :Misty    then pbDisplay(_INTL("Mist is swirling about the battlefield."))
    when :Psychic  then pbDisplay(_INTL("The battlefield is weird."))
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
end