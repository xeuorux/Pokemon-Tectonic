def debugControl
    $DEBUG && Input.press?(Input::CTRL)
end

def pbReceiveRandomPokemon(level)
	getLevelCap = level if level > getLevelCap
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
		:MEOWSTIC,:LITTEN,:TORRACAT,:INCINEROAR,:GIGANTEON]
	return array.include?(species)
end

def isAlien?(species)
	array = [:CLEFFA,:CLEFAIRY,:CLEFABLE,:STARYU,:STARMIE,:LUNATONE,:SOLROCK,:ELGYEM,:BEHEEYEM,:KYUREM,:ETERNATUS,:DEOXYS,:MROGGENROLA,:MBOLDORE,:MGIGALITH]
	return array.include?(species)
end

def isBat?(species)
	array = [:ZUBAT,:GOLBAT,:CROBAT,:GLIGAR,:GLISCOR,:WOOBAT,:SWOOBAT,:NOIBAT,:NOIVERN]
	return array.include?(species)
end

def isSmart?(species)
	array = [:ABRA,:KADABRA,:ALAKAZAM,:BELDUM,:METANG,:METAGROSS,:SOLOSIS,:DUOSION,:REUNICLUS,:ORBEETLE,:DOTTLER,:BLIPBUG,:GSLOWKING,:SLOWKING,:UXIE]
	return array.include?(species)
end

def isKnight?(species)
	array = [:CORVIKNIGHT,:GALLADE,:ESCAVALIER,:BISHARP,:SIRFETCHD,:SAMUROTT,:GOLURK,:ROSERADE]
	return array.include?(species)
end

def isFrog?(species)
	array = [:BULBASAUR,:IVYSAUR,:VENUSAUR,:POLIWHIRL,:POLIWRATH,:POLITOED,:POLIWAG,:SEISMITOAD,:PALPITOAD,:TYMPOLE,:FROAKIE,:FROGADIER,:GRENINJA,:TOXICROAK,:CROAGUNK]
	return array.include?(species)
end

def isQuestionable?(species)
	array = [:LUCARIO,:GARDEVOIR,:UMBREON,:CHARIZARD,:HAEROBIC,:ZOROARK,:DELPHOX,:ARCANINE,:GLACEON,:BLAZIKEN,:SYLVEON,:ZANGOOSE,:VAPOREON,:RAICHU,:TYPHLOSION,:ESPEON,:GOODRA,:CINDERACE,:SALAZZLE]
	return array.include?(species)
end

def isBandMember?(species)
	array = [:WIGGLYTUFF,:JIGGLYPUFF,:IGGLYBUFF,:WHISMUR,:LOUDRED,:EXPLOUD,:PRIMARINA,:BRIONNE,:POPPLIO,:KRICKETUNE,:KRICKETOT,:CHATOT,:TOXEL,:TOXTRICITY,:ARCLAMOR,:MARACTUS,:RILLABOOM,:THWACKEY,:GROOKEY,:NOIBAT,:NOIVERN]
	return array.include?(species)
end

def isTMNT?(species)
	array = [:CARRACOSTA,:TIRTOUGA,:TORKOAL,:TORTERRA,:GROTLE,:TURTWIG,:CHEWTLE,:DREDNAW,:SEISMAW,:SQUIRTLE,:WARTORTLE,:BLASTOISE,:RATICATE,:RATTATA,:CUBONE,:MAROWAK]
	return array.include?(species)
end

def isKing?(species)
	array = [:KINGDRA,:KINGLER,:NIDOKING,:SLAKING,:SLOWKING,:GSLOWKING,:SEAKING]
	return array.include?(species)
end

def isQueen?(species)
	array = [:VESPIQUEN,:TSAREENA,:GARDEVOIR,:NIDOQUEEN,:SALAZZLE]
	return array.include?(species)
end

def isSmasher?(species)
	array = [:LUCARIO,:PIKACHU,:GRENINJA,:CHARIZARD,:JIGGLYPUFF,:IVYSAUR,:LUCARIO,:SQUIRTLE]
	return array.include?(species)
end

def isPirateCrew?(species)
	array = [:EMPOLEON,:AMBIPOM,:DHELMISE,:OCTILLERY,:SCARODON,:RUBARIOR,:CHATOT,:BLASTOISE,:CRAWDAUNT]
	return array.include?(species)
end

def playerIsOutdoors?
	begin
		return GameData::MapMetadata.get($game_map.map_id).outdoor_map
	rescue
		return false
	end
end

def teamEditingAllowed?()
	begin
		return !GameData::MapMetadata.get($game_map.map_id).no_team_editing
	rescue
		return true
	end
end

def showNoTeamEditingMessage()
	pbMessage(_INTL("Editing your team is not allowed at the moment."))
end

def savingAllowed?()
	begin
		return !GameData::MapMetadata.get($game_map.map_id).saving_blocked
	rescue
		return true
	end
end

def showSaveBlockMessage()
	pbMessage(_INTL("Saving is not allowed at the moment."))
end

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
	defeatBoss(:BLUEORB)
	weatherBossDefeated(eventID,100)
end

# Gives the red orb, and does a little scene where the cave darkens and the bright sunshine dissapears
def groudonDefeated(eventID)
	defeatBoss(:REDORB)
	weatherBossDefeated(eventID,50)
end

# Does a little scene where the cave darkens and the extreme wind dissapears
def rayquazaDefeated(eventID)
	defeatBoss(:RELICCROWN)
	weatherBossDefeated(eventID,50)
end

def weatherBossDefeated(eventID,newFogOpacity)
	pbSetSelfSwitch(eventID,'A',true)
	pbWait(Graphics.frame_rate)
	baseWaitTime = Graphics.frame_rate / 4
	weatherCallback = proc {
		pbSetSelfSwitch(eventID,'B',true)
		unlockPlayerInput
	}
	$game_screen.weather(:None,0,baseWaitTime,true,true,weatherCallback)
	weatherWaitTime = baseWaitTime * 2 * $game_screen.weather_strength
	$game_map.start_fog_opacity_change(newFogOpacity, weatherWaitTime)
	lockPlayerInput
end

def playBicycleShortcutTutorial
    if $DEBUG
        echoln("Skipping bicycle tutorial message.")
        return
    end
    pbBGMFade(1.0)
    pbWait(Graphics.frame_rate)
    pbSEPlay("Voltorb Flip tile",150,100)
	dur = tutorialMessageDuration
    pbMessage(_INTL("\\wmYou can set a keyboard shortcut to use your bicycle quickly.\\wtnp[#{dur}]\1"))
    pbMessage(_INTL("\\wmAccess your control setttings with <imp>F1</imp> to set it to whatever you like.\\wtnp[#{dur}]\1"))
end

def tutorialMessageDuration
	dur = 90
	dur -= 15 * $PokemonSystem.textspeed
	return dur
end