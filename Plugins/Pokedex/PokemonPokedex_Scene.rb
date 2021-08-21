SEARCHES_STACK = true

class PokemonPokedex_Scene
  def pbStartScene
    @sliderbitmap       = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_slider")
    @typebitmap         = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @shapebitmap        = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_shapes")
    @hwbitmap           = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_hw")
    @selbitmap          = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_searchsel")
    @searchsliderbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_searchslider"))
	@search2Cursorbitmap 		= AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/Rework/cursor_search"))
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites,"background","Pokedex/bg_list",@viewport)
    addBackgroundPlane(@sprites,"searchbg","Pokedex/Rework/bg_search",@viewport)
    @sprites["searchbg"].visible = false
    @sprites["pokedex"] = Window_Pokedex.new(206,30,276,364,@viewport)
    @sprites["icon"] = PokemonSprite.new(@viewport)
    @sprites["icon"].setOffset(PictureOrigin::Center)
    @sprites["icon"].x = 112
    @sprites["icon"].y = 196
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    #@sprites["searchcursor"] = PokedexSearchSelectionSprite.new(@viewport)
    #@sprites["searchcursor"].visible = false
	@sprites["search2cursor"] = SpriteWrapper.new(@viewport)
	@sprites["search2cursor"].bitmap = @search2Cursorbitmap.bitmap
    @sprites["search2cursor"].visible = false
    @searchResults = false
    @searchParams  = [$PokemonGlobal.pokedexMode,-1,-1,-1,-1,-1,-1,-1,-1,-1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @typebitmap.dispose
    @shapebitmap.dispose
    @hwbitmap.dispose
    @selbitmap.dispose
    @searchsliderbitmap.dispose
    @viewport.dispose
	@search2Cursorbitmap.dispose
  end


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
		  
		  evos = species_data.get_evolutions
		  prevos = species_data.get_prevolutions
		  
		  ret.push([species, species_data.name, height, weight, i + 1, shift, type1, type2, color, shape, abilities, lvlmoves, tutormoves, eggmoves, evos, prevos])
		end
		return ret
	end
	
	def pbRefreshDexList(index=0)
		dexlist = pbGetDexList
		# Sort species in ascending order by Regional Dex number
		dexlist.sort! { |a,b| a[4]<=>b[4] }
		@dexlist = dexlist
		@sprites["pokedex"].commands = @dexlist
		@sprites["pokedex"].index    = index
		@sprites["pokedex"].refresh
		if @searchResults
		  @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_listsearch")
		else
		  @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_list")
		end
		pbRefresh
	end
	
	def pbRefresh
		overlay = @sprites["overlay"].bitmap
		overlay.clear
		base   = Color.new(88,88,80)
		shadow = Color.new(168,184,184)
		iconspecies = @sprites["pokedex"].species
		iconspecies = nil if isLegendary(iconspecies) && !$Trainer.seen?(iconspecies)
		# Write various bits of text
		dexname = _INTL("Pokédex")
		if $Trainer.pokedex.dexes_count > 1
		  thisdex = Settings.pokedex_names[pbGetSavePositionIndex]
		  if thisdex!=nil
			dexname = (thisdex.is_a?(Array)) ? thisdex[0] : thisdex
		  end
		end
		textpos = [
		   [dexname,Graphics.width/2,-2,2,Color.new(248,248,248),Color.new(0,0,0)]
		]
		textpos.push([GameData::Species.get(iconspecies).name,112,46,2,base,shadow]) if iconspecies
		if @searchResults
		  textpos.push([_INTL("Search results"),112,302,2,base,shadow])
		  textpos.push([@dexlist.length.to_s,112,334,2,base,shadow])
		else
		  textpos.push([_INTL("Seen:"),42,302,0,base,shadow])
		  textpos.push([$Trainer.pokedex.seen_count(pbGetPokedexRegion).to_s,182,302,1,base,shadow])
		  textpos.push([_INTL("Owned:"),42,334,0,base,shadow])
		  textpos.push([$Trainer.pokedex.owned_count(pbGetPokedexRegion).to_s,182,334,1,base,shadow])
		end
		# Draw all text
		pbDrawTextPositions(overlay,textpos)
		# Set Pokémon sprite
		setIconBitmap(iconspecies)
		# Draw slider arrows
		itemlist = @sprites["pokedex"]
		showslider = false
		if itemlist.top_row>0
		  overlay.blt(468,48,@sliderbitmap.bitmap,Rect.new(0,0,40,30))
		  showslider = true
		end
		if itemlist.top_item+itemlist.page_item_max<itemlist.itemCount
		  overlay.blt(468,346,@sliderbitmap.bitmap,Rect.new(0,30,40,30))
		  showslider = true
		end
		# Draw slider box
		if showslider
		  sliderheight = 268
		  boxheight = (sliderheight*itemlist.page_row_max/itemlist.row_max).floor
		  boxheight += [(sliderheight-boxheight)/2,sliderheight/6].min
		  boxheight = [boxheight.floor,40].max
		  y = 78
		  y += ((sliderheight-boxheight)*itemlist.top_row/(itemlist.row_max-itemlist.page_row_max)).floor
		  overlay.blt(468,y,@sliderbitmap.bitmap,Rect.new(40,0,40,8))
		  i = 0
		  while i*16<boxheight-8-16
			height = [boxheight-8-16-i*16,16].min
			overlay.blt(468,y+8+i*16,@sliderbitmap.bitmap,Rect.new(40,8,40,height))
			i += 1
		  end
		  overlay.blt(468,y+boxheight-16,@sliderbitmap.bitmap,Rect.new(40,24,40,16))
		end
	end
	  
	def pbDexEntry(index)
		oldsprites = pbFadeOutAndHide(@sprites)
		region = -1
		if !Settings::USE_CURRENT_REGION_DEX
		  dexnames = Settings.pokedex_names
		  if dexnames[pbGetSavePositionIndex].is_a?(Array)
			region = dexnames[pbGetSavePositionIndex][1]
		  end
		end
		
		while true
			scene = PokemonPokedexInfo_Scene.new
			screen = PokemonPokedexInfoScreen.new(scene)
			ret = screen.pbStartScreen(@dexlist,index,region,true)
			
			# If given a species symbol, we move directly to that species
			if ret.is_a?(Symbol)
				# Find the species slot on the existing dexlist, if there
				currentListIndex = -1
				@dexlist.each_with_index do |dexListEntry,index|
					next if dexListEntry[0] != ret
					currentListIndex = index
					break
				end
			
				if @searchResults && currentListIndex < 0
					# Species isn't in the current search, so scrap that search and go to it through its index on a reset dexlist
					@dexlist = pbGetDexList()
					@searchResults = false
					@sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_list")
					@sprites["pokedex"].commands = @dexlist
					
					@dexlist.each_with_index do |dexListEntry,index|
						next if dexListEntry[0] != ret
						currentListIndex = index
						break
					end
					
					ret = currentListIndex
				end
				
				index = currentListIndex
				@sprites["pokedex"].index = index
				next
			# Otherwise, we were given the last looked index of the current dexlist
			# Go back to the main pokedex menu, at that index
			else
				@sprites["pokedex"].index = ret
				break
			end
		end
		
		@sprites["pokedex"].refresh
		pbRefresh
		pbFadeInAndShow(@sprites,oldsprites)
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
          if $Trainer.pokedex.seen?(@sprites["pokedex"].species) || !isLegendary(@sprites["pokedex"].species) || (Input.trigger?(Input::CTRL) && $DEBUG)
            pbPlayDecisionSE
            pbDexEntry(@sprites["pokedex"].index)
          end
		elsif Input.pressex?(:NUMBER_1)
		  acceptSearchResults {
			searchBySpeciesName()
		  }
		elsif Input.pressex?(:NUMBER_2)
		  acceptSearchResults {
			searchByType()
		  }
		elsif Input.pressex?(:NUMBER_3)
		  acceptSearchResults {
			searchByAbility()
		  }
		elsif Input.pressex?(:NUMBER_4)
		  acceptSearchResults {
			searchByMoveLearned()
		  }
		elsif Input.pressex?(:NUMBER_5)
		  acceptSearchResults {
			searchByEvolutionMethod()
		  }
		elsif Input.pressex?(:NUMBER_6)
		  acceptSearchResults {
			searchByAvailableLevel()
		  }
		end
      end
    }
  end
  
  def updateSearch2Cursor(index)
	@sprites["search2cursor"].x = index % 2 == 0 ? 72 : 296
	@sprites["search2cursor"].y = 62 + index / 2 * 96
  end
  
  def pbDexSearch
    # Prepare to start the search screen
	oldsprites = pbFadeOutAndHide(@sprites)
	@sprites["searchbg"].visible     = true
    @sprites["overlay"].visible      = true
    @sprites["search2cursor"].visible = true
	overlay = @sprites["overlay"].bitmap
	overlay.clear
    index = 0
	updateSearch2Cursor(index)
    oldindex = index
	
	# Write the button names onto the overlay
	base   = Color.new(104,104,104)
    shadow = Color.new(248,248,248)
	textpos = [
	   [_INTL("Choose a Search"),Graphics.width/2,-2,2,shadow,base],
       [_INTL("Name"),92,68,0,base,shadow],
       [_INTL("Types"),316,68,0,base,shadow],
       [_INTL("Abilities"),92,164,0,base,shadow],
       [_INTL("Moves"),316,164,0,base,shadow],
	   [_INTL("Evolution"),92,260,0,base,shadow],
	   [_INTL("Available"),316,260,0,base,shadow]
    ]
	pbDrawTextPositions(overlay,textpos)
	
	# Begin the search screen
	pbFadeInAndShow(@sprites)
	loop do
      Graphics.update
      Input.update
      pbUpdate
      if index!=oldindex
		pbPlayCursorSE
        updateSearch2Cursor(index)
        oldindex = index
      end
      if Input.trigger?(Input::UP)
        index -= 2 if index >= 2
      elsif Input.trigger?(Input::DOWN)
        index += 2 if index <= 3
      elsif Input.trigger?(Input::LEFT)
		if index % 2 == 1
			index -= 1
		end
      elsif Input.trigger?(Input::RIGHT)
        if index % 2 == 0
			index += 1
		end
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
		case index 
		when 0
		  searchChanged = acceptSearchResults2 {
			searchBySpeciesName()
		  }
		when 1
		  searchChanged = acceptSearchResults2 {
			searchByType()
		  }
		when 2
		  searchChanged = acceptSearchResults2 {
			searchByAbility()
		  }
		when 3
		  searchChanged = acceptSearchResults2 {
			searchByMoveLearned()
		  }
		when 4
		  searchChanged = acceptSearchResults2 {
			searchByEvolutionMethod()
		  }
		when 5
		  searchChanged = acceptSearchResults2 {
			searchByAvailableLevel()
		  }
		end
		if searchChanged
			break
		else
			pbPlayCloseMenuSE
		end
	  end
	end
	pbFadeOutAndHide(@sprites)
	if @searchResults
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_listsearch")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_list")
    end
	pbRefresh
    pbFadeInAndShow(@sprites,oldsprites)
	Input.update
  end
  
  def acceptSearchResults2(&searchingBlock)
	  pbPlayDecisionSE
	  dexlist = searchingBlock.call
	  if !dexlist
		# Do nothing
	  elsif dexlist.length==0
		pbMessage(_INTL("No matching Pokémon were found."))
	  else
		@dexlist = dexlist
		@sprites["pokedex"].commands = @dexlist
		@sprites["pokedex"].index    = 0
		@sprites["pokedex"].refresh
		@searchResults = true
		return true
	  end
	  return false
  end
  
  def acceptSearchResults(&searchingBlock)
	  pbPlayDecisionSE
	  @sprites["pokedex"].active = false
	  dexlist = searchingBlock.call
	  if !dexlist
		# Do nothing
	  elsif dexlist.length==0
		pbMessage(_INTL("No matching Pokémon were found."))
	  else
		@dexlist = dexlist
		@sprites["pokedex"].commands = @dexlist
		@sprites["pokedex"].index    = 0
		@sprites["pokedex"].refresh
		@searchResults = true
		@sprites["background"].setBitmap("Graphics/Pictures/Pokedex/bg_listsearch")
	  end
	  @sprites["pokedex"].active = true
	  pbRefresh
  end
  
  def searchBySpeciesName()
	  nameInput = pbEnterText("Search species...", 0, 12)
	  if nameInput && nameInput!=""
		  reversed = nameInput[0] == '-'
		  nameInput = nameInput[1..-1] if reversed
		  dexlist = SEARCHES_STACK ? @dexlist : pbGetDexList
		  dexlist = dexlist.find_all { |item|
			next false if isLegendary(item[0]) && !$Trainer.seen?(item[0]) && !$DEBUG
			searchPokeName = item[1]
			value = searchPokeName.downcase.include?(nameInput.downcase) ^ reversed # Boolean XOR
			next value
		  }
		  return dexlist
	  end
	  return nil
  end
  
  def searchByAbility()
	  abilityInput = pbEnterText("Search abilities...", 0, 12)
	  if abilityInput && abilityInput!=""
		  reversed = abilityInput[0] == '-'
		  abilityInput = abilityInput[1..-1] if reversed
		  dexlist = SEARCHES_STACK ? @dexlist : pbGetDexList
		  dexlist = dexlist.find_all { |item|
			next false if isLegendary(item[0]) && !$Trainer.seen?(item[0]) && !$DEBUG
			searchPokeAbilities = item[10]
			value = false
			value = true if searchPokeAbilities[0] && GameData::Ability.get(searchPokeAbilities[0]).real_name.downcase.include?(abilityInput.downcase)
			value = true if searchPokeAbilities[1] && GameData::Ability.get(searchPokeAbilities[1]).real_name.downcase.include?(abilityInput.downcase)
			value = value ^ reversed # Boolean XOR
			next value
		  }
		  return dexlist
	  end
	  return nil
  end
  
  def searchByMoveLearned()
	  moveNameInput = pbEnterText("Search moves...", 0, 12)
          
	  if moveNameInput && moveNameInput!=""
			reversed = moveNameInput[0] == '-'
		    moveNameInput = moveNameInput[1..-1] if reversed
			
		    dexlist = SEARCHES_STACK ? @dexlist : pbGetDexList
		    dexlist = dexlist.find_all { |item|
				next false if isLegendary(item[0]) && !$Trainer.seen?(item[0]) && !$DEBUG
				contains = false
				
				lvlmoves = item[11]
				lvlmoves.each do |move|
				  if GameData::Move.get(move[1]).real_name.downcase.include?(moveNameInput.downcase)
					contains = true
					break
				  end
				end
				next !reversed if contains
				
				tutormoves = item[12]
				tutormoves.each do |move|
				  if GameData::Move.get(move).real_name.downcase.include?(moveNameInput.downcase)
					contains = true
					break
				  end
				end
				next !reversed if contains
				
				eggmoves = item[13]
				eggmoves.each do |move|
				  if GameData::Move.get(move).real_name.downcase.include?(moveNameInput.downcase)
					contains = true
					break
				  end
				end
				
				next contains ^ reversed # Boolean XOR
			}
		  return dexlist
	  end
	  return nil
  end
  
  def searchByType()
	  while true
		  typesInput = pbEnterText("Search types...", 0, 100)
		  typesInput.downcase!
		  if typesInput && typesInput!=""
			  typesInputArray = typesInput.split(" ")
			  
			  # Don't do the search if one of the input type names isn't an actual type
			  invalid = false
			  typesSearchInfo = {}
			  typesInputArray.each do |type_input_entry|
				reversed = type_input_entry[0] == '-'
			    type_input_entry = type_input_entry[1..-1] if reversed
				typeIsReal = false
				GameData::Type.each do |type_data|
					typeIsReal = true if type_data.real_name.downcase == type_input_entry
					break if typeIsReal
				end
				if !typeIsReal
					pbMessage(_INTL("Invalid input: {1}", type_input_entry))
					invalid = true
					break
				end
				typesSearchInfo[type_input_entry] = reversed
			  end
			  next if invalid
			  
			  dexlist = SEARCHES_STACK ? @dexlist : pbGetDexList
			  dexlist = dexlist.find_all { |item|
				next false if isLegendary(item[0]) && !$Trainer.seen?(item[0]) && !$DEBUG
				searchPokeType1 = item[6]
				searchPokeType1Name = GameData::Type.get(searchPokeType1).real_name.downcase if searchPokeType1
				searchPokeType2 = item[7]
				searchPokeType2Name = GameData::Type.get(searchPokeType2).real_name.downcase if searchPokeType2
				
				pokeTypeNames = [searchPokeType1Name,searchPokeType2Name]
				
				survivesSearch = true
				typesSearchInfo.each do |type,reversed|
					if !reversed
						survivesSearch = false if !pokeTypeNames.include?(type)
					else
						survivesSearch = false if pokeTypeNames.include?(type)
					end
				end
				next survivesSearch
			  }
			  return dexlist
		  end
		  return nil
	  end
  end
  
  def searchByEvolutionMethod()
	  evoMethodTextInput = pbEnterText("Search method...", 0, 12)
	  if evoMethodTextInput && evoMethodTextInput!=""
		  reversed = evoMethodTextInput[0] == '-'
		  evoMethodTextInput = evoMethodTextInput[1..-1] if reversed
		  dexlist = SEARCHES_STACK ? @dexlist : pbGetDexList
		  dexlist = dexlist.find_all { |item|
			next false if isLegendary(item[0]) && !$Trainer.seen?(item[0]) && !$DEBUG
			anyContain = false
			# Evolutions
			item[14].each do |evomethod|
				strippedActualDescription = describeEvolutionMethod(evomethod[1],evomethod[2]).downcase.delete(' ')
				strippedInputString = evoMethodTextInput.downcase.delete(' ')
				anyContain = true if strippedActualDescription.include?(strippedInputString)
			end
			value = anyContain ^ reversed # Boolean XOR
			next value
		  }
		  return dexlist
	  end
	  return nil
  end
  

  def searchByAvailableLevel()
	  levelTextInput = pbEnterText("Search available by level...", 0, 3)
	  if levelTextInput && levelTextInput!=""
		  reversed = levelTextInput[0] == '-'
		  levelTextInput = levelTextInput[1..-1] if reversed
	  
		  levelIntAttempt = levelTextInput.to_i
		  return nil if levelIntAttempt == 0
		  
		  if $game_switches[60] # Playing the prototype
			  maps_available_by_cap = {
				15 => [20,22,43,2,48], #Short Route, Forest Crossroads, Forest Route, Forest Cave B1, Flower Town
				21 => [3,4,7,10,11,5], #Savannah Route, Big Cave B1, Big Cave B2, Oasis Town, Oasis Town Hidden, River Route
				27 => [17,9] #Forest Cave B2, River Grove
			  }
			  
			  items_available_by_cap = {
				15 => [],
				21 => [],
				27 => [:MOONSTONE,:FIRESTONE,:WATERSTONE,:LEAFSTONE],
			  }
			  
			  surfingAvailable = levelIntAttempt > 21
		  else # Playing the main game
			  maps_available_by_cap = {
				15 => [33,34,29,30,38,26]
			  }
			  
			  items_available_by_cap = {
				15 => [],
				20 => [],
				25 => [:MOONSTONE],
				30 => [:FIRESTONE,:WATERSTONE,:LEAFSTONE,:THUNDERSTONE,:DAWNSTONE,:DUSKSTONE,:SHINYSTONE,:ICESTONE]
			  }
			  
			  surfingAvailable = false
		  end
		  
		  dexlist = SEARCHES_STACK ? @dexlist : pbGetDexList
		  dexlist = dexlist.find_all { |item|
			next false if isLegendary(item[0]) && !$Trainer.seen?(item[0]) && !$DEBUG
			
			speciesToCheckLocationsFor = [item[0]]
			# Note each pre-evolution which could be the path to aquiring this pokemon by the given level
			currentPrevo = item[15].length > 0 ? item[15][0] : nil
			while currentPrevo != nil
				evoMethod = currentPrevo[1]
				case evoMethod
				# All method based on leveling up to a certain level
				when :Level,:LevelDay,:LevelNight,:LevelMale,:LevelFemale,:LevelRain,
					:AttackGreater,:AtkDefEqual,:DefenseGreater,:LevelDarkInParty,
					:Silcoon,:Cascoon,:Ninjask,:Shedinja
					
					levelThreshold = currentPrevo[2]
					if levelThreshold <= levelIntAttempt
						speciesToCheckLocationsFor.push(currentPrevo[0])
					else
						break
					end
				# All methods based on holding a certain item or using a certain item on the pokemon
				when :HoldItem,:HoldItemMale,:HoldItemFemale,:DayHoldItem,:NightHoldItem,
					:Item,:ItemMale,:ItemFemale,:ItemDay,:ItemNight,:ItemHappiness
					
					# Push this prevo if the evolution from it is gated by an item which is available by this point
					itemNeeded = currentPrevo[2]
					itemAvailable = false
					items_available_by_cap.each do |key, value|
						itemAvailable = true if value.include?(itemNeeded)
						break if key >= levelIntAttempt
					end
					speciesToCheckLocationsFor.push(currentPrevo[0]) if itemAvailable
				# All methods based on leveling up while having a certain move type
				when :HasMove,:HasMoveType
					# TO DO: Bespoke checks for each relevant move or move type per pokemon which has them
				end
				
				# Find the prevo of the prevo
				prevosfSpecies = GameData::Species.get_species_form(currentPrevo[0],0)
				prevolutions = prevosfSpecies.get_prevolutions
				currentPrevo = prevolutions.length > 0 ? prevolutions[0] : nil
			end
			
			# Find all the maps which are available by the given level
			mapsToCheck = []
			levelCapBracket = 0
			maps_available_by_cap.each do |key, value|
				mapsToCheck.concat(value)
				levelCapBracket = key
				break if levelCapBracket >= levelIntAttempt
			end
			
			# For each possible species which could lead to this species, check to see if its available in any of the maps 
			# which are available by the level cap which would apply at the given level
			available = false
			# For each encounters data listing
			GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
				next unless mapsToCheck.include?(enc_data.map)
				# For each species we need to check for
				speciesToCheckLocationsFor.each do |species|
					encounterInfoForSpecies = nil
					# For each slot in that encounters data listing
					enc_data.types.each do |key,slots|
					    next if !slots
						next if key == :ActiveWater && !surfingAvailable
					    slots.each { |slot|
							species_data = GameData::Species.get(slot[1])
							if species_data.species == species
								# Mark down this slot if no such slot is marked, or if this is a lower level encounter
								if encounterInfoForSpecies == nil || slot[3] < encounterInfoForSpecies[3]
									encounterInfoForSpecies = slot
								end
							end
					    }
					end
					# Continue onto the next species if no slots on the map being currently looked at have an entry for this species
					next if !encounterInfoForSpecies

					# Assume that encounters which distribute a pokemon beyond the level cap bracket
					# are not actually available during that level cap
					# But through returning to a secret part of that map later, or something
					available = true if encounterInfoForSpecies[3] <= levelCapBracket
				end
				break if available
			end
			value = available ^ reversed # Boolean XOR
			next value
		  }
		  return dexlist
	  end
	  return nil
  end
end