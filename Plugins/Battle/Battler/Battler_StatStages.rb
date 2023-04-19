ALL_STATS_1 = [:ATTACK, 1, :SPECIAL_ATTACK, 1, :DEFENSE, 1, :SPECIAL_DEFENSE, 1, :SPEED, 1].freeze
ALL_STATS_2 = [:ATTACK, 2, :SPECIAL_ATTACK, 2, :DEFENSE, 2, :SPECIAL_DEFENSE, 2, :SPEED, 2].freeze
ATTACKING_STATS_1 = [:ATTACK, 1, :SPECIAL_ATTACK, 1].freeze
ATTACKING_STATS_2 = [:ATTACK, 2, :SPECIAL_ATTACK, 2].freeze
DEFENDING_STATS_1 = [:DEFENSE, 1, :SPECIAL_DEFENSE, 1].freeze
DEFENDING_STATS_2 = [:DEFENSE, 2, :SPECIAL_DEFENSE, 2].freeze

class PokeBattle_Battler
    def validateStat(stat)
        raise "Given #{stat} is not a symbol!" unless stat.is_a?(Symbol)
        statData = GameData::Stat.try_get(stat)
        raise "Symbol #{stat} is not a valid stat ID!" unless statData
        raise "Symbol #{stat} is not a battle stat!" unless %i[main_battle battle].include?(statData.type)
    end

    #=============================================================================
    # Calculate stats based on stat steps.
    #=============================================================================
    STAT_STEP_BOUND = 12
    STEP_MULTIPLIERS = [2, 2,   2, 2,   2, 2,   2, 2,   2, 2,   2, 2,   2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8].freeze
    STEP_DIVISORS    = [8, 7.5, 7, 6.5, 6, 5.5, 5, 4.5, 4, 3.5, 3, 2.5, 2, 2,   2, 2,   2, 2,   2, 2,   2, 2,   2, 2,   2].freeze

    def statMultiplierAtStep(step)
        if step < -STAT_STEP_BOUND || step > STAT_STEP_BOUND
            raise "Given stat step value #{step} is not valid! Must be between -#{STAT_STEP_BOUND} and #{STAT_STEP_BOUND}, inclusive."
        end
        shiftedStep = step + STAT_STEP_BOUND
        mult = STEP_MULTIPLIERS[shiftedStep].to_f / STEP_DIVISORS[shiftedStep].to_f
        mult = (mult + 1.0) / 2.0 if boss? && AVATAR_DILUTED_STAT_STEPS
        return mult
    end

    def statAfterStep(stat, step = -1)
        step = @steps[stat] if step == -1
        return (getPlainStat(stat) * statMultiplierAtStep(step)).floor
    end

    def finalStats
        ret = {}
        ret[:ATTACK]          = pbAttack
        ret[:DEFENSE]         = pbDefense
        ret[:SPECIAL_ATTACK]  = pbSpAtk
        ret[:SPECIAL_DEFENSE] = pbSpDef
        ret[:SPEED]           = pbSpeed
        return ret
    end

    # Returns an array of [stat, value]
    def highestStatAndValue
        return finalStats.max_by { |_k, v| v }
    end

    def highestStat
        return highestStatAndValue[0]
    end

    def highestStatValue
        return highestStatAndValue[1]
    end

    #=============================================================================
    # Increase stat steps
    #=============================================================================
    def statStepAtMax?(stat)
        return @steps[stat] >= STAT_STEP_BOUND
    end

    def pbRaiseStatStepBasic(stat, increment, ignoreContrary = false)
        unless @battle.moldBreaker
            if hasActiveAbility?(:CONTRARY) && !ignoreContrary
                aiSeesAbility
                return pbLowerStatStepBasic(stat, increment, true)
            end
            # Simple
            increment *= 2 if hasActiveAbility?(:SIMPLE)
        end
        # Change the stat step
        increment = [increment, STAT_STEP_BOUND - @steps[stat]].min
        if increment.positive?
            stat_name = GameData::Stat.get(stat).name
            new = @steps[stat] + increment
            PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@steps[stat]} -> #{new} (+#{increment})")
            @steps[stat] += increment
        end
        return increment
    end

    def pbCanRaiseStatStep?(stat, user = nil, move = nil, showFailMsg = false, ignoreContrary = false, ignoreAbilities: false)
        validateStat(stat)
        return false if fainted?
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker && !ignoreAbilities
            return pbCanLowerStatStep?(stat, user, move, showFailMsg, true, ignoreAbilities: ignoreAbilities)
        end
        # Check the stat step
        if statStepAtMax?(stat)
            if showFailMsg
                @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!", pbThis, GameData::Stat.get(stat).name))
            end
            return false
        end
        return true
    end

    def pbRaiseStatStep(stat, increment, user = nil, showAnim = true, ignoreContrary = false)
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
            aiSeesAbility
            return pbLowerStatStep(stat, increment, user, showAnim, true)
        end
        # Perform the stat step change
        increment = pbRaiseStatStepBasic(stat, increment, ignoreContrary)
        return false if increment <= 0
        # Stat up animation and message
        @battle.pbCommonAnimation("StatUp", self) if showAnim
        increment /= 2.0 if boss? && AVATAR_DILUTED_STAT_STEPS
        if increment == 1
            raiseMessage = _INTL("{1}'s {2} rose!", pbThis, GameData::Stat.get(stat).name)
        else
            raiseMessage = _INTL("{1}'s {2} rose by {3} steps!", pbThis, GameData::Stat.get(stat).name, increment)
        end
        @battle.pbDisplay(raiseMessage)
        # Trigger abilities upon stat gain
        eachActiveAbility do |ability|
            BattleHandlers.triggerAbilityOnStatGain(ability, self, stat, user)
        end
        eachOpposing do |b|
            b.eachActiveAbility do |ability|
                BattleHandlers.triggerAbilityOnEnemyStatGain(ability, b, stat, user, self)
            end
            b.eachActiveItem do |item|
                BattleHandlers.triggerItemOnEnemyStatGain(item, b, user, @battle, self)
            end
        end
        return true
    end

    def pbRaiseStatStepByCause(stat, increment, user, cause, showAnim = true, ignoreContrary = false)
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
            aiSeesAbility
            return pbLowerStatStepByCause(stat, increment, user, cause, showAnim, true)
        end
        # Perform the stat step change
        increment = pbRaiseStatStepBasic(stat, increment, ignoreContrary)
        return false if increment <= 0
        # Stat up animation and message
        @battle.pbCommonAnimation("StatUp", self) if showAnim
        increment /= 2.0 if boss? && AVATAR_DILUTED_STAT_STEPS
        if user.index == @index
            if increment == 1
                raiseMessage = _INTL("{1}'s {2} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name)
            else
                raiseMessage = _INTL("{1}'s {2} raised its {3} by {4} steps!", pbThis, cause, GameData::Stat.get(stat).name, increment)
            end
        else
            if increment == 1
                raiseMessage = _INTL("{1}'s {2} raised {3}'s {4}!", pbThis, cause, pbThis(true), GameData::Stat.get(stat).name)
            else
                raiseMessage = _INTL("{1}'s {2} raised {3}'s {4} by {5} steps!", pbThis, cause, pbThis(true), GameData::Stat.get(stat).name, increment)
            end
        end
        @battle.pbDisplay(raiseMessage)
        # Trigger abilities upon stat gain
        eachActiveAbility do |ability|
            BattleHandlers.triggerAbilityOnStatGain(ability, self, stat, user)
        end
        eachOpposing do |b|
            b.eachActiveAbility do |ability|
                BattleHandlers.triggerAbilityOnEnemyStatGain(ability, b, stat, user, self)
            end
            b.eachActiveItem do |item|
                BattleHandlers.triggerItemOnEnemyStatGain(item, b, user, @battle, self)
            end
        end
        return true
    end

    def pbRaiseStatStepByAbility(stat, increment, user, ability: nil)
        return false if fainted?
        return false if statStepAtMax?(stat)
        ret = false
        @battle.pbShowAbilitySplash(user, ability) if ability
        ret = pbRaiseStatStep(stat, increment, user) if pbCanRaiseStatStep?(stat, user, nil, true)
        @battle.pbHideAbilitySplash(user) if ability
        return ret
    end

    #=============================================================================
    # Decrease stat steps
    #=============================================================================
    def statStepAtMin?(stat)
        return @steps[stat] <= -STAT_STEP_BOUND
    end

    def pbCanLowerStatStep?(stat, user = nil, move = nil, showFailMsg = false, ignoreContrary = false, ignoreAbilities: false)
        validateStat(stat)
        return false if fainted?
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker && !ignoreAbilities
            return pbCanRaiseStatStep?(stat, user, move, showFailMsg, true, ignoreAbilities: ignoreAbilities)
        end
        if !user || user.index != @index # Not self-inflicted
            if substituted? && !(move && move.ignoresSubstitute?(user))
                @battle.pbDisplay(_INTL("{1} is protected by its substitute!", pbThis)) if showFailMsg
                return false
            end
            if pbOwnSide.effectActive?(:Mist) && !(user && user.hasActiveAbility?(:INFILTRATOR))
                @battle.pbDisplay(_INTL("{1} is protected by Mist!", pbThis)) if showFailMsg
                return false
            end
            unless ignoreAbilities
                eachActiveAbility do |ability|
                    return false if BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(ability, self, stat, @battle, showFailMsg)
                end
                unless @battle.moldBreaker
                    eachActiveAbility do |ability|
                        return false if BattleHandlers.triggerStatLossImmunityAbility(ability, self, stat, @battle, showFailMsg)
                    end

                    eachAlly do |b|
                        b.eachActiveAbility do |ability|
                            return false if BattleHandlers.triggerStatLossImmunityAllyAbility(ability, b, self, stat, @battle, showFailMsg)
                        end
                    end
                end
            end
            if hasTribeBonus?(:SCRAPPER) && stat == :DEFENSE
                if showFailMsg
                    @battle.pbShowTribeSplash(self,:SCRAPPER)
                    @battle.pbDisplay(_INTL("{1}'s attitude prevents its Defense from lowering!", pbThis))
                    @battle.pbHideTribeSplash(self)
                end
                return false
            end
            if hasTribeBonus?(:SHIMMERING) && stat == :SPECIAL_DEFENSE
                if showFailMsg
                    @battle.pbShowTribeSplash(self,:SHIMMERING)
                    @battle.pbDisplay(_INTL("{1}'s sheen prevents its Sp. Def from lowering!", pbThis))
                    @battle.pbHideTribeSplash(self)
                end
                return false
            end
        elsif hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker && !ignoreAbilities
            return false
        elsif effectActive?(:EmpoweredFlowState)
            @battle.pbDisplay(_INTL("{1} is in a state of total focus!", pbThis)) if showFailMsg
            return false
        end
        # Check the stat step
        if statStepAtMin?(stat)
            if showFailMsg
                @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!", pbThis, GameData::Stat.get(stat).name))
            end
            return false
        end
        return true
    end

    def pbLowerStatStepBasic(stat, increment, ignoreContrary = false)
        unless @battle.moldBreaker
            if hasActiveAbility?(:CONTRARY) && !ignoreContrary
                aiSeesAbility
                return pbRaiseStatStepBasic(stat, increment, true)
            end
            # Simple
            increment *= 2 if hasActiveAbility?(:SIMPLE)
        end
        # Change the stat step
        increment = [increment, STAT_STEP_BOUND + @steps[stat]].min
        if increment.positive?
            stat_name = GameData::Stat.get(stat).name
            new = @steps[stat] - increment
            PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@steps[stat]} -> #{new} (-#{increment})")
            @steps[stat] -= increment
        end
        return increment
    end

    def pbLowerStatStep(stat, increment, user = nil, showAnim = true, ignoreContrary = false, ignoreMirrorArmor = false)
        # Mirror Armor, only if not self inflicted
        if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index != @index) &&
           !@battle.moldBreaker && pbCanLowerStatStep?(stat)
            battle.pbShowAbilitySplash(self, :MIRRORARMOR)
            @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!", pbThis))
            unless user
                battle.pbHideAbilitySplash(self)
                return false
            end
            if user.pbCanLowerStatStep?(stat, nil, nil, true)
                user.pbLowerStatStepByAbility(stat, increment, user)
                # Trigger user's abilities upon stat loss
                eachActiveAbility do |ability|
                    BattleHandlers.triggerAbilityOnStatLoss(ability, user, stat, self)
                end
            end
            battle.pbHideAbilitySplash(self)
            return false
        end
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
            aiSeesAbility
            return pbRaiseStatStep(stat, increment, user, showAnim, true)
        end
        # Stubborn
        return false if hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
        # Total Focus
        return false if effectActive?(:EmpoweredFlowState)
        # Perform the stat step change
        increment = pbLowerStatStepBasic(stat, increment, ignoreContrary)
        return false if increment <= 0

        # Stat down animation and message
        trauma = user&.hasActiveAbility?(:TRAUMATIZING)
        @battle.pbShowAbilitySplash(user, :TRAUMATIZING) if trauma
        @battle.pbCommonAnimation("StatDown", self) if showAnim
        increment /= 2.0 if boss? && AVATAR_DILUTED_STAT_STEPS
        if increment == 1
            lowerMessage = _INTL("{1}'s {2} fell!", pbThis, GameData::Stat.get(stat).name)
        else
            lowerMessage = _INTL("{1}'s {2} fell by {3} steps!", pbThis, GameData::Stat.get(stat).name, increment)
        end
        @battle.pbDisplay(lowerMessage)
        # Traumatizing
        if trauma
            @battle.pbDisplay(_INTL("It'll last the whole battle!"))

            # Initialize entire hash if needed
            pbOwnSide.applyEffect(:Traumatized, {}) unless pbOwnSide.effectActive?(:Traumatized)

            # Initialize individual pokemon array if needed
            unless pbOwnSide.effects[:Traumatized].key?(@pokemonIndex)
                newStatHash = {}
                pbOwnSide.effects[:Traumatized][@pokemonIndex] = newStatHash
                GameData::Stat.each_battle do |statData|
                    newStatHash[statData.id] = 0
                end
            end

            # Increment relevant array element
            existingValue = pbOwnSide.effects[:Traumatized][@pokemonIndex][stat]
            newValue = [STAT_STEP_BOUND,existingValue+increment].min
            pbOwnSide.effects[:Traumatized][@pokemonIndex][stat] = newValue

            @battle.pbHideAbilitySplash(user)
        end

        # Trigger abilities upon stat loss
        eachActiveAbility do |ability|
            BattleHandlers.triggerAbilityOnStatLoss(ability, self, stat, user)
        end
        applyEffect(:StatsDropped)
        return true
    end

    def pbLowerStatStepByCause(stat, increment, user, cause, showAnim = true, ignoreContrary = false, ignoreMirrorArmor = false)
        # Mirror Armor
        if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index != @index) &&
                !@battle.moldBreaker && pbCanLowerStatStep?(stat)
            battle.pbShowAbilitySplash(self, :MIRRORARMOR)
            @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!", pbThis))
            unless user
                battle.pbHideAbilitySplash(self)
                return false
            end
            if user.pbCanLowerStatStep?(stat, nil, nil, true)
                user.pbLowerStatStepByAbility(stat, increment, user)
                # Trigger user's abilities upon stat loss
                eachActiveAbility do |ability|
                    BattleHandlers.triggerAbilityOnStatLoss(ability, user, stat, self)
                end
            end
            battle.pbHideAbilitySplash(self)
            return false
        end
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
            aiSeesAbility
            return pbRaiseStatStepByCause(stat, increment, user, cause, showAnim, true)
        end
        # Stubborn
        return false if hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
        # Total Focus
        return false if effectActive?(:EmpoweredFlowState)
        # Perform the stat step change
        increment = pbLowerStatStepBasic(stat, increment, ignoreContrary)
        return false if increment <= 0
        # Stat down animation and message
        @battle.pbCommonAnimation("StatDown", self) if showAnim
        increment /= 2.0 if boss? && AVATAR_DILUTED_STAT_STEPS
        if user.index == @index
            if increment == 1
                lowerMessage = _INTL("{1}'s {2} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name)
            else
                lowerMessage = _INTL("{1}'s {2} lowered its {3} by {4} steps!", pbThis, cause, GameData::Stat.get(stat).name, increment)
            end
        else
            if increment == 1
                lowerMessage = _INTL("{1}'s {2} lowered {3}'s {4}!", pbThis, cause, pbThis(true), GameData::Stat.get(stat).name)
            else
                lowerMessage = _INTL("{1}'s {2} lowered {3}'s {4} by {5} steps!", pbThis, cause, pbThis(true), GameData::Stat.get(stat).name, increment)
            end
        end
        @battle.pbDisplay(lowerMessage)
        # Trigger abilities upon stat loss
        eachActiveAbility do |ability|
            BattleHandlers.triggerAbilityOnStatLoss(ability, self, stat, user)
        end
        applyEffect(:StatsDropped)
        return true
    end

    def pbLowerStatStepByAbility(stat, increment, user, ability: nil)
        return false if fainted?
        return false if statStepAtMin?(stat)
        ret = false
        @battle.pbShowAbilitySplash(user, ability) if ability
        ret = pbLowerStatStep(stat, increment, user) if pbCanLowerStatStep?(stat, user, nil, true)
        @battle.pbHideAbilitySplash(user) if ability
        handleStatLossItem(nil, user) if ret
        return ret
    end

    def blockAteAbilities(user,ability)
        return true if fainted?
        # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
        if substituted?
            @battle.pbDisplay(_INTL("{1} is protected by its substitute!", pbThis))
            return true
        end
        if hasActiveAbility?(:INNERFOCUS)
            @battle.pbShowAbilitySplash(self, true)
            @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
                    pbThis, getAbilityName(:INNERFOCUS), user.pbThis(true), getAbilityName(ability)))
            @battle.pbHideAbilitySplash(self)
            return true
        elsif @battle.pbCheckSameSideAbility(:HEARTENINGAROMA, @index)
            aromaHolder = @battle.pbCheckSameSideAbility(:HEARTENINGAROMA, @index)
            @battle.pbShowAbilitySplash(aromaHolder, true)
            @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
                aromaHolder.pbThis, getAbilityName(:HEARTENINGAROMA), user.pbThis(true), getAbilityName(ability)))
            @battle.pbHideAbilitySplash(aromaHolder)
        end
        return false
    end

    def pbMinimizeStatStep(stat, user = nil, move = nil, ignoreContrary = false, ability: nil)
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
            aiSeesAbility
            pbMaximizeStatStep(stat, user, move, true, ability: ability)
        elsif pbCanLowerStatStep?(stat, user, move, true, ignoreContrary)
            @battle.pbShowAbilitySplash(user, ability) if ability
            @steps[stat] = -STAT_STEP_BOUND
            @battle.pbCommonAnimation("StatDown", self)
            statName = GameData::Stat.get(stat).real_name
            @battle.pbDisplay(_INTL("{1} minimized its {2}!", pbThis, statName))
            @battle.pbHideAbilitySplash(user) if ability

            # Trigger abilities upon stat loss
            eachActiveAbility do |ability|
                BattleHandlers.triggerAbilityOnStatLoss(ability, self, stat, user)
            end
            handleStatLossItem(move, user)
        end
    end

    def handleStatLossItem(move, user)
        if move
            applyEffect(:StatsDropped)
        elsif itemActive?
            eachActiveItem do |item|
                BattleHandlers.triggerItemOnStatLoss(item, self, user, move, [], @battle)
            end
        end
    end

    def pbMaximizeStatStep(stat, user = nil, move = nil, ignoreContrary = false, ability: nil)
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
            aiSeesAbility
            pbMinimizeStatStep(stat, user, move, true, ability: ability)
        elsif pbCanRaiseStatStep?(stat, user, move, true, ignoreContrary)
            @battle.pbShowAbilitySplash(user, ability) if ability
            @steps[stat] = STAT_STEP_BOUND
            @battle.pbCommonAnimation("StatUp", self)
            statName = GameData::Stat.get(stat).real_name
            @battle.pbDisplay(_INTL("{1} maximizes its {2}!", pbThis, statName))
            @battle.pbHideAbilitySplash(user) if ability
        end
    end

    # Fails silently
    def tryRaiseStat(stat, user, move: nil, increment: 1, showFailMsg: false, showAnim: true, ability: nil, cause: nil, item: nil)
        return false if increment <= 0
        lowered = false
        if pbCanRaiseStatStep?(stat, user, move, showFailMsg)
            @battle.pbShowAbilitySplash(user, ability) if ability
            if item
                cause = GameData::Item.get(item).name
                @battle.pbCommonAnimation("UseItem", user)
                lowered = true if pbRaiseStatStepByCause(stat, increment, user, cause, showAnim)
            elsif cause
                lowered = true if pbRaiseStatStepByCause(stat, increment, user, cause, showAnim)
            elsif pbRaiseStatStep(stat, increment, user, showAnim)
                lowered = true
            end
        end
        @battle.pbHideAbilitySplash(user) if ability
        return lowered
    end

    # Fails silently
    def tryLowerStat(stat, user, move: nil, increment: 1, showFailMsg: false, showAnim: true, ability: nil, cause: nil, item: nil)
        return false if increment <= 0
        lowered = false
        if pbCanLowerStatStep?(stat, user, move, showFailMsg)
            @battle.pbShowAbilitySplash(user, ability) if ability
            if item
                cause = GameData::Item.get(item).name
                @battle.pbCommonAnimation("UseItem", user)
                lowered = true if pbLowerStatStepByCause(stat, increment, user, cause, showAnim)
            elsif cause
                lowered = true if pbLowerStatStepByCause(stat, increment, user, cause, showAnim)
            elsif pbLowerStatStep(stat, increment, user, showAnim)
                lowered = true
            end
        end
        @battle.pbHideAbilitySplash(user) if ability
        return lowered
    end

    def pbCanRaiseAnyOfStats?(statArray, user, move: nil, showFailMsg: false)
        for i in 0...statArray.length / 2
            return true if pbCanRaiseStatStep?(statArray[i * 2], user, move, showFailMsg)
        end
        return false
    end

    def pbCanLowerAnyOfStats?(statArray, user, move: nil, showFailMsg: false)
        for i in 0...statArray.length / 2
            return true if pbCanLowerStatStep?(statArray[i * 2], user, move, showFailMsg)
        end
        return false
    end

    # Pass in array of form
    # [statToRaise, stepsToRaise, statToRaise2, stepsToRaise2, ...]
    def pbRaiseMultipleStatSteps(statArray, user, move: nil, showFailMsg: false, showAnim: true, ability: nil, item: nil)
        return unless pbCanRaiseAnyOfStats?(statArray, user, move: move, showFailMsg: showFailMsg)
        @battle.pbShowAbilitySplash(user, ability) if ability

        cause = nil
        if item
            @battle.pbCommonAnimation("UseItem", user)
            cause = GameData::Item.get(item).name
        end

        raisedAnySteps = false
        for i in 0...statArray.length / 2
            stat = statArray[i * 2]
            increment = statArray[i * 2 + 1]
            next if increment <= 0
            raisedAnySteps = true if tryRaiseStat(stat, user, move: move, increment: increment, showFailMsg: showFailMsg,
showAnim: showAnim, ability: nil, cause: cause)
            showAnim = false if raisedAnySteps
        end
        @battle.pbHideAbilitySplash(user) if ability
        return raisedAnySteps
    end

    # Pass in array of form
    # [statToRaise, stepsToRaise, statToRaise2, stepsToRaise2, ...]
    def pbLowerMultipleStatSteps(statArray, user, move: nil, showFailMsg: false, showAnim: true, ability: nil, item: nil)
        return unless pbCanLowerAnyOfStats?(statArray, user, move: move, showFailMsg: showFailMsg)
        @battle.pbShowAbilitySplash(user, ability) if ability

        cause = nil
        if item
            @battle.pbCommonAnimation("UseItem", user)
            cause = GameData::Item.get(item).name
        end

        loweredAnySteps = false
        for i in 0...statArray.length / 2
            stat = statArray[i * 2]
            increment = statArray[i * 2 + 1]
            next if increment <= 0
            raisedAnySteps = true if tryLowerStat(stat, user, move: move, increment: increment, showFailMsg: showFailMsg,
showAnim: showAnim, ability: nil, cause: cause)
            showAnim = false if raisedAnySteps
        end
        @battle.pbHideAbilitySplash(user) if ability
        return loweredAnySteps
    end

    #=============================================================================
    # Reset stat steps
    #=============================================================================
    def hasAlteredStatSteps?
        GameData::Stat.each_battle { |s| return true if @steps[s.id] != 0 }
        return false
    end

    def hasRaisedStatSteps?
        GameData::Stat.each_battle { |s| return true if (@steps[s.id]).positive? }
        return false
    end

    def hasRaisedDefenseSteps?
        return true if (@steps[:DEFENSE]).positive?
        return true if (@steps[:SPECIAL_DEFENSE]).positive?
        return true if (@steps[:EVASION]).positive?
        return false
    end

    def hasLoweredStatSteps?
        GameData::Stat.each_battle { |s| return true if (@steps[s.id]).negative? }
        return false
    end

    def pbResetStatSteps
        GameData::Stat.each_battle { |s| @steps[s.id] = 0 }
    end
    
    def pbResetLoweredStatSteps(showMessage = false)
        anyReset = false
        GameData::Stat.each_battle { |s|
            next unless @steps[s.id] < 0
            @steps[s.id] = 0
            anyReset = true
        }
        @battle.pbDisplay(_INTL("{1}'s negative stat changes were eliminated!", pbThis)) if showMessage && anyReset
    end
end
