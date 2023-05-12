BURNED_EXPLANATION = _INTL("Its physical damage is reduced by a third")
POISONED_EXPLANATION = _INTL("The poison will worsen over time")
FROSTBITE_EXPLANATION = _INTL("Its special damage is reduced by a third")
NUMBED_EXPLANATION = _INTL("Its Speed is halved, and it'll deal less damage")
DIZZY_EXPLANATION = _INTL("It's ability is supressed, and it'll take more damage")
LEECHED_EXPLANATION = _INTL("Its HP will be siphoned by the opposing side")

class PokeBattle_Battler
    def getStatuses
        statuses = [abilities.include?(:COMATOSE) ? :SLEEP : @status]
        statuses.push(@bossStatus) if canHaveSecondStatus?
        return statuses
    end

    def canHaveSecondStatus?
        return boss? && GameData::Avatar.get(@pokemon.species).second_status?
    end

    #=============================================================================
    # Generalised checks for whether a status problem can be inflicted
    #=============================================================================
    # NOTE: Not all "does it have this status?" checks use this method. If the
    #			 check is leading up to curing self of that status condition, then it
    #			 will look at hasStatusNoTrigger instead - if it is that
    #			 status condition then it is curable. This method only checks for
    #			 "counts as having that status", which includes Comatose which can't be
    #			 cured.
    def pbHasStatus?(checkStatus)
        eachAbility do |ability|
            return true if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(ability, self, checkStatus)
        end
        return getStatuses.include?(checkStatus)
    end

    def hasStatusNoTrigger(checkStatus)
        return getStatuses.include?(checkStatus)
    end
    alias hasStatusNoTrigger? hasStatusNoTrigger

    def pbHasAnyStatus?
        eachAbility do |ability|
            return true if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(ability, self, nil)
        end
        return hasAnyStatusNoTrigger
    end

    def hasAnyStatusNoTrigger
        hasStatus = false
        getStatuses.each do |status|
            hasStatus = true if status != :NONE
        end
        return hasStatus
    end
    alias hasAnyStatusNoTrigger? hasAnyStatusNoTrigger

    def hasSpotsForStatus
        hasSpots = false
        getStatuses.each do |status|
            hasSpots = true if status == :NONE
        end
        return hasSpots
    end
    alias hasSpotsForStatus? hasSpotsForStatus

    def resetStatusCount(statusOfConcern = nil)
        if statusOfConcern.nil?
            self.statusCount = 0
            @bossStatusCount = 0
        elsif @status == statusOfConcern
            self.statusCount = 0
        elsif @bossStatus == statusOfConcern
            @bossStatusCount = 0
        end
    end

    def reduceStatusCount(statusOfConcern = nil)
        if statusOfConcern.nil?
            self.statusCount -= 1
            @bossStatusCount -= 1
        elsif @status == statusOfConcern
            self.statusCount -= 1
        elsif @bossStatus == statusOfConcern
            @bossStatusCount -= 1
        end
    end

    def increaseStatusCount(statusOfConcern = nil)
        if statusOfConcern.nil?
            self.statusCount += 1
            @bossStatusCount += 1
        elsif @status == statusOfConcern
            self.statusCount += 1
        elsif @bossStatus == statusOfConcern
            @bossStatusCount += 1
        end
    end

    def getStatusCount(statusOfConcern)
        if @status == statusOfConcern
            return @statusCount
        elsif @bossStatus == statusOfConcern
            return @bossStatusCount
        end
        return 0
    end

    def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
        return false if fainted?
        selfInflicted = (user && user.index == @index)
        statusDoublingCurse = pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
        # Already have that status problem
        if getStatuses.include?(newStatus) && !ignoreStatus
            if showMessages
                msg = ""
                case newStatus
                when :SLEEP			then msg = _INTL("{1} is already asleep!", pbThis)
                when :POISON		then msg = _INTL("{1} is already poisoned!", pbThis)
                when :BURN			then msg = _INTL("{1} already has a burn!", pbThis)
                when :NUMB			then msg = _INTL("{1} is already numbed!", pbThis)
                when :FROSTBITE	    then msg = _INTL("{1} is already frostbitten!", pbThis)
                when :DIZZY	        then msg = _INTL("{1} is already dizzy!", pbThis)
                when :LEECHED	    then msg = _INTL("{1} is already being leeched!", pbThis)
                end
                @battle.pbDisplay(msg)
            end
            return false
        end
        # Trying to give too many statuses
        if !hasSpotsForStatus && !ignoreStatus && !selfInflicted
            @battle.pbDisplay(_INTL("{1} cannot have any more status problems...", pbThis(false))) if showMessages
            return false
        end
        # Trying to inflict a status problem on a Pokémon behind a substitute
        if substituted? && !(move && move.ignoresSubstitute?(user)) && !selfInflicted && !statusDoublingCurse
            @battle.pbDisplay(_INTL("It doesn't affect {1} behind its substitute...", pbThis(true))) if showMessages
            return false
        end
        # Terrains immunity
        if affectedByTerrain? && !statusDoublingCurse
            case @battle.field.terrain
            when :Electric
                if %i[SLEEP DIZZY].include?(newStatus)
                    if showMessages
                        @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!", pbThis(true)))
                    end
                    return false
                end
            when :Fairy
                if %i[POISON BURN FROSTBITE].include?(newStatus)
                    @battle.pbDisplay(_INTL("{1} surrounds itself with fairy terrain!", pbThis(true))) if showMessages
                    return false
                end
            end
        end
        # Uproar immunity
        if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker) && !statusDoublingCurse
            @battle.eachBattler do |b|
                next unless b.effectActive?(:Uproar)
                @battle.pbDisplay(_INTL("But the uproar kept {1} awake!", pbThis(true))) if showMessages
                return false
            end
        end
        if newStatus == :DIZZY
            # Downside abilities
            unless @battle.moldBreaker
                downsideAbility = hasActiveAbility?(DOWNSIDE_ABILITIES)
                if downsideAbility
                    if showMessages
                        @battle.pbShowAbilitySplash(self, downsideAbility)
                        @battle.pbDisplay(_INTL("{1}'s ability prevents being dizzied!", pbThis))
                        @battle.pbHideAbilitySplash(self)
                    end
                    return false
                end
            end
            # Downside abilities
            unstoppableAbility = unstoppableAbility?
            if unstoppableAbility
                if showMessages
                    @battle.pbShowAbilitySplash(self, unstoppableAbility)
                    @battle.pbDisplay(_INTL("{1}'s ability can't be prevented, so it can't be dizzied!", pbThis))
                    @battle.pbHideAbilitySplash(self)
                end
                return false
            end
        end
        # Type immunities
        hasImmuneType = false
        immuneType = nil
        case newStatus
        when :POISON
            unless user&.hasActiveAbility?(:CORROSION)
                if pbHasType?(:POISON)
                    hasImmuneType = true
                    immuneType = :POISON
                end
                if pbHasType?(:STEEL)
                    hasImmuneType = true
                    immuneType = :STEEL
                end
            end
        when :BURN
            if pbHasType?(:FIRE)
                hasImmuneType = true
                immuneType = :FIRE
            end
        when :NUMB
            if pbHasType?(:ELECTRIC)
                hasImmuneType = true
                immuneType = :ELECTRIC
            end
        when :FROSTBITE
            if pbHasType?(:ICE)
                hasImmuneType = true
                immuneType = :ICE
            end
        when :DIZZY
            if pbHasType?(:PSYCHIC)
                hasImmuneType = true
                immuneType = :PSYCHIC
            end
        when :LEECHED
            if pbHasType?(:GRASS)
                hasImmuneType = true
                immuneType = :GRASS
            end
        end
        if hasImmuneType
            immuneTypeRealName = GameData::Type.get(immuneType).real_name
            if showMessages
                @battle.pbDisplay(_INTL("It doesn't affect {1} since it's an {2}-type...", pbThis(true),
immuneTypeRealName))
            end
            return false
        end
        # Ability immunity
        immuneAbility = nil
        immAlly = nil
        eachActiveAbility do |ability|
            next unless BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(ability, self, newStatus)
            immuneAbility = ability
            break
        end
        if immuneAbility.nil? && selfInflicted || !@battle.moldBreaker
            eachActiveAbility do |ability|
                next unless BattleHandlers.triggerStatusImmunityAbility(ability, self, newStatus)
                immuneAbility = ability
                break
            end
            eachAlly do |b|
                b.eachActiveAbility do |ability|
                    next unless BattleHandlers.triggerStatusImmunityAllyAbility(ability, self, newStatus)
                    immuneAbility = ability
                    immAlly = b
                    break
                end
            end
        end
        if immuneAbility
            if showMessages
                @battle.pbShowAbilitySplash(immAlly || self, immuneAbility)
                msg = ""
                case newStatus
                when :SLEEP			then msg = _INTL("{1} stays awake!", pbThis)
                when :POISON		then msg = _INTL("{1} cannot be poisoned!", pbThis)
                when :BURN			then msg = _INTL("{1} cannot be burned!", pbThis)
                when :NUMB			then msg = _INTL("{1} cannot be numbed!", pbThis)
                when :FROZEN	    then msg = _INTL("{1} cannot be chilled!", pbThis)
                when :FROSTBITE	    then msg = _INTL("{1} cannot be frostbitten!", pbThis)
                when :DIZZY	        then msg = _INTL("{1} cannot be dizzied!", pbThis)
                when :LEECHED	    then msg = _INTL("{1} cannot become leeched!", pbThis)
                end
                @battle.pbDisplay(msg)
                @battle.pbHideAbilitySplash(immAlly || self)
            end
            return false
        end
        # Safeguard immunity
        if pbOwnSide.effectActive?(:Safeguard) && !selfInflicted && move &&
           !(user && user.hasActiveAbility?(:INFILTRATOR)) && !statusDoublingCurse
            @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
            return false
        end
        return true
    end

    def pbCanSynchronizeStatus?(newStatus, target)
        return false if fainted?
        # Trying to replace a status problem with another one
        return false unless hasSpotsForStatus
        # Terrain immunity
        return false if @battle.field.terrain == :Fairy && affectedByTerrain? && %i[BURN POISON
                                                                                    FROSTBITE].include?(newStatus)
        return false if @battle.field.terrain == :Electric && affectedByTerrain? && %i[SLEEP
                                                                                       DIZZY].include?(newStatus)
        # Type immunities
        hasImmuneType = false
        case newStatus
        when :POISON
            # NOTE: target will have Synchronize, so it can't have Corrosion.
            unless target&.hasActiveAbility?(:CORROSION)
                hasImmuneType |= pbHasType?(:POISON)
                hasImmuneType |= pbHasType?(:STEEL)
            end
        when :BURN
            hasImmuneType |= pbHasType?(:FIRE)
        when :NUMB
            hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
        when :FROZEN, :FROSTBITE
            hasImmuneType |= pbHasType?(:ICE)
        when :DIZZY
            hasImmuneType |= pbHasType?(:PSYCHIC)
        when :LEECHED
            hasImmuneType |= pbHasType?(:GRASS)
        end
        return false if hasImmuneType
        # Ability immunity
        eachActiveAbility do |ability|
            return false if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(ability, self, newStatus)
        end
        unless @battle.moldBreaker
            eachActiveAbility do |ability|
                return false if BattleHandlers.triggerStatusImmunityAbility(ability, self, newStatus)
            end
        end
        eachAlly do |b|
            b.eachActiveAbility do |ability|
                next unless BattleHandlers.triggerStatusImmunityAllyAbility(ability, self, newStatus)
                return false
            end
        end
        # Safeguard immunity
        return false if pbOwnSide.effectActive?(:Safeguard) && !(target && target.hasActiveAbility?(:INFILTRATOR))
        return true
    end

    #=============================================================================
    # Generalised infliction of status problem
    #=============================================================================
    def pbInflictStatus(newStatus, newStatusCount = 0, msg = nil, user = nil)
        if hasTribeBonus?(:TYRANNICAL) && !pbOwnSide.effectActive?(:TyrannicalImmunity)
            @battle.pbShowTribeSplash(self,:TYRANNICAL)
            @battle.pbDisplay(_INTL("{1} refuses to gain a status condition!", pbThis))
            @battle.pbHideTribeSplash(self)
            pbOwnSide.applyEffect(:TyrannicalImmunity)
            return
        end

        newStatusCount = sleepDuration if newStatusCount <= 0 && newStatus == :SLEEP

        statusCheck = false
        eachAbility do |ability|
            statusCheck = true if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(ability, self, nil)
        end

        # Inflict the new status
        if !canHaveSecondStatus?
            self.status	= newStatus
            self.statusCount = newStatusCount
        elsif @status == :NONE && !statusCheck
            self.status	= newStatus
            self.statusCount = newStatusCount
        else
            self.bossStatus	= newStatus
            self.bossStatusCount	= newStatusCount
        end

        # Show animation
        if newStatus == :POISON && newStatusCount.positive?
            @battle.pbCommonAnimation("Toxic", self)
        else
            anim_name = GameData::Status.get(newStatus).animation
            @battle.pbCommonAnimation(anim_name, self) if anim_name
        end

        # Show message
        if msg != "false"
            if msg && !msg.empty?
                @battle.pbDisplay(msg)
            else
                case newStatus
                when :SLEEP
                    @battle.pbDisplay(_INTL("{1} fell asleep!", pbThis))
                when :POISON
                    @battle.pbDisplay(_INTL("{1} was poisoned! {2}!", pbThis, POISONED_EXPLANATION))
                when :BURN
                    @battle.pbDisplay(_INTL("{1} was burned! {2}!", pbThis, BURNED_EXPLANATION))
                when :NUMB
                    @battle.pbDisplay(_INTL("{1} is numbed! {2}!", pbThis, NUMBED_EXPLANATION))
                when :FROSTBITE
                    @battle.pbDisplay(_INTL("{1} was frostbitten! {2}!", pbThis, FROSTBITE_EXPLANATION))
                when :DIZZY
                    @battle.pbDisplay(_INTL("{1} is dizzy! {2}!", pbThis, DIZZY_EXPLANATION))
                when :LEECHED
                    @battle.pbDisplay(_INTL("{1} became leeched! {2}!", pbThis, LEECHED_EXPLANATION))
                end
            end
        end
        if newStatus == :SLEEP
            PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}")
            @battle.eachBattler do |b|
                next if b.nil?
                next unless b.hasActiveAbility?(:DREAMWEAVER)
                b.tryRaiseStat(:SPECIAL_ATTACK, b, ability: :DREAMWEAVER, increment: 2)
            end
        end
        # Form change check
        pbCheckFormOnStatusChange
        # Synchronize
        eachActiveAbility do |ability|
            BattleHandlers.triggerAbilityOnStatusInflicted(ability, self, user, newStatus)
        end

        # Status cures
        pbItemStatusCureCheck
        pbAbilityStatusCureCheck

        # Rampaging moves get cancelled immediately by falling asleep
        disableEffect(:Outrage) if newStatus == :SLEEP

        pbOnAbilitiesLost(abilities) if dizzy?
    end

    #=============================================================================
    # Sleep
    #=============================================================================
    def asleep?
        return pbHasStatus?(:SLEEP)
    end

    def canSleep?(user, showMessages, move = nil, ignoreStatus = false)
        return pbCanInflictStatus?(:SLEEP, user, showMessages, move, ignoreStatus)
    end

    def canSleepYawn?
        return false unless hasSpotsForStatus
        return false if affectedByTerrain? && @battle.field.terrain == :Electric
        unless hasActiveAbility?(:SOUNDPROOF)
            @battle.eachBattler do |b|
                return false if b.effectActive?(:Uproar)
            end
        end
        eachActiveAbility do |ability|
            BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(ability, self, :SLEEP)
        end
        unless @battle.moldBreaker
            eachActiveAbility do |ability|
                return false if BattleHandlers.triggerStatusImmunityAbility(ability, self, :SLEEP)
            end
            eachAlly do |b|
                b.eachActiveAbility do |ability|
                    return false if BattleHandlers.triggerStatusImmunityAllyAbility(ability, self, :SLEEP)
                end
            end
        end
        return false if pbOwnSide.effectActive?(:Safeguard)
        return true
    end

    def applySleep(msg = nil)
        pbInflictStatus(:SLEEP, -1, msg)
    end

    def applySleepSelf(msg = nil, duration = -1)
        pbInflictStatus(:SLEEP, sleepDuration(duration), msg)
    end

    def sleepDuration(duration = -1)
        duration = 3 if duration <= 0
        duration = 1 if hasActiveAbility?(:EARLYBIRD)
        duration -= 1 if boss?
        return duration
    end

    #=============================================================================
    # Poison
    #=============================================================================
    def poisoned?
        return pbHasStatus?(:POISON)
    end

    def canPoison?(user, showMessages, move = nil)
        return pbCanInflictStatus?(:POISON, user, showMessages, move)
    end

    def applyPoison(user = nil, msg = nil, toxic = false)
        if boss && toxic
            @battle.pbDisplay("The projection's power blunts the toxin.")
            toxic = false
        end
        pbInflictStatus(:POISON, toxic ? 1 : 0, msg, user)
    end

    def badlyPoisoned?
        return poisoned? && getPoisonDoublings > 0
    end

    def getPoisonDoublings
        poisonCount = getStatusCount(:POISON)
        if boss?
            doublings = poisonCount / 5
        else
            doublings = poisonCount / 3
        end
        return doublings
    end

    #=============================================================================
    # Burn
    #=============================================================================
    def burned?
        return pbHasStatus?(:BURN)
    end

    def canBurn?(user, showMessages, move = nil)
        return pbCanInflictStatus?(:BURN, user, showMessages, move)
    end

    def applyBurn(user = nil, msg = nil)
        pbInflictStatus(:BURN, 0, msg, user)
    end

    #=============================================================================
    # Frostbite
    #=============================================================================
    def frostbitten?
        return pbHasStatus?(:FROSTBITE)
    end

    def canFrostbite?(user, showMessages, move = nil)
        return pbCanInflictStatus?(:FROSTBITE, user, showMessages, move)
    end

    def applyFrostbite(user = nil, msg = nil)
        pbInflictStatus(:FROSTBITE, 0, msg, user)
    end

    #=============================================================================
    # Paralyze
    #=============================================================================
    def numbed?
        return pbHasStatus?(:NUMB)
    end

    def canNumb?(user, showMessages, move = nil)
        return pbCanInflictStatus?(:NUMB, user, showMessages, move)
    end

    def applyNumb(user = nil, msg = nil)
        pbInflictStatus(:NUMB, 0, msg, user)
    end

    #=============================================================================
    # Dizzy
    #=============================================================================
    def dizzy?
        return pbHasStatus?(:DIZZY)
    end

    def canDizzy?(user, showMessages, move = nil)
        return pbCanInflictStatus?(:DIZZY, user, showMessages, move)
    end

    def applyDizzy(user = nil, msg = nil)
        pbInflictStatus(:DIZZY, 0, msg, user)
    end

    #=============================================================================
    # Leeched
    #=============================================================================
    def leeched?
        return pbHasStatus?(:LEECHED)
    end

    def canLeech?(user, showMessages, move = nil)
        return pbCanInflictStatus?(:LEECHED, user, showMessages, move)
    end

    def applyLeeched(user = nil, msg = nil)
        pbInflictStatus(:LEECHED, 0, msg, user)
    end

    #=============================================================================
    # Flinching
    #=============================================================================
    def pbFlinch(_user = nil)
        unless @battle.moldBreaker
            return if hasActiveAbility?(GameData::Ability::FLINCH_IMMUNITY_ABILITIES)
            return if @battle.pbCheckSameSideAbility(:HEARTENINGAROMA,@index)
        end
        applyEffect(:Flinch)
    end

    #=============================================================================
    # Generalised status displays
    #=============================================================================
    def pbContinueStatus(statusToContinue = nil)
        getStatuses.each do |oneStatus|
            next if !statusToContinue.nil? && oneStatus != statusToContinue
            if oneStatus == :POISON && @statusCount.positive?
                @battle.pbCommonAnimation("Toxic", self)
            else
                anim_name = GameData::Status.get(oneStatus).animation
                @battle.pbCommonAnimation(anim_name, self) if anim_name
            end
            poisonCount = getStatusCount(:POISON)
            yield if block_given?
            if !defined?($PokemonSystem.status_effect_messages) || $PokemonSystem.status_effect_messages.zero?
                case oneStatus
                when :SLEEP
                    @battle.pbDisplay(_INTL("{1} is fast asleep.", pbThis))
                when :POISON
                    case poisonCount
                    when 0..2
                        @battle.pbDisplay(_INTL("{1} was hurt by poison!", pbThis))
                    when 3..5
                        @battle.pbDisplay(_INTL("{1} was badly hurt by poison!", pbThis))
                    when 6..8
                        @battle.pbDisplay(_INTL("{1} was extremely hurt by poison!", pbThis))
                    else
                        @battle.pbDisplay(_INTL("{1} was brought to its knees entirely by poison!", pbThis))
                    end
                    unless fainted?
                        increaseStatusCount(:POISON)
                        newPoisonCount = getStatusCount(:POISON)
                        if newPoisonCount % 3 == 0
                            if newPoisonCount == 3
                                @battle.pbDisplaySlower(_INTL("The poison worsened! Its damage will be doubled until {1} leaves the field.",
pbThis(true)))
                            else
                                @battle.pbDisplaySlower(_INTL("The poison doubled yet again!", pbThis))
                            end
                        end
                    end
                when :BURN
                    @battle.pbDisplay(_INTL("{1} was hurt by its burn!", pbThis))
                when :FROSTBITE
                    @battle.pbDisplay(_INTL("{1} was hurt by frostbite!", pbThis))
                when :LEECHED
                    @battle.pbDisplay(_INTL("{1}'s health was sapped!", pbThis))
                end
            end
            PBDebug.log("[Status continues] #{pbThis}'s sleep count is #{@statusCount}") if oneStatus == :SLEEP
        end
    end

    def pbCureStatus(showMessages = true, statusToCure = nil)
        oldStatuses = []

        if statusToCure.nil? || @status == statusToCure
            oldStatuses.push(@status)
            self.status = :NONE
        end

        if @bossStatus == statusToCure
            oldStatuses.push(@bossStatus)
            self.bossStatus = :NONE
        elsif @status == :NONE
            self.status = @bossStatus
            self.bossStatus = :NONE
        end

        oldStatuses.each do |oldStatus|
            next if oldStatus == :NONE

            PokeBattle_Battler.showStatusCureMessage(oldStatus, self, @battle) if showMessages
            PBDebug.log("[Status change] #{pbThis}'s status #{oldStatus} was cured")

            # Lingering Daze
            next unless oldStatus == :SLEEP
            @battle.eachOtherSideBattler(@index) do |b|
                if b.hasActiveAbility?(:LINGERINGDAZE)
                    pbLowerMultipleStatSteps(ALL_STATS_2, b, ability: :LINGERINGDAZE)
                end
            end
        end

        refreshDataBox
    end

    def self.showStatusCureMessage(status, pokemonOrBattler, battle)
        curedName = pokemonOrBattler.is_a?(PokeBattle_Battler) ? pokemonOrBattler.pbThis : pokemonOrBattler.name
        case status
        when :SLEEP			then battle.pbDisplay(_INTL("{1} woke up!", curedName))
        when :POISON		then battle.pbDisplay(_INTL("{1} was cured of its poisoning.", curedName))
        when :BURN	        then battle.pbDisplay(_INTL("{1}'s burn was healed.", curedName))
        when :FROSTBITE	    then battle.pbDisplay(_INTL("{1}'s frostbite was healed.", curedName))
        when :NUMB 			then battle.pbDisplay(_INTL("{1} is no longer numbed.", curedName))
        when :DIZZY			then battle.pbDisplay(_INTL("{1} is no longer dizzy!", curedName))
        when :LEECHED	    then battle.pbDisplay(_INTL("{1} is no longer being leeched!", curedName))
        end
    end
end
