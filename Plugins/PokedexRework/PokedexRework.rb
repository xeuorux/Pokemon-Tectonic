module Settings
	USE_CURRENT_REGION_DEX = true
	def self.pokedex_names
		return [
		_INTL("National Pokédex")
		]
	end
	DEX_SHOWS_ALL_FORMS = true
end


def setAllPokemonSeen
  $Trainer.pokedex.unlock(-1)
  legendaries1 = [144,145,146,150,151]
  legendaries2 = [243,244,245,249,250,251]
  legendaries3 = (377..386).to_a
  legendaries4 = (480..494).to_a
  legendaries5 = (638..649).to_a
  legendaries6 = (716..721).to_a
  legendaries7 = (785..809).to_a
  legendaries8 = (888..898).to_a
  legendaries = [legendaries1,legendaries2,legendaries3,legendaries4,legendaries5,legendaries6,legendaries7,legendaries8].flatten
  GameData::Species.each do |species_data|
	  next if species_data.form != 0 || legendaries.include?(species_data.id_number)
      sp = species_data.species
      $Trainer.pokedex.set_seen(sp,false)
  end
  $Trainer.pokedex.refresh_accessible_dexes()
end

class PokemonPokedex_Scene
	def pbGetDexList
		region = pbGetPokedexRegion
		regionalSpecies = pbAllRegionalSpecies(region)
		if !regionalSpecies || regionalSpecies.length == 0
		  # If no Regional Dex defined for the given region, use the National Pokédex
		  regionalSpecies = []
		  GameData::Species.each { |s| regionalSpecies.push(s.id) if s.form == 0 }
		end
		shift = Settings::DEXES_WITH_OFFSETS.include?(region)
		ret = []
		regionalSpecies.each_with_index do |species, i|
		  next if !species
		  next if !pbCanAddForModeList?($PokemonGlobal.pokedexMode, species)
		  species_data = GameData::Species.get(species)
		  color  = species_data.color
		  type1  = species_data.type1
		  type2  = species_data.type2 || type1
		  shape  = species_data.shape
		  height = species_data.height
		  weight = species_data.weight
		  
		  abilities = species_data.abilities
          lvlmoves = species_data.moves
		  tutormoves = species_data.tutor_moves
		  
		  firstSpecies = GameData::Species.get(species)
		  while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		  end
		
		  eggmoves = firstSpecies.egg_moves
		  
		  # 0 = National Species
          # 1 = Name
          # 2 = Height
          # 3 = Weight
          # 4 = Number
          # 5 = Shift
          # 6 = 1st Type
          # 7 = 2nd Type
          # 8 = Color
          # 9 = Shape
          # 10 Abilities
          # 11 Level Up Moves
		  # 12 Tutor Moves
		  
		  ret.push([species, species_data.name, height, weight, i + 1, shift, type1, type2, color, shape, abilities, lvlmoves, tutormoves, eggmoves])
		end
		return ret
	  end

	def pbPokedex
    pbActivateWindow(@sprites,"pokedex") {
      loop do
        Graphics.update
        Input.update
        oldindex = @sprites["pokedex"].index
        pbUpdate
        if oldindex!=@sprites["pokedex"].index
          $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index if !@searchResults
          pbRefresh
        end
        if Input.trigger?(Input::ACTION)
          pbPlayDecisionSE
          @sprites["pokedex"].active = false
          pbDexSearch
          @sprites["pokedex"].active = true
        elsif Input.trigger?(Input::BACK)
          if @searchResults
            pbPlayCancelSE
            pbCloseSearch
          else
            pbPlayCloseMenuSE
            break
          end
        elsif Input.trigger?(Input::USE)
          if $Trainer.pokedex.seen?(@sprites["pokedex"].species)
            pbPlayDecisionSE
            pbDexEntry(@sprites["pokedex"].index)
          end
        # Searching for pokemon by name
        elsif !Input.press?(Input::CTRL) && Input.press?(Input::AUX1)
          pbPlayDecisionSE
          @sprites["pokedex"].active = false
          name = pbEnterPokemonName("Search species...", 1, 12)
          dexlist = pbGetDexList
          dexlist = dexlist.find_all { |item|
            next false if !$Trainer.seen?(item[0]) && !$DEBUG
            searchPokeName = item[1]
            next searchPokeName.downcase.include?(name.downcase)
          }
          if dexlist.length==0
            pbMessage(_INTL("No matching Pokémon were found."))
          else
            @dexlist = dexlist
            @sprites["pokedex"].commands = @dexlist
            @sprites["pokedex"].index    = 0
            @sprites["pokedex"].refresh
            @searchResults = true
          end
          @sprites["pokedex"].active = true
          pbRefresh
        # Searching for pokemon by ability
        elsif Input.press?(Input::CTRL) && Input.press?(Input::AUX2)
          pbPlayDecisionSE
          @sprites["pokedex"].active = false
          name = pbEnterPokemonName("Search abilities...", 1, 12)
          dexlist = pbGetDexList
          dexlist = dexlist.find_all { |item|
            next false if !$Trainer.seen?(item[0]) && !$DEBUG
            searchPokeAbilities = item[10]
			next false if !searchPokeAbilities
            next true if searchPokeAbilities[0] && searchPokeAbilities[0].name.downcase.include?(name.downcase)
            next true if searchPokeAbilities[1] && searchPokeAbilities[1].name.downcase.include?(name.downcase)
            next false
          }
          if dexlist.length==0
            pbMessage(_INTL("No matching Pokémon were found."))
          else
            @dexlist = dexlist
            @sprites["pokedex"].commands = @dexlist
            @sprites["pokedex"].index    = 0
            @sprites["pokedex"].refresh
            @searchResults = true
          end
          @sprites["pokedex"].active = true
          pbRefresh
        # Searching for pokemon by move learned
        elsif Input.press?(Input::CTRL) && Input.press?(Input::AUX1)
          pbPlayDecisionSE
          @sprites["pokedex"].active = false
          name = pbEnterPokemonName("Search moves...", 1, 12)
          
          dexlist = pbGetDexList
          dexlist = dexlist.find_all { |item|
            next false if !$Trainer.seen?(item[0]) && !$DEBUG
            contains = false
			
			lvlmoves = item[11]
			lvlmoves.each do |move|
              if GameData::Move.get(move[1]).real_name.downcase.include?(name.downcase)
                contains = true
                break
              end
            end
            next true if contains
			
			tutormoves = item[12]
            tutormoves.each do |move|
              if GameData::Move.get(move).real_name.downcase.include?(name.downcase)
                contains = true
                break
              end
            end
			next true if contains
			
			eggmoves = item[13]
            eggmoves.each do |move|
              if GameData::Move.get(move).real_name.downcase.include?(name.downcase)
                contains = true
                break
              end
            end
			
            next contains
          }
          if dexlist.length==0
            pbMessage(_INTL("No matching Pokémon were found."))
          else
            @dexlist = dexlist
            @sprites["pokedex"].commands = @dexlist
            @sprites["pokedex"].index    = 0
            @sprites["pokedex"].refresh
            @searchResults = true
          end
          @sprites["pokedex"].active = true
          pbRefresh
        #Search by types
        elsif !Input.press?(Input::CTRL) && Input.press?(Input::AUX2)
          pbPlayDecisionSE
          @sprites["pokedex"].active = false
          typeName = pbEnterPokemonName("Search types...", 1, 12)
          dexlist = pbGetDexList
          dexlist = dexlist.find_all { |item|
            next false if !$Trainer.seen?(item[0]) && !$DEBUG
            searchPokeType1 = item[6]
            searchPokeType1Name = GameData::Type.get(searchPokeType1).real_name if searchPokeType1
            searchPokeType2 = item[7]
            searchPokeType2Name = GameData::Type.get(searchPokeType2).real_name if searchPokeType2
            next searchPokeType1Name.downcase.include?(typeName.downcase) || searchPokeType2Name.downcase.include?(typeName.downcase)
          }
          if dexlist.length==0
            pbMessage(_INTL("No matching Pokémon were found."))
          else
            @dexlist = dexlist
            @sprites["pokedex"].commands = @dexlist
            @sprites["pokedex"].index    = 0
            @sprites["pokedex"].refresh
            @searchResults = true
          end
          @sprites["pokedex"].active = true
          pbRefresh
        end
      end
    }
  end
