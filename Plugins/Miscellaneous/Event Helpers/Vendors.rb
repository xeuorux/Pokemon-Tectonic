def purchaseStarters(type,price=0)
	return unless [:GRASS,:FIRE,:WATER].include?(type)
	typeName = GameData::Type.get(type).real_name
	
	token = (type.to_s + "TOKEN").to_sym
	tokenName = GameData::Item.get(token).real_name
	
	pbMessage("Hello, and welcome to the Starters Store!")
	pbMessage("I'm the #{typeName}-type starters salesperson!")
	if price > 0
		pbMessage("You can buy a #{typeName}-type starter Pokemon from me if you have $#{price} and a #{tokenName}.")
	else
		pbMessage("You can buy a #{typeName}-type starter Pokemon from me if you have a #{tokenName}.")
	end
	if $Trainer.money < price
		pbMessage("I'm sorry, but it seems as though you don't have that much money.")
		return
	end
	if !$PlayerBag.pbHasItem?(token)
		pbMessage("I'm sorry, but it seems as though you don't have a #{tokenName}.")
		return
	end
	pbMessage("Would you like to buy a #{typeName}-type starter Pokemon?")
	
	starterArray = []
	case type
	when :GRASS
		starterArray = ["None","Bulbasaur","Chikorita","Treecko","Turtwig","Snivy","Chespin","Rowlet","Grookey"]
	when :FIRE
		starterArray = ["None","Charmander","Cyndaquil","Torchic","Chimchar","Tepig","Fennekin","Litten","Scorbunny"]
	when :WATER
		starterArray = ["None","Squirtle","Totodile","Mudkip","Piplup","Oshawott","Froakie","Popplio","Sobble"]
	else
		return
	end
	
	result = pbShowCommands(nil,starterArray)
	if result == 0
		pbMessage("Understood, please come back if there's a #{typeName}-type starter Pokemon you'd like to purchase!")
	else
		starterChosenName = starterArray[result]
		starterSpecies = starterChosenName.upcase.to_sym
		pbAddPokemon(starterSpecies,10)
		if price > 0
			pbMessage("\\PN handed over $#{price} and a #{tokenName} in exchange.")
		else
			pbMessage("\\PN handed over a #{tokenName} in exchange.")
		end
		$Trainer.money -= price
		$PlayerBag.pbDeleteItem(token)
		pbMessage("Thank you for shopping here at the Starters Store!")
	end
end

def weatherTMSell()
	pbPokemonMart(
		[:TM32,
		:TM33,
		:TM34,
		:TM35],
		"Do you like anything you see?"
	)
end

def terrainTMSell()
	pbPokemonMart(
		[:TM88,
		:TM89,
		:TM90,
		:TM91],
		"Do you like anything you see?"
	)
end

def fossilSell()
	pbPokemonMart(
		[:HELIXFOSSIL,
		:DOMEFOSSIL,
		:OLDAMBER,
		:ROOTFOSSIL,
		:CLAWFOSSIL,
		:SKULLFOSSIL,
		:ARMORFOSSIL,
		:COVERFOSSIL,
		:PLUMEFOSSIL,
		:JAWFOSSIL,
		:SAILFOSSIL],
		"Do you like anything you see?"
	)
end

def malasadaVendor()
	pbPokemonMart(
		[:BIGMALASADA,
		:BERRYJUICE,
		:SODAPOP],
		"Take a look, it's all delicious!",
		true
	)
end

def reviveFossil(fossil)
	fossilsToSpecies = {
		:HELIXFOSSIL => :OMANYTE,
		:DOMEFOSSIL => :KABUTO,
		:OLDAMBER => :AERODACTYL,
		:ROOTFOSSIL => :LILEEP,
		:CLAWFOSSIL => :ANORITH,
		:SKULLFOSSIL => :CRANIDOS,
		:ARMORFOSSIL => :SHIELDON,
		:COVERFOSSIL => :TIRTOUGA,
		:PLUMEFOSSIL => :ARCHEN,
		:JAWFOSSIL => :TYRUNT,
		:SAILFOSSIL => :AMAURA
	}
	
	species = fossilsToSpecies[fossil] || nil
	
	if species.nil?
		pbMessage("Error! Could not determine how to revive the given fossil.")
		return
	end
	item_data = GameData::Item.get(fossil)
	
	pbMessage("\\PN hands over the #{item_data.name} and $3000.")
	
	pbMessage("The procedure has started, now just to wait...")
	
	blackFadeOutIn(30) {
		$Trainer.money = $Trainer.money - 3000
		$PokemonBag.pbDeleteItem(fossil)
	}
	
	pbMessage("It's done! Here is your newly revived Pokemon!")
	
	pbAddPokemon(species,10)
end
