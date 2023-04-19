class PokeBattle_Battle
    SPECIAL_EFFECT_WAIT_TURNS = 4

    def defaultWeather=(value)
        @field.defaultWeather = value
        @field.weather         = value
        @field.weatherDuration = -1
    end

    def weatherSuppressed?
        eachBattler do |b|
            return true if b.hasActiveAbility?(%i[CLOUDNINE AIRLOCK])
        end
        return false
    end

    # Returns the effective weather (note that weather effects can be negated)
    def pbWeather
        return :None if weatherSuppressed?
        return @field.weather
    end

    # Used for causing weather by a move or by an ability.
    def pbStartWeather(user, newWeather, duration = -1, showAnim = true, ignoreFainted = false)
        oldWeather = @field.weather

        resetExisting = @field.weather == newWeather
        endWeather unless resetExisting

        # Set the new weather and duration
        @field.weather = newWeather
        duration = user.getWeatherSettingDuration(newWeather, duration, ignoreFainted) if duration > 0 && user

        noChange = resetExisting && duration == @field.weatherDuration

        # If we're resetting an existing weather, don't set the duration to lower than it was before
        if resetExisting
            @field.weatherDuration = duration if duration > @field.weatherDuration
        else
            @field.weatherDuration = duration
        end

        @field.resetSpecialEffect unless resetExisting

        # Show animation, if desired
        unless noChange
            weather_data = GameData::BattleWeather.try_get(@field.weather)
            pbCommonAnimation(weather_data.animation) if showAnim && weather_data
        end

        if resetExisting
            displayResetWeatherMessage unless noChange
        else
            displayFreshWeatherMessage unless noChange
            # Check for end of primordial weather, and weather-triggered form changes
            eachBattler { |b| b.pbCheckFormOnWeatherChange }
            pbEndPrimordialWeather
        end
        
        if $PokemonSystem.weather_messages == 0 && !noChange
            if @field.weatherDuration < 0
                pbDisplay(_INTL("It'll last indefinitely!"))
            else
                moreTurns = @field.weatherDuration
                moreTurns -= 1 unless @turnCount == 0
                pbDisplay(_INTL("It'll last for {1} more turns!", moreTurns))
            end
        end
        pbHideAbilitySplash(user) if user

        triggerWeatherChangeDialogue(oldWeather, @field.weather) unless resetExisting
    end

    def displayResetWeatherMessage
        case @field.weather
        when :Sun         then pbDisplay(_INTL("The sunshine continues!"))
        when :Rain        then pbDisplay(_INTL("The rain shows no sign of stopping!"))
        when :Sandstorm   then pbDisplay(_INTL("The sandstorm returns to full strength!"))
        when :Hail        then pbDisplay(_INTL("The hail keeps coming!"))
        when :ShadowSky   then pbDisplay(_INTL("The darkened sky darkens even further!"))
        when :Eclipse     then pbDisplay(_INTL("The eclipse extends unnaturally!"))
        when :Moonglow   then pbDisplay(_INTL("The bright moon doesn't wane!"))
        end
    end

    def displayFreshWeatherMessage
        case @field.weather
        when :Sun         then pbDisplay(_INTL("The sun is shining in the sky!"))
        when :Rain        then pbDisplay(_INTL("It started to rain!"))
        when :Sandstorm   then pbDisplay(_INTL("A sandstorm brewed!"))
        when :Hail        then pbDisplay(_INTL("It started to hail!"))
        when :HarshSun    then pbDisplay(_INTL("The sunlight turned extremely harsh!"))
        when :HeavyRain   then pbDisplay(_INTL("A heavy rain began to fall!"))
        when :StrongWinds then pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
        when :ShadowSky   then pbDisplay(_INTL("A shadow sky appeared!"))
        when :Eclipse     then pbDisplay(_INTL("An eclipse covers the sun!"))
        when :Moonglow   then pbDisplay(_INTL("The light of the moon shines down!"))
        end
    end

    def endWeather
        return if @field.weather == :None
        case @field.weather
        when :Sun         then pbDisplay(_INTL("The sunshine faded."))
        when :Rain        then pbDisplay(_INTL("The rain stopped."))
        when :Sandstorm   then pbDisplay(_INTL("The sandstorm subsided."))
        when :Hail        then pbDisplay(_INTL("The hail stopped."))
        when :ShadowSky   then pbDisplay(_INTL("The shadow sky faded."))
        when :Eclipse     then pbDisplay(_INTL("The eclipse ended."))
        when :Moonglow   then pbDisplay(_INTL("The moonlight faded."))
        when :HeavyRain   then pbDisplay(_INTL("The heavy rain has lifted!"))
        when :HarshSun    then pbDisplay(_INTL("The harsh sunlight faded!"))
        when :StrongWinds then pbDisplay(_INTL("The mysterious air current has dissipated!"))
        end
        oldWeather = @field.weather
        @field.weather	= :None
        @field.weatherDuration = 0
        @field.resetSpecialEffect
        triggerWeatherChangeDialogue(oldWeather, :None)
    end

    def pbEndPrimordialWeather
        oldWeather = @field.weather
        # End Primordial Sea, Desolate Land, Delta Stream
        case @field.weather
        when :HarshSun
            if !pbCheckGlobalAbility(:DESOLATELAND) && @field.defaultWeather != :HarshSun
                @field.weather = :None
                pbDisplay("The harsh sunlight faded!")
            end
        when :HeavyRain
            if !pbCheckGlobalAbility(:PRIMORDIALSEA) && @field.defaultWeather != :HeavyRain
                @field.weather = :None
                pbDisplay("The heavy rain has lifted!")
            end
        when :StrongWinds
            if !pbCheckGlobalAbility(:DELTASTREAM) && @field.defaultWeather != :StrongWinds
                @field.weather = :None
                pbDisplay("The mysterious air current has dissipated!")
            end
        end
        if @field.weather != oldWeather
            # Check for form changes caused by the weather changing
            eachBattler { |b| b.pbCheckFormOnWeatherChange }
            # Start up the default weather
            pbStartWeather(nil, @field.defaultWeather) if @field.defaultWeather != :None
        end
    end

    def extendWeather(numTurns = 1)
        return if pbWeather == :None
        @field.weatherDuration += numTurns
        weatherName = GameData::BattleWeather.get(pbWeather).real_name
        if numTurns == 1
            pbDisplay(_INTL("The {1} extends by a turn!",weatherName))
        else
            pbDisplay(_INTL("The {1} extends by {2} turns!",weatherName,numTurns))
        end
    end

    def defaultTerrain=(value)
        @field.defaultTerrain = value
        @field.terrain         = value
        @field.terrainDuration = -1
    end

    def pbStartTerrain(user, newTerrain, fixedDuration = true)
        if @field.terrain == newTerrain
            pbHideAbilitySplash(user) if user
            return
        end
        old_terrain = @field.terrain
        @field.terrain = newTerrain
        duration = fixedDuration ? 5 : -1
        if duration > 0 && user
            user.eachActiveItem do |item|
                duration = BattleHandlers.triggerTerrainExtenderItem(item, newTerrain, duration, user, self)
            end
        end
        @field.terrainDuration = duration
        terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
        pbCommonAnimation(terrain_data.animation) if terrain_data
        case @field.terrain
        when :Electric
            pbDisplay(_INTL("An electric current runs across the battlefield!"))
            pbDisplay(_INTL("Pokemon cannot fall asleep or be dizzied!"))
        when :Grassy
            pbDisplay(_INTL("Grass grew to cover the battlefield!"))
            pbDisplay(_INTL("All Pokemon are healed each turn!"))
        when :Fairy
            pbDisplay(_INTL("Fae mist swirled about the battlefield!"))
            pbDisplay(_INTL("Pokemon cannot be burned, frostbitten, or poisoned!"))
        when :Psychic
            pbDisplay(_INTL("The battlefield got weird!"))
            pbDisplay(_INTL("Priority moves are prevented!"))
        end
        pbHideAbilitySplash(user) if user

        triggerTerrainChangeDialogue(old_terrain, newTerrain)
    end

    def endTerrain
        return if @field.terrain == :None
        case @field.terrain
        when :Electric
            pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
        when :Grassy
            pbDisplay(_INTL("The grass disappeared from the battlefield!"))
        when :Fairy
            pbDisplay(_INTL("The mist disappeared from the battlefield!"))
        when :Psychic
            pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
        end
        @field.terrain = :None
        # Start up the default terrain
        pbStartTerrain(nil, @field.defaultTerrain, false) if @field.defaultTerrain != :None
    end

    def pbChangeField(_user, fieldEffect, modifier)
        return
        @field.effects[PBEffects: fieldEffect] = modifier
    end

    def primevalWeatherPresent?(showMessages = true)
        case @field.weather
        when :HarshSun
            pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!")) if showMessages
            return true
        when :HeavyRain
            pbDisplay(_INTL("There is no relief from this heavy rain!")) if showMessages
            return true
        when :StrongWinds
            pbDisplay(_INTL("The mysterious air current blows on regardless!")) if showMessages
            return true
        end
        return false
    end

    #=============================================================================
    # Start Of Round weather
    #=============================================================================

    def pbSORWeather(priority)
        curWeather = pbWeather

        @field.specialTimer += 1

        threshold = SPECIAL_EFFECT_WAIT_TURNS
        threshold /= 2 if weatherSpedUp?

        showWeatherMessages = $PokemonSystem.weather_messages == 0

        if @field.specialTimer >= threshold
            case curWeather
            when :Eclipse
                pbDisplay(_INTL("The Total Eclipse arrives!")) if showWeatherMessages
                pbCommonAnimation("Eclipse")
                anyAffected = false
                priority.each do |b|
                    next if b.fainted?
                    next unless b.debuffedByEclipse?
                    pbDisplay(_INTL("{1} is panicked!", b.pbThis))
                    b.pbLowerMultipleStatSteps(ALL_STATS_2, b)
                    anyAffected = true
                end
                pbDisplay(_INTL("But no one was panicked.")) if showWeatherMessages && !anyAffected
                eachBattler do |b|
                    b.eachActiveAbility do |ability|
                        BattleHandlers.triggerTotalEclipseAbility(ability, b, self)
                    end
                end
            when :Moonglow
                pbDisplay(_INTL("The Full Moon rises!")) if showWeatherMessages
                pbAnimation(:Moonglow, @battlers[0], [])
                anyAffected = false
                priority.each do |b|
                    next if b.fainted?
                    next unless b.flinchedByMoonglow?
                    pbDisplay(_INTL("{1} is moonstruck! It'll flinch this turn!", b.pbThis))
                    b.pbFlinch
                    anyAffected = true
                end
                pbDisplay(_INTL("But no one was moonstruck.")) if showWeatherMessages && !anyAffected
                eachBattler do |b|
                    b.eachActiveAbility do |ability|
                        BattleHandlers.triggerFullMoonAbility(ability, b, self)
                    end
                end
            end
            @field.specialTimer = 0
            @field.specialWeatherEffect = true
        else
            @field.specialWeatherEffect = false

            # Special effect happening next turn
            if @field.specialTimer + 1 == threshold && @field.weatherDuration > 1
                case curWeather
                when :Eclipse
                    pbDisplay(_INTL("The Total Eclipse is approaching.")) if showWeatherMessages
                when :Moonglow
                    pbDisplay(_INTL("The Full Moon is approaching.")) if showWeatherMessages
                end
            end
        end
    end

    # Returns true if the weather went away
    def tickDownWeather
        # NOTE: Primordial weather doesn't need to be checked here, because if it
        #       could wear off here, it will have worn off already.
        # Count down weather duration
        @field.weatherDuration -= 1 if @field.weatherDuration > 0

        # Weather wears off
        if @field.weatherDuration == 0
            endWeather
            @field.weather = :None
            # Check for form changes caused by the weather changing
            eachBattler { |b| b.pbCheckFormOnWeatherChange }
            # Start up the default weather
            pbStartWeather(nil, @field.defaultWeather) if @field.defaultWeather != :None
            return if @field.weather == :None
        end
    end

    def weatherSpedUp?
        return true if pbWeather == :Eclipse && pbCheckGlobalAbility(:EPHEMERATE)
        return true if pbWeather == :Moonglow && pbCheckGlobalAbility(:SOLSTICE)
        return false
    end

    #=============================================================================
    # End Of Round weather
    #=============================================================================
    def pbEORWeather(priority)
        PBDebug.log("[DEBUG] Counting down weathers")

        return if tickDownWeather

        # Tick down twice if weathers are being sped up
        return if weatherSpedUp? && tickDownWeather

        # Weather continues
        weather_data = GameData::BattleWeather.try_get(@field.weather)
        pbCommonAnimation(weather_data.animation) if weather_data && @field.specialTimer < SPECIAL_EFFECT_WAIT_TURNS - 1

        # Effects due to weather
        curWeather = pbWeather
        showWeatherMessages = $PokemonSystem.weather_messages == 0
        hailDamage = 0
        sandstormDamage = 0
        priority.each do |b|
            # Weather-related abilities
            b.eachActiveAbility do |ability|
                oldHP = b.hp
                BattleHandlers.triggerEORWeatherAbility(ability, curWeather, b, self)
                break if b.pbHealthLossChecks(oldHP)
            end
            # Weather damage
            # NOTE:
            case curWeather
            when :Sandstorm
                next unless b.takesSandstormDamage?
                damageDoubled = pbCheckGlobalAbility(:IRONSTORM)
                if showWeatherMessages
                    if damageDoubled
                        pbDisplay(_INTL("{1} is shredded by the iron-infused sandstorm!", b.pbThis))
                    else
                        pbDisplay(_INTL("{1} is buffeted by the sandstorm!", b.pbThis))
                    end
                end
                fraction = 1.0 / 16.0
                fraction *= 2 if damageDoubled
                fraction *= 2 if curseActive?(:CURSE_BOOSTED_SAND)
                sandstormDamage += b.applyFractionalDamage(fraction)
            when :Hail
                next unless b.takesHailDamage?
                damageDoubled = pbCheckGlobalAbility(:BITTERCOLD)
                if showWeatherMessages
                    if damageDoubled
                        pbDisplay(_INTL("{1} is pummeled by the bitterly cold hail!", b.pbThis))
                    else
                        pbDisplay(_INTL("{1} is buffeted by the hail!", b.pbThis))
                    end
                end
                fraction = 1.0 / 16.0
                fraction *= 2 if damageDoubled
                fraction *= 2 if curseActive?(:CURSE_BOOSTED_HAIL)
                hailDamage += b.applyFractionalDamage(fraction)
            when :ShadowSky
                next unless b.takesShadowSkyDamage?
                pbDisplay(_INTL("{1} is hurt by the shadow sky!", b.pbThis)) if showWeatherMessages
                fraction = 1.0 / 16.0
                b.applyFractionalDamage(fraction)
            when :Moonglow
                # if b.pbHasType?(:FAIRY)
                #     healingMessage = _INTL("{1} absorbs the moonlight!", b.pbThis)
                #     healingAmount = b.applyFractionalHealing(1.0 / 16.0, showMessage: showWeatherMessages, customMessage: healingMessage)
                #     if healingAmount > 0 && b.hasActiveAbility?(:NIGHTLINE)
                #         potentialHeals = []
                #         @battle.pbParty(b.index).each_with_index do |pkmn,index|
                #             next if pkmn.fainted?
                #             next if pkmn.hp == pkmn.totalhp
                #             potentialHeals.push(pkmn)
                #         end
                #         unless potentialHeals.empty?
                #             healTarget = potentialHeals.sample
                #             pbDisplay(_INTL("{1} shares the healing with #{healTarget.name}!"))
                #             newHP = pkmn.hp + healingAmount
                #             newHP = pkmn.totalhp if newHP > pkmn.totalhp
                #             pkmn.hp = newHP
                #         end
                #     end
                # end
            end
        end
        # Ectoparticles
        if hailDamage > 0
            priority.each do |b|
                next unless b.hasActiveAbility?(:ECTOPARTICLES)
                pbShowAbilitySplash(b, :ECTOPARTICLES)
                healingMessage = _INTL("{1} absorbs the suffering from the hailstorm.", b.pbThis)
                b.pbRecoverHP(hailDamage, true, true, true, healingMessage)
                pbHideAbilitySplash(b)
            end
        end
        # Desert Scavenger
        if sandstormDamage > 0
            priority.each do |b|
                next unless b.hasActiveAbility?(:DESERTSCAVENGER)
                pbShowAbilitySplash(b, :DESERTSCAVENGER)
                healingMessage = _INTL("{1} absorbs the suffering from the sandstorm", b.pbThis)
                b.pbRecoverHP(sandstormDamage, true, true, true, healingMessage)
                pbHideAbilitySplash(b)
            end
        end
    end

    #=============================================================================
    # End Of Round terrain
    #=============================================================================
    def pbEORTerrain
        # Count down terrain duration
        @field.terrainDuration -= 1 if @field.terrainDuration > 0 && !@field.effectActive?(:TerrainSealant)
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
        when :Fairy    then pbDisplay(_INTL("Mist is swirling about the battlefield."))
        when :Psychic  then pbDisplay(_INTL("The battlefield is weird."))
        end
    end

    def grassyTerrainEOR(priority)
        return if @field.terrain != :Grassy
        # Status-curing effects/abilities and HP-healing items
        priority.each do |b|
            next if b.fainted?
            next unless b.affectedByTerrain?
            PBDebug.log("[Lingering effect] Grassy Terrain affects #{b.pbThis(true)}")
            fraction = 1.0 / 16.0
            healingMessage = _INTL("{1} is healed by the Grassy Terrain.", b.pbThis)
            b.applyFractionalHealing(fraction, customMessage: healingMessage)
            pbHideAbilitySplash(b) if b.hasActiveAbility?(:NESTING)
        end
    end

    def sunny?
        return %i[Sun HarshSun].include?(pbWeather)
    end

    def rainy?
        return %i[Rain HeavyRain].include?(pbWeather)
    end

    def partialEclipse?
        return pbWeather == :Eclipse && !@field.specialWeatherEffect
    end

    def totalEclipse?
        return pbWeather == :Eclipse && @field.specialWeatherEffect
    end

    def waxingMoon?
        return pbWeather == :Moonglow && !@field.specialWeatherEffect
    end

    def fullMoon?
        return pbWeather == :Moonglow && @field.specialWeatherEffect
    end
end
