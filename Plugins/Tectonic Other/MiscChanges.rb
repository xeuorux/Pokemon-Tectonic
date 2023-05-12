# Always print debug messages to console
module PBDebug
	def self.log(msg)
    if $DEBUG
      echoln("#{msg}\n")
	  if $INTERNAL
		@@log.push("#{msg}\r\n")
		PBDebug.flush
	  end
    end
  end
end

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
	  message = globalMessageReplacements(message)
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

def pbFadeOutAndHide(sprites)
  visiblesprites = {}
  numFrames = (Graphics.frame_rate*0.4).floor
  numFrames = 1 if $PokemonSystem.skip_fades == 0
  alphaDiff = (255.0/numFrames).ceil
  pbDeactivateWindows(sprites) {
    for j in 0..numFrames
      pbSetSpritesToColor(sprites,Color.new(0,0,0,j*alphaDiff))
      (block_given?) ? yield : pbUpdateSpriteHash(sprites)
    end
  }
  for i in sprites
    next if !i[1]
    next if pbDisposed?(i[1])
    visiblesprites[i[0]] = true if i[1].visible
    i[1].visible = false
  end
  return visiblesprites
end

def pbFadeInAndShow(sprites,visiblesprites=nil)
  if visiblesprites
    for i in visiblesprites
      if i[1] && sprites[i[0]] && !pbDisposed?(sprites[i[0]])
        sprites[i[0]].visible = true
      end
    end
  end
  numFrames = (Graphics.frame_rate*0.4).floor
  numFrames = 1 if $PokemonSystem.skip_fades == 0
  alphaDiff = (255.0/numFrames).ceil
  pbDeactivateWindows(sprites) {
    for j in 0..numFrames
      pbSetSpritesToColor(sprites,Color.new(0,0,0,((numFrames-j)*alphaDiff)))
      (block_given?) ? yield : pbUpdateSpriteHash(sprites)
    end
  }
end

def pbChangePlayer(id)
  return false if id < 0 || id >= 8
  meta = GameData::Metadata.get_player(id)
  return false if !meta
  $Trainer.character_ID = id
  $PokemonSystem.gendered_look = id
  $Trainer.trainer_type = meta[0]
  $game_player.character_name = meta[1]
end

def pbStartTrade(pokemonIndex,newpoke,nickname,trainerName,trainerGender=0)
  myPokemon = $Trainer.party[pokemonIndex]
  pbTakeItemsFromPokemon(myPokemon) if myPokemon.hasItem?
  opponent = NPCTrainer.new(trainerName,trainerGender)
  opponent.id = $Trainer.make_foreign_ID
  yourPokemon = nil
  resetmoves = true
  if newpoke.is_a?(Pokemon)
    newpoke.owner = Pokemon::Owner.new_from_trainer(opponent)
    yourPokemon = newpoke
    resetmoves = false
  else
    species_data = GameData::Species.try_get(newpoke)
    raise _INTL("Species does not exist ({1}).", newpoke) if !species_data
    yourPokemon = Pokemon.new(species_data.id, myPokemon.level, opponent)
  end
  yourPokemon.name          = nickname
  yourPokemon.obtain_method = 2   # traded
  yourPokemon.reset_moves if resetmoves
  yourPokemon.record_first_moves
  $Trainer.pokedex.register(yourPokemon)
  $Trainer.pokedex.set_owned(yourPokemon.species)
  pbFadeOutInWithMusic {
    evo = PokemonTrade_Scene.new
    evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,opponent.name)
    evo.pbTrade
    evo.pbEndScreen
  }
  $Trainer.party[pokemonIndex] = yourPokemon
  refreshFollow(false)
end


def globalMessageReplacements(message)
    return message if message.frozen?
    message.gsub!("’","'")
    message.gsub!("‘","'")
    message.gsub!("“","\"")
    message.gsub!("”","\"")
  	message.gsub!("…","...")
	  message.gsub!("–","-")
	  message.gsub!("Pokemon","Pokémon")
	  message.gsub!("Pokedex","Pokédex")
    message.gsub!("Poke ball","Poké Ball")
    message.gsub!("Poke Ball","Poké Ball")
    message.gsub!("Pokeball","Poké Ball")
    message.gsub!("PokEstate","PokÉstate")

    return message
end