######################################################
# Mart vendors
######################################################
BASIC_MART_STOCK = [
	:POKEBALL,
	:ABILITYCAPSULE,
	:REPEL,
]

def basicPokeMart
    pbPokemonMart(BASIC_MART_STOCK)
end

def rangerMart
    pbPokemonMart(BASIC_MART_STOCK,_INTL("Get your supplies here!"))
end

######################################################
# Pokemon vendors
######################################################

def purchaseStarters(type,price=0)
	return unless %i[GRASS FIRE WATER].include?(type)
	typeName = GameData::Type.get(type).name
	
	token = (type.to_s + "TOKEN").to_sym
	tokenName = GameData::Item.get(token).name
	
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

			choicesArray = [_INTL("View MasterDex"), _INTL("Buy Pokemon"), _INTL("Cancel")]
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

def isMixFossil?(item_symbol)
	%i[FOSSILIZEDBIRD FOSSILIZEDDRAKE FOSSILIZEDFISH FOSSILIZEDDINO].include?(item_symbol)
end

def reviveFossil(fossil)
	if isMixFossil?(fossil)
		pbMessage(_INTL("My apologies, I don't know what to do with this type of fossil."))
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
		pbMessage(_INTL("Error! Could not determine how to revive the given fossil."))
		return
	end
	item_data = GameData::Item.get(fossil)
	
	pbMessage(_INTL("\\PN hands over the #{item_data.name} and $3000."))
	
	pbMessage(_INTL("The procedure has started, now just to wait..."))
	
	blackFadeOutIn(30) {
		$Trainer.money = $Trainer.money - 3000
		$PokemonBag.pbDeleteItem(fossil)
	}
	
	pbMessage(_INTL("It's done! Here is your newly revived Pokemon!"))
	
	pbAddPokemon(species,15)
end

def reviveMixFossils(fossil1,fossil2)
	if fossil1 == fossil2
		pbMessage(_INTL("The fossils can't be the same!"))
		return
	end

	fossilsToSpecies = {
		%i[FOSSILIZEDBIRD FOSSILIZEDDRAKE] => :DRACOZOLT,
		%i[FOSSILIZEDBIRD FOSSILIZEDDINO] => :ARCTOZOLT,
		%i[FOSSILIZEDFISH FOSSILIZEDDRAKE] => :DRACOVISH,
		%i[FOSSILIZEDFISH FOSSILIZEDDINO] => :ARCTOVISH
	}

	chosenSpecies = nil
	fossilsToSpecies.each do |key,value|
		if key.include?(fossil1) && key.include?(fossil2)
			chosenSpecies = value
			break
		end
	end

	if chosenSpecies.nil?
		pbMessage(_INTL("Error! Could not determine how to revive the given fossils."))
		return
	end

	pbMessage(_INTL("The procedure has started, now just to wait..."))
	
	blackFadeOutIn(30) {
		$PokemonBag.pbDeleteItem(fossil1)
		$PokemonBag.pbDeleteItem(fossil2)
	}
	
	pbMessage(_INTL("It's done! Here is your newly revived Pokemon!"))
	
	pbAddPokemon(chosenSpecies,15)
end

def pbChooseMixFossilHead(var = 0)
	ret = nil
	pbFadeOutIn {
	  scene = PokemonBag_Scene.new
	  screen = PokemonBagScreen.new(scene,$PokemonBag)
	  ret = screen.pbChooseItemScreen(Proc.new { |item| %i[FOSSILIZEDBIRD FOSSILIZEDFISH].include?(item) })
	}
	$game_variables[var] = ret || :NONE if var > 0
	return ret
end

def pbChooseMixFossilBody(var = 0)
	ret = nil
	pbFadeOutIn {
	  scene = PokemonBag_Scene.new
	  screen = PokemonBagScreen.new(scene,$PokemonBag)
	  ret = screen.pbChooseItemScreen(Proc.new { |item| %i[FOSSILIZEDDRAKE FOSSILIZEDDINO].include?(item) })
	}
	$game_variables[var] = ret || :NONE if var > 0
	return ret
end

