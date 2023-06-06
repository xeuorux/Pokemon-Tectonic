#===============================================================================
# Hits thrice.
#===============================================================================
class PokeBattle_Move_500 < PokeBattle_Move
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 3; end
end

#===============================================================================
# Maximizes accuracy.
#===============================================================================
class PokeBattle_Move_501 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        return !user.pbCanRaiseStatStep?(:ACCURACY, user, self, show_message)
    end

    def pbEffectGeneral(user)
        user.pbMaximizeStatStep(:ACCURACY, user, self)
    end

    def getEffectScore(user, _target)
        score = 60
        score -= (user.steps[:ACCURACY] - 6) * 10
        score += 20 if user.hasInaccurateMove?
        score += 40 if user.hasLowAccuracyMove?
        return score
    end
end

#===============================================================================
# User takes recoil damage equal to 2/3 of the damage this move dealt.
# (Head Charge)
#===============================================================================
class PokeBattle_Move_502 < PokeBattle_RecoilMove
    def recoilFactor; return (2.0 / 3.0); end
end

#===============================================================================
# Increases the user's Sp. Atk by 2 steps, and Speed by 1 step. (Lightning Dance)
#===============================================================================
class PokeBattle_Move_503 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPEED, 1]
    end
end

#===============================================================================
# Increases the move's power by 25% if the target moved this round. (Rootwrack)
#===============================================================================
class PokeBattle_Move_504 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        targetChoice = @battle.choices[target.index][0]
        baseDmg *= 1.25 if targetChoice == :UseMove && target.movedThisRound?
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 1.25 if target.pbSpeed(true) > user.pbSpeed(true)
        return baseDmg
    end
end

#===============================================================================
# Target moves immediately after the user, ignoring priority/speed. (Kickstart)
#===============================================================================
class PokeBattle_Move_505 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        return if target.fainted?
        return if pbMoveFailedTargetAlreadyMoved?(target) # Target has already moved this round
        return if target.effectActive?(:MoveNext) # Target was going to move next anyway (somehow)
        return if @battle.choices[target.index][2].nil? # Target didn't choose to use a move this round
        target.applyEffect(:MoveNext)
        @battle.pbDisplay(_INTL("{1} was kickstarted into action!", target.pbThis))
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Kickstart.")
        return -1000
    end
end

#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations. (Soul Claw, Soul Rip)
#===============================================================================
class PokeBattle_Move_506 < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :SPECIAL_DEFENSE
    end
end

#===============================================================================
# Effectiveness against Steel-type is 2x. (Corrode)
#===============================================================================
class PokeBattle_Move_507 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :STEEL
        return super
    end
end

#===============================================================================
# Increases the user's Attack by 3 steps, but lowers its Speed by 3 steps.
# (Patient Training)
#===============================================================================
class PokeBattle_Move_508 < PokeBattle_StatUpDownMove
    def initialize(battle, move)
        super
        @statUp   = [:ATTACK,6]
        @statDown = [:SPEED,6]
    end
end

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# It also ignores their abilities. (Rend)
#===============================================================================
class PokeBattle_Move_509 < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        super
        @battle.moldBreaker = true unless specialUsage
    end

    def pbCalcAccuracyMultipliers(user, target, multipliers)
        super
        modifiers[EVA_STEP] = 0 # Accuracy stat step
    end

    def ignoresDefensiveStepBoosts?(_user, _target); return true; end

    def getEffectScore(_user, _target)
        return 10
    end

    def shouldHighlight?(_user, target)
        return target.hasRaisedDefenseSteps?
    end
end

#===============================================================================
# Burns or frostbites the target, whichever hits the target's better base stat.
# (Crippling Breath)
#===============================================================================
class PokeBattle_Move_50A < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if !target.canBurn?(user, show_message, self) && !target.canFrostbite?(user, show_message, self)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can neither be burned or frostbitten!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        burnOrFrostbite(user, target)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        burnOrFrostbite(user, target)
    end

    def burnOrFrostbite(user, target)
        real_attack = target.pbAttack
        real_special_attack = target.pbSpAtk

        if target.canBurn?(user, false, self) && real_attack >= real_special_attack
            target.applyBurn(user)
        elsif target.canFrostbite?(user, false, self) && real_special_attack >= real_attack
            target.applyFrostbite(user)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        real_attack = target.pbAttack
        real_special_attack = target.pbSpAtk
        if target.canBurn?(user, false, self) && real_attack >= real_special_attack
            score += getBurnEffectScore(user, target)
        elsif target.canFrostbite?(user, false, self) && real_special_attack >= real_attack
            score += getFrostbiteEffectScore(user, target)
        end
        return score
    end
end

#===============================================================================
# If this move KO's the target, increases the user's Sp. Atk by 5 steps.
# (Slight)
#===============================================================================
class PokeBattle_Move_50B < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return unless target.damageState.fainted
        user.tryRaiseStat(:SPECIAL_ATTACK, user, increment: 5, move: self)
    end

    def getFaintEffectScore(user, target)
        return getMultiStatUpEffectScore([:SPECIAL_ATTACK, 5], user, user)
    end
end

#===============================================================================
# Power is doubled if the target is frostbitten. (Ice Impact)
#===============================================================================
class PokeBattle_Move_50C < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.frostbitten?
        return baseDmg
    end
end

#===============================================================================
# Accuracy perfect against poisoned targets. (Sludge Slam)
#===============================================================================
class PokeBattle_Move_50D < PokeBattle_Move
    def pbBaseAccuracy(user, target)
        return 0 if target.poisoned?
        return super
    end
end

#===============================================================================
# Power is doubled if the target is burned. (Flare Up)
#===============================================================================
class PokeBattle_Move_50E < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.burned?
        return baseDmg
    end
end

#===============================================================================
# Decreases the user's Attack by 4 steps. (Infinite Force)
#===============================================================================
class PokeBattle_Move_50F < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 4]
    end
end

#===============================================================================
# User loses half their hp in recoil. (Steel Beam, Mist Burst)
#===============================================================================
class PokeBattle_Move_510 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        return unless user.takesIndirectDamage?
        @battle.pbDisplay(_INTL("{1} loses half its health in recoil!", user.pbThis))
        user.applyFractionalDamage(1.0 / 2.0, true, true)
    end

    def getEffectScore(user, _target)
        return -((user.hp.to_f / user.totalhp.to_f) * 50).floor
    end
