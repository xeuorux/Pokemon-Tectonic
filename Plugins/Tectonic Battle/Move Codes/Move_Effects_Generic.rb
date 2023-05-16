#===============================================================================
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Status moves always fail.
#===============================================================================
class PokeBattle_UnimplementedMove < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        if statusMove?
            @battle.pbDisplay(_INTL("But it failed, since the move isn't implemented in the code!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Pseudomove for confusion damage.
#===============================================================================
class PokeBattle_Confusion < PokeBattle_Move
    def initialize(battle, move, basePower = 50)
        @battle     = battle
        @realMove   = move
        @id         = 0
        @name       = ""
        @function   = "000"
        @baseDamage = basePower
        @type       = nil
        @category   = 0
        @accuracy   = 100
        @pp         = -1
        @target     = 0
        @priority   = 0
        @flags      = ""
        @effectChance = 0
        @calcType   = nil
        @powerBoost = false
        @snatched   = false
    end

    def physicalMove?(_thisType = nil);    return true;  end
    def specialMove?(_thisType = nil);     return false; end
    def pbCriticalOverride(_user, _target); return -1; end
end

#===============================================================================
# Pseudomove for charm damage.
#===============================================================================
class PokeBattle_Charm < PokeBattle_Move
    def initialize(battle, move, basePower = 50)
        @battle     = battle
        @realMove   = move
        @id         = 0
        @name       = ""
        @function   = "000"
        @baseDamage = basePower
        @type       = nil
        @category   = 1
        @accuracy   = 100
        @pp         = -1
        @target     = 0
        @priority   = 0
        @flags      = ""
        @effectChance = 0
        @calcType   = nil
        @powerBoost = false
        @snatched   = false
    end

    def physicalMove?(_thisType = nil);    return false; end
    def specialMove?(_thisType = nil);     return true; end
    def pbCriticalOverride(_user, _target); return -1; end
end

#===============================================================================
# Implements the move Struggle.
# For cases where the real move named Struggle is not defined.
#===============================================================================
class PokeBattle_Struggle < PokeBattle_Move
    def initialize(battle, move)
        @battle     = battle
        @realMove   = nil # Not associated with a move
        @id         = move ? move.id : :STRUGGLE
        @name       = move ? move.name : _INTL("Struggle")
        @function   = "002"
        @baseDamage = 50
        @type       = nil
        @category   = 0
        @accuracy   = 0
        @pp         = -1
        @target     = 0
        @priority   = 0
        @flags      = ""
        @effectChance = 0
        @calcType   = nil
        @powerBoost = false
        @snatched   = false
        @calculated_category = 0
    end

    def calculateCategory(user, _targets)
        return selectBestCategory(user)
    end

    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        user.applyFractionalDamage(1.0 / 4.0, false, struggle: true)
        @battle.pbDisplay(_INTL("{1} was damaged by recoil!", user.pbThis))
    end
end

#===============================================================================
# Generic status problem-inflicting classes.
#===============================================================================
class PokeBattle_SleepMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        return !target.canSleep?(user, show_message, self)
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applySleep
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applySleep if target.canSleep?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getSleepEffectScore(user, target)
    end
end

class PokeBattle_PoisonMove < PokeBattle_Move
    def initialize(battle, move)
        super
        @toxic = false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        return !target.canPoison?(user, show_message, self)
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.applyPoison(user, nil, @toxic)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyPoison(user, nil, @toxic) if target.canPoison?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getPoisonEffectScore(user, target)
    end
end

class PokeBattle_NumbMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        return !target.canNumb?(user, show_message, self)
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.applyNumb(user)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyNumb(user) if target.canNumb?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getNumbEffectScore(user, target)
    end
end

class PokeBattle_BurnMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        return !target.canBurn?(user, show_message, self)
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.applyBurn(user)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyBurn(user) if target.canBurn?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getBurnEffectScore(user, target)
    end
end

#===============================================================================
# Other problem-causing classes.
#===============================================================================
class PokeBattle_FlinchMove < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.pbFlinch
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.pbFlinch
    end

    def getTargetAffectingEffectScore(user, target)
        baseScore = baseDamage * 10 / user.level
        score = getFlinchingEffectScore(baseScore, user, target, self)
        return score
    end
end

#===============================================================================
# Generic user's stat increase classe.
#===============================================================================
class PokeBattle_StatUpMove < PokeBattle_Move
    def statUp; return @statUp; end

    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        return !user.pbCanRaiseStatStep?(@statUp[0], user, self, show_message)
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.tryRaiseStat(@statUp[0], user, increment: @statUp[1], move: self)
    end

    def pbAdditionalEffect(user, _target)
        user.tryRaiseStat(@statUp[0], user, increment: @statUp[1], move: self)
    end

    def getEffectScore(user, target)
        return getMultiStatUpEffectScore(@statUp, user, user)
    end
end

class PokeBattle_MultiStatUpMove < PokeBattle_Move
    # Each subclass of this must initialize a @statUp in its initialization method

    def statUp; return @statUp; end

    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        failed = true
        for i in 0...@statUp.length / 2
            next unless user.pbCanRaiseStatStep?(@statUp[i * 2], user, self)
            failed = false
            break
        end
        if failed
            @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.pbRaiseMultipleStatSteps(@statUp, user, move: self)
    end

    def pbAdditionalEffect(user, _target)
        user.pbRaiseMultipleStatSteps(@statUp, user, move: self)
    end

    def getEffectScore(user, target)
        return getMultiStatUpEffectScore(@statUp, user, user)
    end
end

class PokeBattle_StatDownMove < PokeBattle_Move
    def pbEffectWhenDealingDamage(user, target)
        return if @battle.pbAllFainted?(target.idxOwnSide)
        user.pbLowerMultipleStatSteps(@statDown, user, move: self)
    end

    def getEffectScore(user, _target)
        return -getMultiStatUpEffectScore(@statDown, user, user)
    end
end

#===============================================================================
# Generic target's stat decrease classes.
#===============================================================================
class PokeBattle_TargetStatDownMove < PokeBattle_Move
    attr_accessor :statDown

    def pbFailsAgainstTarget?(user, target, show_message)
        failsWithTarget?(user, target, show_message, false)
    end

    def shouldShade?(user, target)
        failsWithTarget?(user, target, false, true)
    end

    def failsWithTarget?(user, target, show_message, ignore_abilities)
        return false if damagingMove?
        return !target.pbCanLowerStatStep?(@statDown[0], user, self, show_message, ignoreAbilities: ignore_abilities)
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.tryLowerStat(@statDown[0], user, increment: @statDown[1], move: self)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.tryLowerStat(@statDown[0], user, increment: @statDown[1], move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore(@statDown, user, target)
    end
end

class PokeBattle_TargetMultiStatDownMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        failed = true
        for i in 0...@statDown.length / 2
            next unless target.pbCanLowerStatStep?(@statDown[i * 2], user, self)
            failed = false
            break
        end
        if failed
            # NOTE: It's a bit of a faff to make sure the appropriate failure message
            #       is shown here, I know.
            canLower = false
            if target.hasActiveAbility?(:CONTRARY) && !@battle.moldBreaker
                for i in 0...@statDown.length / 2
                    next if target.statStepAtMax?(@statDown[i * 2])
                    canLower = true
                    break
                end
                @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis)) if !canLower && show_message
            else
                for i in 0...@statDown.length / 2
                    next if target.statStepAtMin?(@statDown[i * 2])
                    canLower = true
                    break
                end
                @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!", user.pbThis)) if !canLower && show_message
            end
            target.pbCanLowerStatStep?(@statDown[0], user, self, true) if canLower && show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.pbLowerMultipleStatSteps(@statDown, user, move: self)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.pbLowerMultipleStatSteps(@statDown, user, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore(@statDown, user, target)
    end
end

#===============================================================================
# Fixed damage-inflicting move.
#===============================================================================
class PokeBattle_FixedDamageMove < PokeBattle_Move
    def pbFixedDamage(_user, _target); return 1; end

    def pbCalcTypeModSingle(moveType, defType, user, target)
        ret = super
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE unless Effectiveness.ineffective?(ret)
        return ret
    end

    def pbCalcDamage(user, target, numTargets = 1)
        fixedDamage = pbFixedDamage(user, target)
        if fixedDamage
            target.damageState.critical = false
            target.damageState.calcDamage = fixedDamage
            target.damageState.calcDamage = 1 if target.damageState.calcDamage < 1
        else
            super
        end
    end

    def calculateDamageForHit(user, target, type, baseDmg, numTargets, aiChecking = false)
        fixedDamage = pbFixedDamage(user, target)
        return fixedDamage if fixedDamage
        super
    end

    def displayWeatherDebuffMessages(_user, _type); return; end
end

#===============================================================================
# Two turn move.
#===============================================================================
class PokeBattle_TwoTurnMove < PokeBattle_Move
    def chargingTurnMove?; return true; end

    # :TwoTurnAttack is set to the move's ID if this
    # method returns true, or nil if false.
    # Non-nil means the charging turn. nil means the attacking turn.
    def pbIsChargingTurn?(user)
        @powerHerb = false
        @chargingTurn = false # Assume damaging turn by default
        @damagingTurn = true
        # 0 at start of charging turn, move's ID at start of damaging turn
        unless user.effectActive?(:TwoTurnAttack)
            @powerHerb = user.hasActiveItem?(:POWERHERB)
            @chargingTurn = true
            @damagingTurn = @powerHerb
        end
        return !@damagingTurn # Deliberately not "return @chargingTurn"
    end

    def damagingMove? # Stops damage being dealt in the first (charging) turn
        return false unless @damagingTurn
        return super
    end

    def pbAccuracyCheck(user, target)
        return true unless @damagingTurn
        return super
    end

    def pbInitialEffect(user, targets, _hitNum)
        pbChargingTurnMessage(user, targets) if @chargingTurn
        if @chargingTurn && @damagingTurn # Move only takes one turn to use
            pbShowAnimation(@id, user, targets, 1) # Charging anim
            targets.each { |b| pbChargingTurnEffect(user, b) }
            if @powerHerb
                # Moves that would make the user semi-invulnerable will hide the user
                # after the charging animation, so the "UseItem" animation shouldn't show
                # for it
                @battle.pbCommonAnimation("UseItem", user) unless %w[0C9 0CA 0CB 0CC 0CD 0CE 14D].include?(@function)
                @battle.pbDisplay(_INTL("{1} became fully charged due to its Power Herb!", user.pbThis))
                user.consumeItem(:POWERHERB)
            end
        end
        pbAttackingTurnMessage(user, targets) if @damagingTurn
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} began charging up!", user.pbThis))
    end

    def pbAttackingTurnMessage(user, targets); end

    def pbChargingTurnEffect(user, target)
        # Skull Bash/Sky Drop/Zephyr Wing are the only two-turn moves with an effect here, and
        # the latter just records the target is being Sky Dropped
    end

    def pbAttackingTurnEffect(user, target); end

    def pbEffectAgainstTarget(user, target)
        if @damagingTurn
            pbAttackingTurnEffect(user, target)
        elsif @chargingTurn
            pbChargingTurnEffect(user, target)
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 if @chargingTurn && !@damagingTurn # Charging anim
        super
    end

    def getEffectScore(user, _target)
        score = 0
        score -= 20 unless user.firstTurn?
        score -= 40 unless user.hasActiveItem?(:POWERHERB)
        return score
    end
end

#===============================================================================
# Healing move.
#===============================================================================
class PokeBattle_HealingMove < PokeBattle_Move
    def healingMove?; return true; end
    def healRatio(_user); return 0.0; end # A float value representing the percent HP heal

    def pbHealAmount(user)
        ratio = healRatio(user)
        if ratio > 0
            healAmount = user.totalhp * ratio
            healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if user.boss?
            return healAmount
        end
        return 1
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.fullHealth?
            @battle.pbDisplay(_INTL("{1}'s HP is full!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        amt = pbHealAmount(user)
        user.pbRecoverHP(amt) if amt > 0
    end

    def getEffectScore(user, target)
        scoringMagnitude = 3
        ratio = healRatio(user)
        scoringMagnitude = 10 * ratio if ratio > 0
        return getHealingEffectScore(user, target, scoringMagnitude)
    end
end

class PokeBattle_HalfHealingMove < PokeBattle_HealingMove
    def healRatio(_user)
        return 1.0 / 2.0
    end
end

#===============================================================================
# Recoil move.
#===============================================================================
module Recoilable
    def recoilMove?; return true; end

    def recoilFactor; return 0.0; end

    def pbRecoilDamage(user, target)
        return (target.damageState.totalHPLost * finalRecoilFactor(user)).round
    end

    def finalRecoilFactor(user, checkingForAI = false)
        return 0 if user.shouldAbilityApply?(:ROCKHEAD, checkingForAI)
        factor = recoilFactor
        factor /= 2 if user.shouldAbilityApply?(:UNBREAKABLE, checkingForAI)
        return factor
    end

    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        recoilDamage = pbRecoilDamage(user, target)
        user.applyRecoilDamage(recoilDamage, false, true)
    end

    def getEffectScore(user, _target)
        return -50 * finalRecoilFactor(user, true)
    end
end

class PokeBattle_RecoilMove < PokeBattle_Move
    include Recoilable
end

#===============================================================================
# Protect move.
#===============================================================================
class PokeBattle_ProtectMove < PokeBattle_Move
    def initialize(battle, move)
        super
        @sidedEffect = false
    end

    # Make sure protectfailure stays active if already is
    # It is set to false in the pbChangeUsageCounters base method
    def pbChangeUsageCounters(user, specialUsage)
        failure = user.effectActive?(:ProtectFailure)
        super
        user.applyEffect(:ProtectFailure) if failure
    end

    def pbMoveFailed?(user, _targets, show_message)
        shouldFail = false
        if @sidedEffect
            shouldFail = true if user.pbOwnSide.effectActive?(@effect)
        elsif user.effectActive?(@effect)
            shouldFail = true
        end
        if shouldFail
            @battle.pbDisplay(_INTL("But it failed, since the effect is already active!")) if show_message
            return true
        end
        if user.effectActive?(:ProtectFailure)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} used a protection move last turn!")) if show_message
            return true
        end
        return false
    end

    def moveFailed(user, _targets)
        user.disableEffect(:ProtectFailure)
    end

    def pbMoveFailedNoSpecial?(user, _targets)
        if pbMoveFailedLastInRound?(user)
            user.disableEffect(:ProtectFailure)
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        if @sidedEffect
            user.pbOwnSide.applyEffect(@effect)
        else
            user.applyEffect(@effect)
        end
        user.applyEffect(:ProtectFailure)
        pbProtectMessage(user)
    end

    def pbProtectMessage(user)
        if @sidedEffect
            @battle.pbDisplay(_INTL("{1} protected {2}!", @name, user.pbTeam(true)))
        else
            @battle.pbDisplay(_INTL("{1} protected itself!", user.pbThis))
        end
    end

    def getEffectScore(user, _target)
        score = 0
        user.eachPredictedProtectHitter do |b|
            score += 30 if user.hasAlly?
        end
        score *= 2 if user.belowHalfHealth?
        user.eachOpposing do |b|
            score += 30 if b.poisoned?
            score += 30 if b.leeched?
            score += 20 if b.burned?
            score += 20 if b.frostbitten?
        end
        return score
    end
end

#===============================================================================
# Moves that protect the user from half damage this turn.
#===============================================================================
class PokeBattle_HalfProtectMove < PokeBattle_ProtectMove
    def getOnHitEffectScore(user,target)
        return 0
    end

    def getEffectScore(user, _target)
        score = 0
        user.eachPredictedAttacker do |b|
            score += 25 if user.hasAlly?
            score += 25 if b.poisoned?
            score += 25 if b.leeched?
            score += 15 if b.burned?
            score += 15 if b.frostbitten?

            # Calculate the expected value of the on-hit effect
            score += getOnHitEffectScore(user,b)
        end
        return score
    end
end

#===============================================================================
# Weather-inducing move.
#===============================================================================
class PokeBattle_WeatherMove < PokeBattle_Move
    def initialize(battle, move)
        super
        @weatherType = :None
        @durationSet = 8
    end

    def pbMoveFailed?(_user, _targets, show_message)
        return false if damagingMove?
        return @battle.primevalWeatherPresent?(show_message)
    end

    def pbEffectGeneral(user)
        @battle.pbStartWeather(user, @weatherType, @durationSet, false) unless @battle.primevalWeatherPresent?
    end

    def getEffectScore(user, _target)
        return getWeatherSettingEffectScore(@weatherType, user, @battle, @durationSet)
    end
end

#===============================================================================
# Pledge move.
#===============================================================================
class PokeBattle_PledgeMove < PokeBattle_Move
    def pbOnStartUse(user, _targets)
        @pledgeSetup = false
        @pledgeCombo = false
        @pledgeOtherUser = nil
        @comboEffect = nil
        @overrideType = nil
        @overrideAnim = nil
        # Check whether this is the use of a combo move
        @combos.each do |i|
            next if i[0] != user.effects[:FirstPledge]
            @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
            @pledgeCombo = true
            @comboEffect = i[1]
            @overrideType = i[2]
            @overrideAnim = i[3]
            @overrideType = nil unless GameData::Type.exists?(@overrideType)
            break
        end
        return if @pledgeCombo
        # Check whether this is the setup of a combo move
        user.eachAlly do |b|
            next if @battle.choices[b.index][0] != :UseMove || b.movedThisRound?
            move = @battle.choices[b.index][2]
            next unless move
            @combos.each do |i|
                next if i[0] != move.function
                @pledgeSetup = true
                @pledgeOtherUser = b
                break
            end
            break if @pledgeSetup
        end
    end

    def damagingMove?
        return false if @pledgeSetup
        return super
    end

    def pbBaseType(user)
        return @overrideType unless @overrideType.nil?
        return super
    end

    def pbBaseDamage(baseDmg, _user, _target)
        baseDmg *= 2 if @pledgeCombo
        return baseDmg
    end

    def pbEffectGeneral(user)
        user.disableEffect(:FirstPledge)
        return unless @pledgeSetup
        @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",
           user.pbThis, @pledgeOtherUser.pbThis(true)))
        @pledgeOtherUser.applyEffect(:FirstPledge, @function)
        @pledgeOtherUser.applyEffect(:MoveNext)
        user.lastMoveFailed = true # Treated as a failure for Stomping Tantrum
    end

    def pbEffectAfterAllHits(user, _target)
        return unless @pledgeCombo

        animName = nil
        case @comboEffect
        when :SeaOfFire # Grass + Fire
            unless user.pbOpposingSide.effectActive?(:SeaOfFire)
                user.pbOpposingSide.applyEffect(:SeaOfFire, 4)
                animName = user.opposes? ? "SeaOfFire" : "SeaOfFireOpp"
            end
        when :Rainbow # Fire + Water
            unless user.pbOpposingSide.effectActive?(:Rainbow)
                user.pbOpposingSide.applyEffect(:Rainbow, 4)
                animName = user.opposes? ? "RainbowOpp" : "Rainbow"
            end
        when :Swamp # Water + Grass
            unless user.pbOpposingSide.effectActive?(:Swamp)
                user.pbOpposingSide.applyEffect(:Swamp, 4)
                animName = user.opposes? ? "Swamp" : "SwampOpp"
            end
        end
        @battle.pbCommonAnimation(animName) if animName
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        return if @pledgeSetup # No animation for setting up
        id = @overrideAnim if @overrideAnim
        return super
    end
