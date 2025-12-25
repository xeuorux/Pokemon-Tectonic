class PokeBattle_Battler
    def generateMoney(multiplier)
        pseudoLevel = rescaleLevelForStats(@level)
        moneyDropped = pseudoLevel * multiplier
        moneyDropped = (moneyDropped * @battle.moneyMult).floor
        pbOwnSide.incrementEffect(:PayDay, moneyDropped)
    end
end