def pbPokemonMart(stock,speech=nil,cantsell=false,polite=true)
  for i in 0...stock.length
    stock[i] = GameData::Item.get(stock[i]).id
    stock[i] = nil if GameData::Item.get(stock[i]).is_single_purchase? && $PokemonBag.pbHasItem?(stock[i])
  end
  stock.compact!
  if cantsell
    speech = _INTL("Welcome!") unless speech
    pbMessage(speech)
    scene = PokemonMart_Scene.new
    screen = PokemonMartScreen.new(scene,stock,polite)
    screen.pbBuyScreen
  else
    unless speech
        if vipCardActive?
            speech = _INTL("Welcome, VIP! I hope you are satisfied with our services.")
        else
            speech = _INTL("Welcome! How may I serve you?")
        end
    end
    commands = []
    cmdBuy  = -1
    cmdSell = -1
    cmdQuit = -1
    commands[cmdBuy = commands.length]  = _INTL("Buy")
    commands[cmdSell = commands.length] = _INTL("Sell")
    commands[cmdQuit = commands.length] = _INTL("Quit")
    loop do
      cmd = pbMessage(speech,commands,cmdQuit+1)
      if cmdBuy>=0 && cmd==cmdBuy
        scene = PokemonMart_Scene.new
        screen = PokemonMartScreen.new(scene,stock,polite)
        screen.pbBuyScreen
      elsif cmdSell>=0 && cmd==cmdSell
        scene = PokemonMart_Scene.new
        screen = PokemonMartScreen.new(scene,stock,polite)
        screen.pbSellScreen
      else
        break
      end
    end
  end
  $game_temp.clear_mart_prices
end