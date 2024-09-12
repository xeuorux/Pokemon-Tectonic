module Compiler
  module_function

  #=============================================================================
  # Main compiler method for events
  #=============================================================================
  def compile_events
    mapData = MapData.new
    t = Time.now.to_i
    Graphics.update
    trainerChecker = TrainerChecker.new
    for id in mapData.mapinfos.keys.sort
      changed = false
      map = mapData.getMap(id)
      next if !map || !mapData.mapinfos[id]
	    mapName = mapData.mapinfos[id].name
      pbSetWindowText(_INTL("Processing map {1} ({2})",id,mapName))
      for key in map.events.keys
        if Time.now.to_i-t>=5
          Graphics.update
          t = Time.now.to_i
        end
        newevent = convert_to_trainer_event(map.events[key],trainerChecker)
        if newevent
          map.events[key] = newevent
          changed = true
        end
        newevent = convert_to_item_event(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = convert_chasm_style_trainers(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = convert_avatars(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = convert_placeholder_pokemon(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = convert_overworld_pokemon(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = change_overworld_placeholders(map.events[key])
		    if newevent
          map.events[key] = newevent
          changed = true
        end
        changed = true if fix_event_name(map.events[key])
        newevent = fix_event_use(map.events[key],id,mapData)
        if newevent
          map.events[key] = newevent
          changed = true
        end
      end
      if Time.now.to_i-t>=5
        Graphics.update
        t = Time.now.to_i
      end
      changed = true if check_counters(map,id,mapData)
      if changed
        mapData.saveMap(id)
        mapData.saveTilesets
      end
    end
    changed = false
    Graphics.update
    commonEvents = load_data("Data/CommonEvents.rxdata")
    pbSetWindowText(_INTL("Processing common events"))
    for key in 0...commonEvents.length
      newevent = fix_event_use(commonEvents[key],0,mapData)
      if newevent
        commonEvents[key] = newevent
        changed = true
      end
    end
    save_data(commonEvents,"Data/CommonEvents.rxdata") if changed
  end

  def edit_maps
    wallReplaceConvexID = GameData::TerrainTag.get(:WallReplaceConvex).id_number
  
    # Iterate over all maps
    mapData = Compiler::MapData.new
    tilesets_data = load_data("Data/Tilesets.rxdata")
    for id in mapData.mapinfos.keys.sort
        map = mapData.getMap(id)
        next if !map || !mapData.mapinfos[id]
        mapName = mapData.mapinfos[id].name

        # Grab the tileset here
        tileset = tilesets_data[map.tileset_id]

        next if tileset.nil?

        # Iterate over all tiles, finding the first with the relevant tag
        taggedPositions = []
        for x in 0..map.data.xsize
          for y in 0..map.data.ysize
            currentID = map.data[x, y, 1]
            next if currentID.nil?
            currentTag = tileset.terrain_tags[currentID]
            if currentTag == wallReplaceConvexID
              taggedPositions.push([x,y])
            end
          end
        end  

        next if taggedPositions.length == 0

        echoln("Map #{mapName} contains some WallReplaceConvex tiles")

        changeNum = 0
        taggedPositions.each do |position|
          taggedX = position[0]
          taggedY = position[1]

          touchedDirs = 0b0000 # North, East, South, West
          taggedPositions.each do |position2|
            posX = position2[0]
            posY = position2[1]
            # North
            touchedDirs = touchedDirs | 0b1000 if posX == taggedX && posY == taggedY - 1
            # East
            touchedDirs = touchedDirs | 0b0100 if posY == taggedY && posX == taggedX + 1
            # South
            touchedDirs = touchedDirs | 0b0010 if posX == taggedX && posY == taggedY + 1
            # West
            touchedDirs = touchedDirs | 0b0001 if posY == taggedY && posX == taggedX - 1
          end

          tileIDToAdd = 0
          if touchedDirs == 0b1100 # Northeast
            tileIDToAdd = 1485
          elsif touchedDirs == 0b1001 # NorthWest
            tileIDToAdd = 1487
          elsif touchedDirs == 0b0110 # Southeast
            tileIDToAdd = 1469
          elsif touchedDirs == 0b0011 # Southwest
            tileIDToAdd = 1471
          end

          next if tileIDToAdd == 0

          map.data[taggedX,taggedY,1] = tileIDToAdd
          changeNum += 1
        end

        if changeNum > 0
          echoln("Saving map after changing #{changeNum} tiles: #{mapName} (#{id})")
          mapData.saveMap(id)
        else
          echoln("Unable to make any changes to: #{mapName} (#{id})")
        end
    end
  end

  def tile_ID_from_coordinates(x, y)
    return x * TILES_PER_AUTOTILE if y == 0   # Autotile
    return TILESET_START_ID + (y - 1) * TILES_PER_ROW + x
  end
  
  #=============================================================================
  # Convert events using the PHT command into fully fledged trainers
  #=============================================================================
  def convert_chasm_style_trainers(event)
    return nil if !event || event.pages.length==0
    match = event.name.match(/PHT\(([_a-zA-Z0-9]+),([_a-zA-Z]+),([0-9]+)\)/)
    return nil if !match
    ret = RPG::Event.new(event.x,event.y)
    ret.id   = event.id
    ret.pages = []
    trainerTypeName = match[1]
    return nil if !trainerTypeName || trainerTypeName == ""
    trainerName = match[2]
    ret.name = "resettrainer(4)stinkable - " + trainerTypeName + " " + trainerName
    trainerMaxLevel = match[3]
    ret.pages = [3]
    
    # Create the first page, where the battle happens
    firstPage = RPG::Event::Page.new
    ret.pages[0] = firstPage
    firstPage.graphic.character_name = trainerTypeName
    firstPage.trigger = 2   # On event touch
    firstPage.list = []
    push_script(firstPage.list,"pbTrainerIntro(:#{trainerTypeName})")
    push_script(firstPage.list,"pbNoticePlayer(get_self)")
    push_text(firstPage.list,"Dialogue here.")
    
    push_branch(firstPage.list,"pbTrainerBattle(:#{trainerTypeName},\"#{trainerName}\")")
    push_branch(firstPage.list,"battlePerfected?",1)
    push_text(firstPage.list,"Dialogue here.",2)
    push_script(firstPage.list,"perfectTrainer(#{trainerMaxLevel})",2)
    push_else(firstPage.list,2)
    push_text(firstPage.list,"Dialogue here.",2)
    push_script(firstPage.list,"defeatTrainer",2)
    push_branch_end(firstPage.list,2)
    push_branch_end(firstPage.list,1)
    
    push_script(firstPage.list,"pbTrainerEnd")
    push_end(firstPage.list)
    
    # Create the second page, which has a talkable action-button graphic
    secondPage = RPG::Event::Page.new
    ret.pages[1] = secondPage
    secondPage.graphic.character_name = trainerTypeName
    secondPage.condition.self_switch_valid = true
    secondPage.condition.self_switch_ch = "A"
    secondPage.list = []
    push_text(secondPage.list,"Dialogue here.")
    push_end(secondPage.list)
    
    # Create the third page, which has no functionality and no graphic
    thirdPage = RPG::Event::Page.new
    ret.pages[2] = thirdPage
    thirdPage.condition.self_switch_valid = true
    thirdPage.condition.self_switch_ch = "D"
    thirdPage.list = []
    push_end(thirdPage.list)
    
    return ret
  end
    
  #=============================================================================
  # Convert events using the PHA name command into fully fledged avatars
  #=============================================================================
  def convert_avatars(event)
    return nil if !event || event.pages.length==0
    match = event.name.match(/.*PHA\(([_a-zA-Z0-9]+),([0-9]+)(?:,([0-9]+))?(?:,([_a-zA-Z]+))?(?:,([_a-zA-Z0-9]+))?(?:,([0-9]+))?\).*/)
    return nil if !match
    ret = RPG::Event.new(event.x,event.y)
    ret.id   = event.id
    ret.pages = []
    avatarSpecies = match[1]
    ret.name = "size(2,2)trainer(4) - " + avatarSpecies
    legendary = GameData::Species.get(avatarSpecies).isLegendary?
    return nil if !avatarSpecies || avatarSpecies == ""
    level = match[2]
    version = match[3] || 0
    directionText = match[4]
    item = match[5] || nil
    itemCount = match[6].to_i || 0
    
    direction = Down
    if !directionText.nil?
      case directionText.downcase
      when "left"
        direction = Left
      when "right"
        direction = Right
      when "up"
        direction = Up
      else
        direction = Down
      end
    end
    
    ret.pages = [2]
    # Create the first page, where the battle happens
    firstPage = RPG::Event::Page.new
    ret.pages[0] = firstPage
    firstPage.graphic.character_name = "zAvatar_#{avatarSpecies}"
    firstPage.graphic.opacity = 180
    firstPage.graphic.direction = direction
    firstPage.trigger = 2   # On event touch
    firstPage.step_anime = true # Animate while still
    firstPage.list = []
    push_script(firstPage.list,"pbNoticePlayer(get_self)")
    push_script(firstPage.list,"introduceAvatar(:#{avatarSpecies})")
    avatarEntry = "[:#{avatarSpecies},#{level},#{version}]"
    push_branch(firstPage.list,"pb#{legendary ? "Big" : "Small"}AvatarBattle(#{avatarEntry})")
    if item.nil?
      push_script(firstPage.list,"defeatBoss",1)
    else
      if itemCount > 1
        push_script(firstPage.list,"defeatBoss(:#{item},#{itemCount})",1)
      else
        push_script(firstPage.list,"defeatBoss(:#{item})",1)
      end
    end
      push_branch_end(firstPage.list,1)
    push_end(firstPage.list)
    
    # Create the second page, which has nothing
    secondPage = RPG::Event::Page.new
    ret.pages[1] = secondPage
    secondPage.condition.self_switch_valid = true
    secondPage.condition.self_switch_ch = "A"
    
    return ret
  end
    
  #=============================================================================
  # Convert events using the PHP name command into fully fledged overworld pokemon
  #=============================================================================
  def convert_placeholder_pokemon(event)
    return nil if !event || event.pages.length==0
    match = event.name.match(/.*PHP\(([a-zA-Z0-9]+)(?:_([0-9]*))?(?:,([_a-zA-Z]+))?(?:,([_a-zA-Z]+))?.*/)
    return nil if !match
    species = match[1]
    return if !species
    species = species.upcase
    form	= match[2]
    form = 0 if !form || form == ""
    speciesData = GameData::Species.get(species.to_sym)
    return if !speciesData
    directionText = match[3]
    direction = Down
    if directionText
      case directionText.downcase
      when "left"
        direction = Left
      when "right"
        direction = Right
      when "up"
        direction = Up
      else
        direction = Down
      end
    end

    shinyText = match[4]
    shiny = false
    if shinyText
        shiny = true if shinyText.downcase.include?("true")
    end
    
    echoln("Converting event: #{species},#{form},#{direction},#{shiny}")
    
    ret = RPG::Event.new(event.x,event.y)
    ret.name = "Overworld " + speciesData.real_name
    ret.id   = event.id
    ret.pages = [3]
    
    # Create the first page, where the cry happens
    firstPage = RPG::Event::Page.new
    ret.pages[0] = firstPage
    fileName = species
    fileName += "_" + form.to_s if form != 0
    if shiny
        firstPage.graphic.character_name = "Followers shiny/#{fileName}"
    else
        firstPage.graphic.character_name = "Followers/#{fileName}"
    end
    firstPage.graphic.direction = direction
    firstPage.step_anime = true # Animate while still
    firstPage.trigger = 0 # Action button
    firstPage.list = []
    if shiny
        push_script(firstPage.list,sprintf("overworldPokemonInteract(:%s, %d, %s)",speciesData.id,form,shiny.to_s))
    elsif form != 0
        push_script(firstPage.list,sprintf("overworldPokemonInteract(:%s, %d)",speciesData.id,form))
    else
        push_script(firstPage.list,sprintf("overworldPokemonInteract(:%s)",speciesData.id,form))
    end
    push_end(firstPage.list)
    
    return ret
  end
  
  #=============================================================================
  # Convert events using the overworld name command to use the correct graphic.
  #=============================================================================
  def convert_overworld_pokemon(event)
    return nil if !event || event.pages.length==0
    match = event.name.match(/(.*)?overworld\(([a-zA-Z0-9]+)\)(.*)?/)
    return nil if !match
    nameStuff = match[1] || ""
    nameStuff += match[3] || ""
    nameStuff += match[2] || ""
    species = match[2]
    return nil if !species
    
    event.name = nameStuff
    event.pages.each do |page|
      next if page.graphic.character_name != "00Overworld Placeholder"
      page.graphic.character_name = "Followers/#{species}" 
    end
    
    return event
    end
    
    def change_overworld_placeholders(event)
    return nil if !event || event.pages.length==0
    return nil unless event.name.downcase.include?("boxplaceholder")
    
    return nil
    #event.pages.each do |page|
    #	page.move_type = 1
    #end
    
    return event
    end
end

def overworldPokemonInteract(species, form = 0, shiny = false)
    Pokemon.play_cry(species, form)
    speciesData = GameData::Species.get_species_form(species,form)
    pbMessage(_INTL("{1} cries out!",speciesData.real_name))
    pbMessage(_INTL("Wow, it's a shiny Pokémon!")) if shiny
end