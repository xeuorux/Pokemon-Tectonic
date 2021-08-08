def pbTrainerDropsItem()
  pbMessage("The fleeing trainer dropped an item!")
  items = [:RARECANDY] # [:POTION,:RARECANDY,:ETHER,:STATUSHEAL,:POKEBALL,:REPEL,:ESCAPEROPE,:PRETTYFEATHER,:POKEDOLL]
  chances =  [100] # [15,30,35,50,65,70,75,95,100]
  number = rand(100)
  itemGiven = :PRETTYFEATHER
  items.each_with_index do |item,index|
    if number < chances[index]
      itemGiven = item
      break
    end
  end
  pbReceiveItem(itemGiven)
end