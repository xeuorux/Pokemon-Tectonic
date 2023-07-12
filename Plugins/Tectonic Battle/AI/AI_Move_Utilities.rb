class PokeBattle_AI
    #=============================================================================
    #
    #=============================================================================
    def pbTargetsMultiple?(move, user)
        target_data = move.pbTarget(user)
        return false if target_data.num_targets <= 1
        num_targets = 0
        case target_data.id
        when :UserAndAllies
            @battle.eachSameSideBattler(user) { |_b| num_targets += 1 }
        when :AllNearFoes
            @battle.eachOtherSideBattler(user) { |b| num_targets += 1 if b.near?(user) }
        when :AllFoes
            @battle.eachOtherSideBattler(user) { |_b| num_targets += 1 }
        when :AllNearOthers
            @battle.eachBattler { |b| num_targets += 1 if b.near?(user) }
        when :AllBattlers
            @battle.eachBattler { |_b| num_targets += 1 }
        end
        return num_targets > 1
    end

    def pbCalcTypeModAI(moveType, user, target, move)
        return Effectiveness::NORMAL_EFFECTIVE unless moveType
        return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
                                                  target.pbHasTypeAI?(:FLYING) && target.hasActiveItem?(:IRONBALL)
        # Determine types
        allowIllusion = !target.aiKnowsAbility?(:ILLUSION)
        tTypes = target.pbTypes(true, allowIllusion)
        # Get effectivenesses
        typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3 # 3 types max
        tTypes.each_with_index do |defType, i|
            typeMods[i] = move.pbCalcTypeModSingle(moveType, defType, user, target)
        end
        # Multiply all effectivenesses together
        ret = 1
        typeMods.each { |m| ret *= m }
        # Modify effectiveness for bosses
        ret = Effectiveness.modify_boss_effectiveness(ret, user, target)
        return ret
    end

    #=============================================================================
    # Move failure
    #=============================================================================
    def aiPredictsFailure?(move, user, target, boss = false)
        fails = false

        if !boss && user.effectActive?(:Flinch) && !user.effectActive?(:FlinchImmunity)
            echoln("[AI FAILURE CHECK] #{user.pbThis} rejects the move #{move.id} due to it being predicted to flinch (Moonglow?)")
            return true
        end

        # Falsify the turn count so that the AI is calculated as though we are actually
        # in the midst of performing the move (turnCount is incremented as the attack phase begins)
        user.turnCount += 1

        # Move blocking abilities make the move fail here
        @battle.pbPriority(true).each do |b|
            next unless b
            abilityBlocked = false
            b.eachAIKnownActiveAbility do |ability|
                next unless BattleHandlers.triggerMoveBlockingAbility(ability, b, user, [target], move, @battle)
                abilityBlocked = true
                break
            end
            next unless abilityBlocked
            fails = true
            echoln("[AI FAILURE CHECK] #{user.pbThis} rejects #{move.id} -- thinks will be blocked by an ability.")
            break
        end

        if move.pbMoveFailedAI?(user, [target])
            fails = true
            echoln("[AI FAILURE CHECK] #{user.pbThis} rejects #{move.id} -- thinks will fail.")
        end

        # Check for ineffective because of abilities or effects on the target
        unless user.index == target.index
            type = pbRoughType(move, user)
            typeMod = pbCalcTypeModAI(type, user, target, move)
            unless user.pbSuccessCheckAgainstTarget(move, user, target, typeMod, false, true)
                fails = true
                echoln("[AI FAILURE CHECK] #{user.pbThis} rejects #{move.id} -- thinks will fail against #{target.pbThis(false)} due to abilities, effects, or typemod.")
            end
        end

        # Magic Bounce/Magic Shield checks for moves which don't target
        if user.index == target.index && move.canMagicCoat? && !@battle.moldBreaker
            @battle.eachBattler do |b|
                next unless b.opposes?(user)
                next if b.semiInvulnerable?
                next unless b.hasActiveAbilityAI?(%i[MAGICBOUNCE MAGICSHIELD])
                echoln("[AI FAILURE CHECK] #{user.pbThis} rejects #{move.id} -- thinks will fail against #{target.pbThis(false)} due to Magic Bounce etc.")
                fails = true
                break
            end
        end

        user.turnCount -= 1

        return fails
    end

    def moveFailureAlert(move, user, target, failureMessage)
        echoln("#{user.pbThis(true)} thinks that move #{move.id} against target #{target.pbThis(true)} will fail due to #{failureMessage}")
    end

    #=============================================================================
    # Get a move's base damage value
    #=============================================================================
    def pbMoveBaseDamageAI(move, user, target)
        baseDmg = move.baseDamage
        baseDmg = move.pbBaseDamageAI(baseDmg, user, target)
        return baseDmg
    end

    #=============================================================================
    # Damage calculation
    #=============================================================================
    def pbTotalDamageAI(move, user, target, numTargets = 1)
        # Get the move's type
        type = pbRoughType(move, user)

        baseDmg = pbMoveBaseDamageAI(move, user, target)

        # Calculate the damage for one hit
        damage = move.calculateDamageForHit(user, target, type, baseDmg, numTargets, true)

        # Estimate how many hits the move will do
        numHits = move.numberOfHits(user, [target], true)

        # Calculate the total estimated damage of all hits
        totalDamage = damage * numHits

        # Reduce damage down to substitute level
        if target.substituted? && !move.ignoresSubstitute?(user)
            totalDamage = [totalDamage,target.effects[:Substitute]].min
        end

        return totalDamage.floor
    end

    #===========================================================================
    # Accuracy calculation
    #===========================================================================
    def pbRoughAccuracy(move, user, target)
        return 100 if target.effectActive?(:Telekinesis)
        baseAcc = move.accuracy
        return 100 if baseAcc == 0
        baseAcc = move.pbBaseAccuracy(user, target)
        return 100 if baseAcc == 0
        # Get the move's type
        type = pbRoughType(move, user)
        # Calculate all modifier effects
        modifiers = {}
        modifiers[:base_accuracy]  = baseAcc
        modifiers[:accuracy_step] = user.steps[:ACCURACY]
        modifiers[:evasion_step]  = target.steps[:EVASION]
        modifiers[:accuracy_multiplier] = 1.0
        modifiers[:evasion_multiplier]  = 1.0
        move.pbCalcAccuracyModifiers(user, target, modifiers, true, type)
        # Calculation
        statBoundary = PokeBattle_Battler::STAT_STEP_BOUND
        accStep = modifiers[:accuracy_step].clamp(-statBoundary, statBoundary)
        evaStep = modifiers[:evasion_step].clamp(-statBoundary, statBoundary)
        accuracy = 100.0 * user.statMultiplierAtStep(accStep)
        evasion  = 100.0 * user.statMultiplierAtStep(evaStep)
        accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
        evasion  = (evasion  * modifiers[:evasion_multiplier]).round
        evasion = 1 if evasion < 1
        # Value always hit moves if otherwise would be hard to hit here
        if modifiers[:base_accuracy] == 0
            return (accuracy / evasion < 1) ? 125 : 100
        end
        return modifiers[:base_accuracy] * accuracy / evasion
    end
end