end

#===============================================================================
# User loses one third of their hp in recoil. (Shred Shot, Shards)
#===============================================================================
class PokeBattle_Move_511 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        return unless user.takesIndirectDamage?
        @battle.pbDisplay(_INTL("{1} loses one third of its health in recoil!", user.pbThis))
        user.applyFractionalDamage(1.0 / 3.0, true, true)
    end

    def getEffectScore(user, _target)
        return -((user.hp.to_f / user.totalhp.to_f) * 30).floor
    end
end

#===============================================================================
# Increases the user's Attack and Sp. Def by 2 step each. (Flow State)
#===============================================================================
class PokeBattle_Move_512 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Increases the user's Sp. Atk and Sp. Def by 2 steps each. (Vanguard)
#===============================================================================
class PokeBattle_Move_513 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Poison's the user, even if normally immune to poison. (Grime Grapple)
#===============================================================================
class PokeBattle_Move_514 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        return if user.poisoned?
        user.applyPoison(nil, _INTL("{1} is poisoned by the grime! {2}",
           user.pbThis, POISONED_EXPLANATION), false)
    end

    def getEffectScore(user, _target)
        return 0 if user.poisoned?
        return -getPoisonEffectScore(user, user, ignoreCheck: true)
    end
end

#===============================================================================
# The user is immune to secondary effects of moves against them until their next attack. (Enlightened Hit)
#===============================================================================
class PokeBattle_Move_515 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        user.applyEffect(:Enlightened)
    end

    def getEffectScore(user, _target)
        score = 10
        score += 10 if user.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# Dizzies the target. Accuracy perfect in moonglow. Hits some
# semi-invulnerable targets. (Moon Impact)
#===============================================================================
class PokeBattle_Move_516 < PokeBattle_DizzyMove
    def pbBaseAccuracy(user, target)
        return 0 if @battle.pbWeather == :Moonglow
        return super
    end

    def shouldHighlight?(_user, _target)
        return @battle.pbWeather == :Moonglow
    end
end

#===============================================================================
# Priority against Pokemon with half or less health. (Aqua Instinct)
#===============================================================================
class PokeBattle_Move_517 < PokeBattle_Move
    def getsPriorityAgainst?(target)
        return target.belowHalfHealth?
    end

    def priorityModification(_user, targets)
        targets.each do |b|
            return 1 if getsPriorityAgainst?(b)
        end
        return 0
    end

    def shouldHighlight?(_user, target)
        return getsPriorityAgainst?(target)
    end
end

#===============================================================================
# Heals user by 1/3 of their max health, but does not fail at full health. (Douse)
#===============================================================================
class PokeBattle_Move_518 < PokeBattle_HealingMove
    def healRatio(_user)
        return 1.0 / 3.0
    end

    def pbMoveFailed?(_user, _targets, _show_message)
        return false
    end
end

#===============================================================================
# Decreases the user's Speed and Defense by 1 step each. Can't miss. (Reflex Overdrive)
#===============================================================================
class PokeBattle_Move_519 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 1, :DEFENSE, 1]
    end

    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# For 5 rounds, Pokemon's Attack and Sp. Atk are swapped. (Puzzle Room)
#===============================================================================
class PokeBattle_Move_51A < PokeBattle_RoomMove
    def initialize(battle, move)
        super
        @roomEffect = :PuzzleRoom
    end
end

#===============================================================================
# User loses their Ice type. Fails if user is not Ice-type. (Cold Conversion)
#===============================================================================
class PokeBattle_Move_51B < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.pbHasType?(:ICE)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is not Ice-type!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAfterAllHits(user, _target)
        user.applyEffect(:ColdConversion)
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_51C < PokeBattle_Move
end

#===============================================================================
# Target gains a weakness to Bug-type attacks. (Creep Out)
#===============================================================================
class PokeBattle_Move_51D < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:CreepOut)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already afraid of Bug-type moves!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        return if target.damageState.substitute
        target.applyEffect(:CreepOut)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.effectActive?(:CreepOut)
        score = 40
        score += 40 if target.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# If the move misses, the user gains 2 steps of speed. (Mudslide)
#===============================================================================
class PokeBattle_Move_51E < PokeBattle_Move
    # This method is called if a move fails to hit all of its targets
    def pbCrashDamage(user, _targets = [])
        @battle.pbDisplay(_INTL("{1} kept going and picked up speed!", user.pbThis))
        user.tryRaiseStat(:SPEED, user, increment: 2, move: self)
    end

    def getEffectScore(user, _target)
        return getMultiStatUpEffectScore([:SPEED, 2], user, user) * 0.5
    end
end

#===============================================================================
# If the move misses, the user gains Accuracy. (Rockapult)
#===============================================================================
class PokeBattle_Move_51F < PokeBattle_Move
    # This method is called if a move fails to hit all of its targets
    def pbCrashDamage(user)
        return unless user.tryRaiseStat(:ACCURACY, user, move: self)
        @battle.pbDisplay(_INTL("{1} adjusted its aim!", user.pbThis))
    end

    def getEffectScore(user, _target)
        return getMultiStatUpEffectScore([:ACCURACY, 1], user, user) * 0.5
    end
end

#===============================================================================
# Increases the user's critical hit rate. (Starfall)
#===============================================================================
class PokeBattle_Move_520 < PokeBattle_Move
    def pbEffectGeneral(user)
        user.applyEffect(:LuckyStar)
    end

    def getEffectScore(user, _target)
        if user.effectActive?(:LuckyStar)
            return 0
        else
            return getCriticalRateBuffEffectScore(user)
        end
    end
end

#===============================================================================
# Target's last move used loses 4 PP. (Spiteful Chant, Eerie Spell)
#===============================================================================
class PokeBattle_Move_521 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbEffectAgainstTarget(_user, target)
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            reduction = [4, m.pp].min
            target.pbSetPP(m, m.pp - reduction)
            @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
               target.pbThis(true), m.name, reduction))
            break
        end
    end

    def getTargetAffectingEffectScore(_user, target)
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            return 30
        end
        return 0
    end