end

#===============================================================================
# Dizzies the target.
#===============================================================================
class PokeBattle_DizzyMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        return !target.canDizzy?(user, show_message, self)
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyDizzy
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return unless target.canDizzy?(user, false, self)
        target.applyDizzy
    end

    def getTargetAffectingEffectScore(user, target)
        return getDizzyEffectScore(user, target)
    end
end

#===============================================================================
# Leeches the target
#===============================================================================
class PokeBattle_LeechMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        return !target.canLeech?(user, show_message, self)
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyLeeched
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return unless target.canLeech?(user, false, self)
        target.applyLeeched
    end

    def getTargetAffectingEffectScore(user, target)
        return getLeechEffectScore(user, target)
    end
end

#===============================================================================
# Frostbite's the target.
#===============================================================================
class PokeBattle_FrostbiteMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        return !target.canFrostbite?(user, show_message, self)
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyFrostbite
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return unless target.canFrostbite?(user, false, self)
        target.applyFrostbite
    end

    def getTargetAffectingEffectScore(user, target)
        return getFrostbiteEffectScore(user, target)
    end
end

class PokeBattle_TargetMultiStatUpMove < PokeBattle_Move
    # Each subclass of this must initialize a @statUp in its initialization method
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        failed = true
        for i in 0...@statUp.length / 2
            next unless target.pbCanRaiseStatStep?(@statUp[i * 2], user, self)
            failed = false
            break
        end
        if failed
            # NOTE: It's a bit of a faff to make sure the appropriate failure message
            #       is shown here, Inow.
            canRaise = false
            if target.hasActiveAbility?(:CONTRARY) && !@battle.moldBreaker
                for i in 0...@statUp.length / 2
                    next if target.statStepAtMin?(@statUp[i * 2])
                    canRaise = true
                    break k
                end
                @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!", target.pbThis)) if !canRaise && show_message
            else
                for i in 0...@statUp.length / 2
                    next if target.statStepAtMax?(@statUp[i * 2])
                    canRaise = true
                    break
                end
                @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", target.pbThis)) if !canRaise && show_message
            end
            target.pbCanRaiseStatStep?(@statUp[0], user, self, true) if canRaise
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.pbRaiseMultipleStatSteps(@statUp, user, move: self)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.pbRaiseMultipleStatSteps(@statUp, user, move: self)
    end

    def getEffectScore(user, target)
        return getMultiStatUpEffectScore(@statUp, user, target)
    end
