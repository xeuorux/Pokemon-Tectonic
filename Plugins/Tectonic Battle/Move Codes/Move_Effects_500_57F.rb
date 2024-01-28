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
# Increases the move's power by 25% if the target moved this round. (Rootwrack)
#===============================================================================
class PokeBattle_Move_504 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        targetChoice = @battle.choices[target.index][0]
        baseDmg *= 1.25 if targetChoice == :UseMove && target.movedThisRound?
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 1.25 if target.pbSpeed(true) > user.pbSpeed(true, move: self)
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
# All stats raised by 2 steps. Fails unless an opponent is below half life.
# (Gloat)
#===============================================================================
class PokeBattle_Move_507 < PokeBattle_MultiStatUpMove
	def initialize(battle, move)
        super
        @statUp = ALL_STATS_2
    end
	
	def pbMoveFailed?(user, targets, show_message)
        anyOppLow = false
        user.eachOpposing do |b|
            next if b.aboveHalfHealth?
            anyOppLow = true
            break
        end
        unless anyOppLow
            @battle.pbDisplay(_INTL("But it failed, since there were no foes below half health!")) if show_message
            return true
        end
        super
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
# Accuracy perfect against poisoned targets. (Sludge Slam)
#===============================================================================
class PokeBattle_Move_50D < PokeBattle_Move
    def pbBaseAccuracy(user, target)
        return 0 if target.poisoned?
        return super
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
        return 0 unless user.takesIndirectDamage?
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
        return 0 if @battle.moonGlowing?
        return super
    end

    def shouldHighlight?(_user, _target)
        return @battle.moonGlowing?
    end
end

