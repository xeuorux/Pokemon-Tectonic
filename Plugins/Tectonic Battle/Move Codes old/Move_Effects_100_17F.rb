#===============================================================================
# Attacks 2 rounds in the future. (Future Sight, etc.)
#===============================================================================
class PokeBattle_Move_111 < PokeBattle_ForetoldMove
end

#===============================================================================
# Grounds the target while it remains active. Hits some semi-invulnerable
# targets. (Smack Down, Thousand Arrows)
#===============================================================================
class PokeBattle_Move_11C < PokeBattle_Move
    def hitsFlyingTargets?; return true; end

    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::NORMAL_EFFECTIVE_ONE if moveType == :GROUND && defType == :FLYING
        return super
    end

    def canSmackDown?(target, checkingForAI = false)
        return false if target.fainted?
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.unaffected || target.damageState.substitute
            return false
        end
        return false if target.inTwoTurnAttack?("0CE") || target.effectActive?(:SkyDrop) # Sky Drop
        return false if !target.airborne? && !target.inTwoTurnAttack?("0C9", "0CC") # Fly/Bounce
        return true
    end

    def pbEffectAfterAllHits(_user, target)
        return unless canSmackDown?(target)
        target.applyEffect(:SmackDown)
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        if canSmackDown?(target)
            score += 30
                if user.pbHasAttackingType?(:GROUND) && !target.effectActive?(:SmackDown)
                    tTypes = target.pbTypes(true, true)
                    tTypes.each do |t|
                        score += 30 if t == :FIRE || t == :POISON || t == :STEEL || t == :ROCK || t == :ELECTRIC
                        score -= 30 if t == :BUG || t == :GRASS || t == :ICE
                    end
                end
            score += 70 if @battle.battleAI.userMovesFirst?(self, user, target) && target.inTwoTurnAttack?("0C9", "0CC")
        end
        score = 5 if score <= 5 # Constant score so AI uses on "kills"
        return score
    end

    def shouldHighlight?(_user, target)
        return canSmackDown?(target)
    end
end

#===============================================================================
# User switches places with its ally. (Ally Switch)
#===============================================================================
class PokeBattle_Move_120 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        eachValidSwitch(user) do |_ally|
            return false
        end
        if show_message
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no valid allies to switch with!"))
        end
        return true
    end

    def eachValidSwitch(battler)
        idxUserOwner = @battle.pbGetOwnerIndexFromBattlerIndex(battler.index)
        battler.eachAlly do |b|
            next if @battle.pbGetOwnerIndexFromBattlerIndex(b.index) != idxUserOwner
            next unless b.near?(battler)
            yield b
        end
    end

    def pbEffectGeneral(user)
        idxA = user.index
        idxB = -1
        eachValidSwitch(user) do |ally|
            idxB = ally.index
        end
        if @battle.pbSwapBattlers(idxA, idxB)
            @battle.pbDisplay(_INTL("{1} and {2} switched places!",
               @battle.battlers[idxB].pbThis, @battle.battlers[idxA].pbThis(true)))
        end
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Ally Switch.")
        return 0
    end
end

#===============================================================================
# Ends target's protections, screens, and substitute immediately. (Siege Breaker)
#===============================================================================
class PokeBattle_Move_12E < PokeBattle_Move
    def ignoresSubstitute?; return true; end
    def ignoresReflect?; return true; end
    
    def pbEffectAgainstTarget(_user, target)
        removeProtections(target)
        target.disableEffect(:Substitute)
    end

    def pbEffectWhenDealingDamage(_user, target)
        side = target.pbOwnSide
        side.eachEffect(true) do |effect, _value, data|
            side.disableEffect(effect) if data.is_screen?
        end
    end

    def sideHasScreens?(side)
        side.eachEffect(true) do |_effect, _value, data|
            return true if data.is_screen?
        end
        return false
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        targets.each do |b|
            next unless sideHasScreens?(b.pbOwnSide)
            hitNum = 1 # Wall-breaking anim
            break
        end
        super
    end

    def getEffectScore(_user, target)
        score = 0
        target.pbOwnSide.eachEffect(true) do |effect, value, data|
            next unless data.is_screen?
			case value
				when 2
					score += 30
				when 3
					score += 50
				when 4..999
					score += 130
            end	
        end
        score += 20 if target.substituted?
        return score
    end

    def shouldHighlight?(_user, target)
        return true if sideHasScreens?(target.pbOwnSide)
        return true if target.substituted?
        return false
    end
end

