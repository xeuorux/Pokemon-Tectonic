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

        # Tick down or reset battle effects
        allEffectHolders do |effectHolder|
            effectHolder.processEffectsEOR
        end

        @sides.each do |side|
            side.disableEffect(:EchoedVoiceCounter) unless side.effectActive?(:EchoedVoiceUsed)
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
            BattleHandlers.triggerEORHealingAbility(b.ability, b, self) if b.abilityActive?
            # Black Sludge, Leftovers
            BattleHandlers.triggerEORHealingItem(b.item, b, self) if b.itemActive?
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

    def healFromStatusAbility(battler, status, denom = 12)
        statusEffectMessages = !defined?($PokemonSystem.status_effect_messages) || $PokemonSystem.status_effect_messages == 0
        if battler.canHeal?
            anim_name = GameData::Status.get(status).animation
            pbCommonAnimation(anim_name, battler) if anim_name
            ratio = 1.0 / denom.to_f
            battler.applyFractionalHealing(ratio, showAbilitySplash: statusEffectMessages,
    showMessage: statusEffectMessages)
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
            healFromStatusAbility(b, :POISON, 4) if b.hasActiveAbility?(:POISONHEAL)
            damageFromDOTStatus(b, :POISON)
        end
        # Damage from burn
        priority.each do |b|
            next if b.fainted?
            next unless b.burned?
            if b.hasActiveAbility?(:BURNHEAL)
                healFromStatusAbility(b, :BURN)
            else
                damageFromDOTStatus(b, :BURN)
            end
        end
        # Damage from frostbite
        priority.each do |b|
            next if b.fainted?
            next unless b.frostbitten?
            if b.hasActiveAbility?(:FROSTHEAL)
                healFromStatusAbility(b, :FROSTBITE)
            else
                damageFromDOTStatus(b, :FROSTBITE)
            end
        end
        # Leeched
        priority.each do |b|
            next if b.fainted?
            next unless b.leeched?
            leechedHP = damageFromDOTStatus(b, :LEECHED)
            next if leechedHP <= 0
            b.eachOpposing do |opposingBattler|
                healthRestore = leechedHP
                healthRestore /= 3.0 if b.boss?
                opposingBattler.pbRecoverHPFromDrain(healthRestore, b)
            end
        end
    end

    def countDownPerishSong(priority)
        # Perish Song
        perishSongUsers = []
        priority.each do |b|
            next if b.fainted? || !b.effectActive?(:PerishSong)
            b.effects[:PerishSong] -= 1
            pbDisplay(_INTL("{1}'s perish count fell to {2}!", b.pbThis, b.effects[:PerishSong]))
            perishSongUsers.push(b.effects[:PerishSongUser]) if b.tickDownAndProc(:PerishSong)
        end
        if perishSongUsers.length > 0 && ((perishSongUsers.find_all do |idxBattler|
                                               opposes?(idxBattler)
                                           end.length == perishSongUsers.length) ||
               (perishSongUsers.find_all { |idxBattler| !opposes?(idxBattler) }.length == perishSongUsers.length))
            pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
        end
    end

    def processTriggersEOR(priority)
        priority.each do |b|
            next if b.fainted?
            # Hyper Mode (Shadow Pokémon)
            if b.inHyperMode?
                if pbRandom(100) < 10
                    b.pokemon.hyper_mode = false
                    b.pokemon.adjustHeart(-50)
                    pbDisplay(_INTL("{1} came to its senses!", b.pbThis))
                else
                    pbDisplay(_INTL("{1} is in Hyper Mode!", b.pbThis))
                end
            end
            # Bad Dreams, Moody, Speed Boost
            BattleHandlers.triggerEOREffectAbility(b.ability, b, self) if b.abilityActive?
            # Flame Orb, Sticky Barb, Toxic Orb
            BattleHandlers.triggerEOREffectItem(b.item, b, self) if b.itemActive?
            # Harvest, Pickup
            BattleHandlers.triggerEORGainItemAbility(b.ability, b, self) if b.abilityActive?
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