#===============================================================================
# Heals user by 1/3 of their max health, but does not fail at full health. (Ebb & Flow)
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
# User loses their Ice type. Fails if user is not Ice-type. (Sublimate)
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
        user.applyEffect(:Sublimate)
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# Lowers the target's Speed. 50% flinch chance. (Crackling Cloud)
#===============================================================================
class PokeBattle_Move_51C < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute

        target.tryLowerStat(:SPEED, user, move: self, increment: 1)

        # Flinching aspect
        chance = pbAdditionalEffectChance(user, target, @calcType, 50)
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = getMultiStatDownEffectScore([:SPEED, 1], user, target)

        # Flinching aspect
        chance = pbAdditionalEffectChance(user, target, @calcType, 50)
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            baseScore = baseDamage * 10 / user.level
            score += getFlinchingEffectScore(baseScore, user, target, self)
        end
        return score
    end
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
# Transforms the user into one of its forms. (Mutate)
#===============================================================================
class PokeBattle_Move_52D < PokeBattle_Move
    def resolutionChoice(user)
        if @battle.autoTesting
            @chosenForm = rand(3) + 1
        elsif !user.pbOwnedByPlayer? # Trainer AI
            @chosenForm = 2 # Always chooses mega mind form
        else
            form1Name = GameData::Species.get_species_form(:DEOXYS,1).form_name
            form2Name = GameData::Species.get_species_form(:DEOXYS,2).form_name
            form3Name = GameData::Species.get_species_form(:DEOXYS,3).form_name
            formNames = [form1Name,form2Name,form3Name]
            chosenIndex = @battle.scene.pbShowCommands(_INTL("Which form should #{user.pbThis(true)} take?"),formNames,0)
            @chosenForm = chosenIndex + 1
        end
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.form == 0
            if show_message
                msg = _INTL("#{user.pbThis} has already mutated!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:DEOXYS)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis)) if show_message
            return true
        end
        unless user.form == 0
            @battle.pbDisplay(_INTL("But {1} has already mutated!", user.pbThis)) if show_message
            return true
        end
        return false
    end
    
    def pbEffectGeneral(user)
        user.pbChangeForm(@chosenForm, _INTL("{1} reforms its genes with space energy!", user.pbThis))
    end

    def resetMoveUsageState
        @chosenForm = nil
    end

    def getEffectScore(_user, _target)
        return 100
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
        return getWantsToBeSlowerScore(user, target, 3, move: self)
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
# If the target would heal until end of turn, instead they take that much life loss. (Hypothermiate, Bad Ending)
#===============================================================================
class PokeBattle_Move_53A < PokeBattle_Move
    def pbAdditionalEffect(_user, target)
        return if target.fainted? || target.damageState.substitute
        target.applyEffect(:HealingReversed)
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
# If the move misses, the user gains Accuracy and Speed. (Joust)
#===============================================================================
class PokeBattle_Move_53D < PokeBattle_Move
    # This method is called if a move fails to hit all of its targets
    def pbCrashDamage(user)
        return unless user.pbRaiseMultipleStatSteps([:ACCURACY, 1, :SPEED, 1], user, move: self)
        @battle.pbDisplay(_INTL("{1} circles back around for a retry!", user.pbThis))
    end

    def getEffectScore(user, _target)
        return getMultiStatUpEffectScore([:ACCURACY, 1, :SPEED, 1], user, user) * 0.5
    end
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
        forceOutTargets(user,targets,[],substituteBlocks: true, invertMissCheck: true)
    end

    def getEffectScore(user, target)
        return getForceOutEffectScore(user, target) * 0.5
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
        return -getMultiStatUpEffectScore([:SPEED, 1], user, target, evaluateThreat: false)
    end
end

#===============================================================================
# Heals for 1/3 the damage dealt. (new!Drain Punch)
#===============================================================================
class PokeBattle_Move_545 < PokeBattle_DrainMove
    def drainFactor(_user, _target); return (1.0 / 3.0); end
end

#===============================================================================
# Always critical hit vs Opponents with raised stats (Humble)
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
# Curses the target by spending 1/4th of the user's HP. (Cursed Oath)
#===============================================================================
class PokeBattle_Move_54A < PokeBattle_Move_10D
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
# Leeches the target and reduces their attacking stats by 1 step each. (Sapping Seed)
#===============================================================================
class PokeBattle_Move_552 < PokeBattle_LeechMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if  !target.canLeech?(user, false, self) &&
            !target.pbCanLowerStatStep?(:ATTACK, user, self) &&
            !target.pbCanLowerStatStep?(:SPECIAL_ATTACK, user, self)

            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't be leeched or have either of its attacking stats lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.applyLeeched if target.canLeech?(user, false, self)
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
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
# Increases the target's Attack by 3 steps, then the target hits itself with its own attack. (Swagger)
#===============================================================================
class PokeBattle_Move_55D < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        target.tryRaiseStat(:ATTACK, user, increment: 3, move: self)
        target.pbConfusionDamage(_INTL("It hurt itself in a rage!"), false, false, selfHitBasePower(target.level))
    end

    def getTargetAffectingEffectScore(user, target)
        score = -25 # TODO: rework this
        score -= getMultiStatUpEffectScore([:ATTACK, 3], user, target, evaluateThreat: false)
        score -= 70 if target.hasActiveAbilityAI?(:UNAWARE)
        return score
    end
    
    def calculateDamageForHitAI(user,target,type,baseDmg,numTargets)
        damage = calculateDamageForHit(user,target,type,baseDmg,numTargets,true)
        damage *= 1.75 unless target.hasActiveAbilityAI?(:UNAWARE)
        return damage
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
        score = -25 # TODO: rework this
        score -= getMultiStatUpEffectScore([:SPECIAL_ATTACK, 3], user, target, evaluateThreat: false)
        score -= 70 if target.hasActiveAbilityAI?(:UNAWARE)
        return score
    end

    def calculateDamageForHitAI(user,target,type,baseDmg,numTargets)
        damage = calculateDamageForHit(user,target,type,baseDmg,numTargets,true)
        damage *= 1.75 unless target.hasActiveAbilityAI?(:UNAWARE)
        return damage
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
# Uses rest on both self and target. (Bedfellows)
#===============================================================================
class PokeBattle_Move_564 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        @battle.forceUseMove(user, :REST)
        @battle.forceUseMove(target, :REST)
    end

    def getEffectScore(user, target)
        score = 0

        unless user.fullHealth?
            score += user.applyFractionalHealing(1.0, aiCheck: true)
            score -= getSleepEffectScore(nil, user) * 0.45
            score += 45 if user.hasStatusNoSleep?
        end
        unless target.fullHealth?
            score -= target.applyFractionalHealing(1.0, aiCheck: true)
            score += getSleepEffectScore(nil, target)
            score -= 45 if target.hasStatusNoSleep?
        end
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
# Debuff's target's attacking stats in hail. (Cold Shoulder)
#===============================================================================
class PokeBattle_Move_56A < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_2, user, move: self) if @battle.icy?
    end
end

#===============================================================================
# Raises all stats by 2 steps. Fails unless the user is asleep. (Oneiromancy)
#===============================================================================
class PokeBattle_Move_56E < PokeBattle_MultiStatUpMove
    def usableWhenAsleep?; return true; end

    def initialize(battle, move)
        super
        @statUp = ALL_STATS_2
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
        return getWantsToBeSlowerScore(user, target, 4, move: self)
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
        return 0 if user.effects[:PerishSong] > 0
        return 0 if user.belowHalfHealth?
        return 0 unless target.hasPhysicalAttack?
        return 150
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

    def getEffectScore(_user, _target)
        return 250
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
        if !GameData::Move.get(getFirstSlotMove(user).id).can_be_forced? || getFirstSlotMove(user).callsAnotherMove?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s first slot move can't be shared!"))
            end
            return true
        end
        return false
    end

    def getFirstSlotMove(user)
        return user.getMoves[0] || nil
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