end

class PokeBattle_SnowballingMove < PokeBattle_Move
    def initialize(battle, move)
        super
        @effectData = GameData::BattleEffect.get(@usageCountEffect)
    end

    def pbChangeUsageCounters(user, specialUsage)
        oldVal = user.effects[@usageCountEffect]
        super
        user.effects[@usageCountEffect] = [oldVal + 1, @effectData.maximum].min
    end

    def damageAtCount(baseDmg, count)
        return baseDmg << count
    end

    def pbBaseDamage(baseDmg, user, _target)
        return damageAtCount(baseDmg, user.effects[@usageCountEffect] - 1)
    end

    def pbBaseDamageAI(baseDmg, user, _target)
        return damageAtCount(baseDmg, user.effects[@usageCountEffect])
    end

    def getEffectScore(user, _target)
        return 20 if user.firstTurn?
        return 0
    end
end

class PokeBattle_RoomMove < PokeBattle_Move
    def setsARoom?(); return true; end

    def initialize(battle, move)
        super
        @roomEffect = nil
    end

    def pbEffectGeneral(user)
        @battle.pbStartRoom(@roomEffect, user)
    end

    def getEffectScore(user, _target)
        return 5 * user.getRoomDuration
    end
end

class PokeBattle_DrainMove < PokeBattle_Move
    def healingMove?; return true; end

    def drainFactor(_user, _target); return 0.0; end

    def shouldDrain?(_user, _target); return true; end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.hpLost <= 0 || !shouldDrain?(user, target)
        hpGain = (target.damageState.hpLost * drainFactor(user, target)).round
        user.pbRecoverHPFromDrain(hpGain, target)
    end

    def getEffectScore(user, target)
        score = 40 * drainFactor(user, target)
        score *= 1.5 if user.hasActiveAbilityAI?(:ROOTED)
        score *= 2.0 if user.hasActiveAbilityAI?(:GLOWSHROOM) && user.battle.pbWeather == :Moonglow
        score *= 1.3 if user.hasActiveItem?(:BIGROOT)
        score *= 2 if user.belowHalfHealth?
        score *= -1 if target.hasActiveAbilityAI?(:LIQUIDOOZE) || user.effectActive?(:NerveBreak)
        return score
    end
