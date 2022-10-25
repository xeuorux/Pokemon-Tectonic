class PokeBattle_Move
    #=============================================================================
    # Move's type calculation
    #=============================================================================
    def pbBaseType(user)
      ret = @type
      if ret && user.abilityActive?
        ret = BattleHandlers.triggerMoveBaseTypeModifierAbility(user.ability,user,self,ret)
      end
      return ret
    end
  
    def pbCalcType(user)
      @powerBoost = false
      ret = pbBaseType(user)
      if ret && GameData::Type.exists?(:ELECTRIC)
        if @battle.field.effectActive?(:IonDeluge) && ret == :NORMAL
          ret = :ELECTRIC
          @powerBoost = false
        end
        if user.effectActive?(:Electrify)
          ret = :ELECTRIC
          @powerBoost = false
        end
      end
      return ret
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
        # Foresight/Scrappy
        if user.hasActiveAbility?(:SCRAPPY) || target.effectActive?(:Foresight)
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST && Effectiveness.ineffective_type?(moveType, defType)
        end
        # Miracle Eye
        if target.effectActive?(:MiracleEye)
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK && Effectiveness.ineffective_type?(moveType, defType)
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
        if target.effectActive?(:Inured)
            ret /= 2 if Effectiveness.super_effective_type?(moveType, defType)
        end
        # Tar Shot
        if target.effectActive?(:TarShot) && moveType == :FIRE
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

        immunityPierced = false

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
                typeMods[i] = newTypeMod
            end
        end

        # Multiply all effectivenesses together
        ret = 1
        typeMods.each { |m| ret *= m }
        
        # Partially pierce immunities
        if inherentImmunitiesPierced?(user,target)
            # Damaging moves that would be immune 
            if ret == 0
                ret = 0.5
                immunityPierced = true
            end

            # This is done here because its skipped in pbSuccessCheckAgainstTarget
            if !uiOnlyCheck && user.targetInherentlyImmune?(user,target,self,ret,true)
                immunityPierced = true
                ret /= 2
            end
        end

        # Explain to the player what is happening
        if immunityPierced && !uiOnlyCheck
            @battle.pbDisplay(_INTL("Near the avatar, immunities are resistances!"))
        end

        # Creep Out
        ret *= 2 if target.effectActive?(:CreepOut) && moveType == :BUG

        # Type effectiveness changing curses
        @battle.curses.each do |curse|
            ret = @battle.triggerEffectivenessChangeCurseEffect(curse,moveType,user,target,ret)
        end
        return ret
    end
  
    #=============================================================================
    # Accuracy check
    #=============================================================================
    def pbBaseAccuracy(user,target); return @accuracy; end
  
    # Accuracy calculations for one-hit KO moves and "always hit" moves are
    # handled elsewhere.
    def pbAccuracyCheck(user,target)
        # "Always hit" effects and "always hit" accuracy
        return true if target.effectActive?(:Telekinesis)
        baseAcc = pbBaseAccuracy(user,target)
        return true if baseAcc == 0
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
  
    def pbCalcAccuracyModifiers(user,target,modifiers)
      # Ability effects that alter accuracy calculation
      if user.abilityActive?
        BattleHandlers.triggerAccuracyCalcUserAbility(user.ability,
           modifiers,user,target,self,@calcType)
      end
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,
           modifiers,user,target,self,@calcType)
      end
      if target.abilityActive? && !@battle.moldBreaker
        BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,
           modifiers,user,target,self,@calcType)
      end
      # Item effects that alter accuracy calculation
      if user.itemActive?
        BattleHandlers.triggerAccuracyCalcUserItem(user.item,
           modifiers,user,target,self,@calcType)
      end
      if target.itemActive?
        BattleHandlers.triggerAccuracyCalcTargetItem(target.item,
           modifiers,user,target,self,@calcType)
      end
      # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to
      # specific values
      if @battle.field.effectActive?(:Gravity)
        modifiers[:accuracy_multiplier] *= 5 / 3.0
      end
      if user.effectActive?(:MicleBerry)
        user.disableEffect(:MicleBerry)
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target.effectActive?(:Foresight) && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effectActive?(:MiracleEye) && modifiers[:evasion_stage] > 0
    end
  
    #=============================================================================
    # Critical hit check
    #=============================================================================
    # Return values:
    #   -1: Never a critical hit.
    #    0: Calculate normally.
    #    1: Always a critical hit.
    def pbCritialOverride(user,target); return 0; end
  
        # Returns whether the move will be a critical hit
    # And whether the critical hit was forced by an effect
	def pbIsCritical?(user,target)
		return [false,false] if target.pbOwnSide.effectActive?(:LuckyChant)
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
		return [true,true] if user.effectActive?(:LaserFocus) || user.effectActive?(:EmpoweredLaserFocus)
		return [false,false] if user.boss?
		c += 1 if highCriticalRate?
		c += user.effects[:FocusEnergy]
		c += 1 if user.effectActive?(:LuckyStar)
		c = ratios.length-1 if c>=ratios.length
		# Calculation
		return [@battle.pbRandom(ratios[c]) == 0,false]
    end

    #=============================================================================
    # Antecedents for damage calculation
    #=============================================================================
    def pbBaseDamage(baseDmg,user,target);              return baseDmg;    end
    def pbBaseDamageMultiplier(damageMult,user,target); return damageMult; end
    def pbModifyDamage(damageMult,user,target);         return damageMult; end
  
    def forcedSpecial?(user,target,checkingForAI=false)
        return true if user.shouldAbilityApply?(:MYSTICFIST,checkingForAI) && punchingMove?
        return true if user.shouldAbilityApply?([:TIMEINTERLOPER,:SPACEINTERLOPER],checkingForAI)
        return false
    end

    def forcedPhysical?(user,target,checkingForAI=false)
        return false
    end

    def specialAfterForcing?(user,target,checkingForAI=false)
        isSpecial = specialMove?
        isSpecial = true if forcedSpecial?(user,target,checkingForAI)
        isSpecial = false if forcedPhysical?(user,target,checkingForAI)
        return isSpecial
    end

    def pbGetAttackStats(user,target,checkingForAI=false)
        if specialAfterForcing?(user,target,checkingForAI)
          return user.spatk, user.stages[:SPECIAL_ATTACK]+6
        end
        return user.attack, user.stages[:ATTACK]+6
    end
    
    def pbGetDefenseStats(user,target,checkingForAI=false)
        if specialAfterForcing?(user,target,checkingForAI)
            return target.spdef, target.stages[:SPECIAL_DEFENSE]+6
        end
        return target.defense, target.stages[:DEFENSE]+6
    end
  
    #=============================================================================
    # Additional effect chance
    #=============================================================================
    def canApplyAdditionalEffects?(user,target,showMessages=false)
        if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
            if showMessages
                battle.pbShowAbilitySplash(target)
                battle.pbHideAbilitySplash(target)
            end
            return false
        end
        return false if target.effectActive?(:Enlightened)
        return true
    end

    def pbAdditionalEffectChance(user,target,effectChance=0)
        return 0 if !canApplyAdditionalEffects?(user,target)
        ret = effectChance > 0 ? effectChance : @effectChance
        ret *= 2 if user.hasActiveAbility?(:SERENEGRACE)
        ret *= 2 if user.pbOwnSide.effectActive?(:Rainbow)
        ret *= 4 if windMove? && user.hasActiveAbility?(:FUMIGATE)
        ret /= 2 if applyRainDebuff?(user)
        ret = 100 if $DEBUG && Input.press?(Input::CTRL)
        return ret
    end
  
    # NOTE: Flinching caused by a move's effect is applied in that move's code,
    #       not here.
    def pbFlinchChance(user,target)
        return 0 if flinchingMove?
        return 0 if !canApplyAdditionalEffects?(user,target)
        ret = 0
        if user.hasActiveAbility?(:STENCH,true)
            ret = 50
        elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
            ret = 10
        end
        ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                    user.pbOwnSide.effectActive?(:Rainbow)
        return ret
    end
end
  