#===============================================================================
# No additional effect.
#===============================================================================
class PokeBattle_Move_Basic < PokeBattle_Move
end

#===============================================================================
# No additional effect.
#===============================================================================
class PokeBattle_Move_Invalid < PokeBattle_Move
    def initialize(battle, move)
        raise _INTL("An Invalid move is being instanced. This shouldn't happen!")
    end
end

#===============================================================================
# Does absolutely nothing. (Splash)
#===============================================================================
class PokeBattle_Move_DoesNothingUnusableInGravity < PokeBattle_Move
    def unusableInGravity?; return true; end

    def pbEffectGeneral(_user)
        @battle.pbDisplay(_INTL("But nothing happened!"))
    end
end

#===============================================================================
# Struggle, if defined as a move in moves.txt. Typically it won't be.
#===============================================================================
class PokeBattle_Move_Struggle < PokeBattle_Struggle
end

#===============================================================================
# All current battlers will perish after 3 more rounds. (Perish Song)
#===============================================================================
class PokeBattle_Move_StartPerishCountsForAllBattlers < PokeBattle_Move
    def pbMoveFailed?(_user, targets, show_message)
        failed = true
        targets.each do |b|
            next if b.effectActive?(:PerishSong)
            failed = false
            break
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since everyone has heard the song already!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, _show_message)
        return target.effectActive?(:PerishSong)
    end

    def pbEffectAgainstTarget(user, target)
        if target.boss? && user != target
            target.applyEffect(:PerishSong, 12)
        else
            target.applyEffect(:PerishSong, 3)
        end
    end

    def getEffectScore(user, _target)
        return 0 unless user.alliesInReserve?
        return 60
    end
end

#===============================================================================
# If target would be KO'd by this attack, it survives with 1HP instead.
# (False Swipe, Hold Back)
#===============================================================================
class PokeBattle_Move_CannotMakeTargetFaint < PokeBattle_Move
    def nonLethal?(_user, _target); return true; end
end

#===============================================================================
# Swaps form if the user is Meloetta. (Relic Song)
#===============================================================================
class PokeBattle_Move_ChangeUserMeloettaForm < PokeBattle_Move
    def pbEndOfMoveUsageEffect(user, _targets, numHits, _switchedBattlers)
        return if numHits == 0
        return if user.fainted? || user.transformed?
        return unless user.isSpecies?(:MELOETTA)
        return if user.hasActiveAbility?(:SHEERFORCE)
        newForm = (user.form + 1) % 2
        user.pbChangeForm(newForm, _INTL("{1} transformed!", user.pbThis))
    end
end

#===============================================================================
# Interrupts a foe switching out or using U-turn/Volt Switch/Parting Shot. Power
# is doubled in that case. (Pursuit)
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
#===============================================================================
class PokeBattle_Move_PursueSwitchingFoe < PokeBattle_Move
    def pbAccuracyCheck(user, target)
        return true if @battle.switching
        return super
    end

    def pbBaseDamage(baseDmg, _user, _target)
        baseDmg *= 2 if @battle.switching
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 2 if @battle.aiPredictsSwitch?(user,target.index)
        return baseDmg
    end
end

#===============================================================================
# Transforms the user into one of its Mega Forms. (Gene Boost)
#===============================================================================
class PokeBattle_Move_ChangeUserMewtwoChoiceOfForm < PokeBattle_Move
    def resolutionChoice(user)
        if @battle.autoTesting
            @chosenForm = rand(2) + 1
        elsif !user.pbOwnedByPlayer? # Trainer AI
            @chosenForm = 2 # Always chooses mega mind form
        else
            form1Name = GameData::Species.get_species_form(:MEWTWO,1).form_name
            form2Name = GameData::Species.get_species_form(:MEWTWO,2).form_name
            formNames = [form1Name,form2Name]
            chosenIndex = @battle.scene.pbShowCommands(_INTL("Which form should #{user.pbThis(true)} take?"),formNames,0)
            @chosenForm = chosenIndex + 1
        end
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.form == 0
            if show_message
                msg = _INTL("#{user.pbThis} has already transformed!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:MEWTWO)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis)) if show_message
            return true
        end
        unless user.form == 0
            @battle.pbDisplay(_INTL("But {1} has already transformed!", user.pbThis)) if show_message
            return true
        end
        return false
    end
    
    def pbEffectGeneral(user)
        user.pbChangeForm(@chosenForm, _INTL("{1} augmented its genes and transformed!", user.pbThis))
    end

    def resetMoveUsageState
        @chosenForm = nil
    end

    def getEffectScore(_user, _target)
        return 100
    end
end

#===============================================================================
# Target transforms into their pre-evolution. (Young Again)
#===============================================================================
class PokeBattle_Move_TransformTargetPreEvolution < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.illusion?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is disguised by an Illusion!"))
            end
            return true
        end
        if target.boss?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is an avatar!"))
            end
            return true
        end
        unless target.species_data
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have a defined species somehow!"))
            end
            return true
        end
        unless GameData::Species.get(target.technicalSpecies).has_previous_species?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} has no previous species to transform into!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.transformSpecies(GameData::Species.get(target.technicalSpecies).get_previous_species)
    end

    def getEffectScore(user, target)
        score = 95
        score += 45 if target.aboveHalfHealth?
        if user.battle.pbCanSwitch?(target.index)
            score -= 30
            score += getForceOutEffectScore(user, target)
        end
        return score
    end