end

#===============================================================================
# Weather and status inducing move.
#===============================================================================
class PokeBattle_InvokeMove < PokeBattle_Move
    def initialize(battle, move)
        super
        @weatherType = :None
        @durationSet = 4
        @statusToApply = nil
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if @battle.primevalWeatherPresent?(false) && target.pbCanInflictStatus?(@statusToApply, user, false,
self) && show_message
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't gain the status and the weather can't be set!"))
        end
    end

    def pbEffectAgainstTarget(user, target)
        target.pbInflictStatus(@statusToApply, 0, nil, user) if target.pbCanInflictStatus?(@statusToApply, user,
true, self)
        @battle.pbStartWeather(user, @weatherType, @durationSet, false) unless @battle.primevalWeatherPresent?
    end

    def getEffectScore(user, target)
        weatherScore = getWeatherSettingEffectScore(@weatherType, user, @battle, @durationSet)
        statusScore = getStatusSettingEffectScore(@statusToApply, user, target)
        return weatherScore + statusScore
    end
end

#===============================================================================
# Type-inducing entry hazard move.
# Removes similar spikes when setting.
# If a damaging move, sets the hazard on the side of the target.
# If a status move, sets the hazard on the side of the user's opponent
#===============================================================================
class PokeBattle_StatusSpikeMove < PokeBattle_Move
    def hazardMove?; return true; end
    def aiAutoKnows?(pokemon); return true; end

    # Every subclass of this needs to assign something to @spikeEffect, and then call super
    def initialize(battle, move)
        super
        @spikeData = GameData::BattleEffect.get(@spikeEffect)
    end

    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.pbOpposingSide.effectAtMax?(@spikeEffect)
            maximum = @spikeData.maximum
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the opposing side already has #{maximum} layers of #{@spikeData.real_name} spikes!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        addSpikeLayer(user.pbOpposingSide, user.pbOpposingTeam(true))
    end

    def pbEffectAgainstTarget(_user, target)
        return unless damagingMove?
        return if target.pbOwnSide.effectAtMax?(@spikeEffect)
        addSpikeLayer(target.pbOwnSide, target.pbTeam(true))
    end

    def addSpikeLayer(side, _teamLabel)
        side.incrementEffect(@spikeEffect)

        side.eachEffect(true) do |effect, _value, data|
            next unless data.is_status_hazard?
            next if effect == @spikeEffect
            side.disableEffect(effect)
        end
    end

    def getEffectScore(user, target)
        return 0 if damagingMove? && target.pbOwnSide.effectAtMax?(@spikeEffect)
        score = 0
        side = damagingMove? ? target.pbOwnSide : user.pbOpposingSide
        score -= statusSpikesWeightOnSide(side, [@spikeEffect])
        score += getHazardSettingEffectScore(user, target)
        return score
    end

    def shouldHighlight?(user, target)
        if target
            side = target.pbOwnSide
        else
            side = user.pbOpposingSide
        end
        return side.effectActive?(@spikeEffect) > 0 && !side.effectAtMax?(@spikeEffect)
    end