#===============================================================================
# Allies of the user also attack the target with Slash. (All For One)
#===============================================================================
class PokeBattle_Move_12F < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        user.eachAlly do |b|
            break if target.fainted?
            @battle.pbDisplay(_INTL("{1} joins in the attack!", b.pbThis))
            battle.forceUseMove(b, :SLASH, target.index)
        end
    end
end

#===============================================================================
# Hits three times by base, and one extra every time the move is used
# over the course of a battle. (Blades of Grass)
#===============================================================================
class PokeBattle_Move_130 < PokeBattle_Move
    def multiHitMove?; return true; end

    def pbNumHits(user, _targets, _checkingForAI = false)
        return 3 + user.moveUsageCount(@id)
    end
end

#===============================================================================
# Removes all Rooms. Fails if there is no Room. (Razing Vines)
#===============================================================================
class PokeBattle_Move_131 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        anyRoom = false
        @battle.field.eachEffect(true) do |effect, _value, effectData|
            next unless effectData.is_room?
            anyRoom = true
            break
        end

        unless anyRoom
            @battle.pbDisplay(_INTL("But it failed, since there is no active room!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.field.eachEffect(true) do |effect, _value, effectData|
            next unless effectData.is_room?
            @battle.field.disableEffect(effect)
        end
    end

    def getEffectScore(user, _target)
        return 80
    end
end

#===============================================================================
# Forces both the user and the target to switch out. (Stink Cover)
#===============================================================================
class PokeBattle_Move_139 < PokeBattle_Move_0EB
    def pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers)
        return if numHits == 0
        targets.push(user)
        forceOutTargets(user, targets, switchedBattlers, substituteBlocks: true, random: false)
    end

    def getTargetAffectingEffectScore(user, target)
        score = super
        score += getSwitchOutEffectScore(user)
        return score
    end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 2 steps each. Always hits.
# (Noble Roar)
#===============================================================================
class PokeBattle_Move_13A < PokeBattle_TargetMultiStatDownMove
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @statDown = ATTACKING_STATS_2
    end

    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# Decreases the Attack, Special Attack and Speed of all nearby poisoned foes
# by 3 steps each. (Venom Drench)
#===============================================================================
class PokeBattle_Move_140 < PokeBattle_Move
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 3, :SPECIAL_ATTACK, 3, :SPEED, 3]
    end

    def pbMoveFailed?(user, _targets, show_message)
        @battle.eachBattler do |b|
            return false if isValidTarget?(user, b)
        end
        @battle.pbDisplay(_INTL("But it failed, since it has no valid targets!")) if show_message
        return true
    end

    def isValidTarget?(user, target)
        return false if target.fainted?
        return false unless target.poisoned?
        return false if !target.pbCanLowerStatStep?(:ATTACK, user, self) &&
                        !target.pbCanLowerStatStep?(:SPECIAL_ATTACK, user, self) &&
                        !target.pbCanLowerStatStep?(:SPEED, user, self)
        return true
    end

    def pbFailsAgainstTarget?(user, target, _show_message)
        return !isValidTarget?(user, target)
    end

    def pbEffectAgainstTarget(user, target)
        target.pbLowerMultipleStatSteps(@statDown, user, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore(@statDown, user, target) if isValidTarget?(user, target)
        return 0
    end
end

#===============================================================================
# Reverses all stat changes of the target. (Topsy-Turvy)
#===============================================================================
class PokeBattle_Move_141 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        failed = true
        GameData::Stat.each_battle do |s|
            next if target.steps[s.id] == 0
            failed = false
            break
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} has no stat changes!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        GameData::Stat.each_battle { |s| target.steps[s.id] *= -1 }
        @battle.pbDisplay(_INTL("{1}'s stats were reversed!", target.pbThis))
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        netSteps = 0
        GameData::Stat.each_battle do |s|
            netSteps += target.steps[s.id]
        end
        if user.opposes?(target)
            score += netSteps * 10
        else
            score -= netSteps * 10
        end
        return score
    end
end

#===============================================================================
# If this move KO's the target, increases the user's Attack by 5 steps.
# (Fell Stinger)
#===============================================================================
class PokeBattle_Move_150 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return unless target.damageState.fainted
        user.tryRaiseStat(:ATTACK, user, increment: 5, move: self)
    end

    def getFaintEffectScore(user, target)
        return getMultiStatUpEffectScore([:ATTACK, 5], user, user)
    end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 1 step each. Then, user