end


class PokemonPokedexInfo_Scene
  def pbStartScene(dexlist,index,region)
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @dexlist = dexlist
    @index   = index
    @region  = region
    @page = 1
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::Center)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @mapdata = pbLoadTownMapData
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    mappos = (map_metadata) ? map_metadata.town_map_position : nil
    if @region < 0                                 # Use player's current region
      @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    end
    @sprites["areamap"] = IconSprite.new(0,0,@viewport)
    @sprites["areamap"].setBitmap("Graphics/Pictures/#{@mapdata[@region][1]}")
    @sprites["areamap"].x += (Graphics.width-@sprites["areamap"].bitmap.width)/2
    @sprites["areamap"].y += (Graphics.height+32-@sprites["areamap"].bitmap.height)/2
    for hidden in Settings::REGION_MAP_EXTRAS
      if hidden[0]==@region && hidden[1]>0 && $game_switches[hidden[1]]
        pbDrawImagePositions(@sprites["areamap"].bitmap,[
           ["Graphics/Pictures/#{hidden[4]}",
              hidden[2]*PokemonRegionMap_Scene::SQUAREWIDTH,
              hidden[3]*PokemonRegionMap_Scene::SQUAREHEIGHT]
        ])
      end
    end
    @sprites["areahighlight"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["areaoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["areaoverlay"].setBitmap("Graphics/Pictures/Pokedex/overlay_area")
    @sprites["formfront"] = PokemonSprite.new(@viewport)
    @sprites["formfront"].setOffset(PictureOrigin::Center)
    @sprites["formfront"].x = 130
    @sprites["formfront"].y = 158
    @sprites["formback"] = PokemonSprite.new(@viewport)
    @sprites["formback"].setOffset(PictureOrigin::Bottom)
    @sprites["formback"].x = 382   # y is set below as it depends on metrics
    @sprites["formicon"] = PokemonSpeciesIconSprite.new(nil, @viewport)
    @sprites["formicon"].setOffset(PictureOrigin::Center)
    @sprites["formicon"].x = 82
    @sprites["formicon"].y = 328
	@sprites["formicon2"] = PokemonSpeciesIconSprite.new(0,@viewport)
    @sprites["formicon2"].setOffset(PictureOrigin::Center)
    @sprites["formicon2"].x = 450
    @sprites["formicon2"].y = 90
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 268
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 348
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @scroll = 0
	@title = "Undefined"
	pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    @available = pbGetAvailableForms
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSceneBrief(species)  # For standalone access, shows first page only
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
#    @region = 0
    dexnum = species
    dexnumshift = false
    if $Trainer.pokedex.unlocked?(-1)   # National Dex is unlocked
      species_data = GameData::Species.try_get(species)
      dexnum = species_data.id_number if species_data
      dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(-1)
    else
      dexnum = 0
      for i in 0...$Trainer.pokedex.dexes_count - 1   # Regional Dexes
        next if !$Trainer.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i,species)
        next if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    @dexlist = [[species,"",0,0,dexnum,dexnumshift]]
    @index   = 0
    @page = 1
    @brief = true
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::Center)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @viewport.dispose
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateDummyPokemon
    @species = @dexlist[@index][0]
    @gender, @form = $Trainer.pokedex.last_form_seen(@species)
    species_data = GameData::Species.get_species_form(@species, @form)
	@title = species_data.real_form_name || species_data.real_name
    @sprites["infosprite"].setSpeciesBitmap(@species,@gender,@form)
    if @sprites["formfront"]
      @sprites["formfront"].setSpeciesBitmap(@species,@gender,@form)
    end
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species,@gender,@form,false,false,true)
      @sprites["formback"].y = 256
      @sprites["formback"].y += species_data.back_sprite_y * 2
    end
    if @sprites["formicon"]
      @sprites["formicon"].pbSetParams(@species,@gender,@form)
    end
	if @sprites["formicon2"]
      @sprites["formicon2"].pbSetParams(@species,@gender,@form)
    end
  end

  def pbGetAvailableForms
    ret = []
    multiple_forms = false
    # Find all genders/forms of @species that have been seen
    GameData::Species.each do |sp|
      next if sp.species != @species
      next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)
      next if sp.pokedex_form != sp.form
      multiple_forms = true if sp.form > 0
      case sp.gender_ratio
      when :AlwaysMale, :AlwaysFemale, :Genderless
        real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
        next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
        real_gender = 2 if sp.gender_ratio == :Genderless
        ret.push([sp.form_name, real_gender, sp.form])
      else   # Both male and female
        for real_gender in 0...2
          next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
          ret.push([sp.form_name, real_gender, sp.form])
          break if sp.form_name && !sp.form_name.empty?   # Only show 1 entry for each non-0 form
        end
      end
    end
    # Sort all entries
    ret.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
    # Create form names for entries if they don't already exist
    ret.each do |entry|
      if !entry[0] || entry[0].empty?   # Necessarily applies only to form 0
        case entry[1]
        when 0 then entry[0] = _INTL("Male")
        when 1 then entry[0] = _INTL("Female")
        else
          entry[0] = (multiple_forms) ? _INTL("One Form") : _INTL("Genderless")
        end
      end
      entry[1] = 0 if entry[1] == 2   # Genderless entries are treated as male
    end
    return ret
  end
  
  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Make certain sprites visible
	@sprites["infosprite"].visible    = (@page==1)
    @sprites["areamap"].visible       = false if @sprites["areamap"] #(@page==7) if @sprites["areamap"]
    @sprites["areahighlight"].visible = false if @sprites["areahighlight"] #(@page==7) if @sprites["areahighlight"]
    @sprites["areaoverlay"].visible   = false if @sprites["areaoverlay"] #(@page==7) if @sprites["areaoverlay"]
    @sprites["formfront"].visible     = (@page==10) if @sprites["formfront"]
    @sprites["formback"].visible      = (@page==10) if @sprites["formback"]
    @sprites["formicon"].visible      = (@page==10) if @sprites["formicon"]
	@sprites["formicon2"].visible      = (@page!=1 && @page <9) if @sprites["formicon2"]
	# Draw page title
	overlay = @sprites["overlay"].bitmap
	base = Color.new(219, 240, 240)
	shadow   = Color.new(88, 88, 80)
	pageTitles = ["INFO", "ABILITIES", "STATS", "TYPE MATCHUPS", "LEVEL UP MOVES", "TUTOR MOVES", "EGG MOVES", "EVOLUTIONS", "AREA", "FORMS"]
	formTitle = pageTitles[page-1]
	drawFormattedTextEx(overlay, 50, 2, Graphics.width, "<outln2>#{formTitle}</outln2>", base, shadow, 18)
	xPos = 240
	xPos -= 14 if @page >= 10
	drawFormattedTextEx(overlay, xPos, 2, Graphics.width, "<outln2>[#{page}/10]</outln2>", base, shadow, 18)
    # Draw page-specific information
    case page
    when 1; drawPageInfo
    when 2; drawPageAbilities
    when 3; drawPageStats
	when 4; drawPageMatchups
    when 5; drawPageLevelUpMoves
	when 7; drawPageEggMoves
    when 6; drawPageTMMoves
    when 8; drawPageEvolution
	when 9; drawPageArea
	when 10; drawPageForms
    end
  end

  def drawPageInfo
	@sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_info"))
	overlay = @sprites["overlay"].bitmap
	base   = Color.new(88, 88, 80)
	shadow = Color.new(168, 184, 184)
	imagepos = []
	if @brief
	  imagepos.push([_INTL("Graphics/Pictures/Pokedex/overlay_info"), 0, 0])
	end
	species_data = GameData::Species.get_species_form(@species, @form)
	# Write various bits of text
	indexText = "???"
	if @dexlist[@index][4] > 0
	  indexNumber = @dexlist[@index][4]
	  indexNumber -= 1 if @dexlist[@index][5]
	  indexText = sprintf("%03d", indexNumber)
	end
	textpos = [
	   [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
		  246, 36, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)],
	   [_INTL("Height"), 314, 152, 0, base, shadow],
	   [_INTL("Weight"), 314, 184, 0, base, shadow]
	]
	if $Trainer.owned?(@species)
	  # Show the owned icon
	  imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 212, 44])
	end
	# Write the category
	textpos.push([_INTL("{1} Pokémon", species_data.category), 246, 68, 0, base, shadow])
	# Write the height and weight
	height = species_data.height
	weight = species_data.weight
	if System.user_language[3..4] == "US"   # If the user is in the United States
		inches = (height / 0.254).round
		pounds = (weight / 0.45359).round
		textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 460, 152, 1, base, shadow])
		textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 494, 184, 1, base, shadow])
	else
		textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 470, 152, 1, base, shadow])
		textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 482, 184, 1, base, shadow])
	end
	# Draw the Pokédex entry text
	drawTextEx(overlay, 40, 244, Graphics.width - (40 * 2), 4,   # overlay, x, y, width, num lines
			 species_data.pokedex_entry, base, shadow)
	# Draw the footprint
	footprintfile = GameData::Species.footprint_filename(@species, @form)
	if footprintfile
		footprint = RPG::Cache.load_bitmap("",footprintfile)
		overlay.blt(226, 138, footprint, footprint.rect)
		footprint.dispose
	end
	# Draw the type icon(s)
	type1 = species_data.type1
	type2 = species_data.type2
	type1_number = GameData::Type.get(type1).id_number
	type2_number = GameData::Type.get(type2).id_number
	type1rect = Rect.new(0, type1_number * 32, 96, 32)
	type2rect = Rect.new(0, type2_number * 32, 96, 32)
	overlay.blt(296, 120, @typebitmap.bitmap, type1rect)
	overlay.blt(396, 120, @typebitmap.bitmap, type2rect) if type1 != type2
	# Draw all text
	pbDrawTextPositions(overlay, textpos)
	# Draw all images
	pbDrawImagePositions(overlay, imagepos)
  end
  
  def drawPageAbilities
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_abilities"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
    for i in @available
      if i[2]==@form
        drawTextEx(overlay,30,54,450,1,_INTL("Abilities of {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
        abilities = fSpecies.abilities
        #ability 1
        drawTextEx(overlay,30,92,450,1,"Ability 1",base,shadow)
        if (abilities[0])
		  ability1 = GameData::Ability.get(abilities[0])
          drawTextEx(overlay,30,128,450,1,ability1.real_name,base,shadow)
          drawTextEx(overlay,30,160,450,2,ability1.real_description,base,shadow)
        else
          drawTextEx(overlay,30,128,450,1,"None",base,shadow)
        end
        #ability 1
        drawTextEx(overlay,30,92+142,450,1,"Ability 2",base,shadow)
        if (abilities[1])
          ability2 = GameData::Ability.get(abilities[1])
          drawTextEx(overlay,30,128+142,450,1,ability2.real_name,base,shadow)
          drawTextEx(overlay,30,160+142,450,2,ability2.real_description,base,shadow)
        else
          drawTextEx(overlay,30,128+142,450,1,"None",base,shadow)
        end
      end
    end
  end
  
  def genderRateToString(gender)
    case gender
    when :AlwaysMale;         return "Male"
    when :FemaleOneEighth;    return "7/8 Male"
    when :Female25Percent;    return "3/4 Male"
    when :Female50Percent;    return "50/50"
    when :Female75Percent;    return "3/4 Fem."
    when :FemaleSevenEighths; return "7/8 Fem."
    when :AlwaysFemale;       return "Female"
    when :Genderless;         return "None"
    end
    return "No data"
  end
  
  def growthRateToString(growthRate)
    case growthRate
      when :Medium;      return "Medium"
      when :Erratic;     return "Erratic"
      when :Fluctuating; return "Flux"
      when :Parabolic;  return "Med. Slow"
      when :Fast;        return "Fast"
      when :Slow;        return "Slow"
    end
  end
  
  def drawPageStats
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_stats"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
	baseStatNames = ["HP","Attack","Defense","Sp. Atk","Sp. Def", "Speed"]
    otherStatNames = ["Gender Rate", "Growth Rate", "Catch Dif.", "Exp. Grant", "Egg Group 1", "Egg Group 2"]
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,30,54,450,1,_INTL("Stats of {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
        
        #Base stats
        drawTextEx(overlay,30,90,450,1,"Base Stats",base,shadow)
        baseStats = fSpecies.base_stats
        total = 0
        baseStats.each_with_index do |stat, index|
          next if !stat
          total += stat[1]
          # Draw stat line
          drawTextEx(overlay,30,130+32*index,450,1,baseStatNames[index],base,shadow)
          drawTextEx(overlay,136,130+32*index,450,1,stat[1].to_s,base,shadow)
        end
        drawTextEx(overlay,30,130+32*6+14,450,1,"Total",base,shadow)
        drawTextEx(overlay,136,130+32*6+14,450,1,total.to_s,base,shadow)
        # Other stats
        drawTextEx(overlay,250,90,450,1,"Other Stats",base,shadow)
        otherStats = []
        genderRate = fSpecies.gender_ratio
        genderRateString = genderRateToString(genderRate)
        otherStats.push(genderRateString)
        growthRate = fSpecies.growth_rate
        growthRateString = growthRateToString(growthRate)
        otherStats.push(growthRateString)
        rareness = fSpecies.catch_rate
		
		if rareness>= 250
	      otherStats.push("F")
		elsif rareness>= 230
	      otherStats.push("D-")
		elsif rareness>= 210
	      otherStats.push("D")
		elsif rareness>= 190
	      otherStats.push("D+")
		elsif rareness>= 170
	      otherStats.push("C-")
		elsif rareness>= 150
	      otherStats.push("C")
	    elsif rareness>= 130
	      otherStats.push("C+")
	    elsif rareness>= 110
	      otherStats.push("B-")
        elsif rareness>= 90
          otherStats.push("B")
        elsif rareness >= 70
          otherStats.push("B+")
        elsif rareness >= 50
          otherStats.push("A-")
        elsif rareness >= 30
          otherStats.push("A")
        elsif rareness >= 10
          otherStats.push("A+")
        else
          otherStats.push("S")
        end

        otherStats.push(fSpecies.base_exp)
        compatibility = fSpecies.egg_groups
        compat1 = "None"
        compat2 = "None"
        
		compat1 = GameData::EggGroup.get(compatibility[0]).real_name if compatibility[0]
	    compat2 = GameData::EggGroup.get(compatibility[1]).real_name if compatibility[1]
		
        otherStats.push(compat1)
        otherStats.push(compat2)
        otherStats.each_with_index do |stat, index|
          next if !stat
          # Draw stat line
          drawTextEx(overlay,230,130+32*index,450,1,otherStatNames[index],base,shadow)
          drawTextEx(overlay,378,130+32*index,450,1,stat.to_s,base,shadow)
        end
      end
    end
  end
  
  def drawPageMatchups
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_matchups"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,30,54,450,1,_INTL("Matchups of {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
		
		#type1 = GameData::Type.get(fSpecies.type1)
		#type2 = GameData::Type.get(fSpecies.type2)
        
		immuneTypes = []
		resistentTypes = []
		weakTypes = []
		
		GameData::Type.each do |t|
			next if t.pseudo_type
			
			effect = Effectiveness.calculate(t.id,fSpecies.type1,fSpecies.type2)
			
			if Effectiveness.ineffective?(effect)
				immuneTypes.push(t)
			elsif Effectiveness.not_very_effective?(effect)
				resistentTypes.push(t)
			elsif Effectiveness.super_effective?(effect)
				weakTypes.push(t)
			end
		end
		
		#Draw the types the pokemon is weak to
		drawTextEx(overlay,30,80,450,1,_INTL("Weak:"),base,shadow)
		if weakTypes.length == 0
			rawTextEx(overlay,30,110,450,1,_INTL("None"),base,shadow)
		else
			weakTypes.each_with_index do |t,index|
				drawTextEx(overlay,30,110+30*index,450,1,_INTL("{1}",t.real_name),base,shadow)
			end
		end
		
		#Draw the types the pokemon resists
		drawTextEx(overlay,150,80,450,1,_INTL("Resist:"),base,shadow)
		if resistentTypes.length == 0
			drawTextEx(overlay,150,110,450,1,_INTL("None"),base,shadow)
		else
			resistentTypes.each_with_index do |t,index|
				drawTextEx(overlay,150,110+30*index,450,1,_INTL("{1}",t.real_name),base,shadow)
			end
		end
		
		#Draw the types the pokemon is immune to
		drawTextEx(overlay,310,80,450,1,_INTL("Immune:"),base,shadow)
		if immuneTypes.length == 0
			drawTextEx(overlay,310,110,450,1,_INTL("None"),base,shadow)
		else
			immuneTypes.each_with_index do |t,index|
				drawTextEx(overlay,310,110+30*index,450,1,_INTL("{1}",t.real_name),base,shadow)
			end
		end
      end
    end
  end
  
  
  
  def drawPageLevelUpMoves
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_moves"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,30,54,450,1,_INTL("Level Up Moves for {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
        learnset = fSpecies.moves
        trueIndex = 0
        @scrollableListLength = learnset.length
        learnset.each_with_index do |move,index|
          next if index<@scroll
          level = move[0]
          move = move[1]
          moveName = GameData::Move.get(move).real_name
          return if !move || !level || !moveName
          levelLabel = level.to_s
          if level == 0
            levelLabel = "E"
          end
          # Draw stat line
          drawTextEx(overlay,30,84+30*trueIndex,450,1,levelLabel,base,shadow)
          drawTextEx(overlay,60,84+30*trueIndex,450,1,moveName,base,shadow)
          trueIndex += 1
          break if trueIndex >= 9
        end
      end
    end
  end
  
  def drawPageEvolution
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_evolution"))
    overlay = @sprites["overlay"].bitmap
    formname = ""
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,30,54,450,1,_INTL("Evolutions of {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
		evolutions = fSpecies.get_evolutions
        evolutions.each_with_index do |evolution,index|
          method = evolution[1]
          parameter = evolution[2]
          species = evolution[0]
          return if !method || !species
          evolutionName = GameData::Species.get_species_form(species,i[2]).real_name
          methodDescription = describeEvolutionMethod(method,parameter)
          # Draw evolution description
          drawTextEx(overlay,30,84+60*index,450,2,_INTL("Evolves into {1} {2}",evolutionName,methodDescription),base,shadow)
        end
        if evolutions.length == 0
          drawTextEx(overlay,30,84,450,2,"None",base,shadow)
        end
      end
    end
  end

  def describeEvolutionMethod(method,parameter=0)
    case method
    when :Level; return "at level #{parameter}"
    when :LevelMale; return "at level #{parameter} if it's male"
    when :LevelFemale; return "at level #{parameter} if it's female"
    when :LevelDay; return "at level #{parameter} during the day"
    when :LevelNight; return "at level #{parameter} during nighttime"
    when :LevelRain; return "at level #{parameter} while raining"
    when :LevelDarkInParty; return "at level #{parameter} while a dark type is in the party"
    when :AttackGreater; return "at level #{parameter} if it has more attack than defense"
    when :AtkDefEqual; return "at level #{parameter} if it has attack equal to defense" 
    when :DefenseGreater; return "at level #{parameter} if it has more defense than attack" 
    when :Silcoon; return "at level #{parameter} half of the time"
    when :Cascoon; return "at level #{parameter} the other half of the time"
    when :Happiness; return "when leveled up while it has high happiness"
    when :MaxHappiness; return "when leveled up while it has maximum happiness"
    when :Beauty; return "when leveled up while it has maximum beauty"
    when :HasMove; return "when leveled up while it knows the move #{GameData::Move.get(parameter).real_name}"
    when :HasMoveType; return "when leveled up while it knows a move of the #{GameData::Move.get(parameter).real_name} type"
    when :Location; return "when leveled up near a special location"
    when :Item; return "when a #{GameData::Item.get(parameter).real_name} is used on it"
    when :ItemMale; return "when a #{GameData::Item.get(parameter).real_name} is used on it if it's male"
    when :ItemFemale; return "when a #{GameData::Item.get(parameter).real_name} is used on it if it's female"
    when :Trade; return "when traded"
    when :TradeItem; return "when traded holding an #{GameData::Item.get(parameter).real_name}"
    end
    return "via a method the programmer was too lazy to describe"
  end
  
  def drawPageTMMoves
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_moves"))
    overlay = @sprites["overlay"].bitmap
    formname = "" 
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)

    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,30,54,450,1,_INTL("TM Moves for {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
        compatibleMoves = fSpecies.tutor_moves
        @scrollableListLength = compatibleMoves.length
        trueIndex = 0
        compatibleMoves.each_with_index do |move,index|
          next if (index/2) < @scroll
		  moveName = GameData::Move.get(move).real_name
          drawTextEx(overlay,30+(trueIndex % 2) * 200,84+30*(trueIndex/2).floor,450,1,moveName,base,shadow)
          trueIndex += 1
          break if trueIndex >= 18
        end
      end
    end
  end
  
  def drawPageEggMoves
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_moves"))
    overlay = @sprites["overlay"].bitmap
    formname = "" 
    base = Color.new(64,64,64)
    shadow = Color.new(176,176,176)

    for i in @available
      if i[2]==@form
        formname = i[0]
        drawTextEx(overlay,30,54,450,1,_INTL("Egg Moves for {1}",@title),base,shadow)
        fSpecies = GameData::Species.get_species_form(@species,i[2])
		firstSpecies = fSpecies
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		end
        compatibleMoves = firstSpecies.egg_moves
        @scrollableListLength = compatibleMoves.length
        trueIndex = 0
        compatibleMoves.each_with_index do |move,index|
          next if (index/2) < @scroll
		  moveName = GameData::Move.get(move).real_name
          drawTextEx(overlay,30+(trueIndex % 2) * 200,84+30*(trueIndex/2).floor,450,1,moveName,base,shadow)
          trueIndex += 1
          break if trueIndex >= 18
        end
      end
    end
  end
  
  def pbFindEncounter(enc_types, species)
    return false if !enc_types
    enc_types.each_value do |slots|
      next if !slots
      slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
    end
    return false
  end

  def drawPageArea
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_area"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
	
	drawTextEx(overlay,150,190,450,1,"!Under Construction!",base,shadow)
	
=begin
    @sprites["areahighlight"].bitmap.clear
    # Fill the array "points" with all squares of the region map in which the
    # species can be found
    points = []
    mapwidth = 1+PokemonRegionMap_Scene::RIGHT-PokemonRegionMap_Scene::LEFT
    GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
      next if !pbFindEncounter(enc_data.types, @species)
      map_metadata = GameData::MapMetadata.try_get(enc_data.map)
      mappos = (map_metadata) ? map_metadata.town_map_position : nil
      next if !mappos || mappos[0] != @region
      showpoint = true
      for loc in @mapdata[@region][2]
        showpoint = false if loc[0]==mappos[1] && loc[1]==mappos[2] &&
                             loc[7] && !$game_switches[loc[7]]
      end
      next if !showpoint
      mapsize = map_metadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0]>0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length*1.0/mapsize[0]).ceil
        for i in 0...sqwidth
          for j in 0...sqheight
            if mapsize[1][i+j*sqwidth,1].to_i>0
              points[mappos[1]+i+(mappos[2]+j)*mapwidth] = true
            end
          end
        end
      else
        points[mappos[1]+mappos[2]*mapwidth] = true
      end
    end
    # Draw coloured squares on each square of the region map with a nest
    pointcolor   = Color.new(0,248,248)
    pointcolorhl = Color.new(192,248,248)
    sqwidth = PokemonRegionMap_Scene::SQUAREWIDTH
    sqheight = PokemonRegionMap_Scene::SQUAREHEIGHT
    for j in 0...points.length
      if points[j]
        x = (j%mapwidth)*sqwidth
        x += (Graphics.width-@sprites["areamap"].bitmap.width)/2
        y = (j/mapwidth)*sqheight
        y += (Graphics.height+32-@sprites["areamap"].bitmap.height)/2
        @sprites["areahighlight"].bitmap.fill_rect(x,y,sqwidth,sqheight,pointcolor)
        if j-mapwidth<0 || !points[j-mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x,y-2,sqwidth,2,pointcolorhl)
        end
        if j+mapwidth>=points.length || !points[j+mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x,y+sqheight,sqwidth,2,pointcolorhl)
        end
        if j%mapwidth==0 || !points[j-1]
          @sprites["areahighlight"].bitmap.fill_rect(x-2,y,2,sqheight,pointcolorhl)
        end
        if (j+1)%mapwidth==0 || !points[j+1]
          @sprites["areahighlight"].bitmap.fill_rect(x+sqwidth,y,2,sqheight,pointcolorhl)
        end
      end
    end
    # Set the text
    textpos = []
    if points.length==0
      pbDrawImagePositions(overlay,[
         [sprintf("Graphics/Pictures/Pokedex/overlay_areanone"),108,188]
      ])
      textpos.push([_INTL("Area unknown"),Graphics.width/2,Graphics.height/2 - 6,2,base,shadow])
    end
    textpos.push([pbGetMessage(MessageTypes::RegionNames,@region),414,38,2,base,shadow])
    textpos.push([_INTL("{1}'s area",GameData::Species.get(@species).name),
       Graphics.width/2,346,2,base,shadow])
    pbDrawTextPositions(overlay,textpos)
=end
  end
  
  def drawPageForms
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    # Write species and form name
    formname = ""
    for i in @available
      if i[1]==@gender && i[2]==@form
        formname = i[0]; break
      end
    end
    textpos = [
       [GameData::Species.get(@species).name,Graphics.width/2,Graphics.height-94,2,base,shadow],
       [formname,Graphics.width/2,Graphics.height-62,2,base,shadow],
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
  end

  def pbGoToPrevious
    newindex = @index
    while newindex>0
      newindex -= 1
      if $Trainer.seen?(@dexlist[newindex][0])
        @index = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @index
    while newindex<@dexlist.length-1
      newindex += 1
      if $Trainer.seen?(@dexlist[newindex][0])
        @index = newindex
        break
      end
    end
  end

  def pbChooseForm
    index = 0
    for i in 0...@available.length
      if @available[i][1]==@gender && @available[i][2]==@form
        index = i
        break
      end
    end
    oldindex = -1
    loop do
      if oldindex!=index
        $Trainer.pokedex.set_last_form_seen(@species, @available[index][1], @available[index][2])
        pbUpdateDummyPokemon
        drawPage(@page)
        @sprites["uparrow"].visible   = (index>0)
        @sprites["downarrow"].visible = (index<@available.length-1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index+@available.length-1) % @available.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index+1) % @available.length
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
  end
  
  def pbScroll
    oldScroll = -1
    loop do
      if (oldScroll != @scroll)
        drawPage(@page)
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.repeat?(Input::UP) && @scroll > 0
        pbPlayCursorSE
        @scroll -= 1
      elsif Input.repeat?(Input::DOWN) && @scroll < @scrollableListLength/(@page == 6 ? 2 : 1) - 9 
        pbPlayCursorSE
        @scroll += 1
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::ACTION)
        pbPlayDecisionSE
        break
      end
    end
  end

  def pbScene
    GameData::Species.play_cry_from_species(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        GameData::Species.play_cry_from_species(@species, @form) if @page == 1
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
		if @page==1
          pbPlayCloseMenuSE
          break
        elsif @page==5 || @page == 6 || @page == 7   # Move lists
		  pbPlayDecisionSE
          pbScroll
          dorefresh = true
        elsif @page==10   # Forms
          if @available.length>1
            pbPlayDecisionSE
            pbChooseForm
            dorefresh = true
          end
        end
      elsif Input.repeat?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index!=oldindex
		  @scroll = 0
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? GameData::Species.play_cry_from_species(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.repeat?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index!=oldindex
		  @scroll = 0
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? GameData::Species.play_cry_from_species(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = 10 if @page>10
        if @page!=oldpage
		  @scroll = 0
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = 10 if @page>10
        if @page!=oldpage
		  @scroll = 0
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end

  def pbSceneBrief
    GameData::Species.play_cry_from_species(@species,@form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::A)
        pbSEStop
		GameData::Species.play_cry_from_species(@species,@form)
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        break
      end
    end
  end
end


class PokeBattle_Scene

	def pbStartSceneSingle(species)   # For use from a Pokémon's summary screen
		region = -1
		if Settings::USE_CURRENT_REGION_DEX
		  region = pbGetCurrentRegion
		  region = -1 if region >= $Trainer.pokedex.dexes_count - 1
		else
		  region = $PokemonGlobal.pokedexDex   # National Dex -1, regional Dexes 0, 1, etc.
		end
		dexnum = pbGetRegionalNumber(region,species)
		dexnumshift = Settings::DEXES_WITH_OFFSETS.include?(region)
		
		species_data = GameData::Species.get(species)
		  color  = species_data.color
		  type1  = species_data.type1
		  type2  = species_data.type2 || type1
		  shape  = species_data.shape
		  height = species_data.height
		  weight = species_data.weight
		  
		  abilities = species_data.abilities
          lvlmoves = species_data.moves
		  tutormoves = species_data.tutor_moves
		  
		  firstSpecies = GameData::Species.get(species)
		  while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
		  end
		
		  eggmoves = firstSpecies.egg_moves
		  
		  # 0 = National Species
          # 1 = Name
          # 2 = Height
          # 3 = Weight
          # 4 = Number
          # 5 = Shift
          # 6 = 1st Type
          # 7 = 2nd Type
          # 8 = Color
          # 9 = Shape
          # 10 Abilities
          # 11 Level Up Moves
		  # 12 Tutor Moves
		  # 13 Egg Moves
		  
		dexlist = [[species, species_data.name, height, weight, i + 1, shift, type1, type2, color, shape, abilities, lvlmoves, tutormoves, eggmoves]]
		@scene.pbStartScene(dexlist,0,region)
		@scene.pbScene
		@scene.pbEndScene
	  end


  #=============================================================================
  # Shows the Pokédex entry screen for a newly caught Pokémon
  #=============================================================================
  def pbShowPokedex(species)
    pbFadeOutIn {
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbStartSceneSingle(species)
    }
  end
end