end

# Each subclass must define a @statUp and @statDown array in their initialization method
class PokeBattle_StatUpDownMove < PokeBattle_Move
    def statUp; return @statUp; end

    def pbMoveFailed?(user, _targets, show_message)
        return false if user.pbCanRaiseAnyOfStats?(@statUp, user, move: self)
        return false if user.pbCanRaiseAnyOfStats?(@statDown, user, move: self)
        @battle.pbDisplay(_INTL("{1}'s stats can't be changed further!", user.pbThis)) if show_message
        return true
    end

    def pbEffectGeneral(user)
        user.pbLowerMultipleStatSteps(@statDown, user, move: self)
        user.pbRaiseMultipleStatSteps(@statUp, user, move: self)
    end

    def getEffectScore(user, target)
        score = 0
        score -= getMultiStatDownEffectScore(@statDown, user, target)
        score += getMultiStatUpEffectScore(@statUp, user, target)
        return score
    end
end

class PokeBattle_PartyMemberEffectMove < PokeBattle_Move
    def legalChoice(pokemon)
        return false unless pokemon
        return true
    end

    def pbMoveFailed?(user, _targets, show_message)
        return true if @battle.autoTesting
        @battle.pbParty(user.index).each do |pkmn|
            return false if legalChoice(pkmn)
        end
        @battle.pbDisplay(_INTL("But it failed, since there are no valid choices in your party!")) if show_message
        return true
    end

    def effectOnPartyMember(pokemon); end

    def pbEffectGeneral(user)
        selectedPokemon = selectPartyMemberForEffect(user.index, proc { |pkmn| next legalChoice(pkmn) })
        effectOnPartyMember(selectedPokemon)
    end
