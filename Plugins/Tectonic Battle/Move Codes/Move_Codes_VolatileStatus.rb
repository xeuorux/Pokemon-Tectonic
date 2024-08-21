#===============================================================================
# The target can no longer use the same move twice in a row. (Torment)
#===============================================================================
class PokeBattle_Move_DisableTargetUsingSameMoveConsecutively < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Torment)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already tormented!"))
            end
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Torment)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        score = 60
        score += 40 unless target.hasDamagingAttack?
        return score
    end
end

# Empowered Torment
class PokeBattle_Move_EmpoweredTorment < PokeBattle_Move_DisableTargetUsingSameMoveConsecutively
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        transformType(user, :DARK)
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:Torment)
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
    end
end

#===============================================================================
# Disables all target's moves that the user also knows. (Imprison)
#===============================================================================
class PokeBattle_Move_DisableTargetMovesKnownByUser < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Imprison)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s is already imprisoning shared moves!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Imprison)
    end

    def getTargetAffectingEffectScore(_user, _target)
        echoln("The AI will never use Imprison.")
        return -1000
    end
end

#===============================================================================
# For 5 rounds, disables the last move the target used. (Disable)
#===============================================================================
class PokeBattle_Move_DisableTargetLastMoveUsed < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @disableTurns = 4
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.canBeDisabled?(true, self)
            @battle.pbDisplay(_INTL("But it failed, since the target can't be disabled!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Disable, @disableTurns)
    end

    def getTargetAffectingEffectScore(_user, target)
        return getDisableEffectScore(target, @disableTurns)
    end
end

#===============================================================================
# For 4 rounds, disables the last move the target used. (Drown)
# Then debuffs a stat based on what was disabled.
#===============================================================================
class PokeBattle_Move_DisableTargetLastMoveUsedLowerTargetRelevantStat4 < PokeBattle_Move_DisableTargetLastMoveUsed
    def initialize(battle, move)
        super
        @disableTurns = 4
    end

    def pbEffectAgainstTarget(user, target)
        super
        statToLower = getDebuffingStat(target)
        target.pbLowerStatStep(statToLower, 4, user) if target.pbCanLowerStatStep?(statToLower,user,self,true)
    end

    def getDebuffingStat(battler)
        return :SPEED unless battler.lastRegularMoveUsed
        case GameData::Move.get(battler.lastRegularMoveUsed).category
        when 0
            return :ATTACK
        when 1
            return :SPECIAL_ATTACK
        when 2
            return :SPEED
        end
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatDownEffectScore([getDebuffingStat(target),4],user,target)
        return score
    end
end

#===============================================================================
# For 5 rounds, disables the last move the target used. Also, (Gem Seal)
# remove 5 PP from it.
#===============================================================================
class PokeBattle_Move_DisableTargetLastMoveUsedReduceItsPPBy5 < PokeBattle_Move_DisableTargetLastMoveUsed
    def pbEffectAgainstTarget(_user, target)
        super
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            reduction = [5, m.pp].min
            target.pbSetPP(m, m.pp - reduction)
            @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
               target.pbThis(true), m.name, reduction))
            break
        end
    end

    def getEffectScore(_user, target)
        score = super
        score += 10
        return score
    end
end

#===============================================================================
# For 4 rounds, disables the target's non-damaging moves. (Taunt)
#===============================================================================
class PokeBattle_Move_DisableTargetStatusMoves4 < PokeBattle_Move
    def ignoresSubstitute?(user); return statusMove?; end

    def initialize(battle, move)
        super
        @tauntTurns = 4
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:Taunt)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already taunted!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def getTauntTurns(target)
        return target.boss? ? @tauntTurns / 2 : @tauntTurns
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyEffect(:Taunt, getTauntTurns(target))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return if target.effectActive?(:Taunt)
        return true if pbMoveFailedAromaVeil?(user, target)
        target.applyEffect(:Taunt, getTauntTurns(target))
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 if target.substituted? && statusMove? && !ignoresSubstitute?(user)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        unkownHate = target.unknownMovesCountAI 
        return 0 unless target.hasStatusMove? || unkownHate == 4
        firstTurnScore = 0
        lastingScore = 0        

        
        # AI taunts if it has no idea what target is doing
        if unkownHate == 4
            firstTurnScore = 50
            lastingScore += 30
        end
        
        # Setup
        if target.hasSetupStatusMove?
           if target.lastRoundMoveCategory == -1 || target.lastRoundMoveCategory == 2 # No point stopping setup that already happened
                firstTurnScore = 50
                lastingScore += 30
            end
        end
        
        # Hazard
        if target.hasUseableStatusHazardMove?
            firstTurnScore = 50
            lastingScore += 30           
        end
        
        # Recovery
        if target.hasRecoveryMove?
            if target.hp <= target.totalhp * 0.7
                firstTurnScore = 50
                lastingScore += 30
            else
                lastingScore += 25
            end
        end

		if @battle.battleAI.userMovesFirst?(self, user, target)
            firstTurnScore *= 2
            firstTurnScore *= 1.3 if user.firstTurn? # Prevent hazards over setting them on lead
        end
        
        lastingScore *= (getTauntTurns(target) - 1)
        score = firstTurnScore + lastingScore
        score = 220 if score >= 220 # AI shouldnt taunt over kills
        return score
    end