end

#===============================================================================
# Target's highest stat is lowered by 4 steps. (Loom Over)
#===============================================================================
class PokeBattle_Move_522 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return !target.pbCanLowerStatStep?(target.highestStat, user, self, show_message)
    end

    def pbEffectAgainstTarget(user, target)
        target.tryLowerStat(target.highestStat, user, increment: 4, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore([target.highestStat, 4], user, target)
    end
end

#===============================================================================
# Move disables self. (Phantom Break)
#===============================================================================
class PokeBattle_Move_523 < PokeBattle_Move
    def pbEffectAfterAllHits(user, _target)
        user.applyEffect(:Disable, 5)
    end

    def getEffectScore(_user, _target)
        return -30
    end
end

#===============================================================================
# Heals the user by 2/3 health. Move disables self. (Stitch Up)
#===============================================================================
class PokeBattle_Move_524 < PokeBattle_HealingMove
    def healRatio(_user)
        return 2.0 / 3.0
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:Disable, 5)
    end

    def getEffectScore(user, _target)
        score = super
        score -= 30
        return score
    end
end

#===============================================================================
# Increases the user's Attack and Defense by 2 steps each, and Speed by 1.
# (Shiver Dance)
#===============================================================================
class PokeBattle_Move_525 < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :SPEED, 1]
    end
end

#===============================================================================
# Puts the target to sleep. User loses half of their max HP as recoil. (Demon's Kiss)
#===============================================================================
class PokeBattle_Move_526 < PokeBattle_SleepMove
    def pbEffectAgainstTarget(user, target)
        target.applySleep
        user.applyFractionalDamage(1.0 / 2.0)
    end

    def getEffectScore(user, _target)
        return getHPLossEffectScore(user, 0.5)
    end
end

#===============================================================================
# Target becomes drowsy. Both of its Attacking stats are lowered by 2 steps.  (Summer Daze)
#===============================================================================
class PokeBattle_Move_527 < PokeBattle_Move_004
    def pbFailsAgainstTarget?(user, target, show_message)
        if @battle.sunny? && (target.pbCanLowerStatStep?(:ATTACK, user, self) ||
                target.pbCanLowerStatStep?(:SPECIAL_ATTACK, user, self))
            return false
        end
        super
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:Yawn, 2)
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_2, user, move: self) if @battle.sunny?
    end

    def getTargetAffectingEffectScore(user, target)
        score = super
        score += getMultiStatDownEffectScore(ATTACKING_STATS_2, user, target) if @battle.sunny?
        return score
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target is at or below half health. (Lullaby)
#===============================================================================
class PokeBattle_Move_528 < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.hp > target.totalhp / 2
            @battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)} is above half health!")) if show_message
            return true
        end
        return !target.canSleep?(user, show_message, self)
    end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target dealt damage to the user this turn. (Puff Ball)
#===============================================================================
class PokeBattle_Move_529 < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        unless user.lastAttacker.include?(target.index)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the #{target.pbThis(true)} didn't attack #{user.pbThis(true)} this turn!"))
            end
            return true
        end
        return !target.canSleep?(user, show_message, self)
    end

    def pbFailsAgainstTargetAI?(user, target)
        return !target.canSleep?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 if hasBeenUsed?(user)
        userSpeed = user.pbSpeed(true)
        targetSpeed = target.pbSpeed(true)
        return 0 if userSpeed > targetSpeed
        return 0 unless target.hasDamagingAttack?
        super
    end
end

#===============================================================================
# Deals 50% more damage if user is statused. (Hard Feelings, Sore Spot)
#===============================================================================
class PokeBattle_Move_52A < PokeBattle_Move
    def damageReducedByBurn?; return false; end

    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 1.5 if user.status != :NONE
        return baseDmg
    end
end

#===============================================================================
# TODO: Unused
#===============================================================================
class PokeBattle_Move_52B < PokeBattle_Move
end

#===============================================================================
# User gains 1/2 the HP it inflicts as damage. Lower's Sp. Def. (Soul Drain)
#===============================================================================
class PokeBattle_Move_52C < PokeBattle_DrainMove
    def drainFactor(_user, _target); return 0.5; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.tryLowerStat(:SPECIAL_DEFENSE, user, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore([:SPECIAL_DEFENSE, 1], user, target)
    end
end

#===============================================================================
# Resets weather and cures all active Pokemon of statuses. (Abyssal Reset)
#===============================================================================
class PokeBattle_Move_52D < PokeBattle_Move
    def pbEffectGeneral(_user)
        @battle.endWeather
        @battle.eachBattler do |b|
            healStatus(b)
        end
    end

    def getEffectScore(_user, _target)
        score = 0
        score += 30 if @battle.field.weather != :None
        @battle.eachBattler do |b|
            pkmn = b.pokemon
            next if !pkmn || !pkmn.able? || pkmn.status == :NONE
            score += b.opposes? ? 30 : -30
        end
        return score
    end
end

#===============================================================================
# Lowers the target's Defense and Evasion by 2. (Echolocate)
#===============================================================================
class PokeBattle_Move_52E < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 2, :EVASION, 2]
    end

    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# Summons Eclipse for 8 turns and lowers the Attack of all enemies by 2 steps. (Wingspan Eclipse)
#===============================================================================
class PokeBattle_Move_52F < PokeBattle_Move_042
    def pbEffectGeneral(user)
        @battle.pbStartWeather(user, :Eclipse, 8, false) unless @battle.primevalWeatherPresent?
    end

    def getEffectScore(user, target)
        return getWeatherSettingEffectScore(:Eclipse, user, @battle, 8)
    end
end

#===============================================================================
# Raises Attack of user and allies by 2 steps. (Howl)
#===============================================================================
class PokeBattle_Move_530 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2]
    end
end

#===============================================================================
# User takes half damage from Super Effective moves. (Inure)
#===============================================================================
class PokeBattle_Move_531 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Inured)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already inured!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Inured)
    end

    def getEffectScore(user, _target)
        if user.firstTurn?
            return 80
        else
            return 60
        end
    end
end