def styleFurfrou
	pbChoosePokemon(1,3,
		proc { |poke|
			!poke.egg? && poke.species == :FURFROU
		}
	)
	return false if pbGet(1) < 0
	pkmn = $Trainer.party[pbGet(1)]
	possibleForms, possibleFormNames = getFormSelectionChoices(:FURFROU,pkmn.form)
	pbMessage(_INTL("What style would you like me to give it?"))
	choice = pbShowCommands(nil,possibleFormNames,possibleFormNames.length+1)
	if choice < possibleForms.length
		pbMessage(_INTL("#{pkmn.name} swapped to #{possibleFormNames[choice]}!"))
		
		pkmn.form = possibleForms[choice].form
		pkmn.changeHappiness("groom")
		refreshFollow(false)
		return true
	end
	return false
end

def createHisuian
	actualSpecies = [:HGROWLITHE,:HVOLTORB,:HQWILFISH,:HSNEASEL,:HZORUA]
	speciesArray = []
	actualSpecies.each do |speciesID|
		speciesArray.push(GameData::Species.get(speciesID).name)
	end
	actualSpecies.unshift(nil)
	speciesArray.unshift(_INTL("None"))
	
	while true
		result = pbShowCommands(nil,speciesArray)

		if result == 0
			pbMessage(_INTL("Ah, I was looking forward to flexing my skills today."))
			break
		else
			chosenSpecies = actualSpecies[result]

			choicesArray = [_INTL("View MasterDex"), _INTL("Buy Pokemon"), _INTL("Cancel")]
			secondResult = pbShowCommands(nil,choicesArray,3)
			case secondResult
			when 1
				item_data = GameData::Item.get(:ORIGINORE)
				pbMessage(_INTL("\\PN hands over the #{item_data.name}."))
				pbMessage(_INTL("Now just to work my magicks..."))
				blackFadeOutIn(30) {
					$PokemonBag.pbDeleteItem(:ORIGINORE)
				}
				pbMessage(_INTL("Poof! And so the impossible has been made possible!"))
				pbAddPokemon(chosenSpecies,10)
				pbMessage(_INTL("My hopes go with you. Be respectful of this relic which you now posess."))
				break
			when 0
				openSingleDexScreen(chosenSpecies)
			end
			next
		end
	end
end

def shinifyPokemonVendor
	unless pbHasItem?(:GLEAMPOWDER)
		pbMessage(_INTL("Don't try to trick me with some knock-off, you don't have any Gleam Powder!"))
		return
	end

	pbChoosePokemon(1,3,
		proc { |poke|
			!poke.egg? && !poke.shiny?
		}
	)
	if pbGet(1) < 0
		pbMessage(_INTL("No suitable canvases?"))
		return
	end

	pkmn = $Trainer.party[pbGet(1)]

	unless payMoney(30_000, false)
		pbMessage(_INTL("I'm surprised, you look like you'd have more money, but you can't afford me."))
		return
	end

	gleamPowderRealName = GameData::Item.get(:GLEAMPOWDER).name
	pbMessage(_INTL("\\PN hands over the #{gleamPowderRealName}, $30,000, and #{pkmn.name}."))

	pbMessage("And so my work begins!")
	blackFadeOutIn(30) {
		$PokemonBag.pbDeleteItem(:GLEAMPOWDER)
		pkmn.shiny = true
	}
	pbMessage(_INTL("Now, bask in the beautiful glow of your shiny #{pkmn.speciesName}!"))
	pbMessage(_INTL("No need to thank me, its beauty is reward enough."))
	pbMessage(_INTL("The money isn't bad either..."))

	return false
end

def cloneMinorLegend
	actualSpecies = [:PHIONE,:TYPENULL,:COSMOG,:MELTAN,:KUBFU]
	speciesArray = []
	actualSpecies.each do |speciesID|
		speciesArray.push(GameData::Species.get(speciesID).name)
	end
	actualSpecies.unshift(nil)
	speciesArray.unshift(_INTL("None"))
	
	while true
		result = pbShowCommands(nil,speciesArray)

		if result == 0
			pbMessage(_INTL("Ah, lacking in miraculous materials, are we?"))
			break
		else
			chosenSpecies = actualSpecies[result]

			choicesArray = [_INTL("View MasterDex"), _INTL("Clone Pokemon"), _INTL("Cancel")]
			secondResult = pbShowCommands(nil,choicesArray,3)
			case secondResult
			when 1
				item_data = GameData::Item.get(:ORIGINORE)
				pbMessage(_INTL("\\PN hands over the #{item_data.name}."))
				pbMessage(_INTL("Now just to work my magicks..."))
				blackFadeOutIn(30) {
					$PokemonBag.pbDeleteItem(:ORIGINORE)
				}
				pbMessage(_INTL("Poof! And so the impossible has been made possible!"))
				pbAddPokemon(chosenSpecies,10)
				pbMessage(_INTL("My hopes go with you. Live the legend!"))
				break
			when 0
				openSingleDexScreen(chosenSpecies)
			end
			next
		end
	end
