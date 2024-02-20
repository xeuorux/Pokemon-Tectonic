def payMoney(cost, showMessage = true)
	raise _INTL("A money cost can't be negative!") if cost < 0
	if $Trainer.money >= cost
		$Trainer.money = $Trainer.money - cost
		pbMessage(_INTL("You hand over $#{cost}.")) if showMessage
		return true
	else
		return false
	end
end

def payEvolutionStone(showMessage = true)
	pbChooseEvolutionStone(1)
	itemID = pbGet(1)
	if itemID != :NONE
		$PokemonBag.pbDeleteItem(itemID)
		pbMessage(_INTL("You hand over the #{getItemName(itemID)}.")) if showMessage
		return true
	else
		return false
	end
end