#===============================================================================
# Raises worst stat four steps, second worst stat by two steps. (Breakdance)
#===============================================================================
class PokeBattle_Move_532 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        @statArray = []
        GameData::Stat.each_main_battle do |statData|
            statID = statData.id
            @statArray.push(statID) if user.pbCanRaiseStatStep?(statID, user, self)
        end
        if @statArray.length == 0
            @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        statsUserCanRaise = user.finalStats.select do |stat, _finalValue|
            next user.pbCanRaiseStatStep?(stat, user, self)
        end
        statsRanked = statsUserCanRaise.sort_by { |_s, v| v }
        user.tryRaiseStat(statsRanked[0][0], user, increment: 3, move: self) if statsRanked.length > 0
        user.tryRaiseStat(statsRanked[1][0], user, increment: 3, move: self) if statsRanked.length > 1
    end

    # TODO
    def getEffectScore(user, _target)
        score = 100
        score += 20 if user.firstTurn?
        GameData::Stat.each_main_battle do |statData|
            score -= user.steps[statData.id] * 5
        end
        return score
    end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target is dizzy. (Pacify)
#===============================================================================
class PokeBattle_Move_534 < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.dizzy?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} isn't dizzy!")) if show_message
            return true
        end
        return !target.canSleep?(user, show_message, self, true)
    end

    def pbEffectAgainstTarget(_user, target)
        target.pbCureStatus(false, :DIZZY)
        target.applySleep
    end
end

#===============================================================================
# Can only be used on the first turn. Deals more damage if the user was hurt this turn. (Stare Down)
#===============================================================================
class PokeBattle_Move_535 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it isn't #{user.pbThis(true)}'s first turn!")) if show_message
            return true
        end
        return false
    end

    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 2 if user.lastAttacker.include?(target.index)
        return baseDmg
    end

    def getEffectScore(user, target)
        return getWantsToBeSlowerScore(user, target, 3)
    end
end

#===============================================================================
# Two turn attack. Ups user's Special Defense by 4 steps first turn, attacks second turn.
# (Zephyr Wing)
#===============================================================================
class PokeBattle_Move_536 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1}'s wings start glowing!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        user.tryRaiseStat(:SPECIAL_DEFENSE, user, increment: 4, move: self)
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatUpEffectScore([:SPECIAL_DEFENSE, 2], user, user)
        return score
    end
end

#===============================================================================
# Frostbites opposing Pokemon that have increased their stats. (Freezing Jealousy)
#===============================================================================
class PokeBattle_Move_537 < PokeBattle_JealousyMove
    def initialize(battle, move)
        @statusToApply = :FROSTBITE
        super
    end
end

#===============================================================================
# Removes all hazards on both sides. (Terraform)
#===============================================================================
class PokeBattle_Move_538 < PokeBattle_Move
    def eachHazard(side, isOurSide)
        side.eachEffect(true) do |effect, _value, data|
            next unless data.is_hazard?
            yield effect, data
        end
    end

    def removeEffect(user, side, effect, data)
        side.disableEffect(effect)
        if data.is_hazard?
            hazardName = data.real_name
            @battle.pbDisplay(_INTL("{1} destroyed {2}!", user.pbThis, hazardName)) unless data.has_expire_proc?
        end
    end

    def pbEffectGeneral(user)
        targetSide = user.pbOpposingSide
        ourSide = user.pbOwnSide
        eachHazard(targetSide, false) do |effect, data|
            removeEffect(user, targetSide, effect, data)
        end
        eachHazard(ourSide, true) do |effect, data|
            removeEffect(user, ourSide, effect, data)
        end
    end

    def getEffectScore(user, target)
        score = 0
        # Dislike removing hazards that affect the enemy
        score -= hazardWeightOnSide(user.pbOpposingSide)
        # Like removing hazards that affect us
        score += hazardWeightOnSide(user.pbOwnSide)
        return score
    end
end

#===============================================================================
# Steals the targets first stealable berry or gem. (Pilfer)
#===============================================================================
class PokeBattle_Move_539 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return unless target.hasAnyBerry? || target.hasAnyItem?
        target.eachItem do |item|
            next unless GameData::Item.get(item).is_berry? || GameData::Item.get(item).is_gem?
            stealItem(user, target, item)
        end
    end

    def getEffectScore(user, target)
        score = 0
        target.eachItem do |item|
            next unless GameData::Item.get(item).is_berry? || GameData::Item.get(item).is_gem?
            score += 50 if canStealItem?(user, target, item)
        end
        return score
    end
end

#===============================================================================
# If the target would heal until end of turn, instead they take that much life loss. (Nerve Break)
#===============================================================================
class PokeBattle_Move_53A < PokeBattle_Move
    def pbAdditionalEffect(_user, target)
        return if target.fainted? || target.damageState.substitute
        target.applyEffect(:NerveBreak)
    end

    def getEffectScore(_user, target)
        if target.hasHealingMove?
            if target.belowHalfHealth?
                return 50
            else
                return 20
            end
        end
        return 0
    end
end

#===============================================================================
# Deals 50% more damage if faster than the target. Then lower's user's speed. (Inertia Shock)
#===============================================================================
class PokeBattle_Move_53B < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 1]
    end

    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.5 if user.pbSpeed > target.pbSpeed
        return baseDmg.round
    end
end

#===============================================================================
# Can't miss if attacking a target that already used an attack this turn. (new!Power Whip)
#===============================================================================
class PokeBattle_Move_53C < PokeBattle_Move
    def pbAccuracyCheck(user, target)
        targetChoice = @battle.choices[target.index][0]
        return true if targetChoice == :UseMove && target.movedThisRound?
        return super
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_53D < PokeBattle_Move
end