end

######################################################
# Useful item vendors
######################################################

CAN_SELL_IN_VENDORS = true

def weatherTMSell()
	weatherTMStock = %i[
		TM32
		TM33
		TM34
		TM35
		TM196
		TM197
	]
	pbPokemonMart(
		weatherTMStock,
		_INTL("Care to buy some?"),
		!CAN_SELL_IN_VENDORS
	)
end

def spikesTMSell()
	spikeTMStock = %i[
		TM123
		TM134
		TM151
		TM154
	]
	pbPokemonMart(
		spikeTMStock,
		_INTL("Care to buy some?"),
		!CAN_SELL_IN_VENDORS
	)
end

def fossilSell()
	fossilStock = %i[
		HELIXFOSSIL
		DOMEFOSSIL
		OLDAMBER
		ROOTFOSSIL
		CLAWFOSSIL
		SKULLFOSSIL
		ARMORFOSSIL
		COVERFOSSIL
		PLUMEFOSSIL
		JAWFOSSIL
		SAILFOSSIL
	]
	pbPokemonMart(
		fossilStock,
		_INTL("Do you like anything you see?"),
		!CAN_SELL_IN_VENDORS
	)
end

def eastEndExclusives
	exclusiveItemsStock = %i[
		DYNAMITESTICK
		ORIGINORE
		GRASSTOKEN WATERTOKEN FIRETOKEN
		DIAMONDTIARA
		RUSTEDSHIELD RUSTEDSWORD
		REINSOFUNITY
	]

	setPrice(:RUSTEDSWORD,20_000)
	setPrice(:RUSTEDSHIELD,20_000)
	setPrice(:REINSOFUNITY,20_000)
	setPrice(:DYNAMITESTICK,5_000)
	
	pbPokemonMart(
		exclusiveItemsStock,
		_INTL("Ohoh! I'm honored that you would pay my store a visit, champion."),
		!CAN_SELL_IN_VENDORS
	)
end

def tmShop
	# Megapunch, Hypervoice
	# Inferno Charge, Flame Thrower
	# Liquidation, Bubble Blast

	# Leaf Blade, Thriving Force
	# Electroslash, Thunderbolt
	# Crystal Crush, Ice Beam

	# Brick Break, Aura Sphere
	# Poison Jab, Miasma
	# Trample, Earth Power

	# Strafe, Cold Front
	# Prediction Strike, Psychic
	# X-Scissor, Bug Buzz

	# Adamantine Press, Power Gem
	# Wailing Blow, Shadow Ball
	# Rend, Dragon Pulse

	# Crunch, Dark Allure
	# Bullet Train, Flash Cannon
	# Play Rough, Moon Blast

	tmsStock = %i[
		TM49 TM142
		TM141 TM102
		TM198 TM96

		TM150 TM28
		TM186 TM108
		TM51 TM105

		TM43 TM156
		TM157 TM178
		TM187 TM167

		TM48 TM95
		TM169 TM111
		TM160 TM161

		TM175 TM163
		TM54 TM133
		TM147 TM162

		TM132 TM158
		TM174 TM170
		TM190 TM192
	]

	pbPokemonMart(
		tmsStock,
		_INTL("One-Stop Tech Shop, for all your electronic need."),
		!CAN_SELL_IN_VENDORS
	)
end

def hackedTMShop
	tmsStock = %i[
		TM04
		TM05
		TM06
		TM11
		TM13
		TM22
		TM23
		TM27
		TM85
		TM114
		TM176
	]

	pbPokemonMart(
		tmsStock,
		_INTL("Hurry and buy some."),
		!CAN_SELL_IN_VENDORS
	)
end

def switchOutTMShop
	tmsStock = %i[
		TM88
		TM89
		TM90
		TM91
	]

	pbPokemonMart(
		tmsStock,
		_INTL("I'm sure you'll appreciate one of these."),
		!CAN_SELL_IN_VENDORS
	)
end

def rechargeTMShop
	tmsStock = %i[

	]

	pbPokemonMart(
		tmsStock,
		_INTL("Don't delay. Buy now!"),
		!CAN_SELL_IN_VENDORS
	)
end

