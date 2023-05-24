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