#===============================================================================
# Decreases the user's Sp. Atk and Sp. Def by 2 steps each. (Geyser, Phantom Gate)
#===============================================================================
class PokeBattle_Move_53E < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# If the move misses, all targets are forced to switch out. (Rolling Boulder)
#===============================================================================
class PokeBattle_Move_53F < PokeBattle_Move
    def forceSwitchMove?; return true; end

    # This method is called if a move fails to hit all of its targets
    def pbAllMissed(user, targets)
        return if @battle.wildBattle?
        return if user.fainted?

        roarSwitched = []
        targets.each do |b|
            next if b.fainted? || b.damageState.substitute
            next if b.effectActive?(:Ingrain)
            next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
            newPkmn = @battle.pbGetReplacementPokemonIndex(b.index, true) # Random
            next if newPkmn < 0
            @battle.pbRecallAndReplace(b.index, newPkmn, true)
            @battle.pbDisplay(_INTL("{1} was dragged out!", b.pbThis))
            @battle.pbClearChoice(b.index) # Replacement Pokémon does nothing this round
            roarSwitched.push(b.index)
        end
        if roarSwitched.length > 0
            @battle.moldBreaker = false if roarSwitched.include?(user.index)
            @battle.pbPriority(true).each do |b|
                b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
            end
        end
    end

    def getEffectScore(user, target)
        return getForceOutEffectScore(user, target) * 0.5
    end
end

#===============================================================================
# User's Special Defense is used instead of user's Special Attack for this move's calculations.
# (Aura Trick)
#===============================================================================
class PokeBattle_Move_540 < PokeBattle_Move
    def pbAttackingStat(user, _target)
        return user, :SPECIAL_DEFENSE
    end
end

#===============================================================================
# Target's "clothing items" are destroyed. (Up In Flames)
#===============================================================================
class PokeBattle_Move_541 < PokeBattle_Move
    def canIncinerateTargetsItem?(target, checkingForAI = false)
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.substitute
            return false
        end
        return true
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canIncinerateTargetsItem?(target)
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item)
            next unless CLOTHING_ITEMS.include?(item)
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1}'s {2} went up in flames!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canIncinerateTargetsItem?(target)
        score = 0
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            next unless CLOTHING_ITEMS.include?(item)
            score += 30
        end
        return score
    end
end

#===============================================================================
# Target's speed is raised. (Propellant)
#===============================================================================
class PokeBattle_Move_542 < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.tryRaiseStat(:SPEED, user, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return -getMultiStatUpEffectScore([:SPEED, 1], user, target)
    end
end

#===============================================================================
# Power doubles for each consecutive use. (Ice Ball)
#===============================================================================
class PokeBattle_Move_543 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :Snowball
        super
    end
end

#===============================================================================
# Power doubles for each consecutive use. (Rock Roll)
#===============================================================================
class PokeBattle_Move_544 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :RockRoll
        super
    end
end

#===============================================================================
# Heals for 1/3 the damage dealt. (new!Drain Punch)
#===============================================================================
class PokeBattle_Move_545 < PokeBattle_DrainMove
    def drainFactor(_user, _target); return (1.0 / 3.0); end
end

#===============================================================================
# Always critical hit vs Opponents with raised stats (Lunar Justice)
#===============================================================================
class PokeBattle_Move_546 < PokeBattle_Move
    def pbCriticalOverride(_user, target)
        return 1 if target.hasRaisedStatSteps?
        return 0
    end

    def shouldHighlight?(_user, target)
        return target.hasRaisedStatSteps?
    end
end

#===============================================================================
# Poisons, dizzies, or leeches the target. (Chaos Wheel)
#===============================================================================
class PokeBattle_Move_547 < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        case @battle.pbRandom(3)
        when 0 then target.applyPoison(user)	if target.canPoison?(user, true, self)
        when 1 then target.applyDizzy(user)	    if target.canDizzy?(user, true, self)
        when 2 then target.applyLeeched(user)	if target.canLeech?(user, true, self)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        poisonScore = getPoisonEffectScore(user, target)
        dizzyScore = getDizzyEffectScore(user, target)
        leechScore = getLeechEffectScore(user, target)
        return (poisonScore + dizzyScore + leechScore) / 3
    end
end

#===============================================================================
# Damages, while also healing the team of statuses. (Purifying Water)
#===============================================================================
class PokeBattle_Move_548 < PokeBattle_Move
    def pbEffectAfterAllHits(user, _target)
        @battle.eachSameSideBattler(user) do |b|
            healStatus(b)
        end
        # Cure all Pokémon in the user's and partner trainer's party.
        # NOTE: This intentionally affects the partner trainer's inactive Pokémon
        #       too.
        @battle.pbParty(user.index).each_with_index do |pkmn, i|
            next if !pkmn || !pkmn.able?
            next if @battle.pbFindBattler(i, user) # Skip Pokémon in battle
            healStatus(pkmn)
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        super
        @battle.pbDisplay(_INTL("The area was purified!"))
    end

    def getEffectScore(user, _target)
        score = 0
        statuses = 0
        @battle.pbParty(user.index).each do |pkmn|
            score += 40 if pkmn && pkmn.status != :NONE
        end
        return score
    end
end

#===============================================================================
# Raises Sp. Atk of user and allies by 2 steps. (Mind Link)
#===============================================================================
class PokeBattle_Move_549 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2]
    end
end

#===============================================================================
# Curses the target by spending 1/4th of the user's HP. (Cursed Oath)
#===============================================================================
class PokeBattle_Move_54A < PokeBattle_Move_10D
    def pbMoveFailed?(user, targets, show_message)
        if user.hp <= (user.totalhp / 4)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        super
    end
    
    def pbEffectAgainstTarget(user, target)
        @battle.pbDisplay(_INTL("{1} cut its own HP!", user.pbThis))
        user.applyFractionalDamage(1.0 / 4.0, false)
        super
    end

    def getEffectScore(user, target)
        score = super
        score += getHPLossEffectScore(user, 0.25)
        return score
    end
end

#===============================================================================
# Removes trapping moves, entry hazards and Leech Seed on user/user's side. Raises speed by 1.
# (Rapid Spin)
#===============================================================================
class PokeBattle_Move_54B < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 1]
    end

    def pbEffectAfterAllHits(user, target)
        return if user.fainted? || target.damageState.unaffected
        user.disableEffect(:Trapping)
        user.disableEffect(:LeechSeed)
        user.pbOwnSide.eachEffect(true) do |effect, _value, data|
            next unless data.is_hazard?
            user.pbOwnSide.disableEffect(effect)
        end
    end

    def getEffectScore(user, target)
        score = super
        score += hazardWeightOnSide(user.pbOwnSide) if user.alliesInReserve?
        score += 20 if user.effectActive?(:LeechSeed)
        score += 20 if user.effectActive?(:Trapping)
        return score
    end
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_54C < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_54D < PokeBattle_Move
end

