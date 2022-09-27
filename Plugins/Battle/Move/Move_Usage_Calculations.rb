class PokeBattle_Move
      #=============================================================================
    # Type effectiveness calculation
    #=============================================================================
    def pbCalcTypeModSingle(moveType,defType,user,target)
        ret = Effectiveness.calculate_one(moveType, defType)
        # Ring Target
        if target.hasActiveItem?(:RINGTARGET)
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.ineffective_type?(moveType, defType)
        end
        # Foresight/Scrappy
        if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST && Effectiveness.ineffective_type?(moveType, defType)
        end
        # Miracle Eye
        if target.effects[PBEffects::MiracleEye]
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK && Effectiveness.ineffective_type?(moveType, defType)
        end
        # Creep Out
        if target.effects[PBEffects::CreepOut] && moveType == :BUG
            ret *= 2
        end
        # Delta Stream's weather
        if @battle.pbWeather == :StrongWinds
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING && Effectiveness.super_effective_type?(moveType, defType)
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
            ret *= 2
        end
        # Break Through
        if user.hasActiveAbility?(:BREAKTHROUGH) && Effectiveness.ineffective_type?(moveType, defType)
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        return ret
    end
    
    def pbCalcTypeMod(moveType,user,target,uiOnlyCheck=false)
        return Effectiveness::NORMAL_EFFECTIVE if !moveType
        return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND && target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
        # Determine types
        tTypes = target.pbTypes(true,uiOnlyCheck)
        # Get effectivenesses
        typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
        if moveType == :SHADOW
        if target.shadowPokemon?
            typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
        else
            typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
        end
        else
        tTypes.each_with_index do |type,i|
            newTypeMod = pbCalcTypeModSingle(moveType,type,user,target)
            if @battle.bossBattle? && newTypeMod == 0
            newTypeMod = 0.5
            @battle.pbDisplay(_INTL("Within the avatar's aura, immunities are resistances!")) if !uiOnlyCheck
            end
            typeMods[i] = newTypeMod
        end
        end
        # Multiply all effectivenesses together
        ret = 1
        typeMods.each { |m| ret *= m }
        
        # Late boss specific immunity abilities check
        if !uiOnlyCheck && @battle.bossBattle? && damagingMove?
        if pbImmunityByAbility(user,target)
            @battle.pbDisplay(_INTL("Except, within the avatar's aura, immunities are resistances!"))
            ret /= 2
        elsif moveType == :GROUND && target.airborne? && !hitsFlyingTargets? && target.hasLevitate? && !@battle.moldBreaker
            @battle.pbDisplay(_INTL("Except, within the avatar's aura, immunities are resistances!"))
            ret /= 2
        end
        end
        # Type effectiveness changing curses
        @battle.curses.each do |curse|
        ret = @battle.triggerEffectivenessChangeCurseEffect(curse,moveType,user,target,ret)
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
        if user.boss?
            accuracy = (accuracy.to_f + 100.0) / 2.0
        end
        evasion  = (evasion.to_f  * modifiers[:evasion_multiplier].to_f).round
        if target.boss?
            evasion = (evasion.to_f + 100.0) / 2.0
        end
        evasion = 1 if evasion < 1
        # Calculation
        calc = accuracy.to_f / evasion.to_f
        return @battle.pbRandom(100) < modifiers[:base_accuracy] * calc
    end

    def applyRainDebuff?(user)
        return RAIN_DEBUFF_ACTIVE && !immuneToRainDebuff?() && [:Rain, :HeavyRain].include?(@battle.field.weather) && user.debuffedByRain?
    end

    def applySunDebuff?(user)
        return SUN_DEBUFF_ACTIVE && !immuneToSunDebuff?() && [:Sun, :HarshSun].include?(@battle.field.weather) && user.debuffedBySun?
    end

    # Returns whether the move will be a critical hit
    # And whether the critical hit was forced by an effect
	def pbIsCritical?(user,target)
		return [false,false] if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
        return [false,false] if applySunDebuff?(user)
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
		return [false,false] if c<0
		# Move-specific "always/never a critical hit" effects
		case pbCritialOverride(user,target)
		when 1  then return [true,true]
		when -1 then return [false,false]
		end
		# Other effects
		return [true,true] if c > 50   # Merciless and similar abilities
		return [true,true] if user.effects[PBEffects::LaserFocus] > 0 || user.effects[PBEffects::EmpoweredLaserFocus]
		return [false,false] if user.boss?
		c += 1 if highCriticalRate?
		c += user.effects[PBEffects::FocusEnergy]
		c += 1 if user.effects[PBEffects::LuckyStar]
		c = ratios.length-1 if c>=ratios.length
		# Calculation
		return [@battle.pbRandom(ratios[c]) == 0,false]
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
        stageMul = PokeBattle_Battler::STAGE_MULTIPLIERS
        stageDiv = PokeBattle_Battler::STAGE_DIVISORS
        # Get the move's type
        type = @calcType   # nil is treated as physical
        # Calculate whether this hit deals critical damage
        target.damageState.critical,target.damageState.forced_critical = pbIsCritical?(user,target)
        # Calcuate base power of move
        baseDmg = pbBaseDamage(@baseDamage,user,target)
        # Calculate user's attack stat
        atk, atkStage = pbGetAttackStats(user,target)
        if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
            atkStage = 6 if target.damageState.critical && atkStage<6
            calc = stageMul[atkStage].to_f/stageDiv[atkStage].to_f
            calc = (calc.to_f + 1.0)/2.0 if user.boss?
            atk = (atk.to_f*calc).floor
        end
        # Calculate target's defense stat
        defense, defStage = pbGetDefenseStats(user,target)
        if !user.hasActiveAbility?(:UNAWARE)
            if defStage > 6 && (target.damageState.critical || user.hasActiveAbility?(:INFILTRATOR))
                defStage = 6
            end
            calc = stageMul[defStage].to_f/stageDiv[defStage].to_f
            calc = (calc.to_f + 1.0)/2.0 if target.boss?
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
        echoln("The calculated base damage multiplier: #{multipliers[:base_damage_multiplier]}")
        echoln("The calculated attack and defense multipliers: #{multipliers[:attack_multiplier]},#{multipliers[:defense_multiplier]}")
        echoln("The calculated final damage multiplier: #{multipliers[:final_damage_multiplier]}")
        # Main damage calculation
        baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
        atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
        defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
        damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
        damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
        target.damageState.calcDamage = damage
    end
    
    def pbCalcAbilityDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        # Global abilities
        if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
            (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
            if @battle.pbCheckGlobalAbility(:AURABREAK)
                multipliers[:base_damage_multiplier] *= 2 / 3.0
            else
                multipliers[:base_damage_multiplier] *= 4 / 3.0
            end
        end
        if @battle.pbCheckGlobalAbility(:RUINOUS)
            multipliers[:base_damage_multiplier] *= 1.2
        end
        # Ability effects that alter damage
        if user.abilityActive?
            BattleHandlers.triggerDamageCalcUserAbility(user.ability,user,target,self,multipliers,baseDmg,type)
        end
        if !@battle.moldBreaker
            # NOTE: It's odd that the user's Mold Breaker prevents its partner's
            #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
            #       how it works.
            user.eachAlly do |b|
                next if !b.abilityActive?
                BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,user,target,self,multipliers,baseDmg,type)
            end
            if target.abilityActive?
                BattleHandlers.triggerDamageCalcTargetAbility(target.ability,user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
                BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,user,target,self,multipliers,baseDmg,type)
            end
            target.eachAlly do |b|
                next if !b.abilityActive?
                BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,user,target,self,multipliers,baseDmg,type)
            end
        end
    end

    def pbCalcTerrainDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        # Terrain moves
        case @battle.field.terrain
        when :Electric
            multipliers[:base_damage_multiplier] *= 1.3 if type == :ELECTRIC && user.affectedByTerrain?
        when :Grassy
            multipliers[:base_damage_multiplier] *= 1.3 if type == :GRASS && user.affectedByTerrain?
        when :Psychic
            multipliers[:base_damage_multiplier] *= 1.3 if type == :PSYCHIC && user.affectedByTerrain?
        when :Misty
            multipliers[:base_damage_multiplier] *= 1.3 if type == :FAIRY && target.affectedByTerrain?
        end
    end

    def pbCalcWeatherDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        case @battle.pbWeather
        when :Sun, :HarshSun
            if type == :FIRE
                multipliers[:final_damage_multiplier] *= @battle.pbWeather == :HarshSun ? 1.5 : 1.3
            elsif applySunDebuff?(user)
                if @battle.pbCheckGlobalAbility(:BLINDINGLIGHT)
                    multipliers[:final_damage_multiplier] *= 0.7
                else
                    multipliers[:final_damage_multiplier] *= 0.85
                end
            end
        when :Rain, :HeavyRain
            if type == :WATER
                    multipliers[:final_damage_multiplier] *= @battle.pbWeather == :HeavyRain ? 1.5 : 1.3
            elsif applyRainDebuff?(user)
                if @battle.pbCheckGlobalAbility(:DREARYCLOUDS)
                    multipliers[:final_damage_multiplier] *= 0.7
                else
                    multipliers[:final_damage_multiplier] *= 0.85
                end
            end
        when :Swarm
            if type == :DRAGON || type == :BUG
                multipliers[:final_damage_multiplier] *= 1.3
            end
        when :Sandstorm
            if target.pbHasType?(:ROCK) && specialMove? && @function != "122"   # Psyshock/Psystrike
                multipliers[:defense_multiplier] *= 1.5
            end
        when :Hail
            if target.pbHasType?(:ICE) && physicalMove? && @function != "506"   # Soul Claw/Rip
                multipliers[:defense_multiplier] *= 1.5
            end
        end
    end

    def pbCalcStatusesDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        # Burn
        if user.burned? && physicalMove? && damageReducedByBurn? && !user.hasActiveAbility?(:GUTS) && !user.hasActiveAbility?(:BURNHEAL)
            damageReduction = user.boss? ? (1.0/5.0) : (1.0/3.0)
            damageReduction *= 2 if user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:final_damage_multiplier] *= (1.0 - damageReduction)
        end
        # Frostbite
        if user.frostbitten? && specialMove? && damageReducedByBurn? && !user.hasActiveAbility?(:AUDACITY) && !user.hasActiveAbility?(:FROSTHEAL)
            damageReduction = user.boss? ? (1.0/5.0) : (1.0/3.0)
            damageReduction *= 2 if user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:final_damage_multiplier] *= (1.0 - damageReduction)
        end
        # Numb
        if user.paralyzed?
            damageReduction = user.boss? ? (3.0/20.0) : (1.0/4.0)
            damageReduction *= 2 if user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:final_damage_multiplier] *= (1.0 - damageReduction)
        end
        # Fluster
        if user.flustered? && physicalMove? && @function != "122" && !user.hasActiveAbility?(:FLUSTERFLOCK) && !user.hasActiveAbility?(:MARVELSCALE)
            defenseDecrease = target.boss? ? (1.0/5.0) : (1.0/3.0)
            defenseDecrease *= 2 if target.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:defense_multiplier] *= (1.0 - defenseDecrease)
        end
        # Mystified
        if user.mystified? && specialMove? && @function != "506" && !user.hasActiveAbility?(:HEADACHE) && !user.hasActiveAbility?(:MARVELSKIN)
            defenseDecrease = target.boss? ? (1.0/5.0) : (1.0/3.0)
            defenseDecrease *= 2 if target.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:defense_multiplier] *= (1.0 - defenseDecrease)
        end
    end

    def pbCalcProtectionsDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        # Aurora Veil, Reflect, Light Screen
        if !ignoresReflect? && !target.damageState.critical && !user.hasActiveAbility?(:INFILTRATOR)
            if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
            if @battle.pbSideBattlerCount(target)>1
                multipliers[:final_damage_multiplier] *= 2 / 3.0
            else
                multipliers[:final_damage_multiplier] *= 0.5
            end
        elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
            if @battle.pbSideBattlerCount(target)>1
                multipliers[:final_damage_multiplier] *= 2 / 3.0
            else
                multipliers[:final_damage_multiplier] *= 0.5
            end
        elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
            if @battle.pbSideBattlerCount(target) > 1
                multipliers[:final_damage_multiplier] *= 2 / 3.0
            else
                multipliers[:final_damage_multiplier] *= 0.5
            end
            end
        end
        # Partial protection moves
        if target.effects[PBEffects::StunningCurl]
            multipliers[:final_damage_multiplier] *= 0.5
        end
        if target.effects[PBEffects::EmpoweredDetect] > 0
            multipliers[:final_damage_multiplier] *= 0.5
        end
        if target.pbOwnSide.effects[PBEffects::Bulwark]
            multipliers[:final_damage_multiplier] *= 0.5
        end
        # For when bosses are partway piercing protection
        if target.damageState.partiallyProtected
            multipliers[:final_damage_multiplier] *= 0.5
        end
    end

    def pbCalcTypeBasedDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        # STAB
        if !user.pbOwnedByPlayer? || !@battle.curses.include?(:DULLED)
            if type && user.pbHasType?(type)
                stab = 1.5
                if user.hasActiveAbility?(:ADAPTED)
                    stab *= 4.0/3.0
                elsif user.hasActiveAbility?(:ULTRAADAPTED)
                    stab *= 3.0/2.0
                end
                multipliers[:final_damage_multiplier] *= stab
            end
        end
        # Type effectiveness
        typeEffect = target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
        multipliers[:final_damage_multiplier] *= typeEffect
        # Charge
        if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
            multipliers[:base_damage_multiplier] *= 2
        end
        # Mud Sport
        if type == :ELECTRIC
            @battle.eachBattler do |b|
            next if !b.effects[PBEffects::MudSport]
                multipliers[:base_damage_multiplier] /= 3.0
                break
            end
            if @battle.field.effects[PBEffects::MudSportField]>0
                m ultipliers[:base_damage_multiplier] /= 3.0
            end
        end
        # Water Sport
        if type == :FIRE
            @battle.eachBattler do |b|
            next if !b.effects[PBEffects::WaterSport]
                multipliers[:base_damage_multiplier] /= 3.0
            break
            end
            if @battle.field.effects[PBEffects::WaterSportField]>0
                multipliers[:base_damage_multiplier] /= 3.0
            end
        end
    end
      
    def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        pbCalcAbilityDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        pbCalcTerrainDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        pbCalcWeatherDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        pbCalcStatusesDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        pbCalcTypeBasedDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
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
            multipliers[:base_damage_multiplier] *= 0.25
        end
        # Other
        if user.effects[PBEffects::MeFirst]
            multipliers[:base_damage_multiplier] *= 1.5
        end
        if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
            multipliers[:base_damage_multiplier] *= 1.5
        end
        # Dragon Ride
        if user.effects[PBEffects::OnDragonRide] && physicalMove?
            multipliers[:final_damage_multiplier] *= 1.5
        end
        # Shimmering Heat
        if target.effects[PBEffects::ShimmeringHeat]
            echoln("Target is protected by Shimmering Heat")
            multipliers[:final_damage_multiplier] *= 0.67
        end
        # Multi-targeting attacks
        if numTargets > 1
            multipliers[:final_damage_multiplier] *= 0.75
        end
        # Battler properites
        multipliers[:base_damage_multiplier] *= user.dmgMult
        multipliers[:base_damage_multiplier] *= [0,(1.0 - target.dmgResist.to_f)].max
        echoln("User's damage mult is #{user.dmgMult} and the target's damage resist is #{target.dmgResist}")
        # Critical hits
        if target.damageState.critical
            if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
                multipliers[:final_damage_multiplier] *= 1.5
            else
                multipliers[:final_damage_multiplier] *= 2
            end
        end
        # Random variance (What used to be for that)
        if !self.is_a?(PokeBattle_Confusion) && !self.is_a?(PokeBattle_Charm)
            multipliers[:final_damage_multiplier] *= 0.9
        end
        # Move-specific base damage modifiers
        multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
        # Move-specific final damage modifiers
        multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
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
        ret /= 2 if applyRainDebuff?(user)
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
            ret = 50
        elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
            ret = 10
        end
        ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                    user.pbOwnSide.effects[PBEffects::Rainbow]>0
        return ret
    end
end