end

#===============================================================================
# For 2 rounds, disables the target's non-damaging moves. (Docile Mask)
#===============================================================================
class PokeBattle_Move_DisableTargetStatusMoves2 < PokeBattle_Move_DisableTargetStatusMoves4
    def initialize(battle, move)
        super
        @tauntTurns = 2
    end
end

#===============================================================================
# For 5 rounds, disables the target's healing moves. (Heal Block)
#===============================================================================
class PokeBattle_Move_DisableTargetHealingMoves5 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:HealBlock)
            @battle.pbDisplay(_INTL("But it failed, since the target's healing is already blocked!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:HealBlock, 5)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        return 0 unless target.hasHealingMove?
        return 40
    end
end

#===============================================================================
# For 4 rounds, the target must use the same move each round. (Encore)
#===============================================================================
class PokeBattle_Move_DisableTargetUsingDifferentMove4 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "DisableTargetUsingDifferentMove4", # Encore
            # Struggle
            "Struggle", # Struggle
            # Moves that affect the moveset
            "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
            "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
            "TransformUserIntoTarget",   # Transform
            # Moves that call other moves
            "UseLastMoveUsedByTarget", # Mirror Move
            "UseLastMoveUsed",   # Copycat
            "UseMoveTargetIsAboutToUse",   # Me First
            "UseMoveDependingOnEnvironment",   # Nature Power
            "UseRandomUserMoveIfAsleep",   # Sleep Talk
            "UseRandomMoveFromUserParty",   # Assist
            "UseRandomNonSignatureMove", # Metronome
        ]
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Encore)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already locked into an encore!")) if show_message
            return true
        end
        unless target.lastRegularMoveUsed
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move yet!")) if show_message
            return true
        end
        if @moveBlacklist.include?(GameData::Move.get(target.lastRegularMoveUsed).function_code)
            @battle.pbDisplay(_INTL("But it failed, since {1} can't be locked into {2}!",
                  target.pbThis(true), GameData::Move.get(target.lastRegularMoveUsed).name)) if show_message
            return true
        end
        if target.effectActive?(:ShellTrap)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is setting a Shell Trap!")) if show_message
            return true
        end
        if target.effectActive?(:Masquerblade)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is hiding a Masquerblade!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        canEncore = false
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            next if m.pp == 0 && m.total_pp > 0
            canEncore = true
            break
        end
        unless canEncore
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} last used move has no more PP!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Encore, 4)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        score = 60
        score += 40 if @battle.pbIsTrapped?(target.index)
        userSpeed = user.pbSpeed(true, move: self)
        targetSpeed = target.pbSpeed(true)
        if userSpeed > targetSpeed
            return 0 if target.lastRegularMoveUsed.nil?
            moveData = GameData::Move.get(target.lastRegularMoveUsed)
            if moveData.category == 2 && %i[User BothSides].include?(moveData.target)
                score += 100
            elsif moveData.category != 2 && moveData.target == :NearOther &&
                  Effectiveness.ineffective?(pbCalcTypeMod(moveData.type, target, user))
                score += 100
            end
        end
        return score
    end
end

#===============================================================================
# For 4 rounds, disables the target's off-type moves. (Bar)
#===============================================================================
class PokeBattle_Move_DisableTargetUsingOffTypeMove4 < PokeBattle_Move
    def ignoresSubstitute?(_user); return statusMove?; end

    def initialize(battle, move)
        super
        @barredTurns = 4
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:Barred)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already barred!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def getBarTurns(target)
        return target.boss? ? @barredTurns / 2 : @barredTurns
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyEffect(:Barred, getBarTurns(target))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return if target.effectActive?(:Barred)
        return true if pbMoveFailedAromaVeil?(user, target)
        target.applyEffect(:Barred, getBarTurns(target))
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.substituted? && statusMove?
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        return 0 unless target.hasOffTypeMove?
        return 40 + getBarTurns(target) * 20
    end
end

#===============================================================================
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
#===============================================================================
class PokeBattle_Move_StartDamageTargetEachTurnIfTargetAsleep < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless target.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} isn't asleep!")) if show_message
            return true
        end
        if target.effectActive?(:Nightmare)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already afflicted by a Nightmare!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Nightmare)
    end

    def getTargetAffectingEffectScore(_user, target)
        score = 100
        score += 50 if target.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# Decrease 6 steps of speed and weakens target to fire moves. (Tar Shot)
#===============================================================================
class PokeBattle_Move_LowerTargetSpeed6MakeTargetWeakerToFire < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if !target.pbCanLowerStatStep?(:SPEED, target, self) && target.effectActive?(:TarShot)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already covered in tar and can't have their Speed lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.substitute
        target.tryLowerStat(:SPEED, user, move: self, increment: 6)
        target.applyEffect(:TarShot)
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += getMultiStatDownEffectScore([:SPEED, 6], user, target)
        score += 50 unless target.effectActive?(:TarShot)
        return score
    end
