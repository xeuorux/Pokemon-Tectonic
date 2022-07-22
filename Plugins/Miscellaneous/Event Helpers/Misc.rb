def pbReceiveRandomPokemon(level)
	$game_variables[26] = level if level > $game_variables[26]
	possibleSpecies = []
	GameData::Species.each do |species_data|
		next if species_data.get_evolutions.length > 0
		next if isLegendary(species_data.id)
		possibleSpecies.push(species_data)
	end
	speciesDat = possibleSpecies.sample
	pkmn = Pokemon.new(speciesDat.species, level)
	pkmn.form = speciesDat.form
	pbAddPokemonSilent(pkmn)
	pbMessage(_INTL("You recieved a #{speciesDat.real_name} (#{speciesDat.real_form_name})"))
end

def hasPokemonInParty(speciesToCheck)
	if !speciesToCheck.is_a?(Array)
		speciesToCheck = [speciesToCheck]
	end
	hasAll = true
	speciesToCheck.each do |species|
		hasInParty = false
		$Trainer.party.each do |party_member|
			echoln("Comparing #{party_member.species} to #{species}")
			if party_member.species == species
				hasInParty = true
				break
			end
		end
		if !hasInParty
			hasAll = false
			break
		end
	end
	return hasAll
end

def isCat?(species)
	array = [:MEOWTH,:PERSIAN,:AMEOWTH,:APERSIAN,:GMEOWTH,:PERRSERKER,:ESPEON,:FLAREON,:GLACEON,
		:JOLTEON,:LEAFEON,:SYLVEON,:UMBREON,:VAPOREON,:SKITTY,:DELCATTY,:ZANGOOSE,:MZANGOOSE,:ABSOL,
		:ABSOLUS,:SHINX,:LUXIO,:LUXRAY,:GLAMEOW,:PURUGLY,:PURRLOIN,:LIEPARD,:LITLEO,:PYROAR,:ESPURR,
		:MEOWSTIC,:LITTEN,:TORRACAT,:INCINEROAR]
	return array.include?(species)
end

def isAlien?(species)
	array = [:CLEFFA,:CLEFAIRY,:CLEFABLE,:STARYU,:STARMIE,:LUNATONE,:SOLROCK,:ELGYEM,:BEHEEYEM,:KYUREM,:ETERNATUS,:DEOXYS]
	return array.include?(species)
end

def isBat?(species)
	array = [:ZUBAT,:GOLBAT,:CROBAT,:GLIGAR,:GLISCOR,:WOOBAT,:SWOOBAT,:NOIBAT,:NOIVERN]
	return array.include?(species)
end

def playerIsOutdoors?
	begin
		return GameData::MapMetadata.get($game_map.map_id).outdoor_map
	rescue
		return false
	end
end

class PokemonGlobalMetadata
	attr_accessor :raffleChancesTried
end

def pokemonRaffle(species,level=10,cost=200,baseChance=5.0,chanceIncrease=1.5,disablingSwitch='A')
	$PokemonGlobal.raffleChancesTried = {} if $PokemonGlobal.raffleChancesTried.nil?
	$PokemonGlobal.raffleChancesTried[species] = 0 if !$PokemonGlobal.raffleChancesTried.has_key?(species)
	speciesName = GameData::Species.get(species).real_name
	if pbConfirmMessageSerious(_INTL("We're running a raffle. Would you like to sepnd $#{cost} on a chance to win a #{speciesName}?"))
		if $Trainer.money < cost
			pbMessage(_INTL("I'm sorry, but you don't seem to have enough money."))
		else
			$Trainer.money -= cost
			pbMessage(_INTL("You hand over $#{cost}."))
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

# Gives the blue orb, and does a little scene where the cave brightens and the rain
def kyogreDefeated(eventID)
	timeTaken = Graphics.frame_rate * 2
	defeatBoss(:BLUEORB)
	pbWait(Graphics.frame_rate)
	pbSetSelfSwitch(eventID,'A',true)
	$game_screen.weather(:None,0,timeTaken)
	$game_map.start_fog_opacity_change(100, timeTaken)
	pbWait(timeTaken)
	pbSetSelfSwitch(eventID,'B',true)
end

# Gives the red orb, and does a little scene where the cave darkens and the bright sunshine dissapears
def groudonDefeated(eventID)
	timeTaken = Graphics.frame_rate * 2
	defeatBoss(:REDORB)
	pbWait(Graphics.frame_rate)
	pbSetSelfSwitch(eventID,'A',true)
	$game_screen.weather(:None,0,timeTaken)
	$game_map.start_fog_opacity_change(50, timeTaken)
	pbWait(timeTaken)
	pbSetSelfSwitch(eventID,'B',true)
end