# switches out. Ignores trapping moves. (Parting Shot)
#===============================================================================
class PokeBattle_Move_151 < PokeBattle_TargetMultiStatDownMove
    def switchOutMove?; return true; end

    def initialize(battle, move)
        super
        @statDown = ATTACKING_STATS_2
    end

    def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
        switcher = user
        targets.each do |b|
            next if switchedBattlers.include?(b.index)
            switcher = b if b.effectActive?(:MagicCoat) || b.effectActive?(:MagicBounce)
        end
        return if switcher.fainted? || numHits == 0
        return unless @battle.pbCanChooseNonActive?(switcher.index)
        @battle.pbDisplay(_INTL("{1} went back to {2}!", switcher.pbThis, @battle.pbGetOwnerName(switcher.index)))
        @battle.pbPursuit(switcher.index)
        return if switcher.fainted?
        newPkmn = @battle.pbGetReplacementPokemonIndex(switcher.index) # Owner chooses
        return if newPkmn < 0
        @battle.pbRecallAndReplace(switcher.index, newPkmn)
        @battle.pbClearChoice(switcher.index) # Replacement Pokémon does nothing this round
        @battle.moldBreaker = false if switcher.index == user.index
        switchedBattlers.push(switcher.index)
        switcher.pbEffectsOnSwitchIn(true)
    end

    def getEffectScore(user, target)
        return getSwitchOutEffectScore(user)
    end
end

#===============================================================================
# No Pokémon can switch out or flee until the end of the next round. (Fairy Lock)
#===============================================================================
class PokeBattle_Move_152 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        if @battle.field.effectActive?(:FairyLock)
            @battle.pbDisplay(_INTL("But it failed, since a Fairy Lock is already active!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:FairyLock, 2)
        @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Fairy Lock.")
        return 0 # The move is both annoying and very weak
    end
end

#===============================================================================
# Entry hazard. Lays a Speed reducing web on the opposing side. (Sticky Web)
#===============================================================================
class PokeBattle_Move_153 < PokeBattle_Move
    def hazardMove?; return true,4; end
    def aiAutoKnows?(pokemon); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOpposingSide.effectActive?(:StickyWeb)
            @battle.pbDisplay(_INTL("But it failed, since a Sticky Web is already laid out!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOpposingSide.applyEffect(:StickyWeb)
    end

    def getEffectScore(user, target)
        return getHazardSettingEffectScore(user, target, 15)
    end
end

#===============================================================================
# Poisons the target and decreases its Speed by 4 steps. (Toxic Thread)
#===============================================================================
class PokeBattle_Move_159 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.canPoison?(user, false, self) &&
           !target.pbCanLowerStatStep?(:SPEED, user, self)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't be poisoned or have its Speed lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyPoison(user) if target.canPoison?(user, false, self)
        target.tryLowerStat(:SPEED, user, increment: 4, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        score = getMultiStatDownEffectScore([:SPEED,4],user,target)
        score += getPoisonEffectScore(user, target)
        return score
    end
end

#===============================================================================
# Decreases the target's Attack by 1 step. Heals user by an amount equal to the
# target's Attack stat. (Strength Sap)
#===============================================================================
class PokeBattle_Move_160 < PokeBattle_StatDrainHealingMove
    def initialize(battle, move)
        super
        @statToReduce = :ATTACK
    end
end

#===============================================================================
# User and target swap their Speed stats (not their stat steps). (Speed Swap)
#===============================================================================
class PokeBattle_Move_161 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbEffectAgainstTarget(user, target)
        userSpeed = user.base_speed
        targetSpeed = target.base_speed
        user.applyEffect(:BaseSpeed,targetSpeed)
        target.applyEffect(:BaseSpeed,userSpeed)
        @battle.pbDisplay(_INTL("{1} switched base Speed with its target!", user.pbThis))
    end

    def getEffectScore(user, target)
        score = getWantsToBeSlowerScore(user, target, 8, move: self)
        return score
    end
end

#===============================================================================
# Negates the target's ability while it remains on the field, if it has already
# performed its action this round. (Core Enforcer)
#===============================================================================
class PokeBattle_Move_165 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        return if target.damageState.substitute || target.effectActive?(:GastroAcid)
        return if target.unstoppableAbility?
        return if @battle.choices[target.index][0] != :UseItem &&
                  !((@battle.choices[target.index][0] == :UseMove ||
                  @battle.choices[target.index][0] == :Shift) && target.movedThisRound?)
        target.applyEffect(:GastroAcid)
    end

    def getEffectScore(user, target)
        score = getWantsToBeSlowerScore(user, target, 3, move: self) if !target.substituted? && !target.effectActive?(:GastroAcid)
        return score
    end
end