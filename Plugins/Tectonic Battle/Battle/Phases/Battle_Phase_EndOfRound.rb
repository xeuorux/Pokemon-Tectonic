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

        # Reset the echoed voice counter unless anyone used echoed voice this turn
        @sides.each do |side|
            side.disableEffect(:EchoedVoiceCounter) unless side.effectActive?(:EchoedVoiceUsed)
        end

        # Tick down or reset battle effects
        allEffectHolders do |effectHolder|
            effectHolder.processEffectsEOR
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
            b.modifyTrackersEOR
        end

        # Neutralizing Gas
        pbCheckNeutralizingGas

        checkForInvalidEffectStates

        @endOfRound = false
    end

    def pbEORHealing(priority)
        # Status-curing effects/abilities and HP-healing items
        priority.each do |b|
            next if b.fainted?
            # Healer, Hydration, Shed Skin
            b.eachActiveAbility do |ability|
                BattleHandlers.triggerEORHealingAbility(ability, b, self)
            end
            # Black Sludge, Leftovers
            b.eachActiveItem do |item|
                BattleHandlers.triggerEORHealingItem(item, b, self)
            end
        end
    end

    def damageFromDOTStatus(battler, status)
        if battler.takesIndirectDamage?
            fraction = 1.0 / 8.0
            fraction *= 2 if battler.pbOwnedByPlayer? && curseActive?(:CURSE_STATUS_DOUBLED)
            if status == :POISON
                battler.getPoisonDoublings.times do
                    fraction *= 2
                end
            end
            damage = 0
            battler.pbContinueStatus(status) do
                damage = battler.applyFractionalDamage(fraction)
            end
            triggerDOTDeathDialogue(battler) if battler.fainted?
            return damage
        end
        return 0
    end

    def healFromStatusAbility(ability, battler, status, denom = 12)
        statusEffectMessages = !defined?($PokemonSystem.status_effect_messages) || $PokemonSystem.status_effect_messages == 0
        if battler.canHeal?
            anim_name = GameData::Status.get(status).animation
            pbCommonAnimation(anim_name, battler) if anim_name
            ratio = 1.0 / denom.to_f
            battler.applyFractionalHealing(ratio, ability: ability, showMessage: statusEffectMessages)
        end
    end

    def pbEORDamage(priority)
        # Damage from Hyper
        priority.each do |b|
            next if !b.inHyperMode? || @choices[b.index][0] != :UseMove
            pbDisplay(_INTL("The Hyper Mode attack hurts {1}!", b.pbThis(true)))
            b.applyFractionalDamage(1.0 / 24.0)
        end
        # Damage from poisoning
        priority.each do |b|
            next if b.fainted?
            next unless b.poisoned?
            healFromStatusAbility(:POISONHEAL, b, :POISON, 4) if b.hasActiveAbility?(:POISONHEAL)
            damageFromDOTStatus(b, :POISON)

            # Venom Gorger
            if b.getStatusCount(:POISON) % 3 == 0
                b.eachOpposing do |opposingB|
                    next unless opposingB.hasActiveAbility?(:VENOMGORGER)
                    healingMessage = _INTL("{1} slurped up venom leaking from #{b.pbThis(true)}.")
                    fraction = 1.0 / 3.0
                    fraction *= b.getPoisonDoublings
                    opposingB.applyFractionalHealing(fraction, ability: :VENOMGORGER, customMessage: healingMessage)
                end
            end
        end
        # Damage from burn
        priority.each do |b|
            next if b.fainted?
            next unless b.burned?
            if b.hasActiveAbility?(:BURNHEAL)
                healFromStatusAbility(:BURNHEAL, b, :BURN)
            else
                damageFromDOTStatus(b, :BURN)
            end
        end
        # Damage from frostbite
        priority.each do |b|
            next if b.fainted?
            next unless b.frostbitten?
            if b.hasActiveAbility?(:FROSTHEAL)
                healFromStatusAbility(:FROSTHEAL, b, :FROSTBITE)
            else
                damageFromDOTStatus(b, :FROSTBITE)
            end
        end
        # Leeched
        priority.each do |b|
            next if b.fainted?
            next unless b.leeched?
            enemyCount = 0
            b.eachOpposing do |opposingBattler|
                enemyCount += 1
            end
            next if enemyCount == 0
            leechedHP = damageFromDOTStatus(b, :LEECHED)
            next if leechedHP <= 0
            healthRestore = leechedHP / enemyCount.to_f
            b.eachOpposing do |opposingBattler|
                opposingBattler.pbRecoverHPFromDrain(healthRestore, b)
            end
        end
    end

    def countDownPerishSong(priority)
        # Perish Song
        fainters = []
        priority.each do |b|
            next if b.fainted?
            next unless b.effectActive?(:PerishSong)
            pbDisplay(_INTL("{1}'s perish count fell to {2}!", b.pbThis, b.effects[:PerishSong] - 1))
            b.tickDownAndProc(:PerishSong)
        end
    end

    def processTriggersEOR(priority)
        priority.each do |b|
            next if b.fainted?
            # Bad Dreams, Moody, Speed Boost
            b.eachActiveAbility do |ability|
                BattleHandlers.triggerEOREffectAbility(ability, b, self)
            end
            # Flame Orb, Sticky Barb, Toxic Orb
            b.eachActiveItem do |item|
                BattleHandlers.triggerEOREffectItem(item, b, self)
            end
            # Harvest, Pickup
            b.eachActiveAbility do |ability|
                BattleHandlers.triggerEORGainItemAbility(ability, b, self)
            end
        end
    end

    def checkForInvalidEffectStates
        allEffectHolders do |effectHolder|
            effectHolder.effects.each do |effect, value|
                effectData = GameData::BattleEffect.try_get(effect)
                raise _INTL("Effect \"#{effectData.real_name}\" is not a defined effect.") if effectData.nil?
                next if effectData.valid_value?(value)
                raise _INTL("Effect \"#{effectData.real_name}\" is in invalid state: #{value}")

                mainEffectActive = effectData.active_value?(value)

                effectData.each_sub_effect do |sub_effect|
                    sub_active = effectActive?(sub_effect)
                    if sub_active != mainEffectActive
                        raise _INTL("Sub-Effect #{getData(sub_effect).real_name} of effect #{effectData.real_name} has mismatched activity status")
                    end
                end
            end
        end
    end

    #=============================================================================
    # End Of Round shift distant battlers to middle positions
    #=============================================================================
    def pbEORShiftDistantBattlers
        # Move battlers around if none are near to each other
        # NOTE: This code assumes each side has a maximum of 3 battlers on it, and
        #       is not generalised to larger side sizes.
        unless singleBattle?
            swaps = [] # Each element is an array of two battler indices to swap
            for side in 0...2
                next if pbSideSize(side) == 1 # Only battlers on sides of size 2+ need to move
                # Check if any battler on this side is near any battler on the other side
                anyNear = false
                eachSameSideBattler(side) do |b|
                    eachOtherSideBattler(b) do |otherB|
                        next unless nearBattlers?(otherB.index, b.index)
                        anyNear = true
                        break
                    end
                    break if anyNear
                end
                break if anyNear
                # No battlers on this side are near any battlers on the other side; try
                # to move them
                # NOTE: If we get to here (assuming both sides are of size 3 or less),
                #       there is definitely only 1 able battler on this side, so we
                #       don't need to worry about multiple battlers trying to move into
                #       the same position. If you add support for a side of size 4+,
                #       this code will need revising to account for that, as well as to
                #       add more complex code to ensure battlers will end up near each
                #       other.
                eachSameSideBattler(side) do |b|
                    # Get the position to move to
                    pos = -1
                    case pbSideSize(side)
                    when 2 then pos = [2, 3, 0, 1][b.index] # The unoccupied position
                    when 3 then pos = (side == 0) ? 2 : 3 # The centre position
                    end
                    next if pos < 0
                    # Can't move if the same trainer doesn't control both positions
                    idxOwner = pbGetOwnerIndexFromBattlerIndex(b.index)
                    next if pbGetOwnerIndexFromBattlerIndex(pos) != idxOwner
                    swaps.push([b.index, pos])
                end
            end
            # Move battlers around
            swaps.each do |pair|
                next if pbSideSize(pair[0]) == 2 && swaps.length > 1
                next unless pbSwapBattlers(pair[0], pair[1])
                case pbSideSize(side)
                when 2
                    pbDisplay(_INTL("{1} moved across!", @battlers[pair[1]].pbThis))
                when 3
                    pbDisplay(_INTL("{1} moved to the center!", @battlers[pair[1]].pbThis))
                end
            end
        end
    end
end