end

#===============================================================================
# Target's last move used loses 4 PP. (Spiteful Chant, Eerie Spell)
#===============================================================================
class PokeBattle_Move_LowerPPOfTargetLastMoveBy4 < PokeBattle_Move
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
# Uses the highest base-power attacking move known by any non-user Pokémon in the user's party. (Optimized Action)
#===============================================================================
class PokeBattle_Move_UseHighestBasePowerMoveFromUserParty < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def getOptimizedMove(user)
        optimizedMove = nil
        optimizedBP = -1
        @battle.pbParty(user.index).each_with_index do |pkmn, i|
            next if !pkmn || i == user.pokemonIndex
            next unless pkmn.able?
            pkmn.moves.each do |move|
                next if move.category == 2
                next unless move.base_damage > optimizedBP
                battleMove = @battle.getBattleMoveInstanceFromID(move.id)
                next if battleMove.forceSwitchMove?
                next if battleMove.is_a?(PokeBattle_TwoTurnMove)
                next if battleMove.is_a?(PokeBattle_HelpingMove)
                optimizedMove = move.id
                optimizedBP = move.base_damage
            end
        end
        return optimizedMove
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless getOptimizedMove(user)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since there are no moves #{user.pbThis(true)} can use!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(getOptimizedMove(user))
    end
end

#===============================================================================
# The target uses its most recent move again. (Instruct)
#===============================================================================
class PokeBattle_Move_TargetUsesItsLastUsedMoveAgain < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        unless target.lastRegularMoveUsed
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move yet!"))
            end
            return true
        end
        unless target.pbHasMove?(target.lastRegularMoveUsed)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} no longer knows its most recent move!"))
            end
            return true
        end
        if target.usingMultiTurnAttack?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is locked into an attack!"))
            end
            return true
        end
        targetMove = @battle.choices[target.index][2]
        if targetMove && (targetMove.function == "FailsIfUserDamagedThisTurn" ||   # Focus Punch
                          targetMove.function == "UsedAfterUserTakesPhysicalDamage" ||   # Shell Trap
                          targetMove.function == "UsedAfterUserTakesSpecialDamage" ||   # Masquerblade
                          targetMove.function == "BurnAttackerBeforeUserActs" ||     # Beak Blast
                          targetMove.function == "FrostbiteAttackerBeforeUserActs")   # Condensate
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is focusing!")) if show_message
            return true
        end
        if !GameData::Move.get(target.lastRegularMoveUsed).can_be_forced?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s last used move cant be instructed!"))
            end
            return true
        end
        if @battle.getBattleMoveInstanceFromID(target.lastRegularMoveUsed).is_a?(PokeBattle_TwoTurnMove)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s last used move is a two-turn move!"))
            end
            return true
        end
        idxMove = -1
        target.eachMoveWithIndex do |m, i|
            idxMove = i if m.id == target.lastRegularMoveUsed
        end
        if target.getMoves[idxMove].pp == 0 && target.getMoves[idxMove].total_pp > 0
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s last used move it out of PP!"))
            end
            return true
        end
        return false
    end

    def pbFailsAgainstTargetAI?(user, target)
        return false if user.pbSpeed(true) < target.pbSpeed(true) # Assume target will actually use a move
        return pbFailsAgainstTarget?(user, target, false)
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Instruct)
    end

    def getEffectScore(_user, _target)
        return 130 # Score assumes you put Instruct on the team for a reason, do not put Instruct on a team without really thinking about it
    end