end

# Each subclass must have an initialization method that defines the statusToApply variable
class PokeBattle_JealousyMove < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        if target.pbCanInflictStatus?(@statusToApply, user, false, self) && target.hasRaisedStatSteps?
            target.pbInflictStatus(@statusToApply, 0, nil, user)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return getStatusSettingEffectScore(@statusToApply, user, target) if target.hasRaisedStatSteps?
        return 0
    end

    def shouldHighlight?(_user, target)
        return target.hasRaisedStatSteps?
    end
end

# Each subclass must have an initialization method that defines the @statUp array
class PokeBattle_TeamStatBuffMove < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        failed = true
        @battle.eachSameSideBattler(user) do |b|
            for i in 0...@statUp.length / 2 do
                statSym = @statUp[i * 2]
                next unless b.pbCanRaiseStatStep?(statSym, user, self)
                failed = false
                break
            end
            break unless failed
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since neither #{user.pbThis(true)} nor any of its allies can receive the stat improvements!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.eachSameSideBattler(user) do |b|
            b.pbRaiseMultipleStatSteps(@statUp, user, move: self, showFailMsg: true)
        end
    end

    def getEffectScore(user, _target)
        score = 0
        @battle.eachSameSideBattler(user) do |b|
            score += getMultiStatUpEffectScore(@statUp, user, b)
        end
        return score
    end
end