#===============================================================================
# Increases the user's Sp. Atk, Sp. Def and accuracy by 2 steps each. (Store Fuel)
#===============================================================================
class PokeBattle_Move_54E < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :ACCURACY, 2]
    end
end

#===============================================================================
# Effectiveness against Dragon-type is 2x. (Slay)
#===============================================================================
class PokeBattle_Move_54F < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :DRAGON
        return super
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks the user while this effect applies, that Pokémon becomes numbed.
# (Stunning Curl)
#===============================================================================
class PokeBattle_Move_550 < PokeBattle_HalfProtectMove
    def initialize(battle, move)
        super
        @effect = :StunningCurl
    end

    def getOnHitEffectScore(user,target)
        return getNumbEffectScore(user, target)
    end
end

#===============================================================================
# Entry hazard. Lays burn spikes on the opposing side.
# (Flame Spikes)
#===============================================================================
class PokeBattle_Move_551 < PokeBattle_StatusSpikeMove
    def initialize(battle, move)
        @spikeEffect = :FlameSpikes
        super
    end
end

#===============================================================================
# (Currently unused)
#===============================================================================
class PokeBattle_Move_552 < PokeBattle_Move
end

#===============================================================================
# Poisons opposing Pokemon that have increased their stats. (Stinging Jealousy)
#===============================================================================
class PokeBattle_Move_553 < PokeBattle_JealousyMove
    def initialize(battle, move)
        @statusToApply = :POISON
        super
    end
end

#===============================================================================
# Raises Defense of user and allies by 3 steps. (Stand Together)
#===============================================================================
class PokeBattle_Move_554 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 3]
    end
end

#===============================================================================
# Raises Attack of user and allies by 3 steps. (Camaraderie)
#===============================================================================
class PokeBattle_Move_555 < PokeBattle_TeamStatBuffMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# (Currently unused)
#===============================================================================
class PokeBattle_Move_556 < PokeBattle_Move
end

#===============================================================================
# Drains 2/3s if target hurt the user this turn (Trap Jaw)
#===============================================================================
class PokeBattle_Move_557 < PokeBattle_Move
    def healingMove?; return true; end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.hpLost <= 0
        return unless user.lastAttacker.include?(target.index)
        hpGain = (target.damageState.hpLost * 2 / 3).round
        user.pbRecoverHPFromDrain(hpGain, target)
    end

    def getEffectScore(user, target)
        return getWantsToBeSlowerScore(user, target, 3)
    end
end

#===============================================================================
# Forces the target to use a substitute (Doll Stitch)
#===============================================================================
class PokeBattle_Move_558 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        @battle.forceUseMove(target, :SUBSTITUTE)
    end
end

#===============================================================================
# Target becomes Ghost type. (Evaporate)
#===============================================================================
class PokeBattle_Move_559 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't change its type!")) if show_message
            return true
        end
        unless user.pbHasOtherType?(:GHOST)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already only a Ghost-type!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbChangeTypes(:GHOST)
        typeName = GameData::Type.get(:GHOST).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_55A < PokeBattle_Move
end