end

#===============================================================================
# Target is forced to use this Pokemon's first move slot. (Hivemind)
#===============================================================================
class PokeBattle_Move_TargetUsesMoveInUserFirstSlot < PokeBattle_Move
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
# Two turn attack. Skips first turn, and transforms the user into their second form
# on the 2nd turn. Only ampharos can use it. (Transcendant Energy)
#===============================================================================
class PokeBattle_Move_TwoTurnChangeUserAmpharosForm < PokeBattle_TwoTurnMove
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:AMPHAROS)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        elsif user.form != 0
            @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} is radiating energy!", user.pbThis))
    end

    def pbEffectGeneral(user)
        return unless @damagingTurn
        user.pbChangeForm(1, _INTL("{1} transcended its limits and transformed!", user.pbThis))
    end

    def getEffectScore(user, _target)
        score = super
        score += 100
        score += 50 if user.firstTurn?
        return score
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @chargingTurn && !@damagingTurn
            @battle.pbCommonAnimation("StatUp", user)
        else
            @battle.pbCommonAnimation("MegaEvolution", user)
            super
        end
    end
end

#===============================================================================
# Transforms the user into one of its forms. (Mutate)
#===============================================================================
class PokeBattle_Move_ChangeUserDeoxusChoiceOfForm < PokeBattle_Move
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
# User switches places with its ally. (Ally Switch)
#===============================================================================
class PokeBattle_Move_UserSwapsPositionsWithAlly < PokeBattle_Move
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
# Allies of the user also attack the target with Slash. (All For One)
#===============================================================================
class PokeBattle_Move_AlliesAlsoUseSlashAgainstTarget < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        user.eachAlly do |b|
            break if target.fainted?
            @battle.pbDisplay(_INTL("{1} joins in the attack!", b.pbThis))
            battle.forceUseMove(b, :SLASH, target.index)
        end
    end
end

#===============================================================================
# Can't miss if attacking a target that already used an attack this turn. (Power Whip)
#===============================================================================
class PokeBattle_Move_CantMissAgainstTargetAlreadyAttacked < PokeBattle_Move
    def pbAccuracyCheck(user, target)
        targetChoice = @battle.choices[target.index][0]
        return true if targetChoice == :UseMove && target.movedThisRound?
        return super
    end
end

def selfHitBasePower(level)
    calcLevel = [level, 50].min
    selfHitBasePower = (20 + calcLevel)
    selfHitBasePower = selfHitBasePower.ceil
    return selfHitBasePower
end

#===============================================================================
# Increases the target's Attack by 3 steps, then the target hits itself with its own attack. (Swagger)
#===============================================================================
class PokeBattle_Move_RaiseTargetAtk3TargetHitsSelfPhysical < PokeBattle_Move
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
class PokeBattle_Move_RaiseTargetSpAtk3TargetHitsSelfSpecial < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        target.tryRaiseStat(:SPECIAL_ATTACK, user, increment: 3, move: self)
        target.pbConfusionDamage(_INTL("It hurt itself in mental turmoil!"), true, false, selfHitBasePower(target.level))
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
# The user takes 33% less damage until end of this turn.
# (Shimmering Heat)
#===============================================================================
class PokeBattle_Move_UserTakesThirdLessDamageThisTurn < PokeBattle_Move
    def pbEffectAfterAllHits(user, _target)
        user.applyEffect(:ShimmeringHeat)
    end

    def getEffectScore(user, target)
        return getWantsToBeFasterScore(user, target, 3)
    end
end

#===============================================================================
# Faints the opponant if they are below 1/4 HP, after dealing damage. (Cull)
#===============================================================================
class PokeBattle_Move_FaintsTargetBelowQuarterOfTotalHP < PokeBattle_Move
    def canCull?(target)
        return target.hp < (target.totalhp / 4)
    end

    def pbEffectAgainstTarget(user, target)
        if canCull?(target)
            @battle.pbDisplay(_INTL("#{user.pbThis} culls #{target.pbThis(true)}!"))
            target.pbReduceHP(target.hp, false)
            target.pbItemHPHealCheck
        end
    end

    def shouldHighlight?(_user, target)
        return canCull?(target)
    end
end

