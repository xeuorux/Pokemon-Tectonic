class PokeBattle_Battler
    def ownersPolicies
        return [] if pbOwnedByPlayer?
        return owner.policies if owner
        return []
    end

    ###############################################################################
    # Understanding the battler's moves
    ###############################################################################

    def hasPhysicalAttack?
        eachMove do |m|
            next unless m.physicalMove?(m.type)
            return true
        end
        return false
    end

    def hasSpecialAttack?
        eachMove do |m|
            next unless m.specialMove?(m.type)
            return true
        end
        return false
    end

    def hasDamagingAttack?
        eachMove do |m|
            next unless m.damagingMove?
            return true
        end
        return false
    end

    def hasStatusMove?
        eachMove do |m|
            next unless m.statusMove?
            return true
        end
        return false
    end

    def hasSleepAttack?
        eachMove do |m|
            battleMove = @battle.getBattleMoveInstanceFromID(m.id)
            next unless battleMove.usableWhenAsleep?
            return true
        end
        return false
    end

    def hasSoundMove?
        eachMove do |m|
            next unless m.soundMove?
            return true
        end
        return false
    end

    def hasStatusPunishMove?
        return pbHasMoveFunction?("07F") # Hex, Cruelty
    end

    def hasHealingMove?
        eachMove do |m|
            battleMove = @battle.getBattleMoveInstanceFromID(m.id)
            next unless battleMove.healingMove?
            return true
        end
        return false
    end

    def hasInaccurateMove?
        eachMove do |m|
            next unless m.accuracy <= 85
            return true
        end
        return false
    end

    def hasLowAccuracyMove?
        eachMove do |m|
            next unless m.accuracy <= 65
            return true
        end
        return false
    end

    def hasHighCritAttack?
        eachMove do |m|
            next unless m.highCriticalRate?
            return true
        end
        return false
    end

    def pbHasAttackingType?(check_type)
        return false unless check_type
        check_type = GameData::Type.get(check_type).id
        eachMove { |m| return true if m.type == check_type && m.damagingMove? }
        return false
    end

    def hasForceSwitchMove?
        eachMove do |m|
            next unless m.forceSwitchMove?
            return true
        end
        return false
    end

    def canChooseProtect?
        eachMoveWithIndex do |move, i|
            next unless move.is_a?(PokeBattle_ProtectMove)
            next unless @battle.pbCanChooseMove?(index, i, false)
            next if @battle.battleAI.aiPredictsFailure?(move, self, self)
            return true
        end
        return false
    end

    def canChooseFullSpreadMove?(categoryOnly = -1)
        eachMoveWithIndex do |move, i|
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

    def aiSeesAbility
        @battle.aiSeesAbility(self)
    end

    def ignoreAbilityInAI?(aiChecking)
        return false unless aiChecking
        return aiKnowsAbility?
    end

    def aiKnowsAbility?
        return false if effectActive?(:Illusion) && pbOwnedByPlayer?
        return @battle.aiKnowsAbility?(@pokemon)
    end

    # A helper method that diverts to an AI-based check or a true calculation check as appropriate
    def shouldAbilityApply?(check_ability, checkingForAI)
        if checkingForAI
            return hasActiveAbilityAI?(check_ability)
        else
            return hasActiveAbility?(check_ability)
        end
    end

    # An ability check method that is fooled by Illusion
    # May in the future be extended to having the AI be ignorant about the player's abilities until they are revealed
    def hasActiveAbilityAI?(check_ability, ignore_fainted = false)
        return false if aiKnowsAbility?
        return hasActiveAbility?(check_ability, ignore_fainted)
    end

    ###############################################################################
    # Understanding the battler's type
    ###############################################################################

    # Returns the active types of this Pokémon. The array should not include the
    # same type more than once, and should not include any invalid type numbers (e.g. -1).
    # is fooled by Illusion
    def pbTypesAI(withType3 = false)
        if illusion? && pbOwnedByPlayer?
            ret = [disguisedAs.type1]
            ret.push(disguisedAs.type2) if disguisedAs.type2 != disguisedAs.type1
        else
            ret = [@type1]
            ret.push(@type2) if @type2 != @type1
        end
        # Burn Up erases the Fire-type.
        ret.delete(:FIRE) if effectActive?(:BurnUp)
        # Roost erases the Flying-type. If there are no types left, adds the Normal-
        # type.
        if effectActive?(:Roost)
            ret.delete(:FLYING)
            ret.push(:NORMAL) if ret.length == 0
        end
        # Add the third type specially.
        ret.push(@effects[:Type3]) if withType3 && effectActive?(:Type3) && !ret.include?(@effects[:Type3])
        return ret
    end

    def shouldTypeApply?(type, checkingForAI)
        if checkingForAI
            return pbHasTypeAI?(type)
        else
            return pbHasType?(type)
        end
    end

    def pbHasTypeAI?(type)
        return false unless type
        activeTypes = pbTypesAI(true)
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
