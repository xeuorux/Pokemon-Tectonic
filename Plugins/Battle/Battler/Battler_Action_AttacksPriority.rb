class PokeBattle_Battler
    # Called when the Pokémon is Encored, or if it can't use any of its moves.
    # Makes the Pokémon use the Encored move (if Encored), or Struggle.
    def pbAutoChooseMove(idxBattler,showMessages=true)
        battler = @battlers[idxBattler]
        if battler.fainted?
            pbClearChoice(idxBattler)
            return true
        end
        # Encore
        idxEncoredMove = battler.pbEncoredMoveIndex
        if idxEncoredMove >= 0 && pbCanChooseMove?(idxBattler,idxEncoredMove,false)
            encoreMove = battler.moves[idxEncoredMove]
            @choices[idxBattler][0] = :UseMove         # "Use move"
            @choices[idxBattler][1] = idxEncoredMove   # Index of move to be used
            @choices[idxBattler][2] = encoreMove       # PokeBattle_Move object
            @choices[idxBattler][3] = -1               # No target chosen yet
            return true if singleBattle?
            if pbOwnedByPlayer?(idxBattler)
                if showMessages
                    pbDisplayPaused(_INTL("{1} has to use {2}!",battler.name,encoreMove.name))
                end
                return pbChooseTarget(battler,encoreMove)
            end
            return true
        end
        # Struggle
        if pbOwnedByPlayer?(idxBattler) && showMessages
            pbDisplayPaused(_INTL("{1} has no moves left!",battler.name))
        end
        @choices[idxBattler][0] = :UseMove    # "Use move"
        @choices[idxBattler][1] = -1          # Index of move to be used
        @choices[idxBattler][2] = @struggle   # Struggle PokeBattle_Move object
        @choices[idxBattler][3] = -1          # No target chosen yet
        return true
    end
end