class PokeBattle_Move
    #=============================================================================
    # Effect methods per move usage
    #=============================================================================
    def pbCanChooseMove?(_user, _commandPhase, _showMessages); return true; end # For Belch
    def pbDisplayChargeMessage(user); end # For Focus Punch/shell Trap/Beak Blast
    def pbOnStartUse(user, targets); end
    def pbAddTarget(targets, user); end # For Counter, etc. and Bide
    def pbModifyTargets(targets, user); end # For Dragon Darts, etc.
    def pbAllMissed(user, targets); end # Move effects that occur after all hits if all of them missed

    def pbEffectOnNumHits(user, target, numHits);
 end # Move effects that occur after all hits, which base themselves on how many hits landed

    def pbMoveFailedNoSpecial?(_user, _targets)
        return false
    end # Check if the move should fail, specifically if its not being specifically used (e.g. Dancer)

    def priorityModification(_user, _target); return 0; end # Checks whether the move should have modified priority
    def moveFailed(user, targets); end

    # Reset move usage counters (child classes can increment them).
    def pbChangeUsageCounters(user, _specialUsage)
        [user, @battle.field].each do |effectHolder|
            effectHolder.eachEffect(true) do |effect, _value, data|
                next unless data.resets_on_move_start
                effectHolder.disableEffect(effect)
            end
        end
    end

    def calculateCategory(user, targets)
        return selectBestCategory(user, targets[0]) if user.hasActiveAbility?(:MYSTICFIST)
        return -1
    end

    #=============================================================================
    # Methods for displaying stuff when the move is used
    #=============================================================================
    def pbDisplayUseMessage(user, _targets = [])
        displayZMoveUseMessage(user) if zMove? && !@specialUseZMove

        if empoweredMove?
            unless @battle.autoTesting
                @battle.pbDisplayWithFormatting(_INTL("\\ss{1} used <c2=06644bd2>{2}</c2>!", user.pbThis,
@name))
            end
        else
            @battle.pbDisplayBrief(_INTL("{1} used {2}!", user.pbThis, @name))
        end
    end

    def displayZMoveUseMessage(user)
        @battle.pbCommonAnimation("ZPower", user, nil) if @battle.scene.pbCommonAnimationExists?("ZPower")
        PokeBattle_ZMove.from_status_move(@battle, @id, user) if statusMove?
        @battle.pbDisplay(_INTL("{1} surrounded itself with its Z-Power!", user.pbThis)) unless statusMove?
        @battle.pbDisplay(_INTL("{1} unleashed its full force Z-Move!", user.pbThis))
    end

    def displayDamagingMoveMessages(user, calcType, targets = [])
        displayBPAdjustmentMessage(user, targets) unless multiHitMove?
        # Display messages letting the player know that weather is debuffing a move (if it is)
        displayWeatherDebuffMessages(user, calcType) if $PokemonSystem.weather_messages == 0
    end

    def displayBPAdjustmentMessage(user, targets)
        targets.each do |target|
            bp = pbBaseDamage(@baseDamage, user, target).floor
            if bp != @baseDamage
                if targets.length == 1
                    @battle.pbDisplayBrief(_INTL("Its base power was adjusted to {1}!", bp))
                else
                    @battle.pbDisplayBrief(_INTL("Its base power was adjusted to {1} against {2}!", bp,
target.pbThis(true)))
                end
            end
        end
    end

    def displayWeatherDebuffMessages(user, type)
        if applyRainDebuff?(user, type)
            if @battle.pbCheckGlobalAbility(:DREARYCLOUDS)
                @battle.pbDisplay(_INTL("{1}'s attack is dampened a lot by the dreary rain.", user.pbThis))
            else
                @battle.pbDisplay(_INTL("{1}'s attack is dampened by the rain.", user.pbThis))
            end
        end
        if applySunDebuff?(user, type)
            if @battle.pbCheckGlobalAbility(:BLINDINGLIGHT)
                @battle.pbDisplay(_INTL("{1} is blinded by the bright light of the sun.", user.pbThis))
            else
                @battle.pbDisplay(_INTL("{1} is distracted by the shining sun.", user.pbThis))
            end
        end
    end

    def pbMissMessage(_user, _target); return false; end
    def pbShowFailMessages?(_targets); return true; end

    #=============================================================================
    #
    #=============================================================================
    # Whether the move is currently in the "charging" turn of a two turn attack.
    # Is false if Power Herb or another effect lets a two turn move charge and
    # attack in the same turn.
    # user.effects[:TwoTurnAttack] is set to the move's ID during the
    # charging turn, and is nil during the attack turn.
    def pbIsChargingTurn?(_user); return false; end
    def pbDamagingMove?; return damagingMove?; end

    def canParentalBond?(user, targets, checkingForAI = false)
        return false unless pbDamagingMove?
        return false if chargingTurnMove?
        return false unless targets.length == 1
        return true if user.shouldAbilityApply?(:PARENTALBOND,checkingForAI)
        return true if user.shouldAbilityApply?(:STRIKESTWICE,checkingForAI) && @battle.rainy?
        return false
    end

    def numberOfHits(user, targets, checkingForAI = false)
        calcedHits = calcNumHits(user, targets, checkingForAI)

        if user.shouldAbilityApply?(:LONGODDS, checkingForAI) && multiHitMove? && pbDamagingMove?
            calcedHits2 = calcNumHits(user, targets, checkingForAI)
            if checkingForAI
                calcedHits += calcedHits2
            else
                calcedHits += @battle.pbRandom(calcedHits2 + 1)
            end
        end

        return calcedHits
    end

    def calcNumHits(user, targets, checkingForAI = false)
        if checkingForAI
            return pbNumHitsAI(user, targets)
        else
            return pbNumHits(user, targets, checkingForAI)
        end
    end

    # The maximum number of hits in a round this move will actually perform. This
    # can be 1 for Beat Up, and can be 2 for any moves affected by Parental Bond.
    def pbNumHits(user, targets, checkingForAI = false)
        return 2 if canParentalBond?(user, targets, checkingForAI)
        numHits = 1
        numHits += 1 if user.shouldAbilityApply?(:SPACEINTERLOPER, checkingForAI) && pbDamagingMove?
        numHits += 1 if user.effectActive?(:VolleyStance) && specialMove?
        return numHits
    end

    #=============================================================================
    # Effect methods per hit
    #=============================================================================
    def pbOverrideSuccessCheckPerHit(_user, _target); return false; end
    def pbCrashDamage(user); end
    def pbInitialEffect(user, targets, hitNum); end
    def pbDesignateTargetsForHit(targets, _hitNum); return targets; end # For Dragon Darts
    def pbRepeatHit?(_hitNum = 0); return false; end # For Dragon Darts

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        return if @autoTesting
        return unless showAnimation
        if user.effects[:ParentalBond] == 1
            @battle.pbCommonAnimation("ParentalBond", user, targets)
        else
            @battle.pbAnimation(id, user, targets, hitNum)
        end
    end

    def pbSelfKO(user); end
    def pbEffectBeforeDealingDamage(user, target); end
    def pbEffectWhenDealingDamage(user, target); end
    def pbEffectAgainstTarget(user, target); end
    def pbEffectGeneral(user); end
    def pbAdditionalEffect(user, target); end
    def pbEffectAfterAllHits(user, target); end # Move effects that occur after all hits
    def pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers); end
    def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers); end

    #=============================================================================
    # Check if target is immune to the move because of its ability
    #=============================================================================
    def pbImmunityByAbility(user, target, showMessages = true, aiChecking = false)
        return false if @battle.moldBreaker
        ret = false
        if target.abilityActive?
            ret = BattleHandlers.triggerMoveImmunityTargetAbility(target.ability, user, target, self, @calcType, @battle,
showMessages, aiChecking)
        end
        unless ret
            target.eachAlly do |b|
                next unless b.abilityActive?
                ret = BattleHandlers.triggerMoveImmunityAllyAbility(b.ability, user, target, self, @calcType, @battle, b,
showMessages)
                break if ret
            end
        end
        return ret
    end

    #=============================================================================
    # Move failure checks
    #=============================================================================
    # Check whether the move fails completely due to move-specific requirements.
    def pbMoveFailed?(_user, _targets, _show_message); return false; end

    # Checks whether the move will be ineffective against the target.
    def pbFailsAgainstTarget?(_user, _target, _show_message); return false; end

    def pbMoveFailedAI?(user, targets)
        return pbMoveFailed?(user, targets, false)
    end

    def pbFailsAgainstTargetAI?(user, target)
        return pbFailsAgainstTarget?(user, target, false)
    end

    def pbMoveFailedLastInRound?(user, showMessage = true)
        unmoved = false
        @battle.eachBattler do |b|
            next if b.index == user.index
            next if @battle.choices[b.index][0] != :UseMove && @battle.choices[b.index][0] != :Shift
            next if b.movedThisRound?
            unmoved = true
            break
        end
        unless unmoved
            @battle.pbDisplay(_INTL("But it failed!")) if showMessage
            return true
        end
        return false
    end

    def pbMoveFailedTargetAlreadyMoved?(target, showMessage = true)
        if (@battle.choices[target.index][0] != :UseMove &&
           @battle.choices[target.index][0] != :Shift) || target.movedThisRound?
            @battle.pbDisplay(_INTL("But it failed!")) if showMessage
            return true
        end
        return false
    end

    def pbMoveFailedAromaVeil?(_user, target, showMessage = true)
        return false if @battle.moldBreaker
        if target.hasActiveAbility?(:AROMAVEIL)
            if showMessage
                @battle.pbShowAbilitySplash(target)
                @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
                @battle.pbHideAbilitySplash(target)
            end
            return true
        end
        target.eachAlly do |b|
            next unless b.hasActiveAbility?(:AROMAVEIL)
            if showMessage
                @battle.pbShowAbilitySplash(target)
                @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
                @battle.pbHideAbilitySplash(target)
            end
            return true
        end
        return false
    end

    #=============================================================================
    # Weaken the damage dealt (doesn't actually change a battler's HP)
    #=============================================================================
    def pbCheckDamageAbsorption(user, target)
        # Substitute will take the damage
        if target.substituted? && !ignoresSubstitute?(user) && (!user || user.index != target.index)
            target.damageState.substitute = true
            return
        end
        # Disguise will take the damage
        if !@battle.moldBreaker && target.isSpecies?(:MIMIKYU) && target.form == 0 && target.ability == :DISGUISE
            target.damageState.disguise = true
            return
        end
        # Ice Face will take the damage
        if !@battle.moldBreaker && target.species == :EISCUE && target.form == 0 && target.ability == :ICEFACE && physicalMove?
            target.damageState.iceface = true
            return
        end
    end

    def pbReduceDamage(user, target)
        damage = target.damageState.calcDamage
        target.damageState.displayedDamage = damage
        # Substitute takes the damage
        if target.damageState.substitute
            damage = target.effects[:Substitute] if damage > target.effects[:Substitute]
            target.damageState.hpLost       = damage
            target.damageState.totalHPLost += damage
            target.damageState.displayedDamage = damage
            return
        end
        # Disguise takes the damage
        if target.damageState.disguise
            target.damageState.displayedDamage = 0
            return
        end
        # Ice Face takes the damage
        if target.damageState.iceface
            target.damageState.displayedDamage = 0
            return
        end
        # Target takes the damage
        damageAdjusted = false
        if damage >= target.hp
            damage = target.hp
            # Survive a lethal hit with 1 HP effects
            if nonLethal?(user, target)
                damage -= 1
                damageAdjusted = true
            elsif target.effectActive?(:Endure)
                target.damageState.endured = true
                damage -= 1
                damageAdjusted = true
            elsif target.effectActive?(:EmpoweredEndure)
                target.damageState.endured = true
                damage -= 1
                damageAdjusted = true
                target.tickDownAndProc(:EmpoweredEndure)
            elsif target.hasActiveAbility?(:DIREDIVERSION) && !target.item.nil? && target.itemActive? && !@battle.moldBreaker
                target.damageState.direDiversion = true
                damage -= 1
                damageAdjusted = true
            elsif damage == target.totalhp
                if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
                    target.damageState.sturdy = true
                    damage -= 1
                    damageAdjusted = true
                elsif target.hasActiveAbility?(:DANGERSENSE) && !@battle.moldBreaker
                    target.damageState.dangerSense = true
                    damage -= 1
                    damageAdjusted = true
                elsif (target.hasActiveItem?(FULL_ENDURE_ITEMS) && target.hp == target.totalhp) || target.hasActiveItem?(:CLARITYSASH)
                    target.damageState.focusSash = true
                    damage -= 1
                    damageAdjusted = true
                elsif target.hasActiveItem?(:CASSBERRY) && target.hp == target.totalhp
                    target.damageState.endureBerry = true
                    damage -= 1
                    damageAdjusted = true
                elsif target.hasActiveItem?(:FOCUSBAND) && @battle.pbRandom(100) < 10
                    target.damageState.focusBand = true
                    damage -= 1
                    damageAdjusted = true
                end
            end
        end
        target.damageState.displayedDamage = damage if damageAdjusted
        damage = 0 if damage < 0
        target.damageState.displayedDamage = 0 if target.damageState.displayedDamage < 0
        target.damageState.hpLost       = damage
        target.damageState.totalHPLost += damage
    end

    #=============================================================================
    # Change the target's HP by the amount calculated above
    #=============================================================================
    def pbInflictHPDamage(target)
        if target.damageState.substitute
            target.effects[:Substitute] -= target.damageState.hpLost
        else
            target.hp -= target.damageState.hpLost
        end
    end

    #=============================================================================
    # Animate the damage dealt, including lowering the HP
    #=============================================================================
    # Animate being damaged and losing HP (by a move)
    def pbAnimateHitAndHPLost(user, targets, fastHitAnimation = false)
        return if @battle.autoTesting
        # Animate allies first, then foes
        animArray = []
        for side in 0...2 # side here means "allies first, then foes"
            targets.each do |b|
                next if b.damageState.unaffected || b.damageState.hpLost == 0
                next if (side == 0 && b.opposes?(user)) || (side == 1 && !b.opposes?(user))
                if b.damageState.substitute
                    oldHP = b.hp
                else
                    oldHP = b.hp + b.damageState.hpLost
                end
                PBDebug.log("[Move damage] #{b.pbThis} lost #{b.damageState.hpLost} HP (#{oldHP}=>#{b.hp})")
                effectiveness = b.damageState.typeMod / Effectiveness::NORMAL_EFFECTIVE
                animArray.push([b, oldHP, effectiveness])
            end
            if animArray.length > 0
                @battle.scene.pbHitAndHPLossAnimation(animArray, fastHitAnimation)
                animArray.clear
            end
        end
    end

    #=============================================================================
    # Messages upon being hit
    #=============================================================================
    def pbEffectivenessMessage(_user, target, numTargets = 1)
        return if target.damageState.disguise
        return if target.damageState.iceface
        return if defined?($PokemonSystem.effectiveness_messages) && $PokemonSystem.effectiveness_messages == 1
        if Effectiveness.hyper_effective?(target.damageState.typeMod)
            if numTargets > 1
                @battle.pbDisplay(_INTL("It's hyper effective on {1}!", target.pbThis(true)))
            else
                @battle.pbDisplay(_INTL("It's hyper effective!"))
            end
        elsif Effectiveness.super_effective?(target.damageState.typeMod)
            if numTargets > 1
                @battle.pbDisplay(_INTL("It's super effective on {1}!", target.pbThis(true)))
            else
                @battle.pbDisplay(_INTL("It's super effective!"))
            end
        elsif Effectiveness.barely_effective?(target.damageState.typeMod)
            if numTargets > 1
                @battle.pbDisplay(_INTL("It's barely effective on {1}...", target.pbThis(true)))
            else
                @battle.pbDisplay(_INTL("It's barely effective..."))
            end
        elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
            if numTargets > 1
                @battle.pbDisplay(_INTL("It's not very effective on {1}...", target.pbThis(true)))
            else
                @battle.pbDisplay(_INTL("It's not very effective..."))
            end
        end
    end

    def pbHitEffectivenessMessages(user, target, numTargets = 1)
        return if target.damageState.disguise
        return if target.damageState.iceface
        if target.damageState.substitute
            @battle.pbDisplay(_INTL("The substitute took damage for {1}!", target.pbThis(true)))
        end
        if target.damageState.critical
            onAddendum = numTargets > 1 ? " on #{target.pbThis(true)}" : ""
            if target.damageState.forced_critical
                @battle.pbDisplay(_INTL("#{user.pbThis} performed a critical attack#{onAddendum}!"))
            else
                @battle.pbDisplay(_INTL("A critical hit#{onAddendum}!"))
            end
        end
        # Effectiveness message, for moves with 1 hit
        pbEffectivenessMessage(user, target, numTargets) if target.damageState.messagesPerHit
        if target.damageState.substitute && !target.substituted? # Substitute ran out of HP
            target.disableEffect(:Substitute)
            @battle.pbDisplay(_INTL("{1}'s substitute faded!", target.pbThis))
        end
    end

    def pbEndureKOMessage(target)
        if target.damageState.disguise
            @battle.pbShowAbilitySplash(target)
            @battle.pbDisplay(_INTL("Its disguise served it as a decoy!"))
            @battle.pbHideAbilitySplash(target)
            target.pbChangeForm(1, _INTL("{1}'s disguise was busted!", target.pbThis))
        elsif target.damageState.iceface
            @battle.pbShowAbilitySplash(target)
            target.pbChangeForm(1, _INTL("{1} transformed!", target.pbThis))
            @battle.pbHideAbilitySplash(target)
        elsif target.damageState.endured
            @battle.pbDisplay(_INTL("{1} endured the hit!", target.pbThis))
        elsif target.damageState.sturdy
            @battle.pbShowAbilitySplash(target)
            @battle.pbDisplay(_INTL("{1} endured the hit!", target.pbThis))
            @battle.pbHideAbilitySplash(target)
        elsif target.damageState.dangerSense
            @battle.pbShowAbilitySplash(target)
            @battle.pbDisplay(_INTL("{1} avoided taking the full hit!", target.pbThis))
            @battle.pbHideAbilitySplash(target)
        elsif target.damageState.focusSash
            @battle.pbCommonAnimation("UseItem", target)
            @battle.pbDisplay(_INTL("{1} hung on using its {2}!", target.pbThis, target.itemName))
            target.pbConsumeItem
        elsif target.damageState.focusBand
            @battle.pbCommonAnimation("UseItem", target)
            @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!", target.pbThis))
        elsif target.damageState.direDiversion
            @battle.pbDisplay(_INTL("{1} blocked the hit with its item! It barely hung on!", target.pbThis))
            target.pbConsumeItem
        elsif target.damageState.endureBerry
            @battle.pbDisplay(_INTL("{1} hung on by consuming its {2}!", target.pbThis, target.itemName))
            target.pbConsumeItem
        end
    end

    # Used by Counter/Mirror Coat/Metal Burst/Revenge/Focus Punch/Bide/Assurance.
    def pbRecordDamageLost(user, target)
        damage = target.damageState.hpLost
        # NOTE: In Gen 3 where a move's category depends on its type, Hidden Power
        #       is for some reason countered by Counter rather than Mirror Coat,
        #       regardless of its calculated type. Hence the following two lines of
        #       code.
        moveType = nil
        moveType = :NORMAL if @function == "090" # Hidden Power
        if physicalMove?(moveType)
            target.applyEffect(:Counter, damage)
            target.pointAt(:CounterTarget, user)
        elsif specialMove?(moveType)
            target.applyEffect(:MirrorCoat, damage)
            target.pointAt(:MirrorCoatTarget, user)
        end
        if target.effectActive?(:Bide)
            target.effects[:BideDamage] += damage
            target.pointAt(:BideTarget, user) if user.index != target.index
        end
        target.damageState.fainted = true if target.fainted?
        target.lastHPLost = damage # For Focus Punch
        target.tookDamage = true if damage > 0 # For Assurance
        target.lastAttacker.push(user.index) # For Revenge
        if target.opposes?(user)
            target.lastHPLostFromFoe = damage # For Metal Burst
            target.lastFoeAttacker.push(user.index)        # For Metal Burst
            if target.damageState.typeMod > target.lastRoundHighestTypeModFromFoe
                target.lastRoundHighestTypeModFromFoe = target.damageState.typeMod
            end
        end
    end
end
