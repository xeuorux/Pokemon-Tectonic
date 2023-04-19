class PokeBattle_AI
    #=============================================================================
    # Get a score for the given move based on its effect
    #=============================================================================
    def pbGetMoveScoreFunctionCode(score, move, user, target, _policies = [])
        case move.function
        #---------------------------------------------------------------------------
        when "13A" # Noble Roar
            avg	= target.steps[:ATTACK] * 10
            avg += target.steps[:SPECIAL_ATTACK] * 10
            score += avg / 2
        #---------------------------------------------------------------------------
        when "151" # Parting Shot
            avg	= target.steps[:ATTACK] * 10
            avg += target.steps[:SPECIAL_ATTACK] * 10
            score += avg / 2
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