def naturesGallery
	stock = %i[
		HEATROCK DAMPROCK SMOOTHROCK ICYROCK MIRROREDROCK PINPOINTROCK
		LIGHTCLAY
		FLOATSTONE
		BIGROOT
		LUCKYEGG
		CRYSTALVEIL
		GALARICAWREATH
		ALOLANWREATH
	]

	pbPokemonMart(
		stock,
		_INTL("Nature's Gallery, your gateway to nature's beauty."),
		!CAN_SELL_IN_VENDORS
	)
end

def heldItemShop
	stock = %i[
		POWERLOCK ENERGYLOCK
		UTILITYUMBRELLA 
		BLACKSLUDGE
		GRIPCLAW BINDINGBAND
		REDCARD EJECTBUTTON EJECTPACK
		AIRBALLOON EXPERTBELT
		EVIOLITE
		METRONOME
		MUSCLEBAND WISEGLASSES
		SCOPELENS WIDELENS
		LAGGINGTAIL SEVENLEAGUEBOOTS
		HEAVYDUTYBOOTS
		FOCUSSASH
		STICKYBARB
		IRONBALL
		ADRENALINEORB
		WEAKNESSPOLICY
		REINFORCINGROD
		LOADEDDICE
		PROXYFIST COVERTCLOAK
	]	

	pbPokemonMart(
		stock,
		_INTL("Welcome to Emma's Empolorium! What're you looking for today?"),
		!CAN_SELL_IN_VENDORS
	)
end

def advancedHeldItemsShop
	advancedHeldItemStock = %i[
		CHOICEBAND CHOICESPECS CHOICESCARF
		LUMBERAXE
		LEFTOVERS WATERBALLOON SHELLBELL
		ASSAULTVEST STRIKEVEST
		LIFEORB
		THROATSPRAY WHETSTONE
		ROCKYHELMET HIVISJACKET
	]

	pbPokemonMart(
		advancedHeldItemStock,
		_INTL("I've got the lion's share of powerful items. Buy now!"),
		!CAN_SELL_IN_VENDORS
	)
end

def diegosWares
	castleStock = %i[
		KNIGHTHELMET NINJASCARF
	]

	pbPokemonMart(
		castleStock,
		_INTL("Welcome to Diego's Wares! Please, come look through our goods."),
		!CAN_SELL_IN_VENDORS
	)
end

def gemVendor
	gemStock = %i[
		FIREGEM WATERGEM ELECTRICGEM GRASSGEM ICEGEM FIGHTINGGEM POISONGEM GROUNDGEM FLYINGGEM
		PSYCHICGEM BUGGEM ROCKGEM GHOSTGEM DRAGONGEM DARKGEM STEELGEM NORMALGEM FAIRYGEM
	]

	pbPokemonMart(
		gemStock,
		_INTL("Yo, I'm Adam, the gem guy. Gonna buy some gems, or what?"),
		!CAN_SELL_IN_VENDORS
	)
end

def basicBallVendor
	basicBallStock = %i[
		GREATBALL
		REPEATBALL
		NESTBALL
		TIMERBALL
		QUICKBALL
		SLICEBALL
	]
	pbPokemonMart(
		basicBallStock,
		_INTL("Welcome to the PokeBall Depot! How may I serve you?"),
		!CAN_SELL_IN_VENDORS
	)
end

def weirdBallsVendor
	weirdBallStock = %i[
		ULTRABALL
		LEECHBALL
		POTIONBALL
		DISABLEBALL
		DREAMBALL
		FASTBALL  HEAVYBALL
		LOVEBALL
		LUXURYBALL FRIENDBALL
		HEALBALL
		ROYALBALL
	]
	pbPokemonMart(
		weirdBallStock,
		_INTL("Custom Pokéballs, made to order! You won't find these in a mart!"),
		!CAN_SELL_IN_VENDORS
	)
end

def evoStoneVendor(expanded = false)
	stock = %i[
		FIRESTONE
		THUNDERSTONE
		WATERSTONE
		LEAFSTONE
		DAWNSTONE
		DUSKSTONE
		MOONSTONE
		SUNSTONE
		ICESTONE
	]

	expandedStock = %i[
		SHINYSTONE
	]
	stock = expandedStock.concat(stock) if expanded

	if expanded
		message = _INTL("How can we help to empower your Pokemon?")
	else
		message = _INTL("Regrettably, you are restricted from purchasing any Shiny Stones. Otherwise, how may I serve you?")
	end

	pbPokemonMart(
		stock,
		message,
		!CAN_SELL_IN_VENDORS
	)
