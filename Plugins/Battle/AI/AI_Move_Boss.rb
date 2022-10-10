class PokeBattle_AI
    def pbChooseMovesBoss(idxBattler)
        user        = @battle.battlers[idxBattler]
        # Get scores and targets for each move
        # NOTE: A move is only added to the choices array if it has a non-zero
        #       score.
        choices     = []
        user.eachMoveWithIndex do |_m,i|
        if !@battle.pbCanChooseMove?(idxBattler,i,false)
            echoln("The boss can't choose: #{_m.name}")
            next
        end
            pbRegisterMoveBoss(user,i,choices)
        end
        logMoveChoices(user,choices)
        
        # If there are valid choices, pick among them
        if choices.length > 0
            # Determine the most preferred move
            preferredChoice = nil
            
            choices.reject!{|choice| choice[1] <= 0}

            # Seperate the choices that the boss specific AI picked out from the others
            empoweredDamagingChoices, choices = choices.partition {|choice| user.moves[choice[0]].isEmpowered?}
            guaranteedChoices, regularChoices = choices.partition {|choice| choice[1] >= 5000}

            if guaranteedChoices.length == 0
                if empoweredDamagingChoices.length > 0 && user.primevalTimer >= 2
                    preferredChoice = empoweredDamagingChoices[0]
                    user.primevalTimer = 0
                    PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use a primeval attacking move since there exists at least one, and the timer is high enough")
                else
                    if @battle.commandPhasesThisRound > 0 && !user.lastMoveChosen.nil? && regularChoices.length >= 2
                        targetingSize = user.indexesTargetedThisTurn.length
                        targetingSize = 2 if targetingSize > 2
                        regularChoices.reject!{|regular_choice| user.moves[regular_choice[0]].pbTarget(user).num_targets != targetingSize}
                        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will not use moves with a number of targets other than #{targetingSize}. It's left with the following:")
                        logMoveChoices(user,regularChoices)
                    end

                    if preferredChoice.nil?
                        if !user.lastMoveChosen.nil?
                            if regularChoices.length >= 2
                                regularChoices.reject!{|regular_choice| user.moves[regular_choice[0]].id == user.lastMoveChosen}
                                PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will try not to pick #{user.lastMoveChosen} this turn since that was the last move it chose")
                            else
                                PBDebug.log("[AI] #{user.pbThis} (#{user.index}) only has one valid choice, so it won't exclude #{user.lastMoveChosen} (its last chosen move)")
                            end
                        end
                        sortedChoices = regularChoices.sort_by{|choice| -choice[1]}
                        preferredChoice = sortedChoices[0]
                        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) thinks #{user.moves[preferredChoice[0]].name}" +
                        "is the highest rated of its remaining choices") if !preferredChoice.nil?
                    end
                end
            else
                preferredChoice = guaranteedChoices[0]
                PBDebug.log("[AI] #{user.pbThis} (#{user.index}) chooses #{user.moves[preferredChoice[0]].name}" +
                ", since is the first listed among its guaranteed moves") if !preferredChoice.nil?
            end

            if preferredChoice != nil
                @battle.pbRegisterMove(idxBattler,preferredChoice[0],false)
                @battle.pbRegisterTarget(idxBattler,preferredChoice[2]) if preferredChoice[2]>=0
            end
        end

        # if there is somehow still no choice, choose to use Struggle
        if @battle.choices[idxBattler][2].nil?
            echoln("All AI protocols have failed or fallen through, picking struggle since it's a boss.")
            @battle.choices[idxBattler][0] = :UseMove    # "Use move"
            @battle.choices[idxBattler][1] = -1          # Index of move to be used
            @battle.choices[idxBattler][2] = @battle.struggle   # Struggle PokeBattle_Move object
            @battle.choices[idxBattler][3] = -1          # No target chosen yet
        end

        choice = @battle.choices[idxBattler]
        move = choice[2]
        target = choice[3]

        # Log the result
        user.lastMoveChosen = move.id
        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{move.name}")

        targets = user.pbFindTargets(choice,move,user)
        
        
        singleTurnBigAttack = false
        if  move.damagingMove? && move.empowered?
            @battle.pbDisplay(_INTL("#{user.pbThis} is winding up a big attack!"))
            singleTurnBigAttack = true
        else
            user.resetExtraMovesPerTurn
            PokeBattle_AI.triggerBossDecidedOnMove(user.species,move,user,targets)

            if move.function == "0E0"
                singleTurnBigAttack = true
            end
        end

        extraAggro = false
        if singleTurnBigAttack
            extraAggro = true
            user.extraMovesPerTurn = 0
            user.primevalTimer = 0
        end

        if @battle.commandPhasesThisRound == 0
            user.indexesTargetedThisTurn = []
            # Set the avatar aggro cursors on the targets of the choice
            targets.each do |target|
                next if !target.opposes?(user)
                index = target.index
                @battle.scene.setAggroCursorOnIndex(index,extraAggro)

                user.indexesTargetedThisTurn.push(index)
            end
        end
    end

    def pbRegisterMoveBoss(user,idxMove,choices)
        move = user.moves[idxMove]
        # Never ever use empowered status moves normally
        if move.isEmpowered? && !move.damagingMove?
            echoln("Scoring #{move.name} a 0 due to it being an empowered status move.")
            return
        end 
    
        target_data = move.pbTarget(user)
        if target_data.num_targets > 1
            # If move affects multiple battlers and you don't choose a particular one
            totalScore = 0
            if move.damagingMove?
                targets = []
                @battle.eachBattler do |b|
                    next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
                    next if !user.opposes?(b)
                    targets.push(b)
                    score = pbGetMoveScoreBoss(move,user,b)
                    targetPercent = b.hp.to_f / b.totalhp.to_f
                    score = (score*(1.0 + 0.5 * targetPercent)).floor
                    totalScore += score
                end
                if targets.length() != 0
                    totalScore = totalScore / targets.length().to_f
                else
                    totalScore = 0
                end
            else
                totalScore = pbGetMoveScoreBoss(move,user,nil)
            end
            if totalScore > 0
                choices.push([idxMove,totalScore,-1])
            else
                echoln("Scoring #{move.name} a 0.")
            end
        elsif target_data.num_targets == 0
            # If move has no targets, affects the user, a side or the whole field
            score = pbGetMoveScoreBoss(move,user,user)
            choices.push([idxMove,score,-1])
        else
            # If move affects one battler and you have to choose which one
            scoresAndTargets = []
            @battle.eachBattler do |b|
                next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
                next if target_data.targets_foe && !user.opposes?(b)
                    
                score = pbGetMoveScoreBoss(move,user,b)
                if move.damagingMove?
                    targetPercent = b.hp.to_f / b.totalhp.to_f
                    score = (score*(1.0 + 0.5 * targetPercent)).floor
                end
                if score > 0
                    scoresAndTargets.push([score,b.index])
                else
                    echoln("Scoring #{move.name} a 0.")
                end
            end
            if scoresAndTargets.length >= 1
                chosenST = nil
                # Try to target the same pokemon as before in the same turn
                if scoresAndTargets.length >= 2 && @battle.commandPhasesThisRound >= 1
                    chosenST = scoresAndTargets.find { |scoreAndTarget| user.indexesTargetedThisTurn.include?(scoreAndTarget[1]) }
                end
        
                # Get the one best target for the move
                if chosenST.nil?
                    scoresAndTargets.sort! { |a,b| b[0] <=> a[0] }
                    chosenST = scoresAndTargets[0]
                end
        
                choices.push([idxMove,chosenST[0],chosenST[1]]) if !chosenST.nil?
            end
        end
    end
end