end

#===============================================================================
# User curses the target.
#===============================================================================
class PokeBattle_Move_CurseTarget < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Curse)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already cursed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:Curse)
    end

    def getEffectScore(user, target)
        score = getCurseEffectScore(user, target)
        return score
    end
end

#===============================================================================
# Curses the target by spending 1/4th of the user's HP. (Cursed Oath)
#===============================================================================
class PokeBattle_Move_CurseTargetUserPaysQuarterOfTotalHP < PokeBattle_Move_CurseTarget
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

# Empowered Cursed Oath
class PokeBattle_Move_EmpoweredCursedOath < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyEffect(:Curse)
        end
        transformType(user, :GHOST)
    end
end

#===============================================================================
# Numb's the target. If they are already numbed, curses them instead. (Spectral Tongue)
#===============================================================================
class PokeBattle_Move_NumbTargetOrCurseIfNumb < PokeBattle_Move
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
# User cuts its own HP by 25% to curse all foes and also to set Ingrain. (Cursed Roots)
#===============================================================================
class PokeBattle_Move_CurseAllFoesUserPaysQuarterOfTotalHPStartsIngrain < PokeBattle_Move_StartHealUserEachTurnTrapUser
    def pbMoveFailed?(user, _targets, show_message)
        if user.hp <= (user.totalhp / 4)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        allCursed = true
        user.eachOpposing do |b|
            next if b.effectActive?(:Curse)
            allCursed = false
            break
        end
        if user.effectActive?(:Ingrain) && allCursed
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s roots are already planted and all foes are already cursed!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("{1} cut its own HP!", user.pbThis))
        user.applyFractionalDamage(1.0 / 4.0, false)

        user.eachOpposing do |b|
            next if b.effectActive?(:Curse)
            b.applyEffect(:Curse)
        end

        super
    end

    def getEffectScore(user, _target)
        score = super
        score += getHPLossEffectScore(user, 0.25)
        return score
    end
end

#===============================================================================
# Target cannot use sound-based moves for 2 more rounds. (Throat Chop)
#===============================================================================
class PokeBattle_Move_DisableTargetSoundMoves3 < PokeBattle_Move
    def pbAdditionalEffect(_user, target)
        return if target.fainted? || target.damageState.substitute
        target.applyEffect(:ThroatChop, 3)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 30 if !target.effectActive?(:ThroatChop) && target.hasSoundMove? && !target.substituted?
        return 0
    end
end

#===============================================================================
# The next ground type move to hit the target deals double damage. (Volatile Toxin)
#===============================================================================
class PokeBattle_Move_TargetTakesDoubleDamageFromNextGroundAttack < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:VolatileToxin)
    end
end

#===============================================================================
# Target gains a weakness to Bug-type attacks. (Creep Out)
#===============================================================================
class PokeBattle_Move_MakeTargetWeakerToBug < PokeBattle_Move
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
# Grounds the target while it remains active. Hits some semi-invulnerable
# targets. (Smack Down, Thousand Arrows, Weigh Anchor)
#===============================================================================
class PokeBattle_Move_HitsTargetInSkyGroundsTarget < PokeBattle_Move
    def hitsFlyingTargets?; return true; end

    def pbCalcTypeModSingle(moveType, defType, user=nil, target=nil)
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
        return false if !target.airborne? &&
            !target.inTwoTurnSkyAttack?
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
            score += 70 if @battle.battleAI.userMovesFirst?(self, user, target) &&
                target.inTwoTurnSkyAttack?
        end
        score = 5 if score <= 5 # Constant score so AI uses on "kills"
        return score
    end

    def shouldHighlight?(_user, target)
        return canSmackDown?(target)
    end
end

#===============================================================================
# Negates the target's ability while it remains on the field, if it has already
# performed its action this round. (Core Enforcer)
#===============================================================================
class PokeBattle_Move_NegateTargetAbilityIfTargetActed < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        return if target.damageState.substitute || target.effectActive?(:GastroAcid)
        return if target.immutableAbility?
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

#===============================================================================
# If the target would heal until end of turn, instead they take that much life loss.
# (Hypothermiate, Heartstopper, Bad Ending)
#===============================================================================
class PokeBattle_Move_ReverseTargetHealingThisTurn < PokeBattle_Move
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
# The target's healing is cut in half until they switch out (Icy Injection)
#===============================================================================
class PokeBattle_Move_TargetHasHalvedHealing < PokeBattle_Move
    def pbAdditionalEffect(_user, target)
        return if target.fainted? || target.damageState.substitute
        target.applyEffect(:IcyInjection)
    end

    def getEffectScore(_user, target)
        if target.hasHealingMove?
            if target.belowHalfHealth?
                return 45
            else
                return 30
            end
        end
        return 0
    end
end