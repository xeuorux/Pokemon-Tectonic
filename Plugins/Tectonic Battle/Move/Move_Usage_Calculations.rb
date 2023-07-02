class PokeBattle_Move
    #=============================================================================
    # Move's type calculation
    #=============================================================================
    def pbBaseType(user)
      ret = @type
      if ret
        user.eachActiveAbility do |ability|
            ret = BattleHandlers.triggerMoveBaseTypeModifierAbility(ability,user,self,ret)
        end
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
        tTypes.each_with_index do |type,i|
            newTypeMod = pbCalcTypeModSingle(moveType,type,user,target)
            typeMods[i] = newTypeMod
        end

        # Multiply all effectivenesses together
        ret = 1
        typeMods.each { |m| ret *= m }
        
        # Partially pierce immunities
        if inherentImmunitiesPierced?(user,target)
            # This is done here because its skipped in pbSuccessCheckAgainstTarget
            if !uiOnlyCheck && user.targetInherentlyImmune?(user,target,self)
                immunityPierced = true
                ret /= 2
            elsif user.targetTypeModImmune?(user,target,self,ret,!uiOnlyCheck)
                ret = 4.0 # Weird effectiveness stuff present here
                immunityPierced = true
            end
        end

        # Explain to the player what is happening
        if immunityPierced && !uiOnlyCheck && $PokemonSystem.avatar_mechanics_messages == 0
            if AVATARS_REGULAR_ATTACKS_PIERCE_IMMUNITIES
                @battle.pbDisplay(_INTL("Near the avatar, immunities are resistances!"))
            else
                @battle.pbDisplay(_INTL("The Empowered attack pierced the immunity!"))
            end
        end

        # Creep Out
        ret *= 2 if target.effectActive?(:CreepOut) && moveType == :BUG

        # Tar Shot
        ret *= 2 if target.effectActive?(:TarShot) && moveType == :FIRE

        # Modify effectiveness for bosses
        ret = Effectiveness.modify_boss_effectiveness(ret, user, target)

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
        modifiers[:accuracy_step] = user.steps[:ACCURACY]
        modifiers[:evasion_step]  = target.steps[:EVASION]
        modifiers[:accuracy_multiplier] = 1.0
        modifiers[:evasion_multiplier]  = 1.0
        pbCalcAccuracyModifiers(user,target,modifiers)
        # Check if move can't miss
        return true if modifiers[:base_accuracy] == 0
        # Calculation
        statBoundary = PokeBattle_Battler::STAT_STEP_BOUND
        accStep = modifiers[:accuracy_step].clamp(-statBoundary, statBoundary)
        evaStep = modifiers[:evasion_step].clamp(-statBoundary, statBoundary)
        accuracy = 100.0 * user.statMultiplierAtStep(accStep)
        evasion  = 100.0 * user.statMultiplierAtStep(evaStep)
        accuracy = (accuracy.to_f * modifiers[:accuracy_multiplier].to_f).round
        evasion  = (evasion.to_f  * modifiers[:evasion_multiplier].to_f).round
        accuracy = (accuracy.to_f + 100.0) / 2.0 if user.boss? && AVATAR_DILUTED_STAT_STEPS
        evasion = (evasion.to_f + 100.0) / 2.0 if target.boss? && AVATAR_DILUTED_STAT_STEPS
        evasion = 1 if evasion < 1
        # Calculation
        calc = accuracy.to_f / evasion.to_f
        return @battle.pbRandom(100) < modifiers[:base_accuracy] * calc
    end
  
    def pbCalcAccuracyModifiers(user,target,modifiers,aiChecking=false,aiType=nil)
        typeToUse = aiChecking ? aiType : @calcType
        # Ability effects that alter accuracy calculation
        user.eachAbilityShouldApply(aiChecking) do |ability|
            BattleHandlers.triggerAccuracyCalcUserAbility(ability,modifiers,user,target,self,typeToUse)
        end
        user.eachAlly do |b|
            b.eachAbilityShouldApply(aiChecking) do |ability|
                BattleHandlers.triggerAccuracyCalcUserAllyAbility(ability,modifiers,user,target,self,typeToUse)
            end
        end
        unless @battle.moldBreaker
            target.eachAbilityShouldApply(aiChecking) do |ability|
                BattleHandlers.triggerAccuracyCalcTargetAbility(ability,modifiers,user,target,self,typeToUse)
            end
        end
        # Item effects that alter accuracy calculation
        user.eachActiveItem do |item|
            BattleHandlers.triggerAccuracyCalcUserItem(item,modifiers,user,target,self,typeToUse,aiChecking)
        end
        target.eachActiveItem do |item|
            BattleHandlers.triggerAccuracyCalcTargetItem(item,modifiers,user,target,self,typeToUse)
        end
        # Other effects, inc. ones that set accuracy_multiplier or evasion_step to
        # specific values
        modifiers[:accuracy_multiplier] *= 2.0 if @battle.field.effectActive?(:Gravity)

        modifiers[:evasion_step] = 0 if target.effectActive?(:Foresight) && modifiers[:evasion_step] > 0
        modifiers[:evasion_step] = 0 if target.effectActive?(:MiracleEye) && modifiers[:evasion_step] > 0

        if aiChecking
            modifiers[:evasion_step] = 0 if @function == "0A9" # Chip Away
            modifiers[:base_accuracy] = 0 if ["0A5", "139", "13A", "13B", "13C", "147"].include?(@name) # "Always hit"
            modifiers[:base_accuracy] = 0 if user.effectActive?(:LockOn) && user.pointsAt?(:LockOnPos, target)
        end
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

        # Critical prevention effects
        if crit
            unless @battle.moldBreaker
                target.eachActiveAbility do |ability|
                    next unless BattleHandlers.triggerCriticalPreventTargetAbility(ability,user,target,@battle)
                    unless checkingForAI
                        battle.pbShowAbilitySplash(target,ability)
                        battle.pbDisplay(_INTL("#{target.pbThis} prevents the hit from being critical!"))
                        battle.pbHideAbilitySplash(target)
                    end
                    crit = false
                    forced = true
                    break
                end
            end

            # Tactician tribe prevents random crits
            if !forced && target.hasTribeBonus?(:TACTICIAN)
                unless checkingForAI
                    battle.pbShowTribeSplash(target,:TACTICIAN)
                    battle.pbDisplay(_INTL("#{target.pbThis} prevents the hit from being critical!"))
                    battle.pbHideTribeSplash(target)
                end
                crit = false
                forced = true
            end
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
        user.eachActiveAbility do |ability|
            c = BattleHandlers.triggerCriticalCalcUserAbility(ability,user,target,self,c)
        end
        unless @battle.moldBreaker
            target.eachActiveAbility do |ability|
                c = BattleHandlers.triggerCriticalCalcTargetAbility(ability,user,target,c)
            end
        end
        # Item effects that alter critical hit rate
        user.eachActiveAbility do |item|
            c = BattleHandlers.triggerCriticalCalcUserItem(item,user,target,c)
        end
        target.eachActiveItem do |item|
            c = BattleHandlers.triggerCriticalCalcTargetItem(item,user,target,c)
        end

        if veryHighCriticalRate?
            c += 2
        elsif highCriticalRate?
            c += 1
        end
		c += user.effects[:FocusEnergy]
		c += 1 if user.effectActive?(:LuckyStar)
        c += 1 if user.inHyperMode? && @calcType == :SHADOW

        return c
    end

    def critsPossible?(user,target)
        return false if target.pbOwnSide.effectActive?(:LuckyChant)
        return false if target.pbOwnSide.effectActive?(:DiamondField) && !(user && user.hasActiveAbility?(:INFILTRATOR))
        return false if applySunDebuff?(user,@calcType)
        return false if pbCriticalOverride(user,target) < 0
        return true
    end
  
	def guaranteedCrit?(user,target)
        return true if user.effectActive?(:LaserFocus) || user.effectActive?(:EmpoweredLaserFocus)
        return true if user.effectActive?(:LuckyCheer)
        return true if pbCriticalOverride(user,target) > 0
        user.eachActiveAbility do |ability|
            return true if BattleHandlers.triggerGuaranteedCriticalUserAbility(ability,user,target,@battle)
        end
        return false
    end

    #=============================================================================
    # Antecedents for damage calculation
    #=============================================================================
    def pbBaseDamage(baseDmg,user,target);              return baseDmg;    end

    # For when the damage boost must be applied after the move usage has progressed
    # Or the damage mult is ugly and will result in weird display BP
    def pbModifyDamage(damageMult,user,target);         return damageMult; end

    def ignoresDefensiveStepBoosts?(user,target);           return false;       end
  
    def forcedSpecial?(user,target,checkingForAI=false)
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
    def canApplyRandomAddedEffects?(user,target,showMessages=false,aiChecking=false)
        unless @battle.moldBreaker
            %i[SHIELDDUST HARSHTRAINING].each do |ability|
                if target.shouldAbilityApply?(ability,aiChecking)
                    if showMessages
                        battle.pbShowAbilitySplash(target,ability)
                        battle.pbDisplay(_INTL("#{target.pbThis} prevents a random added effect!"))
                        battle.pbHideAbilitySplash(target)
                    end
                    return false
                end
            end
        end
        if target.pbOwnSide.effectActive?(:DiamondField) && !(user && user.hasActiveAbility?(:INFILTRATOR))
            if showMessages
                battle.pbDisplay(_INTL("The Diamond Field protects #{target.pbThis} from a random added effect!"))
            end
        end
        if target.effectActive?(:Enlightened)
            if showMessages
                battle.pbDisplay(_INTL("#{target.pbThis} is enlightened, and so ignores a random added effect!"))
            end
            return false
        end
        if target.hasActiveItem?(:COVERTCLOAK) && user.opposes?(target)
            if showMessages
                battle.pbDisplay(_INTL("#{target.pbThis}'s #{getItemName(:COVERTCLOAK)} protects it from a random added effect!"))
            end
            return false
        end
        return true
    end

    def pbAdditionalEffectChance(user,target,type,effectChance=0,aiChecking = false)
        return 100 if user.hasActiveAbility?(:STARSALIGN) && @battle.eclipsed?
        return 100 if user.hasActiveAbility?(:WISHMAKER) || target.hasActiveAbility?(:WISHMAKER)
        return 100 if !user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_PERFECT_LUCK)
        ret = effectChance > 0 ? effectChance : @effectChance
        return 100 if ret >= 100 || debugControl
        ret += 20 if user.hasTribeBonus?(:FORTUNE)
        ret += 50 if windMove? && user.hasActiveAbility?(:FUMIGATE)
        ret += 50 if bitingMove? && user.hasActiveAbility?(:GNAWING)
        ret *= 1.5 if flinchingMove? && user.hasActiveAbility?(:RATTLEEM)
        ret *= 2 if flinchingMove? && user.hasActiveAbility?(:TERRORIZE)
        ret *= 2 if user.hasActiveAbility?(:SERENEGRACE)
        ret *= 2 if user.pbOwnSide.effectActive?(:Rainbow)
        ret /= 2 if applyRainDebuff?(user,type)
        ret /= 2 if target.hasTribeBonus?(:SERENE)
        if ret < 100 && user.hasActiveItem?(:LUCKHERB)
            ret = 100
            user.applyEffect(:LuckHerbConsumed) unless aiChecking
        end
        return ret
    end
  
    # NOTE: Flinching caused by a move's effect is applied in that move's code,
    #       not here.
    def pbFlinchChance(user,target)
        return 0 if flinchingMove?
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
  