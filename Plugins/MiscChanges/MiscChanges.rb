# Always print debug messages to console
module PBDebug
	def self.log(msg)
    if $DEBUG
      echo("#{msg}\n")
	  if $INTERNAL
		@@log.push("#{msg}\r\n")
		PBDebug.flush
	  end
    end
  end
end

# Setting the "off screen events" flags
Events.onMapChange += proc { |_sender,e|
  old_map_ID = e[0] # previous map ID, 0 if no map ID
  
  if old_map_ID == 0 || old_map_ID == $game_map.map_id
    echo("Skipping off screen events check on this map because of some unknown error.\n")
    next
  end

  $game_switches[98] = true
  $game_switches[99] = true
}

# Turn off all field moves

HiddenMoveHandlers::CanUseMove     = MoveHandlerHash.new
HiddenMoveHandlers::ConfirmUseMove = MoveHandlerHash.new
HiddenMoveHandlers::UseMove        = MoveHandlerHash.new


def pbReceiveRandomPokemon(level)
  $game_variables[26] = level if level > $game_variables[26]
  possibleSpecies = []
  GameData::Species.each do |species_data|
	next if species_data.get_evolutions.length > 0 && ![:ONIX,:SCYTHER].include?(species_data.species)
	if species_data.real_form_name
		regionals = ["alolan","galarian","makyan"]
		regionalForm = false
		regionals.each do |regional|
			regionalForm = true if species_data.real_form_name.downcase.include?(regional)
		end
		next if !regionalForm
	end
	possibleSpecies.push(species_data)
  end
  speciesDat = possibleSpecies.sample
  pkmn = Pokemon.new(speciesDat.species, level)
  pkmn.form = speciesDat.form
  pbAddPokemonSilent(pkmn)
  pbMessage(_INTL("You recieved a #{speciesDat.real_name} (#{speciesDat.real_form_name})"))
end

def pbPickBerry(berry, qty = 1)
  interp=pbMapInterpreter
  thisEvent=interp.get_character(0)
  berryData=interp.getVariable
  berry=GameData::Item.get(berry)
  itemname=(qty>1) ? berry.name_plural : berry.name
  if qty>1
    message=_INTL("There are {1} \\c[1]{2}\\c[0]!\nWant to pick them?",qty,itemname)
  else
    message=_INTL("There is 1 \\c[1]{1}\\c[0]!\nWant to pick it?",itemname)
  end
  if pbConfirmMessage(message)
    if !$PokemonBag.pbCanStore?(berry,qty)
      pbMessage(_INTL("Too bad...\nThe Bag is full..."))
      return
    end
    $PokemonBag.pbStoreItem(berry,qty)
    if qty>1
      pbMessage(_INTL("You picked the {1} \\c[1]{2}\\c[0].\\wtnp[20]",qty,itemname))
    else
      pbMessage(_INTL("You picked the \\c[1]{1}\\c[0].\\wtnp[20]",itemname))
    end
    pocket = berry.pocket
    pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
       $Trainer.name,itemname,pocket,PokemonBag.pocketNames()[pocket]))
    if Settings::NEW_BERRY_PLANTS
      pbMessage(_INTL("The berry plant withered away."))
      berryData=[0,nil,0,0,0,0,0,0]
    else
      pbMessage(_INTL("The berry plant withered away."))
      berryData=[0,nil,false,0,0,0]
    end
    interp.setVariable(berryData)
    pbSetSelfSwitch(thisEvent.id,"A",true)
  end
end