#===============================================================================
# Heals user to 100%. Only usable on first turn. (Fresh Start)
#===============================================================================
class PokeBattle_Move_55B < PokeBattle_HealingMove
    def healRatio(_user)
        return 1.0
    end

    def pbMoveFailed?(user, targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it's not #{user.pbThis(true)}'s first turn!")) if show_message
            return true
        end
        return super
    end
end

#===============================================================================
# Two turn attack. Attacks first turn, skips second turn unless the target fainted.
# TODO: Currently unused
#===============================================================================
class PokeBattle_Move_55C < PokeBattle_Move_0C2
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.fainted
        super
    end
end

def selfHitBasePower(level)
    calcLevel = [level, 50].min
    selfHitBasePower = (25 + calcLevel * 1.2)
    selfHitBasePower = selfHitBasePower.ceil
    return selfHitBasePower
end

#===============================================================================
# Increases the target's Attack by 3 steps, then the target hits itself with its own attack. (Swagger)
#===============================================================================
class PokeBattle_Move_55D < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        target.tryRaiseStat(:ATTACK, user, increment: 3, move: self)
        target.pbConfusionDamage(_INTL("It hurt itself in rage!"), false, false, selfHitBasePower(target.level))
    end

    def getTargetAffectingEffectScore(user, target)
        score = 120
        score -= getMultiStatUpEffectScore([:ATTACK, 3], user, target)
        return score
    end
end

#===============================================================================
# Increases the target's Sp. Atk. by 3 steps, then the target hits itself with its own Sp. Atk. (Flatter)
#===============================================================================
class PokeBattle_Move_55E < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        target.tryRaiseStat(:SPECIAL_ATTACK, user, increment: 3, move: self)
        target.pbConfusionDamage(_INTL("It hurt itself in mental turmoil!"), true, false,
selfHitBasePower(target.level))
    end

    def getTargetAffectingEffectScore(user, target)
        score = 120
        score -= getMultiStatUpEffectScore([:SPECIAL_ATTACK, 3], user, target)
        return score
    end
end

#===============================================================================
# User must use this move for 2 more rounds. (Outrage, etc.)
#===============================================================================
class PokeBattle_Move_55F < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        user.applyEffect(:Outrage, 3) if !target.damageState.unaffected && !user.effectActive?(:Outrage)
        user.tickDownAndProc(:Outrage)
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# Decreases the target's Sp. Atk and Sp. Def by 2 steps each. (Prank)
#===============================================================================
class PokeBattle_Move_560 < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# #TODO: Currently unused
#===============================================================================
class PokeBattle_Move_561 < PokeBattle_Move
end

#===============================================================================
# Effectiveness against Electric-type is 2x. (Blackout)
#===============================================================================
class PokeBattle_Move_562 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :ELECTRIC
        return super
    end
end

#===============================================================================
# Effectiveness against Ghost-type is 2x. (Holly Charm)
#===============================================================================
class PokeBattle_Move_563 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :GHOST
        return super
    end
end

#===============================================================================
# Uses rest on both self and target. (Bedfellows)
#===============================================================================
class PokeBattle_Move_564 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        @battle.forceUseMove(user, :REST)
        @battle.forceUseMove(target, :REST)
    end

    def getEffectScore(user, target)
        score = 0

        score += 50 if user.belowHalfHealth?
        score += 30 if user.hp < user.totalhp / 4
        score += 30 if user.pbHasAnyStatus?
        score -= 50 unless user.hasSleepAttack?

        score -= 50 if target.belowHalfHealth?
        score -= 30 if target.hp < target.totalhp / 4
        score -= 30 if target.pbHasAnyStatus?
        score += 50 unless target.hasSleepAttack?
        return score
    end
end

#===============================================================================
# Heals user by 2/3 of its max HP.
#===============================================================================
class PokeBattle_Move_565 < PokeBattle_HealingMove
    def healRatio(_user)
        return 2.0 / 3.0
    end
end

#===============================================================================
# Returns user to party for swap, deals more damage the lower HP the user has. (Hare Heroics)
#===============================================================================
class PokeBattle_Move_566 < PokeBattle_Move_0EE
    def pbBaseDamage(_baseDmg, user, _target)
        ret = 20
        n = 48 * user.hp / user.totalhp
        if n < 2
            ret = 200
        elsif n < 5
            ret = 150
        elsif n < 10
            ret = 100
        elsif n < 17
            ret = 80
        elsif n < 33
            ret = 40
        end
        return ret
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a special attack while this effect applies, that Pokémon is
# burned. (Red-Hot Retreat)
#===============================================================================
class PokeBattle_Move_567 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :RedHotRetreat
    end

    def getEffectScore(user, target)
        score = super
        # Check only special attackers
        user.eachPredictedProtectHitter(1) do |b|
            score += getBurnEffectScore(user, b)
        end
        return score
    end
end

#===============================================================================
# Reduces the target's defense by two steps.
# After inflicting damage, user switches out. Ignores trapping moves.
# (Rip Turn)
#===============================================================================
class PokeBattle_Move_568 < PokeBattle_Move_0EE
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.tryLowerStat(:DEFENSE, user, move: self, increment: 2)
    end

    def getTargetAffectingEffectScore(user, target)
        score = super
        score += getMultiStatDownEffectScore([:DEFENSE, 2], user, target)
        return score
    end
end

#===============================================================================
# Entry hazard. Lays frostbite spikes on the opposing side.
# (Frost Spikes)
#===============================================================================
class PokeBattle_Move_569 < PokeBattle_StatusSpikeMove
    def initialize(battle, move)
        @spikeEffect = :FrostSpikes
        super
    end
end

#===============================================================================
# 50% more damage in hailstorm. (Leap Out.)
#===============================================================================
class PokeBattle_Move_56A < PokeBattle_Move
    def pbModifyDamage(damageMult, _user, _target)
        damageMult *= 1.5 if @battle.pbWeather == :Hail
        return damageMult
    end
end

#===============================================================================
# 100% Recoil Move (Thunder Belly)
#===============================================================================
class PokeBattle_Move_56B < PokeBattle_RecoilMove
    def recoilFactor; return 1.0; end
end

#===============================================================================
# Hits 2-5 times, for three turns in a row. (Pattern Release)
#===============================================================================
class PokeBattle_Move_56C < PokeBattle_Move_0C0
    def pbEffectAfterAllHits(user, target)
        user.applyEffect(:Outrage, 3) if !target.damageState.unaffected && !user.effectActive?(:Outrage)
        user.tickDownAndProc(:Outrage)
    end
end

#===============================================================================
# Future attacks hits twice as many times (Volley Stance)
#===============================================================================
class PokeBattle_Move_56D < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:VolleyStance)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already in a volley stance!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:VolleyStance)
    end

    def getEffectScore(user, target)
        return getMultiStatUpEffectScore([:SPECIAL_ATTACK, 2], user, target) + 10
    end
end

#===============================================================================
# Raises all stats by 2 steps. Fails unless the user is asleep. (Astral Dream)
#===============================================================================
class PokeBattle_Move_56E < PokeBattle_MultiStatUpMove
    def usableWhenAsleep?; return true; end

    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :SPEED, 2]
    end

    def pbMoveFailed?(user, targets, show_message)
        unless user.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} isn't asleep!")) if show_message
            return true
        end
        super
    end
end

#===============================================================================
# Lower's the Speed of all targets whom have moved this round. (Vine Maze)
#===============================================================================
class PokeBattle_Move_56F < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        targetChoice = @battle.choices[target.index][0]
        target.tryLowerStat(:SPEED, user, move: self, increment: 3) if targetChoice == :UseMove && target.movedThisRound?
    end

    def getTargetAffectingEffectScore(user, target)
        return getWantsToBeSlowerScore(user, target, 4)
    end
end

#===============================================================================
# Dizzies the target. Accuracy perfect in rain. Hits flying semi-invuln targets. (Hurricane)
#===============================================================================
class PokeBattle_Move_570 < PokeBattle_DizzyMove
    def immuneToRainDebuff?; return true; end

    def hitsFlyingTargets?; return true; end

    def pbBaseAccuracy(user, target)
        return 0 if @battle.rainy?
        return super
    end

    def shouldHighlight?(_user, _target)
        return @battle.rainy?
    end
end

#===============================================================================
# Power increases if the user is below half health. (Frantic Fang)
#===============================================================================
class PokeBattle_Move_571 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        ret = baseDmg
        ret *= 2 if user.belowHalfHealth?
        return ret
    end
end

#===============================================================================
# Puts the target to sleep if they are at or below half health, and raises the user's attack. (Tranquil Tune)
#===============================================================================
class PokeBattle_Move_572 < PokeBattle_Move_528
    def pbEffectAgainstTarget(user, target)
        super
        user.tryRaiseStat(:ATTACK, user, move: self)
    end

    def getEffectScore(user, target)
        return getMultiStatUpEffectScore([:ATTACK, 1], user, target)
    end
end

