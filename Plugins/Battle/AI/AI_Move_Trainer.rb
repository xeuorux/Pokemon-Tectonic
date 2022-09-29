class PokeBattle_AI
    # Trainer Pokémon calculate how much they want to use each of their moves.
    def pbEvaluateMoveTrainer(user,move,skill,policies=[])
        target_data = move.pbTarget(user)
        newChoice = nil
        if target_data.num_targets > 1
            # If move affects multiple battlers and you don't choose a particular one
            totalScore = 0
            targets = []
            @battle.eachBattler do |b|
                next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
                targets.push(b)
                score = pbGetMoveScore(move,user,b,skill,policies)
                totalScore += ((user.opposes?(b)) ? score : -score)
            end
            if targets.length > 1
                totalScore *= targets.length / (targets.length.to_f + 1.0)
                totalScore = totalScore.floor
            end
            newChoice = [totalScore,-1] if totalScore>0
        elsif target_data.num_targets == 0
            # If move has no targets, affects the user, a side or the whole field
            score = pbGetMoveScore(move,user,user,skill,policies)
            newChoice = [score,-1] if score>0
        else
            # If move affects one battler and you have to choose which one
            scoresAndTargets = []
            @battle.eachBattler do |b|
                next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
                next if target_data.targets_foe && !user.opposes?(b)
                score = pbGetMoveScore(move,user,b,skill,policies)
                scoresAndTargets.push([score,b.index]) if score>0
            end
            if scoresAndTargets.length>0
                # Get the one best target for the move
                scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
                newChoice = [scoresAndTargets[0][0],scoresAndTargets[0][1]]
            end
        end
        return newChoice
    end
end