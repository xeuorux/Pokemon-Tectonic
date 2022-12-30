class PokeBattle_AI
    def pbChooseMovesBoss(idxBattler)
        user = @battle.battlers[idxBattler]
        bossAI = user.bossAI

        targetWeak = false

        if user.firstTurnThisRound?
            bossAggro = GameData::Avatar.get_from_pokemon(user).aggression
            bossAggro += 2 if user.hp < user.totalhp
            targetWeak = pbAIRandom(PokeBattle_AI_Boss::MAX_BOSS_AGGRESSION) < bossAggro
            if targetWeak
                PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) will value targeting low health targets this turn")
            else
                PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) will value targeting high health targets this turn")
            end
        end

        # Get scores and targets for each move
        # NOTE: A move is only added to the choices array if it has a non-zero
        #       score.
        choices = []
        targetingSizeLastRound = user.indicesTargetedLastRound.length
        targetingSizeLastRound = 2 if targetingSizeLastRound > 2
        PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) values moves with targeting size other than #{targetingSizeLastRound}")
        user.eachMoveWithIndex do |move, i|
            move.pp = move.total_pp if @battle.autoTesting
            unless @battle.pbCanChooseMove?(idxBattler, i, false)
                PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) can't choose: #{move.name}")
                next
            end
            newChoice = getChoiceForMoveBoss(user, i, choices, bossAI, targetWeak, targetingSizeLastRound)
            choices.push(newChoice) if newChoice
        end
        logMoveChoices(user, choices)

        # If there are valid choices, pick among them
        if choices.length > 0
            # Determine the most preferred move
            preferredChoice = nil

            choices.reject! { |choice| choice[1] <= 0 }

            # Seperate the choices that the boss specific AI picked out from the others
            empoweredDamagingChoices, choices = choices.partition { |choice| user.moves[choice[0]].empoweredMove? }
            guaranteedChoices, regularChoices = choices.partition { |choice| choice[1] >= 5000 }

            if guaranteedChoices.length > 1
                PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) has more than one guarenteed choices! THIS IS BAD")
            end

            empoweredDamagingChoices.reject! { |choice| user.primevalTimer < user.moves[choice[0]].turnsBetweenUses }

            if guaranteedChoices.length == 0
                if empoweredDamagingChoices.length > 0
                    preferredChoice = empoweredDamagingChoices[0]
                    user.primevalTimer = 0
                    PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) will use a primeval attacking move since there exists at least one, and the timer is high enough")
                else
                    # Disallow targeted moves that would target a different category than the moves used before in the turn
                    if !user.firstTurnThisRound? && regularChoices.length >= 2
                        targetingSize = user.indicesTargetedThisRound.length
                        targetingSize = 2 if targetingSize > 2
                        regularChoices.reject! do |regular_choice|
                            numTargets = user.moves[regular_choice[0]].pbTarget(user).num_targets
                            next false if numTargets == 0
                            next numTargets != targetingSize
                        end
                        PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) will not use moves with a number of targets other than #{targetingSize}. It's left with the following:")
                        logMoveChoices(user, regularChoices)
                    end

                    # Don't use the same move in a row if possible
                    unless user.lastMoveChosen.nil?
                        if regularChoices.length >= 2
                            regularChoices.reject! do |regular_choice|
                                user.moves[regular_choice[0]].id == user.lastMoveChosen
                            end
                            PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) will try not to pick #{user.lastMoveChosen} this turn since that was the last move it chose")
                        else
                            PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) only has one valid choice, so it won't exclude #{user.lastMoveChosen} (its last chosen move)")
                        end
                    end

                    # Sort the moves by their calculated score
                    sortedChoices = regularChoices.sort_by { |regularChoices| next -regularChoices[1] }

                    logMoveChoices(user, sortedChoices)

                    preferredChoice = sortedChoices[0]
                    unless preferredChoice.nil?
                        PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) chooses #{user.moves[preferredChoice[0]].name}" +
                            " since is the first listed among its remaining choices")
                    end
                end
            else
                preferredChoice = guaranteedChoices[0]
                unless preferredChoice.nil?
                    PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) chooses #{user.moves[preferredChoice[0]].name}" +
                        ", since is the first listed among its guaranteed moves")
                end
            end

            unless preferredChoice.nil?
                @battle.pbRegisterMove(idxBattler, preferredChoice[0], false)
                @battle.pbRegisterTarget(idxBattler, preferredChoice[2]) if preferredChoice[2] >= 0
            end
        end

        # if there is somehow still no choice, choose to use Struggle
        if @battle.choices[idxBattler][2].nil?
            PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) AI protocols have fallen through, trying to find a backup move")
            fallbackMove = bossAI.getFallbackMove
            if fallbackMove
                @battle.choices[idxBattler][0] = :UseMove    # "Use move"
                @battle.choices[idxBattler][1] = -1          # Index of move to be used
                @battle.choices[idxBattler][2] =
                    PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(fallbackMove))
                @battle.choices[idxBattler][3] = -1          # No target chosen yet
            end
        end

        # if there is somehow still no choice, choose to use Struggle
        if @battle.choices[idxBattler][2].nil?
            PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) AI protocols have failed, picking struggle")
            print _INTL("Boss using struggle!") if @battle.autoTesting
            @battle.choices[idxBattler][0] = :UseMove    # "Use move"
            @battle.choices[idxBattler][1] = -1          # Index of move to be used
            @battle.choices[idxBattler][2] = @battle.struggle # Struggle PokeBattle_Move object
            @battle.choices[idxBattler][3] = -1 # No target chosen yet
        end

        # Trigger things that happen after the boss has made a choice
        bossMovesChosen(user, @battle.choices[idxBattler], bossAI)
    end

    def bossMovesChosen(user, choice, bossAI)
        move = choice[2]
        target = choice[3]

        # Log the result
        user.lastMoveChosen = move.id
        PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) will use #{move.name} with target #{target}")

        targets = user.pbFindTargets(choice, move, user)

        # Determine which aggro cursor to use
        # And show warning messages
        empoweredAttack = false
        extraAggro = false

        if move.damagingMove? && move.empoweredMove?
            @battle.pbDisplayBossNarration(_INTL("#{user.pbThis} is winding up a big attack!"))
            empoweredAttack = true
        else
            user.resetExtraMovesPerTurn
            bossAI.decidedOnMove(move, user, targets, @battle)
        end

        if empoweredAttack || bossAI.moveIsDangerous?(move, user, targets, @battle)
            extraAggro = true
            user.primevalTimer = 0
        end

        user.extraMovesPerTurn = 0 if empoweredAttack || bossAI.takesUpWholeTurn?(move, user, targets, @battle)

        # Put the aggro cursors onto the right targets
        if @battle.commandPhasesThisRound == 0
            # Set the avatar aggro cursors on the targets of the choice
            targets.each do |target|
                next unless target.opposes?(user)
                index = target.index
                @battle.scene.setAggroCursorOnIndex(index, extraAggro)

                user.indicesTargetedThisRound.push(index)
            end
        end
    end

    def getChoiceForMoveBoss(user, idxMove, choices, bossAI, targetWeak = false, targetingSizeLastRound = -1)
        move = user.moves[idxMove]

        # Never ever use empowered status moves normally
        if move.empoweredMove? && !move.damagingMove?
            PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) scores #{move.name} a 0 due to it being an empowered status move.")
            return nil
        end

        choice = nil

        target_data = move.pbTarget(user)
        if target_data.num_targets > 1
            # If move affects multiple battlers and you don't choose a particular one
            totalScore = 0
            if move.damagingMove?
                targets = []
                @battle.eachBattler do |b|
                    next unless @battle.pbMoveCanTarget?(user.index, b.index, target_data)
                    next unless user.opposes?(b)
                    targets.push(b)
                    score = pbGetMoveScoreBoss(move, user, b, bossAI)
                    hpMod = 0.5 * b.hp.to_f / b.totalhp.to_f
                    hpMod *= -1 if targetWeak
                    score += hpMod
                    totalScore += score
                end
                if targets.length != 0
                    totalScore /= targets.length.to_f
                else
                    totalScore = 0
                end
            else
                totalScore = pbGetMoveScoreBoss(move, user, nil, bossAI)
            end
            totalScore = totalScore.round
            if totalScore > 0
                choice = [idxMove, totalScore, -1]
            else
                PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) scores #{move.name} a 0.")
            end
        elsif target_data.num_targets == 0
            # If move has no targets, affects the user, a side or the whole field
            score = pbGetMoveScoreBoss(move, user, user, bossAI)
            choices.push([idxMove, score, -1])
        else
            # If move affects one battler and you have to choose which one
            scoresAndTargets = []
            @battle.eachBattler do |b|
                next unless @battle.pbMoveCanTarget?(user.index, b.index, target_data)
                next if target_data.targets_foe && !user.opposes?(b)
                score = pbGetMoveScoreBoss(move, user, b, bossAI)
                if move.damagingMove?
                    hpMod = 50 * b.hp.to_f / b.totalhp.to_f
                    hpMod *= -1 if targetWeak
                    score += hpMod
                end
                score = score.round
                if score > 0
                    scoresAndTargets.push([score, b.index])
                else
                    PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) scores #{move.name} a 0.")
                end
            end
            if scoresAndTargets.length >= 1
                chosenST = nil
                # Try to target the same pokemon as before in the same turn
                if scoresAndTargets.length >= 2 && @battle.commandPhasesThisRound >= 1
                    chosenST = scoresAndTargets.find do |scoreAndTarget|
                        target = scoreAndTarget[1]
                        if user.indicesTargetedThisRound.include?(target)
                            PBDebug.log("[BOSS AI] #{user.pbThis} (#{user.index}) found a target for move #{move.name} which it previously targeted this turn (target #{target})")
                            next true
                        end
                        next false
                    end
                end

                # Get the one best target for the move
                if chosenST.nil?
                    scoresAndTargets.sort! { |a, b| b[0] <=> a[0] }
                    chosenST = scoresAndTargets[0]
                end

                choice = [idxMove, chosenST[0], chosenST[1]] if chosenST
            end
        end

        if choice
            moveForChoice = user.moves[choice[0]]
            numTargets = moveForChoice.pbTarget(user).num_targets

            # Value moves that have a different targeting size than last turn
            choice[1] += 30 if numTargets != 0 && numTargets != targetingSizeLastRound

            # Value moves that are STAB on the first turn of the battle or of a phase
            choice[1] += 30 if user.primevalTimer == 0 && user.pbHasType?(moveForChoice.type)
        end

        return choice
    end

    def addTargetIfPresent(string, target)
        string = "#{string} against target #{target.pbThis(true)}" if target.is_a?(PokeBattle_Battler)
        return string
    end

    def pbGetMoveScoreBoss(move, user, target, bossAI)
        score = 100

        if bossAI.rejectMove?(move, user, target, @battle)
            PBDebug.log(addTargetIfPresent(
                            "[BOSS AI] #{user.pbThis} (#{user.index}) custom AI rejects move #{move.name}", target))
            return 0
        end

        # Rejecting moves based on failure

        # Don't use a move that would fail against the target
        if !target.nil? && move.pbFailsAgainstTargetAI?(user, target)
            PBDebug.log("[BOSS AI] Scoring #{move.name} a 0 due to being predicted to fail against the target against target #{target.pbThis(true)}")
            return 0
        end

        # Don't use a move that would fail outright
        if move.pbMoveFailedAI?(user, [target])
            PBDebug.log("[BOSS AI] Scoring #{move.name} a 0 due to being predicted to fail entirely")
            return 0
        end

        if bossAI.requireMove?(move, user, target, @battle)
            PBDebug.log(addTargetIfPresent(
                            "[BOSS AI] #{user.pbThis} (#{user.index}) custom AI requires move #{move.name}", target))
            return 99_999
        end

        return score
    end
end
