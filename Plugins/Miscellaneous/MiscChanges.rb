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
		  if data.abilities.include?(:LEVITATE) || data.abilities.include?(:DESERTSPIRIT)
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

DebugMenuCommands.register("reformulatecatchrates", {
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
        next
      end
      newRarity = newRarity.floor
      diff = (newRarity - sp.catch_rate)
      totalDiff += diff
      diff  = "+".concat(diff.to_s) if diff > 0
      numSpecies += 1
      pokeballRate = (PokeBattle_Battle.captureThresholdCalcInternals(:NONE,50,300,newRarity).to_f/CATCH_BASE_CHANCE.to_f ) ** 4
      pokeballRate = (pokeballRate * 10000).floor / 100
      ultraballRate = (PokeBattle_Battle.captureThresholdCalcInternals(:NONE,50,300,newRarity * 2).to_f/CATCH_BASE_CHANCE.to_f ) ** 4
      ultraballRate = (ultraballRate * 10000).floor / 100
      end
      averageChange = totalDiff/numSpecies
	  
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

def pbChooseList(commands, default = 0, cancelValue = -1, sortType = 1)
  cmdwin = pbListWindow([])
  itemID = default
  itemIndex = 0
  sortMode = (sortType >= 0) ? sortType : 0   # 0=ID, 1=alphabetical
  sorting = true
  loop do
    if sorting
      if sortMode == 0
        commands.sort! { |a, b| a[0] <=> b[0] }
      elsif sortMode == 1
        commands.sort! { |a, b| a[1] <=> b[1] }
      end
      if itemID.is_a?(Symbol)
        commands.each_with_index { |command, i| itemIndex = i if command[2] == itemID }
      elsif itemID && itemID > 0
        commands.each_with_index { |command, i| itemIndex = i if command[0] == itemID }
      end
      realcommands = []
      for command in commands
        if sortType <= 0
          realcommands.push(sprintf("%03d: %s", command[0], command[1]))
        else
          realcommands.push(command[1])
        end
      end
      sorting = false
    end
    cmd = pbCommandsSortable(cmdwin, realcommands, -1, itemIndex, (sortType < 0))
    if cmd[0] == 0   # Chose an option or cancelled
      itemID = (cmd[1] < 0) ? cancelValue : (commands[cmd[1]][2] || commands[cmd[1]][0])
      break
    elsif cmd[0] == 1   # Toggle sorting
      itemID = commands[cmd[1]][2] || commands[cmd[1]][0]
      sortMode = (sortMode + 1) % 2
      sorting = true
    elsif cmd[0] == 2   # Go to first matching
      text = pbEnterText("Enter selection.",0,20).downcase
      if text.blank?
        sorting = true
        next
      end
      changed = false
      commands.each_with_index { |command, i|
        next if i == itemIndex
        if command[1].downcase.start_with?(text) || command[2].to_s.downcase.start_with?(text) # Real name, or ID
          itemIndex = i
          changed = true
        end
      }
      pbMessage(_INTL("Could not find a command entry matching that input.")) if !changed
      sorting = true
      end
    end
  cmdwin.dispose
  return itemID
end

def pbCommandsSortable(cmdwindow,commands,cmdIfCancel,defaultindex=-1,sortable=false)
  cmdwindow.commands = commands
  cmdwindow.index    = defaultindex if defaultindex >= 0
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  cmdwindow.width    = Graphics.width / 2 if cmdwindow.width < Graphics.width / 2
  cmdwindow.height   = Graphics.height
  cmdwindow.z        = 99999
  cmdwindow.active   = true
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::ACTION) && sortable
      command = [1,cmdwindow.index]
      break
    elsif Input.trigger?(Input::BACK)
      command = [0,(cmdIfCancel>0) ? cmdIfCancel-1 : cmdIfCancel]
      break
    elsif Input.trigger?(Input::USE)
      command = [0,cmdwindow.index]
      break
	elsif Input.trigger?(Input::SPECIAL)
      command = [2,cmdwindow.index]
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
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

def pbListScreen(title,lister)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  list = pbListWindow([])
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(title,
     Graphics.width / 2, 0, Graphics.width / 2, 64, viewport)
  title.z = 2
  lister.setViewport(viewport)
  selectedIndex = -1
  commands = lister.commands
  selindex = lister.startIndex
  if commands.length==0
    value = lister.value(-1)
    lister.dispose
    title.dispose
    list.dispose
    viewport.dispose
    return value
  end
  list.commands = commands
  list.index    = selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index != selectedIndex
      lister.refresh(list.index)
      selectedIndex = list.index
    end
    if Input.trigger?(Input::BACK)
      selectedIndex = -1
      break
    elsif Input.trigger?(Input::USE)
      break
    elsif Input.trigger?(Input::SPECIAL)
      inputText = pbEnterText("Enter selection.",0,20).downcase
      if inputText.blank?
        next
      end

      newIndex = -1
      list.commands.each_with_index do |command,index|
        if command.to_s.downcase.include?(inputText)
          newIndex = index
          break
        end
      end

      if newIndex == -1
        pbMessage(_INTL("Could not find a command entry matching that input."))
      else
        list.index = newIndex
      end
    end
  end
  value = lister.value(selectedIndex)
  lister.dispose
  title.dispose
  list.dispose
  viewport.dispose
  Input.update
  return value
end