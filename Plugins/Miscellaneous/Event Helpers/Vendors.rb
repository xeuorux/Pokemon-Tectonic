def payMoney(cost)
	raise _INTL("A money cost can't be negative!") if cost < 0
	if $Trainer.money >= cost
		$Trainer.money = $Trainer.money - cost
		pbMessage(_INTL("You hand over #{cost}."))
		return true
	else
		return false
	end
end

def purchaseStarters(type,price=0)
	return unless [:GRASS,:FIRE,:WATER].include?(type)
	typeName = GameData::Type.get(type).real_name
	
	token = (type.to_s + "TOKEN").to_sym
	tokenName = GameData::Item.get(token).real_name
	
	pbMessage(_INTL("Hello, and welcome to the Starters Store!"))
	pbMessage(_INTL("I'm the #{typeName}-type starters salesperson!"))
	if price > 0
		pbMessage(_INTL("You can buy a #{typeName}-type starter Pokemon from me if you have $#{price} and a #{tokenName}."))
	else
		pbMessage(_INTL("You can buy a #{typeName}-type starter Pokemon from me if you have a #{tokenName}."))
	end
	if $Trainer.money < price
		pbMessage(_INTL("I'm sorry, but it seems as though you don't have that much money."))
		return
	end
	if !$PlayerBag.pbHasItem?(token)
		pbMessage(_INTL("I'm sorry, but it seems as though you don't have a #{tokenName}."))
		return
	end
	pbMessage(_INTL("Which #{typeName}-type starter Pokemon would you like to look at?"))
	
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
	
	while true
		result = pbShowCommands(nil,starterArray)

		if result == 0
			pbMessage(_INTL("Understood, please come back if there's a #{typeName}-type starter Pokemon you'd like to purchase!"))
			break
		else
			starterChosenName = starterArray[result]
			starterSpecies = starterChosenName.upcase.to_sym

			choicesArray = ["View Pokedex", "Buy Pokemon", "Cancel"]
			secondResult = pbShowCommands(nil,choicesArray,3)
			case secondResult
			when 1
				pbAddPokemon(starterSpecies,10)
				if price > 0
					pbMessage(_INTL("\\PN handed over $#{price} and a #{tokenName} in exchange."))
				else
					pbMessage(_INTL("\\PN handed over a #{tokenName} in exchange."))
				end
				$Trainer.money -= price
				$PlayerBag.pbDeleteItem(token)
				pbMessage(_INTL("Thank you for shopping here at the Starters Store!"))
				break
			when 0
				openSingleDexScreen(starterSpecies)
			end
			next
		end
	end
end

def weatherTMSell()
	pbPokemonMart(
		[:TM32,
		:TM33,
		:TM34,
		:TM35],
		"Care to buy some?"
	)
end

def terrainTMSell()
	pbPokemonMart(
		[:TM88,
		:TM89,
		:TM90,
		:TM91],
		"Care to buy some?"
	)
end

def spikesTMSell()
	pbPokemonMart(
		[:TM123,
		:TM134,
		:TM151,
		:TM154],
		"Care to buy some?"
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

def isMixFossil?(item_symbol)
	[:FOSSILIZEDBIRD,:FOSSILIZEDDRAKE,:FOSSILIZEDFISH,:FOSSILIZEDDINO].include?(item_symbol)
end

def reviveFossil(fossil)
	if isMixFossil?(fossil)
		pbMessage("My apologies, I don't know what to do with this type of fossil.")
		return
	end

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
	
	pbAddPokemon(species,15)
end

def reviveMixFossils(fossil1,fossil2)
	if fossil1 == fossil2
		pbMessage("The fossils can't be the same!")
		return
	end

	fossilsToSpecies = {
		[:FOSSILIZEDBIRD,:FOSSILIZEDDRAKE] => :DRACOZOLT,
		[:FOSSILIZEDBIRD,:FOSSILIZEDDINO] => :ARCTOZOLT,
		[:FOSSILIZEDFISH,:FOSSILIZEDDRAKE] => :DRACOVISH,
		[:FOSSILIZEDFISH,:FOSSILIZEDDINO] => :ARCTOVISH
	}

	chosenSpecies = nil
	fossilsToSpecies.each do |key,value|
		if key.include?(fossil1) && key.include?(fossil2)
			chosenSpecies = value
			break
		end
	end

	if chosenSpecies.nil?
		pbMessage("Error! Could not determine how to revive the given fossils.")
		return
	end

	pbMessage("The procedure has started, now just to wait...")
	
	blackFadeOutIn(30) {
		$PokemonBag.pbDeleteItem(fossil1)
		$PokemonBag.pbDeleteItem(fossil2)
	}
	
	pbMessage("It's done! Here is your newly revived Pokemon!")
	
	pbAddPokemon(chosenSpecies,15)
end

def pbChooseMixFossilHead(var = 0)
	ret = nil
	pbFadeOutIn {
	  scene = PokemonBag_Scene.new
	  screen = PokemonBagScreen.new(scene,$PokemonBag)
	  ret = screen.pbChooseItemScreen(Proc.new { |item| [:FOSSILIZEDBIRD,:FOSSILIZEDFISH].include?(item) })
	}
	$game_variables[var] = ret || :NONE if var > 0
	return ret
end

def pbChooseMixFossilBody(var = 0)
	ret = nil
	pbFadeOutIn {
	  scene = PokemonBag_Scene.new
	  screen = PokemonBagScreen.new(scene,$PokemonBag)
	  ret = screen.pbChooseItemScreen(Proc.new { |item| [:FOSSILIZEDDRAKE,:FOSSILIZEDDINO].include?(item) })
	}
	$game_variables[var] = ret || :NONE if var > 0
	return ret
end

def arenaVendor()
	pbPokemonMart(
		[:VANILLATULUMBA,
		:LEMONADE,
		:SODAPOP],
		"Grab a Tulumba, a Makyan specialty!",
		true
	)
end

def styleFurfrou()
	pbChoosePokemon(1,3,
		proc { |poke|
			!poke.egg? && poke.species == :FURFROU
		}
	)
	return false if pbGet(1) < 0
	pkmn = $Trainer.party[pbGet(1)]
	possibleForms, possibleFormNames = getFormSelectionChoices(:FURFROU,pkmn.form)
	choice = pbMessage("What style would you like me to give it?",possibleFormNames,possibleFormNames.length)
	if choice < possibleForms.length
		pbMessage("#{pkmn.name} swapped to #{possibleFormNames[choice]}!")
		
		showPokemonChanges(pkmn) {
			pkmn.form = possibleForms[choice].form
		}
		return true
	end
	return false
end