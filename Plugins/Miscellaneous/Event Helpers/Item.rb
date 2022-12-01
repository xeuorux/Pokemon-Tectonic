def pbDeleteItem(item,amount=1)
	$PokemonBag.pbDeleteItem(item,amount)
end

def pbSilentItem(item,quantity=1)
	$PokemonBag.pbStoreItem(item,quantity)
end

def pbHasItem?(item)
	return $PokemonBag.pbHasItem?(item)
end