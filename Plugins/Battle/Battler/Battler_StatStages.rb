class PokeBattle_Battler
    def validateStat(stat)
        raise "Given #{stat} is not a symbol!" unless stat.is_a?(Symbol)
        statData = GameData::Stat.try_get(stat)
        raise "Symbol #{stat} is not a valid stat ID!" unless statData
        raise "Symbol #{stat} is not a battle stat!" unless %i[main_battle battle].include?(statData.type)
    end

    #=============================================================================
    # Calculate stats based on stat stages.
    #=============================================================================
    STAGE_MULTIPLIERS = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8].freeze
    STAGE_DIVISORS    = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2].freeze

    def statMultiplierAtStage(stage)
        if stage < -6 || stage > 6
            raise "Given stat stage value #{stage} is not valid! Must be between -6 and 6, inclusive."
        end
        shiftedStage = stage + 6
        mult = STAGE_MULTIPLIERS[shiftedStage].to_f / STAGE_DIVISORS[shiftedStage].to_f
        mult = (mult + 1.0) / 2.0 if boss?
        return mult
    end

    def statAfterStage(stat, stage = -1)
        stage = @stages[stat] if stage == -1
        return (getPlainStat(stat) * statMultiplierAtStage(stage)).floor
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
    # Increase stat stages
    #=============================================================================
    def statStageAtMax?(stat)
        return @stages[stat] >= 6
    end

    def pbRaiseStatStageBasic(stat, increment, ignoreContrary = false)
        unless @battle.moldBreaker
            if hasActiveAbility?(:CONTRARY) && !ignoreContrary
                aiSeesAbility
                return pbLowerStatStageBasic(stat, increment, true)
            end
            # Simple
            increment *= 2 if hasActiveAbility?(:SIMPLE)
        end
        # Change the stat stage
        increment = [increment, 6 - @stages[stat]].min
        if increment.positive?
            stat_name = GameData::Stat.get(stat).name
            new = @stages[stat] + increment
            PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (+#{increment})")
            @stages[stat] += increment
        end
        return increment
    end

    def pbCanRaiseStatStage?(stat, user = nil, move = nil, showFailMsg = false, ignoreContrary = false, ignoreAbilities: false)
        validateStat(stat)
        return false if fainted?
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker && !ignoreAbilities
            return pbCanLowerStatStage?(stat, user, move, showFailMsg, true, ignoreAbilities: ignoreAbilities)
        end
        # Check the stat stage
        if statStageAtMax?(stat)
            if showFailMsg
                @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!", pbThis, GameData::Stat.get(stat).name))
            end
            return false
        end
        return true
    end

    def pbRaiseStatStage(stat, increment, user = nil, showAnim = true, ignoreContrary = false)
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
            aiSeesAbility
            return pbLowerStatStage(stat, increment, user, showAnim, true)
        end
        # Perform the stat stage change
        increment = pbRaiseStatStageBasic(stat, increment, ignoreContrary)
        return false if increment <= 0
        # Stat up animation and message
        @battle.pbCommonAnimation("StatUp", self) if showAnim
        arrStatTexts = [
            _INTL("{1}'s {2} rose{3}!", pbThis, GameData::Stat.get(stat).name, boss? ? " slightly" : ""),
            _INTL("{1}'s {2} rose{3}!", pbThis, GameData::Stat.get(stat).name, boss? ? "" : " sharply"),
            _INTL("{1}'s {2} rose{3}!", pbThis, GameData::Stat.get(stat).name,
                                    boss? ? " greatly" : " drastically"),
        ]
        @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
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

    def pbRaiseStatStageByCause(stat, increment, user, cause, showAnim = true, ignoreContrary = false)
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
            aiSeesAbility
            return pbLowerStatStageByCause(stat, increment, user, cause, showAnim, true)
        end
        # Perform the stat stage change
        increment = pbRaiseStatStageBasic(stat, increment, ignoreContrary)
        return false if increment <= 0
        # Stat up animation and message
        @battle.pbCommonAnimation("StatUp", self) if showAnim
        if user.index == @index
            arrStatTexts = [
                _INTL("{1}'s {2}{4} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
                           boss? ? " slightly" : ""),
                _INTL("{1}'s {2}{4} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
                        boss? ? "" : " sharply"),
                _INTL("{1}'s {2}{4} raised its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
                        boss? ? " greatly" : " drastically"),
            ]
        else
            arrStatTexts = [
                _INTL("{1}'s {2}{5} raised {3}'s {4}!", user.pbThis, cause, pbThis(true),
                           GameData::Stat.get(stat).name, boss? ? " slightly" : ""),
                _INTL("{1}'s {2}{5} raised {3}'s {4}!", user.pbThis, cause, pbThis(true),
                        GameData::Stat.get(stat).name, boss? ? "" : " sharply"),
                _INTL("{1}'s {2}{5} raised {3}'s {4}!", user.pbThis, cause, pbThis(true),
                        GameData::Stat.get(stat).name, boss? ? " greatly" : " drastically"),
            ]
        end
        @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
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

    def pbRaiseStatStageByAbility(stat, increment, user, ability: nil)
        return false if fainted?
        return false if statStageAtMax?(stat)
        ret = false
        @battle.pbShowAbilitySplash(user, ability) if ability
        ret = pbRaiseStatStage(stat, increment, user) if pbCanRaiseStatStage?(stat, user, nil, true)
        @battle.pbHideAbilitySplash(user) if ability
        return ret
    end

    #=============================================================================
    # Decrease stat stages
    #=============================================================================
    def statStageAtMin?(stat)
        return @stages[stat] <= -6
    end

    def pbCanLowerStatStage?(stat, user = nil, move = nil, showFailMsg = false, ignoreContrary = false, ignoreAbilities: false)
        validateStat(stat)
        return false if fainted?
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker && !ignoreAbilities
            return pbCanRaiseStatStage?(stat, user, move, showFailMsg, true, ignoreAbilities: ignoreAbilities)
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
        # Check the stat stage
        if statStageAtMin?(stat)
            if showFailMsg
                @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!", pbThis, GameData::Stat.get(stat).name))
            end
            return false
        end
        return true
    end

    def pbLowerStatStageBasic(stat, increment, ignoreContrary = false)
        unless @battle.moldBreaker
            if hasActiveAbility?(:CONTRARY) && !ignoreContrary
                aiSeesAbility
                return pbRaiseStatStageBasic(stat, increment, true)
            end
            # Simple
            increment *= 2 if hasActiveAbility?(:SIMPLE)
        end
        # Change the stat stage
        increment = [increment, 6 + @stages[stat]].min
        if increment.positive?
            stat_name = GameData::Stat.get(stat).name
            new = @stages[stat] - increment
            PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (-#{increment})")
            @stages[stat] -= increment
        end
        return increment
    end

    def pbLowerStatStage(stat, increment, user = nil, showAnim = true, ignoreContrary = false, ignoreMirrorArmor = false)
        # Mirror Armor, only if not self inflicted
        if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index != @index) &&
           !@battle.moldBreaker && pbCanLowerStatStage?(stat)
            battle.pbShowAbilitySplash(self, :MIRRORARMOR)
            @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!", pbThis))
            unless user
                battle.pbHideAbilitySplash(self)
                return false
            end
            if user.pbCanLowerStatStage?(stat, nil, nil, true)
                user.pbLowerStatStageByAbility(stat, increment, user)
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
            return pbRaiseStatStage(stat, increment, user, showAnim, true)
        end
        # Stubborn
        return false if hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
        # Total Focus
        return false if effectActive?(:EmpoweredFlowState)
        # Perform the stat stage change
        increment = pbLowerStatStageBasic(stat, increment, ignoreContrary)
        return false if increment <= 0
        # Stat down animation and message
        @battle.pbCommonAnimation("StatDown", self) if showAnim
        arrStatTexts = [
            _INTL("{1}'s {2}{3} fell!", pbThis, GameData::Stat.get(stat).name, boss? ? " slightly" : ""),
            _INTL("{1}'s {2}{3} fell!", pbThis, GameData::Stat.get(stat).name, boss? ? "" : " harshly"),
            _INTL("{1}'s {2}{3} fell!", pbThis, GameData::Stat.get(stat).name,
                                    boss? ? " severely" : " badly"),
        ]
        @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
        # Trigger abilities upon stat loss
        eachActiveAbility do |ability|
            BattleHandlers.triggerAbilityOnStatLoss(ability, self, stat, user)
        end
        applyEffect(:StatsDropped)
        return true
    end

    def pbLowerStatStageByCause(stat, increment, user, cause, showAnim = true, ignoreContrary = false, ignoreMirrorArmor = false)
        # Mirror Armor
        if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index != @index) &&
                !@battle.moldBreaker && pbCanLowerStatStage?(stat)
            battle.pbShowAbilitySplash(self, :MIRRORARMOR)
            @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!", pbThis))
            unless user
                battle.pbHideAbilitySplash(self)
                return false
            end
            if user.pbCanLowerStatStage?(stat, nil, nil, true)
                user.pbLowerStatStageByAbility(stat, increment, user)
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
            return pbRaiseStatStageByCause(stat, increment, user, cause, showAnim, true)
        end
        # Stubborn
        return false if hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
        # Total Focus
        return false if effectActive?(:EmpoweredFlowState)
        # Perform the stat stage change
        increment = pbLowerStatStageBasic(stat, increment, ignoreContrary)
        return false if increment <= 0
        # Stat down animation and message
        @battle.pbCommonAnimation("StatDown", self) if showAnim
        if user.index == @index
            arrStatTexts = [
                _INTL("{1}'s {2}{4} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
                           boss? ? " slightly" : ""),
                _INTL("{1}'s {2}{4} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
                        boss? ? "" : " harshly"),
                _INTL("{1}'s {2}{4} lowered its {3}!", pbThis, cause, GameData::Stat.get(stat).name,
                        boss? ? " severely" : " badly"),
            ]
        else
            arrStatTexts = [
                _INTL("{1}'s {2}{5} lowered {3}'s {4}!", user.pbThis, cause, pbThis(true),
                           GameData::Stat.get(stat).name, boss? ? " slightly" : ""),
                _INTL("{1}'s {2}{5} lowered {3}'s {4}!", user.pbThis, cause, pbThis(true),
                        GameData::Stat.get(stat).name, boss? ? "" : " harshly"),
                _INTL("{1}'s {2}{5} lowered {3}'s {4}!", user.pbThis, cause, pbThis(true),
                        GameData::Stat.get(stat).name, boss? ? " severely" : " badly"),
            ]
        end
        @battle.pbDisplay(arrStatTexts[[increment - 1, 2].min])
        # Trigger abilities upon stat loss
        eachActiveAbility do |ability|
            BattleHandlers.triggerAbilityOnStatLoss(ability, self, stat, user)
        end
        applyEffect(:StatsDropped)
        return true
    end

    def pbLowerStatStageByAbility(stat, increment, user, ability: nil)
        return false if fainted?
        return false if statStageAtMin?(stat)
        ret = false
        @battle.pbShowAbilitySplash(user, ability) if ability
        ret = pbLowerStatStage(stat, increment, user) if pbCanLowerStatStage?(stat, user, nil, true)
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

    def pbMinimizeStatStage(stat, user = nil, move = nil, ignoreContrary = false, ability: nil)
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
            aiSeesAbility
            pbMaximizeStatStage(stat, user, move, true, ability: ability)
        elsif pbCanLowerStatStage?(stat, user, move, true, ignoreContrary)
            @battle.pbShowAbilitySplash(user, ability) if ability
            @stages[stat] = -6
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

    def pbMaximizeStatStage(stat, user = nil, move = nil, ignoreContrary = false, ability: nil)
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
            aiSeesAbility
            pbMinimizeStatStage(stat, user, move, true, ability: ability)
        elsif pbCanRaiseStatStage?(stat, user, move, true, ignoreContrary)
            @battle.pbShowAbilitySplash(user, ability) if ability
            @stages[stat] = 6
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
        if pbCanRaiseStatStage?(stat, user, move, showFailMsg)
            @battle.pbShowAbilitySplash(user, ability) if ability
            if item
                cause = GameData::Item.get(item).name
                @battle.pbCommonAnimation("UseItem", user)
                lowered = true if pbRaiseStatStageByCause(stat, increment, user, cause, showAnim)
            elsif cause
                lowered = true if pbRaiseStatStageByCause(stat, increment, user, cause, showAnim)
            elsif pbRaiseStatStage(stat, increment, user, showAnim)
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
        if pbCanLowerStatStage?(stat, user, move, showFailMsg)
            @battle.pbShowAbilitySplash(user, ability) if ability
            if item
                cause = GameData::Item.get(item).name
                @battle.pbCommonAnimation("UseItem", user)
                lowered = true if pbLowerStatStageByCause(stat, increment, user, cause, showAnim)
            elsif cause
                lowered = true if pbLowerStatStageByCause(stat, increment, user, cause, showAnim)
            elsif pbLowerStatStage(stat, increment, user, showAnim)
                lowered = true
            end
        end
        @battle.pbHideAbilitySplash(user) if ability
        return lowered
    end

    def pbCanRaiseAnyOfStats?(statArray, user, move: nil, showFailMsg: false)
        for i in 0...statArray.length / 2
            return true if pbCanRaiseStatStage?(statArray[i * 2], user, move, showFailMsg)
        end
        return false
    end

    def pbCanLowerAnyOfStats?(statArray, user, move: nil, showFailMsg: false)
        for i in 0...statArray.length / 2
            return true if pbCanLowerStatStage?(statArray[i * 2], user, move, showFailMsg)
        end
        return false
    end

    # Pass in array of form
    # [statToRaise, stagesToRaise, statToRaise2, stagesToRaise2, ...]
    def pbRaiseMultipleStatStages(statArray, user, move: nil, showFailMsg: false, showAnim: true, ability: nil, item: nil)
        return unless pbCanRaiseAnyOfStats?(statArray, user, move: move, showFailMsg: showFailMsg)
        @battle.pbShowAbilitySplash(user, ability) if ability

        cause = nil
        if item
            @battle.pbCommonAnimation("UseItem", user)
            cause = GameData::Item.get(item).name
        end

        raisedAnyStages = false
        for i in 0...statArray.length / 2
            stat = statArray[i * 2]
            increment = statArray[i * 2 + 1]
            next if increment <= 0
            raisedAnyStages = true if tryRaiseStat(stat, user, move: move, increment: increment, showFailMsg: showFailMsg,
showAnim: showAnim, ability: nil, cause: cause)
            showAnim = false if raisedAnyStages
        end
        @battle.pbHideAbilitySplash(user) if ability
        return raisedAnyStages
    end

    # Pass in array of form
    # [statToRaise, stagesToRaise, statToRaise2, stagesToRaise2, ...]
    def pbLowerMultipleStatStages(statArray, user, move: nil, showFailMsg: false, showAnim: true, ability: nil, item: nil)
        return unless pbCanLowerAnyOfStats?(statArray, user, move: move, showFailMsg: showFailMsg)
        @battle.pbShowAbilitySplash(user, ability) if ability

        cause = nil
        if item
            @battle.pbCommonAnimation("UseItem", user)
            cause = GameData::Item.get(item).name
        end

        loweredAnyStages = false
        for i in 0...statArray.length / 2
            stat = statArray[i * 2]
            increment = statArray[i * 2 + 1]
            next if increment <= 0
            raisedAnyStages = true if tryLowerStat(stat, user, move: move, increment: increment, showFailMsg: showFailMsg,
showAnim: showAnim, ability: nil, cause: cause)
            showAnim = false if raisedAnyStages
        end
        @battle.pbHideAbilitySplash(user) if ability
        return loweredAnyStages
    end

    #=============================================================================
    # Reset stat stages
    #=============================================================================
    def hasAlteredStatStages?
        GameData::Stat.each_battle { |s| return true if @stages[s.id] != 0 }
        return false
    end

    def hasRaisedStatStages?
        GameData::Stat.each_battle { |s| return true if (@stages[s.id]).positive? }
        return false
    end

    def hasRaisedDefenseStages?
        return true if (@stages[:DEFENSE]).positive?
        return true if (@stages[:SPECIAL_DEFENSE]).positive?
        return true if (@stages[:EVASION]).positive?
        return false
    end

    def hasLoweredStatStages?
        GameData::Stat.each_battle { |s| return true if (@stages[s.id]).negative? }
        return false
    end

    def pbResetStatStages
        GameData::Stat.each_battle { |s| @stages[s.id] = 0 }
    end
end