end

def berryVendor
	setPrice(:CADOBERRY,1000)
	setPrice(:SITRUSBERRY,1000)
	setPrice(:LUMBERRY,1000)
	setPrice(:LEPPABERRY,500)
	
	setPrice(:RAWSTBERRY,500)
	setPrice(:ASPEARBERRY,500)
	setPrice(:PECHABERRY,500)
	setPrice(:PERSIMBERRY,500)
	setPrice(:CHERIBERRY,500)
	setPrice(:CHESTOBERRY,500)
	setPrice(:SPELONBERRY,500)

	berryStock = %i[
		CADOBERRY SITRUSBERRY
		LUMBERRY
		LEPPABERRY
		RAWSTBERRY ASPEARBERRY
		PECHABERRY
		PERSIMBERRY
		CHERIBERRY
		CHESTOBERRY
		SPELONBERRY
	]

	pbPokemonMart(
		berryStock,
		_INTL("Care to buy some of our extra berry harvest?"),
		!CAN_SELL_IN_VENDORS
	)
end

def weirdBerryVendor
	setPrice(:LIECHIBERRY,1000)
	setPrice(:GANLONBERRY,1000)
	setPrice(:SALACBERRY,1000)
	setPrice(:PETAYABERRY,1000)
	setPrice(:APICOTBERRY,1000)
	setPrice(:LANSATBERRY,1000)
	setPrice(:STARFBERRY,1000)
	setPrice(:MICLEBERRY,1000)

	setPrice(:MICLEBERRY,1000)
	setPrice(:CUSTAPBERRY,1000)
	setPrice(:JABOCABERRY,1000)
	setPrice(:ROWAPBERRY,1000)
	setPrice(:KEEBERRY,1000)
	setPrice(:MARANGABERRY,1000)

	berryStock = %i[
		LIECHIBERRY
		GANLONBERRY
		SALACBERRY
		PETAYABERRY
		APICOTBERRY
		LANSATBERRY
		STARFBERRY
		MICLEBERRY
		CUSTAPBERRY
		JABOCABERRY
		ROWAPBERRY
		KEEBERRY
		MARANGABERRY
	]

	pbPokemonMart(
		berryStock,
		_INTL("Some of these are illegal to import. Don't get me caught."),
		!CAN_SELL_IN_VENDORS
	)
end

def expCandyVendor
	expCandyStock = %i[
		EXPCANDYXS
		EXPCANDYS
		EXPCANDYM
		EXPCANDYL
		EXPCANDYXL
	]
	pbPokemonMart(
		expCandyStock,
		_INTL("Welcome to Sweetrock Candy Outlet! How may I serve you?"),
		!CAN_SELL_IN_VENDORS
	)
end

def herbVendor
	herbStock = %i[
		AGILITYHERB STRENGTHHERB INTELLECTHERB
		WHITEHERB BLACKHERB
		POWERHERB ENERGYHERB
		SKILLHERB LUCKHERB
		MIRRORHERB PARADOXHERB
		MENTALHERB
	]
	pbPokemonMart(
		herbStock,
		_INTL("Name's Herbert. Care for any herbs?"),
		!CAN_SELL_IN_VENDORS
	)
end


######################################################
# Minor food vendors
######################################################

def malasadaVendor()
	pbPokemonMart(
		%i[BIGMALASADA BERRYJUICE],
		_INTL("Take a look, it's all delicious!"),
		true
	)
end

def pubVendor
	pubStock = %i[
		EEVEETICKET
		SWEETHEART
	]
	pbPokemonMart(pubStock,"What can I get you?",true)
end

def farmVendor
	pubStock = %i[
		SWEETAPPLE
		TARTAPPLE
		MOOMOOMILK
	]
	setPrice(:MOOMOOMILK,800)
	pbPokemonMart(pubStock,"Farm food, fresh for feastin'.",true)
end

def arenaVendor()
	pbPokemonMart(
		[:VANILLATULUMBA],
		_INTL("Grab a Tulumba, a Makyan specialty!"),
		true
	)
end

def vendingMachine
	return unless playerFacingNorth?
	pbPokemonMart(
		%i[FRESHWATER SODAPOP LEMONADE MOOMOOMILK],
		_INTL("It's a vending machine."),
		true,
		false,
	)
end