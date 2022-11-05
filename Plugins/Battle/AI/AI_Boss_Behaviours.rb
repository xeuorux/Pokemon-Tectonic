class PokeBattle_AI_Boss
    def rejectPoisonMovesIfBelched
        @rejectMovesIf.push(proc { |move, user, battle|
            next true if user.belched? && move.type == :POISON && move.id != :BELCH
        })
    end

    def prioritizeFling
        @requiredMoves.push(:FLING)
    end

    def spaceOutProtecting
        @useMovesIFF.push(proc { |move, user, battle|
            if move.is_a?(PokeBattle_ProtectMove)
                if battle.turnCount % 3 == 0 && user.firstTurnThisRound?
                    next 1
                else
                    next -1
                end
            end
        })
    end
end