#===============================================================================
# Type effectiveness is multiplied by the Psychic-type's effectiveness against
# the target. (Leyline Burst)
#===============================================================================
class PokeBattle_Move_573 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        ret = super
        if GameData::Type.exists?(:PSYCHIC)
            psychicEffectiveness = Effectiveness.calculate_one(:PSYCHIC, defType)
            ret *= psychicEffectiveness.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        return ret
    end
end

#===============================================================================
# Power increases with the highest allies defense. (Hard Place)
#===============================================================================
class PokeBattle_Move_574 < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, _target)
        highestDefense = 0
        user.eachAlly do |ally_battler|
            real_defense = ally_battler.pbDefense
            highestDefense = real_defense if real_defense > highestDefense
        end
        return [highestDefense, 40].max
    end
end

#===============================================================================
# Doubles an allies Attack and Speed. The user cannot swap out of battle.
# If the user faints, so too does that ally. (Dragon Ride)
#===============================================================================
class PokeBattle_Move_575 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:OnDragonRide)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already on a dragon ride!"))
            end
            return true
        end
        if user.effectActive?(:GivingDragonRideTo)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis} is already giving a dragon ride!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:OnDragonRide)
        user.applyEffect(:GivingDragonRideTo, target.index)
        @battle.pbDisplay(_INTL("{1} gives {2} a ride on its back!", user.pbThis, target.pbThis(true)))
    end

    def getEffectScore(user, target)
        return 0 if user.belowHalfHealth?
        return 0 unless target.hasPhysicalAttack?
        return 120
    end
end

#===============================================================================
# Two turn attack. Sets rain first turn, attacks second turn.
# (Archaic Deluge)
#===============================================================================
class PokeBattle_Move_576 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} begins the flood!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        @battle.pbStartWeather(user, :Rain, 5, false)
    end

    def getEffectScore(user, _target)
        return getWeatherSettingEffectScore(:Rain, user, battle, 5)
    end
end

#===============================================================================
# The user takes 33% less damage until end of this turn.
# (Shimmering Heat)
#===============================================================================
class PokeBattle_Move_577 < PokeBattle_Move
    def pbEffectAfterAllHits(user, _target)
        user.applyEffect(:ShimmeringHeat)
    end

    def getEffectScore(user, target)
        return getWantsToBeFasterScore(user, target, 3)
    end
end

#===============================================================================
# Revives a fainted Grass-type party member back to 100% HP. (Breathe Life)
#===============================================================================
class PokeBattle_Move_578 < PokeBattle_PartyMemberEffectMove
    def legalChoice(pokemon)
        return false unless super
        return false unless pokemon.fainted?
        return false unless pokemon.hasType?(:GRASS)
        return true
    end

    def effectOnPartyMember(pokemon)
        pokemon.heal
        @battle.pbDisplay(_INTL("{1} recovered all the way to full health!", pokemon.name))
    end

    def getScore(_user, _target)
        return 200
    end
end

#===============================================================================
# Numb's the target. If they are already numbed, curses them instead. (Spectral Tongue)
#===============================================================================
class PokeBattle_Move_579 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.numbed?
            if target.effectActive?(:Curse) && show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already cursed!"))
            end
        else
            return !target.canNumb?(user, show_message, self)
        end
    end

    def pbEffectAgainstTarget(user, target)
        if target.numbed?
            target.applyEffect(:Curse)
        else
            target.applyNumb(user)
        end
    end

    def shouldHighlight?(_user, target)
        return target.numbed?
    end

    def getScore(user, target)
        if target.numbed?
            return getNumbEffectScore(user, target)
        else
            return getCurseEffectScore(user, target)
        end
    end
end

#===============================================================================
# Target is forced to use this Pokemon's first move slot. (Hivemind)
#===============================================================================
class PokeBattle_Move_57A < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless getFirstSlotMove(user)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no moves!")) if show_message
            return true
        end
        unless GameData::Move.get(getFirstSlotMove(user).id).can_be_forced?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s first slot move can't be shared!"))
            end
            return true
        end
        return false
    end

    def getFirstSlotMove(user)
        return user.moves[0] || nil
    end

    def pbEffectAgainstTarget(user, target)
        @battle.forceUseMove(target, getFirstSlotMove(user).id)
    end

    def getScore(_user, _target)
        echoln("The AI will never use Hivemind.")
        return -1000
    end
end

#===============================================================================
# Increases the user's Sp. Def by 5 steps. (Mucus Armor)
#===============================================================================
class PokeBattle_Move_57B < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 5]
    end
end

#===============================================================================
# This move is physical if user's Attack is higher than its Special Attack (Long Shot)
# (after applying stat steps)
#===============================================================================
class PokeBattle_Move_57C < PokeBattle_Move
    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, _targets)
        return selectBestCategory(user)
    end
end

#===============================================================================
# The target loses their Water-type before the move strikes. (Dry Heat)
#===============================================================================
class PokeBattle_Move_57D < PokeBattle_Move
    def pbEffectBeforeDealingDamage(user, target)
        if target.pbHasType?(:WATER)
            target.applyEffect(:DryHeat)
            target.damageState.typeMod = pbCalcTypeMod(@calcType, user, target)
        end
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a physical attack while this effect applies, that Pokémon is
# frostbitten. (Icicle Armor)
#===============================================================================
class PokeBattle_Move_57E < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :IcicleArmor
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter(0) do |b|
            score += getFrostbiteEffectScore(user, b)
        end
        return score
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks the user while this effect applies, that Pokémon becomes poisoned.
# (Venom Guard)
#===============================================================================
class PokeBattle_Move_57F < PokeBattle_HalfProtectMove
    def initialize(battle, move)
        super
        @effect = :VenomGuard
    end

    def getOnHitEffectScore(user,target)
        return getPoisonEffectScore(user, target)
    end
end

#===============================================================================
# Two turn attack. Sets rain first turn, attacks second turn.
# (Archaic Deluge)
#===============================================================================
class PokeBattle_Move_576 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} begins the flood!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        @battle.pbStartWeather(user, :Rain, 5, false)
    end

    def getEffectScore(user, _target)
        return getWeatherSettingEffectScore(:Rain, user, battle, 5)
    end
end