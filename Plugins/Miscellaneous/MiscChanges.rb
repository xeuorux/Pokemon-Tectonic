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

DebugMenuCommands.register("relearnsfix", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Bad relearns fix..."),
  "description" => _INTL("Swap moves that are 'relearned' at level 1 into the egg moves category of the lines first species."),
  "effect"      => proc { |sprites, viewport|
    GameData::Species.each do |species_data|
		next if species_data.form != 0
		next if species_data.get_prevolutions.length == 0
				
		movesToKeep = []
		firstSpecies = species_data
		
		# Find the first species of this line, and also gather an array of all moves learned by previous pokemon in the line
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
			firstSpecies.moves.each do |learnset_entry|
				movesToKeep.push(learnset_entry[1])
			end
		end
		
		# Also gather any "evolution" moves from the current species
		species_data.moves.each do |learnset_entry|
			next unless learnset_entry[0] == 0
			movesToKeep.push(learnset_entry[1])
		end
		
		movesToKeep.uniq!
		movesToKeep.compact!
		
		newLearnSet = []
		species_data.moves.each do |learnset_entry|
			level = learnset_entry[0]
			move = learnset_entry[1]
			if movesToKeep.include?(move) || level != 1
				newLearnSet.push([level,move])
			else
				echo("Transferring the move #{move} of the species #{species_data.id} to its first line-member #{firstSpecies.id}\n")
				firstSpecies.egg_moves.push(move)
			end
		end
		
		new_species_hash = {
          :id                    => species_data.id,
          :id_number             => species_data.id_number,
          :name                  => species_data.name,
          :form_name             => species_data.form_name,
          :category              => species_data.category,
          :pokedex_entry         => species_data.pokedex_entry,
          :type1                 => species_data.type1,
          :type2                 => species_data.type2,
          :base_stats            => species_data.base_stats,
          :evs                   => species_data.evs,
          :base_exp              => species_data.base_exp,
          :growth_rate           => species_data.growth_rate,
          :gender_ratio          => species_data.gender_ratio,
          :catch_rate            => species_data.catch_rate,
          :happiness             => species_data.happiness,
          :moves                 => newLearnSet, # MODIFIED
          :tutor_moves           => species_data.tutor_moves,
          :egg_moves             => species_data.egg_moves,
          :abilities             => species_data.abilities,
          :hidden_abilities      => species_data.hidden_abilities,
          :wild_item_common      => species_data.wild_item_common,
          :wild_item_uncommon    => species_data.wild_item_uncommon,
          :wild_item_rare        => species_data.wild_item_rare,
          :egg_groups            => species_data.egg_groups,
          :hatch_steps           => species_data.hatch_steps,
          :incense               => species_data.incense,
          :evolutions            => species_data.evolutions,
          :height                => species_data.height,
          :weight                => species_data.weight,
          :color                 => species_data.color,
          :shape                 => species_data.shape,
          :habitat               => species_data.habitat,
          :generation            => species_data.generation,
          :back_sprite_x         => species_data.back_sprite_x,
          :back_sprite_y         => species_data.back_sprite_y,
          :front_sprite_x        => species_data.front_sprite_x,
          :front_sprite_y        => species_data.front_sprite_y,
          :front_sprite_altitude => species_data.front_sprite_altitude,
          :shadow_x              => species_data.shadow_x,
          :shadow_size           => species_data.shadow_size
        }
		GameData::Species.register(new_species_hash)
		
		firstSpecies.egg_moves.uniq!
		firstSpecies.egg_moves.compact!
	end
	GameData::Species.save
	Compiler.write_pokemon
  }
})

module GameData
	class Trainer
		def initialize(hash)
		  @id             = hash[:id]
		  @id_number      = hash[:id_number]
		  @trainer_type   = hash[:trainer_type]
		  @real_name      = hash[:name]         || "Unnamed"
		  @version        = hash[:version]      || 0
		  @items          = hash[:items]        || []
		  @real_lose_text = hash[:lose_text]    || ""
		  @pokemon        = hash[:pokemon]      || []
		  @pokemon.each do |pkmn|
			GameData::Stat.each_main do |s|
			  pkmn[:iv][s.id] ||= 0 if pkmn[:iv]
			  pkmn[:ev][s.id] ||= 0 if pkmn[:ev]
			end
		  end
		end
	end
end

DebugMenuCommands.register("autopositionbacksprites", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Auto-Position Back Sprites"),
  "description" => _INTL("Automatically reposition all Pokémon back sprites. Don't use lightly."),
  "always_show" => true,
  "effect"      => proc {
    if pbConfirmMessage(_INTL("Are you sure you want to reposition all back sprites?"))
      msgwindow = pbCreateMessageWindow
      pbMessageDisplay(msgwindow, _INTL("Repositioning all back sprites. Please wait."), false)
      Graphics.update
      
	  GameData::Species.each do |sp|
		Graphics.update if sp.id_number % 50 == 0
		bitmap1 = GameData::Species.sprite_bitmap(sp.species, sp.form, nil, nil, nil, true)
		if bitmap1 && bitmap1.bitmap   # Player's y
		  sp.back_sprite_x = 0
		  sp.back_sprite_y = (bitmap1.height - (findBottom(bitmap1.bitmap) + 1)) / 2
		  data = GameData::Species.get(sp)
		  if data.abilities.include?(:LEVITATE)
			sp.back_sprite_y -= 4
		  elsif data.egg_groups.include?(:Water2)
			sp.back_sprite_y -= 2
		  end
		end
		bitmap1.dispose if bitmap1
	  end
	  GameData::Species.save
	  Compiler.write_pokemon
	  Compiler.write_pokemon_forms
	  
      pbDisposeMessageWindow(msgwindow)
    end
  }
})