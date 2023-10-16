class PokeBattle_Battler
    def ownersPolicies
        return [] if pbOwnedByPlayer?
        return owner.policies if owner
        return []
    end

    def inWeatherTeam
        policies = ownersPolicies
        %i[SUN_TEAM RAIN_TEAM SAND_TEAM HAIL_TEAM ECLIPSE_TEAM MOONGLOW_TEAM].each do |weatherPolicy|
            return true if policies.include?(weatherPolicy)
        end
        return false
    end

    # AI method to predict if user can act this turn
    def canActThisTurn?
        return false if effectActive?(:HyperBeam)
        return false if effectActive?(:Attached)
        return false if effectActive?(:Truant)
        return false if willStayAsleepAI?
        return true
    end

    # AI method to predict if the user will wake up before moving this turn
    def willStayAsleepAI?
        return asleep? && getStatusCount(:SLEEP) > 1
    end

    def getHealingEffectScore(healingAmount)
        healingScore = 0
        healingScore += healingAmount * pbDefense
        healingScore += healingAmount * pbSpDef
        healingScore /= (3 * level)
        healingPercentage = (100 * healingAmount / @totalhp.to_f).round(1)
        echoln("\t\t[EFFECT SCORING] #{pbThis} scores the value of healing #{healingAmount} HP (#{healingPercentage} percent) at #{healingScore}")
        return healingScore
    end
    
    def getSpeedTier # TODO: Merge this with pbSpeed
        speedTiers = [
            [0,0], # 0 / this should not happen
            [0,0], # 5 / this should not happen
            [23,33], # 10 / base 45 (0 investment) / base 60 (10 investment)
            [26,37], # 15 / base 45 (0 investment) / base 60 (10 investment)
            [35,48], # 20 / base 60 (0 investment) / base 75 (10 investment)
            [38,55], # 25 / base 60 (0 investment) / base 80 (10 investment)
            [41,63], # 30 / base 60 (0 investment) / base 85 (10 investment)
            [47,72], # 35 / base 65 (0 investment) / base 95 (10 investment)
            [54,84], # 40 / base 70 (0 investment) / base 100 (10 investment)
            [57,90], # 45 / base 70 (0 investment) / base 100 (10 investment)
            [61,97], # 50 / base 70 (0 investment) / base 100 (10 investment)
            [64,103], # 55 / base 70 (0 investment) / base 100 (10 investment)
            [68,109], # 60 / base 70 (0 investment) / base 100 (10 investment)
            [71,115], # 65 / base 70 (0 investment) / base 100 (10 investment)
            [75,122], # 70 / base 70 (0 investment) / base 100 (10 investment)
        ]
        tierCheck = speedTiers[(level / 5.0).ceil]
        effectiveSpeed = base_speed
        effectiveSpeed /= 2 if numbed? && !hasActiveAbility?(:NATURALCURE)
        effectiveSpeed * 1.4 if hasActiveItem?:CHOICESCARF
        effectiveSpeed * 1.1 if hasActiveItem?:SEVENLEAGUEBOOTS
        if effectiveSpeed >= tierCheck[1]
            return 2 # Fast
        elsif effectiveSpeed >= tierCheck[0]
            return 1 # Average
        else
            return 0 # Slow
        end
    end

    ###############################################################################
    # Understanding the battler's moves
    ###############################################################################

    def aiSeesMove(move)
        @battle.aiSeesMove(self,move)
    end

    def unknownMovesCountAI
        movesNotKnownByAICount = 4
        eachAIKnownMove do |_move|
            movesNotKnownByAICount -= 1
        end
        return movesNotKnownByAICount
    end

    def eachAIKnownMove
        return if effectActive?(:Illusion) && pbOwnedByPlayer? && !aiKnowsAbility?(:ILLUSION)
        knownMoveIDs = @battle.aiKnownMoves(@pokemon)
        getMoves.each do |move|
            next unless move
            next if pbOwnedByPlayer? && !knownMoveIDs.include?(move.id)
            yield move
        end
    end

    def eachAIKnownMoveWithIndex
        return if effectActive?(:Illusion) && pbOwnedByPlayer? && !aiKnowsAbility?(:ILLUSION)
        knownMoveIDs = @battle.aiKnownMoves(@pokemon)
        getMoves.each_with_index do |move, index|
            next unless move
            next if pbOwnedByPlayer? && !knownMoveIDs.include?(move.id)
            yield move, index
        end
    end

    def hasPhysicalAttack?
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

    def hasRecoveryMove?
        eachAIKnownMove do |m|
            battleMove = @battle.getBattleMoveInstanceFromID(m.id)
            next unless battleMove.healingMove? && m.category == 2
            return true
        end
        return false
    end

    def hasInaccurateMove?
        eachAIKnownMove do |m|
            next unless m.accuracy <= 85 && m.accuracy > 0 # Moves that always work are accuracy 0
            return true
        end
        return false
    end
    
    def hasMediumAccuracyMove?
        eachAIKnownMove do |m|
            next unless m.accuracy <= 75 && m.accuracy > 0 # Moves that always work are accuracy 0
            return true
        end
        return false
    end
    
    def hasLowAccuracyMove?
        eachAIKnownMove do |m|
            next unless m.accuracy <= 65 && m.accuracy > 0 # Moves that always work are accuracy 0
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

    def hasStatBoostingMove?
        eachAIKnownMove do |m|
            next unless m.is_a?(PokeBattle_MultiStatUpMove)
            return true
        end
        return false
    end

    def hasStatBoostStealingMove?
        eachAIKnownMove do |m|
            next unless m.statStepStealingMove?
            return true
        end
        return false
    end

    def hasHazardSettingMove?
        eachAIKnownMove do |m|
            next unless m.hazardMove?
            return true
        end
        return false
    end

    def hasHazardRemovalMove?
        eachAIKnownMove do |m|
            next unless m.hazardRemovalMove?
            return true
        end
        return false
    end
    
    def hasRedirectionMove?
        eachAIKnownMove do |m|
            next unless m.redirectionMove?
            return true
        end
        return false
    end

    def eachRedirectingAlly
        eachAlly do |b|
            next unless b.hasRedirectionMove?
            yield b
        end
    end

    def canChoosePursuit?(target)
        eachAIKnownMoveWithIndex do |move, i|
            next unless move.function == "088"
            next unless @battle.pbCanChooseMove?(index, i, false)
            next if @battle.battleAI.aiPredictsFailure?(move, self, target)
            return move
        end
        return nil
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

    def eachAbilityShouldApply(aiCheck)
        eachActiveAbility do |abilityID|
            next unless shouldAbilityApply?(abilityID, aiCheck)
            yield abilityID
        end
    end

    def ignoreAbilityInAI?(checkAbility,aiCheck)
        return false unless aiCheck
        return aiKnowsAbility?(checkAbility)
    end

    def aiKnowsAbility?(checkAbility)
        return true unless pbOwnedByPlayer?
        return true if hasActiveItem?(:FRAGILELOCKET)
        if checkAbility.is_a?(Array)
            checkAbility.each do |specificAbility|
                return true if @addedAbilities.include?(specificAbility)
            end
        else
            return true if @addedAbilities.include?(checkAbility)
        end
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
        allowIllusion = !aiKnowsAbility?(:ILLUSION)
        activeTypes = pbTypes(true, allowIllusion)
        return activeTypes.include?(GameData::Type.get(type).id)
    end

    ###############################################################################
    # Understanding the battler's opponents
    ###############################################################################

    def defensiveMatchupAI
        score,killInfoArray = @battle.battleAI.worstDefensiveMatchupAgainstActiveFoes(self)
        return score
    end

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