#===============================================================================
# The user, if a Deerling or Sawsbuck, changes their form in season order. (Season's End)
#===============================================================================
class PokeBattle_Move_ChangeUserDeerlingSawsbuckForm < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:DEERLING) || user.countsAs?(:SAWSBUCK)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        if user.countsAs?(:DEERLING) || user.countsAs?(:SAWSBUCK)
            newForm = (user.form + 1) % 4
            formChangeMessage = _INTL("The season shifts!")
            user.pbChangeForm(newForm, formChangeMessage)
        end
    end
end

########################################################
### Specific avatar only moves
########################################################

#===============================================================================
# Targets struck lose their flinch immunity. Only usable by the avatar of Rayquaza (Stratosphere Scream)
#===============================================================================
class PokeBattle_Move_RayquazaTargetLosesFlinchImmunity < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:RAYQUAZA) || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectAfterAllHits(_user, target)
        return if target.fainted?
        return if target.damageState.unaffected
        if target.effectActive?(:FlinchImmunity)
            target.disableEffect(:FlinchImmunity)
            @battle.pbDisplay(_INTL("#{target.pbThis} is newly afraid. It can be flinched again!"))
        end
    end
end

#===============================================================================
# Summons an Avatar of Luvdisc and an Avatar of Remoraid.
# Only usable by the avatar of Kyogre (Seven Seas Edict)
#===============================================================================
class PokeBattle_Move_KyogreSummonAvatarLuvdiscRemoraid < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:KYOGRE)# || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        unless @battle.pbSideSize(user.index) == 1
            @battle.pbDisplay(_INTL("But there is no room for fish to join!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("Fish are drawn to the field!", user.pbThis))
        @battle.summonAvatarBattler(:LUVDISC, user.level, 0, user.index % 2)
        @battle.summonAvatarBattler(:REMORAID, user.level, 0, user.index % 2)
        @battle.pbSwapBattlers(user.index, user.index + 2)
    end
end

#===============================================================================
# Summons Gravity for 10 turn and doubles the weight of Pokemon on the opposing side.
# Only usable by the avatar of Groudon (Warping Core)
#===============================================================================
class PokeBattle_Move_GroudonStartGravity10DoubleFoeWeight < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:GROUDON) || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        if @battle.field.effectActive?(:Gravity)
            @battle.pbDisplay(_INTL("But gravity is already warped!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.field.applyEffect(:Gravity, 5)
        @battle.eachOtherSideBattler(user) do |b|
            b.applyEffect(:WarpingCore)
        end
    end
end

#===============================================================================
# All Normal-type moves become Electric-type for the rest of the round.
# (Ion Deluge, Plasma Fists)
#===============================================================================
class PokeBattle_Move_NormalMovesBecomeElectric < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if @battle.field.effectActive?(:IonDeluge)
            @battle.pbDisplay(_INTL("But it failed, since ions already shower the field!")) if show_message
            return true
        end
        return true if pbMoveFailedLastInRound?(user, show_message)
        return false
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:IonDeluge)
    end
end

#===============================================================================
# Accuracy perfect in moonglow. (Nightfelling)
#===============================================================================
class PokeBattle_Move_CantMissIfInMoonglow < PokeBattle_Move
    def pbBaseAccuracy(user, target)
        return 0 if @battle.moonGlowing?
        return super
    end

    def shouldHighlight?(_user, _target)
        return @battle.moonGlowing?
    end
end

#===============================================================================
# The user chooses one of Fire Fang, Ice Fang, and Thunder Fang to use. (Elemental Fang)
#===============================================================================
class PokeBattle_Move_UseChoiceOf3ElementalFangs < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @validMoves = %i[
            FIREFANG
            THUNDERFANG
            ICEFANG
        ]
    end

    def resolutionChoice(user)
        validMoveNames = []
        @validMoves.each do |move|
            validMoveNames.push(getMoveName(move))
        end

        if @battle.autoTesting
            @chosenMove = @validMoves.sample
        elsif !user.pbOwnedByPlayer? # Trainer AI
            @chosenMove = @validMoves[0]
        else
            chosenIndex = @battle.scene.pbShowCommands(_INTL("Which move should #{user.pbThis(true)} use?"),validMoveNames,0)
            @chosenMove = @validMoves[chosenIndex]
        end
    end

    def pbEffectAgainstTarget(user, target)
        user.pbUseMoveSimple(@chosenMove, target.index) if @chosenMove
    end

    def resetMoveUsageState
        @chosenMove = nil
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        return # No animation
    end
end