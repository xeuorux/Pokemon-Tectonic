class PokeBattle_AI
    #=============================================================================
    # Get a score for the given move based on its effect
    #=============================================================================
    def pbGetMoveScoreFunctionCode(score, move, user, target, _policies = [])
        case move.function
        #---------------------------------------------------------------------------
        when "13A" # Noble Roar
            avg	= target.stages[:ATTACK] * 10
            avg += target.stages[:SPECIAL_ATTACK] * 10
            score += avg / 2
        #---------------------------------------------------------------------------
        when "151" # Parting Shot
            avg	= target.stages[:ATTACK] * 10
            avg += target.stages[:SPECIAL_ATTACK] * 10
            score += avg / 2
        #---------------------------------------------------------------------------
        when "159" # Toxic Thread
            if !target.canPoison?(user, false) && !target.pbCanLowerStatStage?(:SPEED, user)
                score = 0
            else
                if target.canPoison?(user, false)
                    score += 30
                    score += 30 if target.hp <= target.totalhp / 4
                    score += 50 if target.hp <= target.totalhp / 8
                    score -= 40 if target.effectActive?(:Yawn)
                    score -= 40 if target.hasActiveAbilityAI?(%i[GUTS MARVELSCALE TOXICBOOST])
                end
                score += target.stages[:SPEED] * 10 if target.pbCanLowerStatStage?(:SPEED, user)
            end
        #---------------------------------------------------------------------------
        else
            if @battle.autoTesting
                score = move.getEffectScore(user, target)
            else
                begin
                    score = move.getEffectScore(user, target)
                rescue StandardError
                    echoln("FAILURE IN THE SCORING SYSTEM FOR MOVE #{move.name} #{move.function}")
                    return 0
                end
            end
        end
        return score
    end
end
