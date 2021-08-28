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

DebugMenuCommands.register("autopositionbacksprites", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Reformulate catch rates"),
  "description" => _INTL("Reformulates all catch rates. Don't use lightly."),
  "always_show" => true,
  "effect"      => proc {
    if pbConfirmMessage(_INTL("Are you sure you want to reformulate all catch rates?"))
      msgwindow = pbCreateMessageWindow
      pbMessageDisplay(msgwindow, _INTL("Reformulating all catch rates. Please wait."), false)
      Graphics.update
      
	  totalDiff = 0
	  numSpecies = 0
	  GameData::Species.each do |sp|
        total = 0
        sp.base_stats.each_with_index do |stat, index|
          total += stat[1]
        end
		total = [[220,total].max,720].min
		newRarity = (8.8 * (250 - (250 * (total-220)/500)) ** 0.6) + 5
		if newRarity.is_a?(Complex)
			echoln("#{sp.real_name}: Complex number...")
			next
		end
		newRarity = newRarity.floor
		diff = (newRarity - sp.catch_rate)
		totalDiff += diff
		diff  = "+".concat(diff.to_s) if diff > 0
		numSpecies += 1
		pokeballRate = (captureThresholdCalcInternals(:NONE,50,300,newRarity).to_f/CATCH_BASE_CHANCE.to_f ) ** 4
		pokeballRate = (pokeballRate * 10000).floor / 100
		ultraballRate = (captureThresholdCalcInternals(:NONE,50,300,newRarity * 2).to_f/CATCH_BASE_CHANCE.to_f ) ** 4
		ultraballRate = (ultraballRate * 10000).floor / 100
		echoln("#{sp.real_name}: #{sp.catch_rate} -> #{newRarity} (#{diff}), #{pokeballRate}, #{ultraballRate}")
		#sp.catch_rate = newRarity
	  end
	  averageChange = totalDiff/numSpecies
	  echoln("Average: #{averageChange > 0 ? "+" : ""}#{averageChange}")
	  #GameData::Species.save
	  #Compiler.write_pokemon
	  #Compiler.write_pokemon_forms
	  
      pbDisposeMessageWindow(msgwindow)
    end
  }
})

class Interpreter
#-----------------------------------------------------------------------------
  # * Show Text
  #-----------------------------------------------------------------------------
  def command_101
    return false if $game_temp.message_window_showing
    message     = @list[@index].parameters[0]
    message_end = ""
    commands                = nil
    number_input_variable   = nil
    number_input_max_digits = nil
    # Check the next command(s) for things to add on to this text
    loop do
      next_index = pbNextIndex(@index)
      case @list[next_index].code
      when 401   # Continuation of 101 Show Text
        text = @list[next_index].parameters[0]
        message += " " if text != "" && message[message.length - 1, 1] != " "
        message += text
        @index = next_index
        next
      when 101   # Show Text
        message_end = "\1"
      when 102   # Show Choices
        commands = @list[next_index].parameters
        @index = next_index
      when 103   # Input Number
        number_input_variable   = @list[next_index].parameters[0]
        number_input_max_digits = @list[next_index].parameters[1]
        @index = next_index
      end
      break
    end
    # Translate the text
    message = _MAPINTL($game_map.map_id, message)
	message.gsub!("’","'")
	message.gsub!("…","...")
	message.gsub!("Pokemon","Pokémon")
	message.gsub!("Pokeex","Pokédex")
    # Display the text, with commands/number choosing if appropriate
    @message_waiting = true   # Lets parallel process events work while a message is displayed
    if commands
      cmd_texts = []
      for cmd in commands[0]
        cmd_texts.push(_MAPINTL($game_map.map_id, cmd))
      end
      command = pbMessage(message + message_end, cmd_texts, commands[1])
      @branch[@list[@index].indent] = command
    elsif number_input_variable
      params = ChooseNumberParams.new
      params.setMaxDigits(number_input_max_digits)
      params.setDefaultValue($game_variables[number_input_variable])
      $game_variables[number_input_variable] = pbMessageChooseNumber(message + message_end, params)
      $game_map.need_refresh = true if $game_map
    else
      pbMessage(message + message_end)
    end
    @message_waiting = false
    return true
  end
end