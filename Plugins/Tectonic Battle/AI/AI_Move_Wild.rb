class PokeBattle_AI
    def pbChooseMovesWild(idxBattler)
        battler = @battle.battlers[idxBattler]
        moveIndex = battler.turnCount % battler.getMoves.length
        @battle.pbRegisterMove(idxBattler, moveIndex, false)
    end
end
