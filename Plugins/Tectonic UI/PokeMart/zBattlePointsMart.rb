class BattlePointsAdapter < PokemonMartAdapter
    def getMoney
      return $Trainer.battle_points
    end
  
    def getMoneyString
      return $Trainer.battle_points.to_s
    end
  
    def setMoney(value)
      $Trainer.battle_points = value
    end
end

class BattlePointsMartScreen < PokemonMartScreen
    def initialize(scene,stock)
      @scene=scene
      @stock=stock
      @adapter=BattlePointsAdapter.new
      @human = true
    end
end

def pbBattlePointsMart(stock,speech=nil)
    for i in 0...stock.length
        stock[i] = GameData::Item.get(stock[i]).id
        stock[i] = nil if GameData::Item.get(stock[i]).is_single_purchase? && $PokemonBag.pbHasItem?(stock[i])
    end
    speech = _INTL("Welcome! How may I serve you?") unless speech
    pbMessage(speech)
    stock.compact!
    scene = PokemonMart_Scene.new
    screen = BattlePointsMartScreen.new(scene,stock)
    screen.pbBuyScreen
    $game_temp.clear_mart_prices
end