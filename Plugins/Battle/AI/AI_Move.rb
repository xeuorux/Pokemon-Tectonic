class PokeBattle_AI
    def pbChooseMoves(idxBattler)
        user        = @battle.battlers[idxBattler]
        wildBattler = (@battle.wildBattle? && @battle.opposes?(idxBattler))
        skill       = 0
        policies    = []
        if !wildBattler
            owner = @battle.pbGetOwnerFromBattlerIndex(user.index)
            skill  = owner.skill_level || 0
            policies = owner.policies || []
        end
        # Get scores and targets for each move
        # NOTE: A move is only added to the choices array if it has a non-zero
        #       score.
        choices     = []
        user.eachMoveWithIndex do |_m,i|
          next if !@battle.pbCanChooseMove?(idxBattler,i,false)
          if wildBattler
            pbRegisterMoveWild(user,i,choices)
          else
            newChoice = pbEvaluateMoveTrainer(user,user.moves[i],skill,policies)
                choices.push([i].concat(newChoice)) if newChoice
          end
        end
        # Figure out useful information about the choices
        totalScore = 0
        maxScore   = 0
        choices.each do |c|
          totalScore += c[1]
          maxScore = c[1] if maxScore<c[1]
        end
        # Log the available choices
        logMoveChoices(user,choices)
          
        if !wildBattler && maxScore <= 40 && pbEnemyShouldWithdrawEx?(idxBattler,2)
          if $INTERNAL
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will try to switch due to terrible moves")
          end
          return
        end
        
        # If there are valid choices, pick among them
        if choices.length > 0
            # Determine the most preferred move
            preferredChoice = nil
            if wildBattler
                preferredChoice = choices[pbAIRandom(choices.length)]
                PBDebug.log("[AI] #{user.pbThis} (#{user.index}) chooses #{user.moves[preferredChoice[0]].name} at random")
            else
                sortedChoices = choices.sort_by{|choice| -choice[1]}
                preferredChoice = sortedChoices[0]
                PBDebug.log("[AI] #{user.pbThis} (#{user.index}) thinks #{user.moves[preferredChoice[0]].name} is the highest rated choice")
            end
            if preferredChoice != nil
                @battle.pbRegisterMove(idxBattler,preferredChoice[0],false)
                @battle.pbRegisterTarget(idxBattler,preferredChoice[2]) if preferredChoice[2]>=0
            end
        else # If there are no calculated choices, create a list of the choices all scored the same, to be chosen between randomly later on
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) scored no moves above a zero, resetting all choices to default")
          user.eachMoveWithIndex do |m,i|
            next if !@battle.pbCanChooseMove?(idxBattler,i,false)
            next if m.empoweredMove?
            choices.push([i,100,-1])   # Move index, score, target
          end
          if choices.length == 0   # No moves are physically possible to use; use Struggle
            @battle.pbAutoChooseMove(user.index)
          end
        end
        # if there is somehow still no choice, randomly choose a move from the choices and register it
        if @battle.choices[idxBattler][2].nil?
          echoln("All AI protocols have failed or fallen through, picking at random.")
          randNum = pbAIRandom(totalScore)
          choices.each do |c|
            randNum -= c[1]
            next if randNum >= 0
            @battle.pbRegisterMove(idxBattler,c[0],false)
            @battle.pbRegisterTarget(idxBattler,c[2]) if c[2]>=0
            break
          end
        end
        # Log the result
        if @battle.choices[idxBattler][2]
          user.lastMoveChosen = @battle.choices[idxBattler][2].id
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
        end
        
        choice = @battle.choices[idxBattler]
        move = choice[2]
        target = choice[3]
    end
  
    #=============================================================================
    # Get scores for the given move against each possible target
    #=============================================================================
    # Wild Pokémon choose their moves randomly.
    def pbRegisterMoveWild(_user,idxMove,choices)
      choices.push([idxMove,100,-1])   # Move index, score, target
    end
end
  