class PokeBattle_Move
    #=============================================================================
    # Move's type calculation
    #=============================================================================
    def pbBaseType(user)
        ret = @type
        if ret
            user.eachActiveAbility do |ability|
                ret = BattleHandlers.triggerMoveBaseTypeModifierAbility(ability, user, self, ret)
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
    def pbCalcTypeModSingle(moveType, defType, user = nil, target = nil)
        ret = Effectiveness.calculate_one(moveType, defType)
        # Ring Target
        if target&.hasActiveItem?(:RINGTARGET) && Effectiveness.ineffective_type?(moveType, defType)
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        # Delta Stream's weather
        if @battle&.pbWeather == :StrongWinds && (defType == :FLYING && Effectiveness.super_effective_type?(moveType, defType))
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        # Grounded Flying-type Pokémon become susceptible to Ground moves
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE if !target&.airborne? && (defType == :FLYING && moveType == :GROUND)
        # Inured
        ret /= 2 if target&.effectActive?(:Inured) && Effectiveness.super_effective_type?(moveType, defType)
        # Break Through
        if user&.hasActiveAbility?(:BREAKTHROUGH) && Effectiveness.ineffective_type?(moveType, defType)
            ret = Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        return ret
    end

    def pbCalcTypeMod(moveType, user, target, uiOnlyCheck = false)
        return Effectiveness::NORMAL_EFFECTIVE unless moveType
        if moveType == :GROUND && target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
            return Effectiveness::NORMAL_EFFECTIVE
        end

        # Determine types
        tTypes = target.pbTypes(true, uiOnlyCheck)

        immunityPierced = false

        # Get effectivenesses
        typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3 # 3 types max
        tTypes.each_with_index do |type, i|
            newTypeMod = pbCalcTypeModSingle(moveType, type, user, target)
            typeMods[i] = newTypeMod
        end

        # Multiply all effectivenesses together
        ret = 1
        typeMods.each { |m| ret *= m }

        # Partially pierce immunities
        if inherentImmunitiesPierced?(user, target)
            # This is done here because its skipped in pbSuccessCheckAgainstTarget
            if !uiOnlyCheck && user.targetInherentlyImmune?(user, target, self)
                immunityPierced = true
                ret /= 2
            elsif user.targetTypeModImmune?(user, target, self, ret, !uiOnlyCheck)
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
            ret = @battle.triggerEffectivenessChangeCurseEffect(curse, moveType, user, target, ret)
        end

        return ret
    end

    #=============================================================================
    # Accuracy check
    #=============================================================================
    def pbBaseAccuracy(_user, _target); return @accuracy; end

    # Accuracy calculations for one-hit KO moves and "always hit" moves are
    # handled elsewhere.
    def pbAccuracyCheck(user, target)
        # "Always hit" effects and "always hit" accuracy
        return true if target.effectActive?(:Telekinesis)
        baseAcc = pbBaseAccuracy(user, target)
        return true if baseAcc == 0
        # Calculate all multiplier effects
        modifiers = {}
        modifiers[:base_accuracy] = baseAcc
        modifiers[:accuracy_step] = user.steps[:ACCURACY]
        modifiers[:evasion_step]  = target.steps[:EVASION]
        modifiers[:accuracy_multiplier] = 1.0
        modifiers[:evasion_multiplier]  = 1.0
        pbCalcAccuracyModifiers(user, target, modifiers)
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

    def pbCalcAccuracyModifiers(user, target, modifiers, aiCheck = false, aiType = nil)
        typeToUse = aiCheck ? aiType : @calcType
        # Ability effects that alter accuracy calculation
        user.eachAbilityShouldApply(aiCheck) do |ability|
            BattleHandlers.triggerAccuracyCalcUserAbility(ability, modifiers, user, target, self, typeToUse)
        end
        user.eachAlly do |b|
            b.eachAbilityShouldApply(aiCheck) do |ability|
                BattleHandlers.triggerAccuracyCalcUserAllyAbility(ability, modifiers, user, target, self, typeToUse)
            end
        end
        unless @battle.moldBreaker
            target.eachAbilityShouldApply(aiCheck) do |ability|
                BattleHandlers.triggerAccuracyCalcTargetAbility(ability, modifiers, user, target, self, typeToUse)
            end
        end
        # Item effects that alter accuracy calculation
        user.eachActiveItem do |item|
            BattleHandlers.triggerAccuracyCalcUserItem(item, modifiers, user, target, self, typeToUse, aiCheck)
        end
        target.eachActiveItem do |item|
            BattleHandlers.triggerAccuracyCalcTargetItem(item, modifiers, user, target, self, typeToUse)
        end
        # Other effects, inc. ones that set accuracy_multiplier or evasion_step to
        # specific values
        modifiers[:accuracy_multiplier] *= 2.0 if @battle.field.effectActive?(:Gravity)
        modifiers[:accuracy_multiplier] *= 1.5 if user.effectActive?(:Spotting)

        if aiCheck
            modifiers[:evasion_step] = 0 if @function == "IgnoreTargetDefSpDefEvaStatStages" # Chip Away
            if %w[AlwaysHits RemoveProtectionsBypassSubstituteAlwaysHits HyperspaceFury].include?(@name)
                modifiers[:base_accuracy] = 0
            end # "Always hit"
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
    def pbCriticalOverride(_user, _target); return 0; end

    # Returns whether the attack is critical, and whether it was forced to be so
    def pbIsCritical?(user, target, checkingForAI = false)
        unless critsPossible?(user, target)
            if checkingForAI
                return 0
            else
                return [false, false]
            end
        end

        crit = false
        forced = false
        rate = criticalHitRate(user, target)

        if guaranteedCrit?(user, target)
            crit = true
            forced = true
        end

        if !crit && isRandomCrit?(user, target, rate)
            crit = true
            forced = false
        end

        # Critical prevention effects
        if crit
            unless @battle.moldBreaker
                target.eachActiveAbility do |ability|
                    next unless BattleHandlers.triggerCriticalPreventTargetAbility(ability, user, target, @battle)
                    unless checkingForAI
                        battle.pbShowAbilitySplash(target, ability)
                        battle.pbDisplay(_INTL("#{target.pbThis} prevents the hit from being critical!"))
                        battle.pbHideAbilitySplash(target)
                    end
                    crit = false
                    forced = true
                    break
                end
            end

            # Tactician tribe prevents random crits
            if target.hasTribeBonus?(:TACTICIAN)
                unless checkingForAI
                    battle.pbShowTribeSplash(target, :TACTICIAN)
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
            return crit, forced
        end
    end

    def isRandomCrit?(user, _target, rate)
        return false if user.boss?

        # Calculation
        ratios = [16, 8, 4, 2, 1]
        rate = ratios.length - 1 if rate >= ratios.length
        return @battle.pbRandom(ratios[rate]) == 0
    end

    def criticalHitRate(user, target)
        c = 0
        # Ability effects that alter critical hit rate
        user.eachActiveAbility do |ability|
            c = BattleHandlers.triggerCriticalCalcUserAbility(ability, user, target, self, c)
        end
        unless @battle.moldBreaker
            target.eachActiveAbility do |ability|
                c = BattleHandlers.triggerCriticalCalcTargetAbility(ability, user, target, c)
            end
        end
        # Item effects that alter critical hit rate
        user.eachActiveItem do |item|
            c = BattleHandlers.triggerCriticalCalcUserItem(item, user, target, c)
        end
        target.eachActiveItem do |item|
            c = BattleHandlers.triggerCriticalCalcTargetItem(item, user, target, c)
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

    def critsPossible?(user, target)
        return false if target.pbOwnSide.effectActive?(:LuckyChant)
        return false if target.pbOwnSide.effectActive?(:DiamondField) && !(user && user.hasActiveAbility?(:INFILTRATOR))
        return false if applySunDebuff?(user, @calcType)
        return false if pbCriticalOverride(user, target) < 0
        return true
    end

    def guaranteedCrit?(user, target)
        return true if user.effectActive?(:LaserFocus) || user.effectActive?(:EmpoweredLaserFocus)
        return true if user.effectActive?(:LuckyCheer)
        return true if pbCriticalOverride(user, target) > 0
        user.eachActiveAbility do |ability|
            return true if BattleHandlers.triggerGuaranteedCriticalUserAbility(ability, user, target, @battle)
        end
        return false
    end

    #=============================================================================
    # Antecedents for damage calculation
    #=============================================================================
    def pbBaseDamage(baseDmg, _user, _target);              return baseDmg;    end

    # For when the damage boost must be applied after the move usage has progressed
    # Or the damage mult is ugly and will result in weird display BP
    def pbModifyDamage(damageMult, _user, _target);         return damageMult; end

    def ignoresDefensiveStepBoosts?(_user, _target); return false; end

    def forcedSpecial?(user, _target, checkingForAI = false)
        return true if user.shouldAbilityApply?(%i[TIMEINTERLOPER SPACEINTERLOPER], checkingForAI)
        return false
    end

    def forcedPhysical?(user, _target, checkingForAI = false)
        return true if user.shouldAbilityApply?([:BRUTEFORCE], checkingForAI)
        return false
    end

    def specialAfterForcing?(user, target, checkingForAI = false)
        isSpecial = specialMove?
        isSpecial = true if forcedSpecial?(user, target, checkingForAI)
        isSpecial = false if forcedPhysical?(user, target, checkingForAI)
        return isSpecial
    end

    def pbAttackingStat(user, target, checkingForAI = false)
        return user, :SPECIAL_ATTACK if specialAfterForcing?(user, target, checkingForAI)
        return user, :ATTACK
    end

    def pbDefendingStat(user, target, checkingForAI = false)
        return target, :SPECIAL_DEFENSE if specialAfterForcing?(user, target, checkingForAI)
        return target, :DEFENSE
    end

    #=============================================================================
    # Additional effect chance
    #=============================================================================
    def canApplyRandomAddedEffects?(user, target, showMessages = false, aiCheck = false)
        unless @battle.moldBreaker
            target.eachAbilityShouldApply(aiCheck) do |ability|
                next unless BattleHandlers.triggerPreventAddedEffectTargetAbility(ability, @battle, user, target, self,
showMessages)
                return false
            end
        end
        if target.shouldItemApply?(:COVERTCLOAK, aiCheck) && user.opposes?(target)
            if showMessages
                battle.pbDisplay(_INTL("#{target.pbThis}'s #{getItemName(:COVERTCLOAK)} protects it from a random added effect!"))
                target.aiLearnsItem(:COVERTCLOAK)
            end
            return false
        end
        return true
    end

    def pbAdditionalEffectChance(user, target, type, effectChance = 0, aiCheck = false)
        return 100 if @battle.pbCheckGlobalAbility(:WISHMAKER)
        # Abilities ensure effect chance
        user.eachAbilityShouldApply(aiCheck) do |ability|
            return 100 if BattleHandlers.triggerCertainAddedEffectUserAbility(ability, @battle, user, target, self)
        end
        return 100 if !user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_PERFECT_LUCK)
        ret = effectChance > 0 ? effectChance : @effectChance
        return 100 if ret >= 100 || debugControl
        ret += 20 if user.hasTribeBonus?(:FORTUNE)

        # User's abilities modify effect chance
        user.eachAbilityShouldApply(aiCheck) do |ability|
            ret = BattleHandlers.triggerAddedEffectChanceModifierUserAbility(ability, user, target, self, ret)
        end

        # Target's abilities modify effect chance
        unless @battle.moldBreaker
            target.eachAbilityShouldApply(aiCheck) do |ability|
                ret = BattleHandlers.triggerAddedEffectChanceModifierTargetAbility(ability, user, target, self, ret)
            end
        end

        ret *= 2 if user.pbOwnSide.effectActive?(:Rainbow)
        ret /= 2 if applyRainDebuff?(user, type)
        ret /= 2 if target.hasTribeBonus?(:SERENE)
        if ret < 100 && user.shouldItemApply?(:LUCKHERB, aiCheck)
            ret = 100
            user.applyEffect(:LuckHerbConsumed) unless aiCheck
        end
        return ret
    end

    # NOTE: Flinching caused by a move's effect is applied in that move's code,
    #       not here.
    def pbFlinchChance(user, _target)
        return 0 if flinchingMove?
        ret = 0
        ret = 50 if user.hasActiveAbility?(:STENCH, true)
        ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                    user.pbOwnSide.effectActive?(:Rainbow)
        return ret
    end
end
