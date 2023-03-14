class PokeBattle_AI
    def pbChooseMovesTrainer(idxBattler, choices)
        user = @battle.battlers[idxBattler]
        owner = @battle.pbGetOwnerFromBattlerIndex(user.index)
        policies = owner.policies || []

        # Log the available choices
        logMoveChoices(user, choices)

        # If there are valid choices, pick among them
        if choices.length > 0
            # Determine the most preferred move
            sortedChoices = choices.sort_by { |choice| -choice[1] }
            preferredChoice = sortedChoices[0]
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) thinks #{user.moves[preferredChoice[0]].name} is the highest rated choice")
            unless preferredChoice.nil?
                @battle.pbRegisterMove(idxBattler, preferredChoice[0], false)
                @battle.pbRegisterTarget(idxBattler, preferredChoice[2]) if preferredChoice[2] >= 0
            end
        else # If there are no calculated choices, create a list of the choices all scored the same, to be chosen between randomly later on
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) scored no moves above a zero, resetting all choices to default")
            user.eachMoveWithIndex do |m, i|
                next unless @battle.pbCanChooseMove?(idxBattler, i, false)
                next if m.empoweredMove?
                choices.push([i, 100, -1]) # Move index, score, target
            end
            if choices.length == 0 # No moves are physically possible to use; use Struggle
                @battle.pbAutoChooseMove(user.index)
            end
        end

        # if there is somehow still no choice, randomly choose a move from the choices and register it
        if @battle.choices[idxBattler][2].nil?
            echoln("All AI protocols have failed or fallen through, picking at random.")
            randomChoice = choices.sample
            @battle.pbRegisterMove(idxBattler, randomChoice[0], false)
            @battle.pbRegisterTarget(idxBattler, randomChoice[2]) if randomChoice[2] >= 0
        end

        # Log the result
        if @battle.choices[idxBattler][2]
            user.lastMoveChosen = @battle.choices[idxBattler][2].id
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
        end
    end

    # Returns an array filled with each move that has a target worth using against
    # Giving also the best target to use the move against and the score of doing so
    def pbGetBestTrainerMoveChoices(user, policies = [])
        choices = []
        user.eachMoveWithIndex do |_move, i|
            next unless @battle.pbCanChooseMove?(user.index, i, false)
            newChoice = pbEvaluateMoveTrainer(user, user.moves[i], policies)
            # Push a new array of [moveIndex,moveScore,targetIndex]
            # where targetIndex could be -1 for anything thats not single target
            choices.push([i].concat(newChoice)) if newChoice
        end
        return choices
    end

    def pbEvaluateMoveTrainer(user, move, policies = [])
        target_data = move.pbTarget(user)
        newChoice = nil
        if target_data.num_targets > 1
            # If move affects multiple battlers and you don't choose a particular one
            totalScore = 0
            targets = []
            @battle.eachBattler do |b|
                next unless @battle.pbMoveCanTarget?(user.index, b.index, target_data)
                targets.push(b)
            end
            targets.each do |b|
                score = pbGetMoveScore(move, user, b, policies, targets.length)
                totalScore += (user.opposes?(b) ? score : -score)
            end
            if targets.length > 1
                totalScore *= targets.length / (targets.length.to_f + 1.0)
                totalScore = totalScore.floor
            end
            newChoice = [totalScore, -1] if totalScore > 0
        elsif target_data.num_targets == 0
            # If move has no targets, affects the user, a side or the whole field
            score = pbGetMoveScore(move, user, user, policies, 0)
            newChoice = [score, -1] if score > 0
        else
            # If move affects one battler and you have to choose which one
            scoresAndTargets = []
            @battle.eachBattler do |b|
                next unless @battle.pbMoveCanTarget?(user.index, b.index, target_data)
                next if target_data.targets_foe && !user.opposes?(b)
                score = pbGetMoveScore(move, user, b, policies)
                scoresAndTargets.push([score, b.index]) if score > 0
            end
            if scoresAndTargets.length > 0
                # Get the one best target for the move
                scoresAndTargets.sort! { |a, b| b[0] <=> a[0] }
                newChoice = [scoresAndTargets[0][0], scoresAndTargets[0][1]]
            end
        end
        return newChoice
    end

    #=============================================================================
    # Get a score for the given move being used against the given target
    #=============================================================================
    def pbGetMoveScore(move, user, target, policies = [], numTargets = 1)
        move.calculated_category = move.calculateCategory(user, [target])
        move.calcType = move.pbCalcType(user)

        return 0 if aiPredictsFailure?(move, user, target)

        effectScore = pbGetMoveScoreFunctionCode(0, move, user, target, policies)

        if effectScore.nil?
            echoln("ERROR! #{user.pbThis} unable to score #{move.id} against target #{target.pbThis(false)}. Assuming an effect score of 0.")
            effectScore = 0
        end

        # Account for some abilities
        score = getAdditiveAbilityScore(score, move, user, target)

        # Adjust score based on how much damage it can deal
        if move.damagingMove?
            begin
                score = pbGetMoveScoreDamage(effectScore, move, user, target, numTargets)
            rescue StandardError => exception
                pbPrintException($!) if $DEBUG
            end
            score *= 0.75 if policies.include?(:DISLIKEATTACKING)
        else
            score = effectScore
        end

        # All score changes from this point forward must be multiplicative!!

        # Don't prefer targeting the target if they'd be semi-invulnerable
        if move.accuracy > 0 && (target.semiInvulnerable? || target.effectActive?(:SkyDrop))
            echoln("#{user.pbThis} scores the move #{move.id} differently against target #{target.pbThis(false)} due to the target being semi-invulnerable.")
            canHitAnyways = false
            # Knows what can get past semi-invulnerability
            if target.effectActive?(:SkyDrop)
                canHitAnyways = true if move.hitsFlyingTargets?
            elsif target.inTwoTurnAttack?("0C9", "0CC", "0CE")
                canHitAnyways = true if move.hitsFlyingTargets? # Fly, Bounce, Sky Drop
            elsif target.inTwoTurnAttack?("0CA")          # Dig
                canHitAnyways = true if move.hitsDiggingTargets?
            elsif target.inTwoTurnAttack?("0CB")          # Dive
                canHitAnyways = true if move.hitsDivingTargets?
            end
            canHitAnyways = true if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)

            if user.pbSpeed(true) > target.pbSpeed(true)
                if canHitAnyways
                    score *= 2
                else
                    score = 0
                end
            else
                score /= 2
            end
        end

        # Pick a good move for the Choice items
        if user.hasActiveItem?(CHOICE_LOCKING_ITEMS) || user.hasActiveAbilityAI?(CHOICE_LOCKING_ABILITIES)
            echoln("#{user.pbThis} scores the move #{move.id} differently due to choice locking.")
            if move.damagingMove?
                score *= 1.5
            else
                score /= 2
            end
        end

        # Account for accuracy of move
        accuracy = pbRoughAccuracy(move, user, target)
        score *= accuracy / 100.0

        if accuracy < 100
            echoln("#{user.pbThis} predicts the move #{move.id} against target #{target.pbThis(false)} will have an accuracy of #{accuracy}")
        end

        # Account for the value of priority
        movePrio = @battle.getMovePriority(move, user, [target], true)
        unless @battle.aiPredictsSwitch?(user,target.index,true) # Priority doesn't matter if they are switching out
            if target.pbSpeed(true) > user.pbSpeed(true) && movePrio > 0
                echoln("#{user.pbThis} scores the move #{move.id} higher since its positive priority (#{movePrio}) when normally would be slower")
                score *= 1.5
            elsif target.pbSpeed(true) < user.pbSpeed(true) && movePrio < 0
                echoln("#{user.pbThis} scores the move #{move.id} lower since its negative priority (#{movePrio}) when normally would be faster")
                score *= 0.66
            end
        end

        # Account for some abilities
        score = getMultiplicativeAbilityScore(score, move, user, target)

        # Final adjustments t score
        score = score.to_i
        score = 0 if score < 0
        echoln("#{user.pbThis} scores the move #{move.id} against target #{target.pbThis(false)}: #{score}")
        return score
    end

    # TODO
    # Method that accounts for the target having triggered abilities on hit
    # And similar contingencies
    def getAdditiveAbilityScore(score, move, user, target)
        return score
    end

    def getMultiplicativeAbilityScore(score, move, user, target)
        if move.danceMove?
            dancerBonus = 1.0
            user.eachOther do |b|
                next unless b.hasActiveAbilityAI?(:DANCER)
                if b.opposes?(user)
                    dancerBonus -= 0.8
                else
                    dancerBonus += 0.8
                end
            end
            score *= dancerBonus
        end

        if move.soundMove?
            dancerBonus = 1.0
            user.eachOther do |b|
                next unless b.hasActiveAbilityAI?(:ECHO)
                if b.opposes?(user)
                    dancerBonus -= 0.8
                else
                    dancerBonus += 0.8
                end
            end
            score *= dancerBonus
        end

        return score
    end

    def aiPredictsFailure?(move, user, target)
        fails = false

        if user.effectActive?(:Flinch) && !user.effectActive?(:FlinchImmunity)
            echoln("#{user.pbThis} rejects the move #{move.id} due to it being predicted to flinch (Moonglow?)")
            return true
        end

        # Falsify the turn count so that the AI is calculated as though we are actually
        # in the midst of performing the move (turnCount is incremented as the attack phase begins)
        user.turnCount += 1

        if move.pbMoveFailedAI?(user, [target])
            fails = true
            echoln("#{user.pbThis} rejects the move #{move.id} due to it being predicted to fail.")
        end

        # Don't prefer moves that are ineffective because of abilities or effects
        type = pbRoughType(move, user)
        typeMod = pbCalcTypeModAI(type, user, target, move)
        unless user.pbSuccessCheckAgainstTarget(move, user, target, typeMod, false, true)
            fails = true
            echoln("#{user.pbThis} rejects the move #{move.id} due to it being predicted to fail or be ineffective against target #{target.pbThis(false)}.")
        end

        user.turnCount -= 1

        return fails
    end

    #=============================================================================
    # Add to a move's score based on how much damage it will deal (as a percentage
    # of the target's current HP)
    #=============================================================================
    def pbGetMoveScoreDamage(effectScore, move, user, target, numTargets = 1)
        damagePercentage = getDamagePercentageAI(move, user, target, numTargets)

        # Adjust score
        if damagePercentage >= 100 # Prefer lethal damage
            damagePercentage = 200
            damagePercentage = 300 if move.hasKOEffect?(user, target)
        end

        if move.effectChance != 0 && move.effectChance != 100
            type = pbRoughType(move, user)
            realProcChance = move.pbAdditionalEffectChance(user, target, type)
            factor = (realProcChance / 100.0)
            echoln("#{user.pbThis} multiplies #{move.id}'s effect score of #{effectScore} by a factor of #{factor} based on its predicted additional effect chance (against target #{target.pbThis(false)})")
            effectScore *= factor
        end

        damageScore = (damagePercentage * 2.0).to_i
        echoln("#{user.pbThis} gives #{move.id} an effect score of #{effectScore} and a damage score of #{damageScore} (against target #{target.pbThis(false)})")

        return effectScore + damageScore
    end

    def getDamagePercentageAI(move, user, target, numTargets = 1)
        # Calculate how much damage the move will do (roughly)
        realDamage = pbTotalDamageAI(move, user, target, numTargets)

        # Convert damage to percentage of target's remaining HP
        damagePercentage = realDamage * 100.0 / target.hp

        echoln("#{user.pbThis} thinks that move #{move.id} will deal #{realDamage} damage -- #{damagePercentage.round(1)} percent of #{target.pbThis(false)}'s HP")

        return damagePercentage
    end
end
