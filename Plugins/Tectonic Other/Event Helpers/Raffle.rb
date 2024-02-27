class PokemonGlobalMetadata
	attr_accessor :raffleChancesTried
end

def pokemonRaffle(species,level=10,cost=200,baseChance=5.0,chanceIncrease=1.5,disablingSwitch='A')
	$PokemonGlobal.raffleChancesTried = {} if $PokemonGlobal.raffleChancesTried.nil?
	$PokemonGlobal.raffleChancesTried[species] = 0 if !$PokemonGlobal.raffleChancesTried.has_key?(species)
	speciesName = GameData::Species.get(species).real_name
	if pbConfirmMessageSerious(_INTL("We're running a raffle. Would you like to spend $#{cost} on a chance to win a #{speciesName}?"))
		if $Trainer.money < cost
			pbMessage(_INTL("I'm sorry, but you don't seem to have enough money."))
		else
			$Trainer.money -= cost
			pbMessage(_INTL("You hand over ${1}.",cost))
			chance = baseChance + chanceIncrease * $PokemonGlobal.raffleChancesTried[species]
			roll = rand(100)
			echoln("Raffle chance and roll: #{chance},#{roll}")
			pbMessage(_INTL("Alright, let me roll for you...\\|"))
			if roll < chance
				pbMessage(_INTL("Congratulations, you have won the raffle! Here is your #{speciesName}, as promised."))
				pbAddPokemon(species,level)
				setMySwitch(disablingSwitch,true)
			else
				pbMessage(_INTL("No luck! Try again next time."))
			end
			$PokemonGlobal.raffleChancesTried[species] += 1
		end
	end
end