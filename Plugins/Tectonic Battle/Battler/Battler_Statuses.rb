def getSleepExplanation; return _INTL("It'll skip its next two moves"); end
def getBurnExplanation; return _INTL("Its physical damage is reduced by a third"); end
def getPoisonExplanation; return _INTL("The poison will worsen over time"); end
def getFrostbiteExplanation; return _INTL("Its special damage is reduced by a third"); end
def getNumbExplanation; return _INTL("Its Speed is halved, and it'll deal less damage"); end
def getDizzyExplanation; return _INTL("Its ability is suppressed, and it'll take more damage"); end
def getLeechExplanation; return _INTL("Its HP will be siphoned by the opposing side"); end

POISON_DOUBLING_TURNS = 2

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

    def hasStatusNoSleep?
        getStatuses.each do |status|
            next if status == :NONE
            next if status == :SLEEP
            return true
        end
        return false
    end

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
        if !hasSpotsForStatus && !ignoreStatus
            @battle.pbDisplay(_INTL("{1} cannot have any more status problems...", pbThis(false))) if showMessages
            return false
        end
        # Trying to inflict a status problem on a Pokémon behind a substitute
        if substituted? && !(move && move.ignoresSubstitute?(user)) && !selfInflicted && !statusDoublingCurse
            @battle.pbDisplay(_INTL("It doesn't affect {1} behind its substitute...", pbThis(true))) if showMessages
            return false
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
                        showMyAbilitySplash(downsideAbility)
                        @battle.pbDisplay(_INTL("{1}'s ability prevents being dizzied!", pbThis))
                        hideMyAbilitySplash
                    end
                    return false
                end
            end
            # Downside abilities
            unstoppableAbility = immutableAbility?
            if unstoppableAbility
                if showMessages
                    showMyAbilitySplash(unstoppableAbility)
                    @battle.pbDisplay(_INTL("{1}'s ability can't be prevented, so it can't be dizzied!", pbThis))
                    hideMyAbilitySplash
                end
                return false
            end
        end
        # Type immunities
        immuneType = hasTypeImmunityToStatus?(newStatus, user)
        if immuneType
            immuneTypeRealName = GameData::Type.get(immuneType).name
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
        if pbOwnSide.effectActive?(:Safeguard) && !selfInflicted &&
           !(user && user.hasActiveAbility?(:INFILTRATOR)) && !statusDoublingCurse
            @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
            return false
        end
        return true
    end

    def pbCanSynchronizeStatus?(newStatus, applicator)
        return false if fainted?
        # Trying to replace a status problem with another one
        return false unless hasSpotsForStatus
        # Already has that status
        return false if getStatuses.include?(newStatus)
        # Type immunities
        return false if hasTypeImmunityToStatus?(newStatus, applicator)
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
        return false if pbOwnSide.effectActive?(:Safeguard) && !(applicator && applicator.hasActiveAbility?(:INFILTRATOR))
        return true
    end

    # Returns which type is providing the immunity
    # Or nil if no immunity present
    def hasTypeImmunityToStatus?(status, applicator)
        immuneType = nil
        case status
        when :POISON
            unless applicator&.hasActiveAbility?(:CORROSION)
                immuneType = :STEEL if pbHasType?(:STEEL)
                immuneType = :POISON if pbHasType?(:POISON)
            end
        when :BURN
            immuneType = :FIRE if pbHasType?(:FIRE)
        when :NUMB
            immuneType = :ELECTRIC if pbHasType?(:ELECTRIC)
        when :FROSTBITE
            immuneType = :ICE if pbHasType?(:ICE)
        when :LEECHED
            immuneType = :GRASS if pbHasType?(:GRASS)
        end
        return immuneType
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
                if $PokemonSystem.status_effect_messages.zero?
                    case newStatus
                    when :SLEEP
                        @battle.pbDisplay(_INTL("{1} fell asleep! {2}!", pbThis, getSleepExplanation))
                    when :POISON
                        @battle.pbDisplay(_INTL("{1} was poisoned! {2}!", pbThis, getPoisonExplanation))
                    when :BURN
                        @battle.pbDisplay(_INTL("{1} was burned! {2}!", pbThis, getBurnExplanation))
                    when :NUMB
                        @battle.pbDisplay(_INTL("{1} is numbed! {2}!", pbThis, getNumbExplanation))
                    when :FROSTBITE
                        @battle.pbDisplay(_INTL("{1} was frostbitten! {2}!", pbThis, getFrostbiteExplanation))
                    when :DIZZY
                        @battle.pbDisplay(_INTL("{1} is dizzy! {2}!", pbThis, getDizzyExplanation))
                    when :LEECHED
                        @battle.pbDisplay(_INTL("{1} became leeched! {2}!", pbThis, getLeechExplanation))
                    end
                else # Skip full status explanation if setting was turned off
                    case newStatus
                    when :SLEEP
                        @battle.pbDisplay(_INTL("{1} fell asleep!", pbThis))
                    when :POISON
                        @battle.pbDisplay(_INTL("{1} was poisoned!", pbThis))
                    when :BURN
                        @battle.pbDisplay(_INTL("{1} was burned!", pbThis))
                    when :NUMB
                        @battle.pbDisplay(_INTL("{1} is numbed!", pbThis))
                    when :FROSTBITE
                        @battle.pbDisplay(_INTL("{1} was frostbitten!", pbThis))
                    when :DIZZY
                        @battle.pbDisplay(_INTL("{1} is dizzy!", pbThis))
                    when :LEECHED
                        @battle.pbDisplay(_INTL("{1} became leeched!", pbThis))
                    end
                end
            end
        end
        if newStatus == :SLEEP
            PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}")

            # Dream Weaver
            @battle.eachBattler do |b|
                next unless b.hasActiveAbility?(:DREAMWEAVER)
                b.tryRaiseStat(:SPECIAL_ATTACK, b, ability: :DREAMWEAVER, increment: 2)
            end

            # Snooze Fest
            if hasActiveAbility?(:SNOOZEFEST)
                showMyAbilitySplash(:SNOOZEFEST)
                eachOther do |b|
                    next unless b.canSleep?(self, true)
                    next if b.effectActive?(:Yawn)
                    b.applyEffect(:Yawn,2)
                end
                hideMyAbilitySplash
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
        disableEffect(:Outrage) if asleep?

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

    def getPoisonDoublings
        poisonCount = getStatusCount(:POISON)
        if boss?
            doublings = poisonCount / (POISON_DOUBLING_TURNS * 2)
        else
            doublings = poisonCount / POISON_DOUBLING_TURNS
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
        return true if neurotoxined?
        return pbHasStatus?(:DIZZY)
    end

    def neurotoxined?
        return false unless poisoned?
        @battle.pbOpposingParty(@index).each do |enemyPartyMember|
            next if enemyPartyMember.nil?
            next if enemyPartyMember.fainted?
            next unless enemyPartyMember.hasAbility?(:NEUROTOXIN)
            next if enemyPartyMember.status == :DIZZY
            return true
        end
        return false
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
    def flinchImmuneByAbility?(checkingForAI = false)
        unless @battle.moldBreaker
            return true if shouldAbilityApply?(GameData::Ability.getByFlag("FlinchImmunity"), checkingForAI)
            return true if @battle.pbCheckSameSideAbility(:EFFLORESCENT,@index)
        end
        return false
    end
    
    def pbFlinch
        return if flinchImmuneByAbility?
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

            showMessages = $PokemonSystem.status_effect_messages.zero?
            
            case oneStatus
            when :SLEEP
                @battle.pbDisplay(_INTL("{1} is fast asleep.", pbThis)) if showMessages
            when :POISON
                if showMessages
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
                end
                unless fainted?
                    increaseStatusCount(:POISON)
                    newPoisonCount = getStatusCount(:POISON)
                    if newPoisonCount % POISON_DOUBLING_TURNS == 0
                        if showMessages
                            if newPoisonCount == POISON_DOUBLING_TURNS
                                @battle.pbDisplaySlower(_INTL("The poison worsened! Its damage will be doubled until {1} leaves the field.", pbThis(true)))
                            else
                                @battle.pbDisplaySlower(_INTL("The poison doubled yet again!", pbThis))
                            end
                        else
                            @battle.pbDisplay(_INTL("{1}'s poison worsened!", pbThis))
                        end
                    end
                end
            when :BURN
                @battle.pbDisplay(_INTL("{1} was hurt by its burn!", pbThis)) if showMessages
            when :FROSTBITE
                @battle.pbDisplay(_INTL("{1} was hurt by frostbite!", pbThis)) if showMessages
            when :LEECHED
                @battle.pbDisplay(_INTL("{1}'s health was sapped!", pbThis)) if showMessages
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
