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
            # This is done here because its skipped in pbSuccessCheckAgainstTarget
            if !uiOnlyCheck && user.targetInherentlyImmune?(user,target,self,ret,true)
                immunityPierced = true
                ret /= 2
            elsif ret == 0
                ret = 0.5
                immunityPierced = true
            end
        end

        # Explain to the player what is happening
        if immunityPierced && !uiOnlyCheck
            @battle.pbDisplay(_INTL("Near the avatar, immunities are resistances!"))
        end

        # Creep Out
        ret *= 2 if target.effectActive?(:CreepOut) && moveType == :BUG

        ret *= 2 if user.hasActiveItem?(:GRANDMASTERSCROLL)

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
    def pbCriticalOverride(user,target); return 0; end

    # Returns whether the attack is critical, and whether it was forced to be so
    def pbIsCritical?(user,target,checkingForAI=false)
        if !critsPossible?(user,target)
            if checkingForAI
                return 0
            else
                return [false,false] 
            end
        end

        crit = false
        forced = false
        rate = criticalHitRate(user,target)
        
        if guaranteedCrit?(user,target)
            crit = true
            forced = true
        end

        if !crit && isRandomCrit?(user,target,rate)
            crit = true
            forced = false
        end

        if crit && target.abilityActive? && !@battle.moldBreaker &&
                BattleHandlers.triggerCriticalPreventTargetAbility(target.ability,user,target,@battle)
            if !checkingForAI
                battle.pbShowAbilitySplash(target)
                battle.pbDisplay(_INTL("#{target.pbThis} prevents the hit from being critical!"))
                battle.pbHideAbilitySplash(target)
            end
            crit = false
            forced = true
        end

        if checkingForAI
            if forced
                return crit ? 5 : -1
            else
                return rate
            end
        else
            return crit,forced
        end
    end

    def isRandomCrit?(user,target,rate)
        return false if user.boss?

        # Calculation
        ratios = [16,8,4,2,1]
        rate = ratios.length - 1 if rate >= ratios.length
        return @battle.pbRandom(ratios[rate]) == 0
    end

    def criticalHitRate(user,target)
        c = 0
        # Ability effects that alter critical hit rate
        if user.abilityActive?
            c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,move,c)
        end
        if target.abilityActive? && !@battle.moldBreaker
            c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
        end
        # Item effects that alter critical hit rate
        if user.itemActive?
            c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
        end
        if target.itemActive?
            c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
        end

        c += 1 if highCriticalRate?
		c += user.effects[:FocusEnergy]
		c += 1 if user.effectActive?(:LuckyStar)
        c += 1 if user.inHyperMode? && @calcType == :SHADOW

        return c
    end

    def critsPossible?(user,target)
        return false if target.pbOwnSide.effectActive?(:LuckyChant)
        return false if applySunDebuff?(user,@calcType)
        return false if pbCriticalOverride(user,target) < 0
        return true
    end
  
	def guaranteedCrit?(user,target)
        return true if user.effectActive?(:LaserFocus) || user.effectActive?(:EmpoweredLaserFocus)
        return true if pbCriticalOverride(user,target) > 0
        return true if user.abilityActive? && BattleHandlers.triggerGuaranteedCriticalUserAbility(user.ability,user,target,@battle)
        return false
    end

    #=============================================================================
    # Antecedents for damage calculation
    #=============================================================================
    def pbBaseDamage(baseDmg,user,target);              return baseDmg;    end

    # For when the damage boost must be applied after the move usage has progressed
    # Or the damage mult is ugly and will result in weird display BP
    def pbModifyDamage(damageMult,user,target);         return damageMult; end

    def ignoresDefensiveStageBoosts?(user,target);           return false;       end
  
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

    def pbAttackingStat(user,target,checkingForAI=false)
        if specialAfterForcing?(user,target,checkingForAI)
          return user, :SPECIAL_ATTACK
        end
        return user, :ATTACK
    end
    
    def pbDefendingStat(user,target,checkingForAI=false)
        if specialAfterForcing?(user,target,checkingForAI)
            return target, :SPECIAL_DEFENSE
        end
        return target, :DEFENSE
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

    def pbAdditionalEffectChance(user,target,type,effectChance=0)
        return 0 if !canApplyAdditionalEffects?(user,target)
        ret = effectChance > 0 ? effectChance : @effectChance
        return 100 if ret >= 100
        ret *= 2 if user.hasActiveAbility?(:SERENEGRACE)
        ret *= 2 if user.pbOwnSide.effectActive?(:Rainbow)
        ret *= 4 if windMove? && user.hasActiveAbility?(:FUMIGATE)
        ret /= 2 if applyRainDebuff?(user,type)
        ret = 100 if debugControl
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
  