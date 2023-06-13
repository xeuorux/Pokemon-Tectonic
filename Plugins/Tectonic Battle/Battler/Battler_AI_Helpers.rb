class PokeBattle_Battler
    def ownersPolicies
        return [] if pbOwnedByPlayer?
        return owner.policies if owner
        return []
    end

    ###############################################################################
    # Understanding the battler's moves
    ###############################################################################

    def aiSeesMove(move)
        @battle.aiSeesMove(self,move)
    end

    def eachAIKnownMove
        return if effectActive?(:Illusion) && pbOwnedByPlayer?
        knownMoveIDs = @battle.aiKnownMoves(@pokemon)
        @moves.each do |move|
            next if pbOwnedByPlayer? && !knownMoveIDs.include?(move.id)
            yield move
        end
    end

    def eachAIKnownMoveWithIndex
        return if effectActive?(:Illusion) && pbOwnedByPlayer?
        knownMoveIDs = @battle.aiKnownMoves(@pokemon)
        @moves.each_with_index do |move, index|
            next if pbOwnedByPlayer? && !knownMoveIDs.include?(move.id)
            yield move, index
        end
    end

    def hasPhysicalAttack?(aiChecking = false)
        eachAIKnownMove do |m|
            next unless m.physicalMove?(m.type)
            return true
        end
        return false
    end

    def hasSpecialAttack?
        eachAIKnownMove do |m|
            next unless m.specialMove?(m.type)
            return true
        end
        return false
    end

    def hasDamagingAttack?
        eachAIKnownMove do |m|
            next unless m.damagingMove?(true)
            return true
        end
        return false
    end

    def hasStatusMove?
        eachAIKnownMove do |m|
            next unless m.statusMove?
            return true
        end
        return false
    end

    def hasSleepAttack?
        eachAIKnownMove do |m|
            battleMove = @battle.getBattleMoveInstanceFromID(m.id)
            next unless battleMove.usableWhenAsleep?
            return true
        end
        return false
    end

    def hasSoundMove?
        eachAIKnownMove do |m|
            next unless m.soundMove?
            return true
        end
        return false
    end

    def hasStatusPunishMove?
        return pbHasMoveFunction?("07F") # Hex, Cruelty
    end

    def hasHealingMove?
        eachAIKnownMove do |m|
            battleMove = @battle.getBattleMoveInstanceFromID(m.id)
            next unless battleMove.healingMove?
            return true
        end
        return false
    end

    def hasInaccurateMove?
        eachAIKnownMove do |m|
            next unless m.accuracy <= 85
            return true
        end
        return false
    end

    def hasLowAccuracyMove?
        eachAIKnownMove do |m|
            next unless m.accuracy <= 65
            return true
        end
        return false
    end

    def hasHighCritAttack?
        eachAIKnownMove do |m|
            next unless m.highCriticalRate?
            return true
        end
        return false
    end

    def pbHasAttackingType?(check_type)
        return false unless check_type
        check_type = GameData::Type.get(check_type).id
        eachAIKnownMove do |m|
            return true if m.type == check_type && m.damagingMove?(true)
        end
        return false
    end

    def hasOffTypeMove?
        eachAIKnownMove do |m|
            next if pbHasTypeAI?(m.type)
            return true
        end
        return false
    end

    def hasForceSwitchMove?
        eachAIKnownMove do |m|
            next unless m.forceSwitchMove?
            return true
        end
        return false
    end

    def canChooseProtect?
        eachAIKnownMoveWithIndex do |move, i|
            next unless move.is_a?(PokeBattle_ProtectMove)
            next unless @battle.pbCanChooseMove?(index, i, false)
            next if @battle.battleAI.aiPredictsFailure?(move, self, self)
            return true
        end
        return false
    end

    def canChooseFullSpreadMove?(categoryOnly = -1)
        eachAIKnownMoveWithIndex do |move, i|
            next if categoryOnly == 0 && !move.physicalMove?
            next if categoryOnly == 1 && !move.specialMove?
            next if categoryOnly == 2 && !move.statusMove?
            next unless @battle.pbCanChooseMove?(index, i, false)
            target_data = move.pbTarget(self)
            next unless target_data.id == :AllNearOthers
            return true
        end
        return false
    end

    ###############################################################################
    # Understanding the battler's allies and party.
    ###############################################################################

    def hasAlly?
        eachAlly do |_b|
            return true
        end
        return false
    end

    def alliesInReserveCount
        return @battle.pbAbleNonActiveCount(idxOwnSide)
    end

    def alliesInReserve?
        return alliesInReserveCount != 0
    end

    def enemiesInReserveCount
        return @battle.pbAbleNonActiveCount(idxOpposingSide)
    end

    def enemiesInReserve?
        return enemiesInReserveCount != 0
    end

    ###############################################################################
    # Understanding the battler's ability
    ###############################################################################

    def aiLearnsAbility(abilityID)
        @battle.aiLearnsAbility(self,abilityID)
    end

    def eachAIKnownActiveAbility
        eachActiveAbility do |abilityID|
            next unless aiKnowsAbility?(abilityID)
            yield abilityID
        end
    end

    def eachAbilityShouldApply(aiChecking)
        eachActiveAbility do |abilityID|
            next unless shouldAbilityApply?(abilityID, aiChecking)
            yield abilityID
        end
    end

    def ignoreAbilityInAI?(checkAbility,aiChecking)
        return false unless aiChecking
        return aiKnowsAbility?(checkAbility)
    end

    def aiKnowsAbility?(checkAbility)
        return true unless pbOwnedByPlayer?
        return false if effectActive?(:Illusion)
        return true if @addedAbilities.include?(checkAbility)
        return @battle.aiKnowsAbility?(@pokemon,checkAbility)
    end

    # A helper method that diverts to an AI-based check or a true calculation check as appropriate
    def shouldAbilityApply?(checkAbility, checkingForAI)
        if checkingForAI
            return hasActiveAbilityAI?(checkAbility)
        else
            return hasActiveAbility?(checkAbility)
        end
    end

    def hasActiveAbilityAI?(checkAbility, ignore_fainted = false)
        return false unless aiKnowsAbility?(checkAbility)
        return hasActiveAbility?(checkAbility, ignore_fainted)
    end

    ###############################################################################
    # Understanding the battler's type
    ###############################################################################

    def shouldTypeApply?(type, checkingForAI)
        if checkingForAI
            return pbHasTypeAI?(type)
        else
            return pbHasType?(type)
        end
    end

    def pbHasTypeAI?(type)
        return false unless type
        activeTypes = pbTypes(true, true)
        return activeTypes.include?(GameData::Type.get(type).id)
    end

    ###############################################################################
    # Understanding the battler's opponents
    ###############################################################################

    def eachPotentialAttacker(categoryOnly = -1)
        eachOpposing(true) do |b|
            next unless b.canActThisTurn?
            next if categoryOnly == 0 && !b.hasPhysicalAttack?
            next if categoryOnly == 1 && !b.hasSpecialAttack?
            next if categoryOnly == 2 && !b.hasStatusMove?
            yield b
        end
    end

    def eachPredictedAttacker(categoryOnly = -1)
        eachPotentialAttacker(categoryOnly) do |b|
            next unless @battle.aiPredictsAttack?(self,b.index,true,categoryOnly)
            yield b
        end
    end

    def eachPredictedTargeter(categoryOnly = -1)
        eachPotentialAttacker(categoryOnly) do |b|
            next unless @battle.aiPredictsAttack?(self,b.index,true,categoryOnly) ||
                        @battle.aiPredictsStatus?(self,b.index,true)
            yield b
        end
    end

    def eachPredictedProtectHitter(categoryOnly = -1)
        eachPredictedTargeter(categoryOnly) do |b|
            next if b.inTwoTurnAttack?("0CD")
            yield b
        end

        if ownersPolicies.include?(:EQ_PROTECT)
            eachAlly(true) do |b|
                next unless b.canChooseFullSpreadMove?(categoryOnly)
                yield b
            end
        end
    end
end
