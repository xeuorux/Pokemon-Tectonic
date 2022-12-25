SEARCHES_STACK = true

class PokemonPokedex_Scene
  def pbStartScene
	generateSpeciesUseData() if $DEBUG
	generateSignaturesData() if $DEBUG

    @sliderbitmap       	= AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_slider")
    @typebitmap         	= AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @shapebitmap        	= AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_shapes")
    @hwbitmap           	= AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_hw")
    @selbitmap          	= AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_searchsel")
    @searchsliderbitmap 	= AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_searchslider"))
	@search2Cursorbitmap	= AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/Rework/cursor_search"))
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites,"background","Pokedex/bg_list",@viewport)
    addBackgroundPlane(@sprites,"searchbg","Pokedex/Rework/bg_search",@viewport)
	addBackgroundPlane(@sprites,"searchbg2","Pokedex/Rework/bg_search_2",@viewport)
    @sprites["searchbg"].visible = false
	@sprites["searchbg2"].visible = false
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
	@searchPopupbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/z_header_filled"))
	@sprites["z_header"] = SpriteWrapper.new(@viewport)

	@sprites["z_header"].bitmap = @searchPopupbitmap.bitmap
	@sprites["z_header"].x = Graphics.width - @searchPopupbitmap.width
	@sprites["z_header"].visible = false
    @searchParams  = [$PokemonGlobal.pokedexMode,-1,-1,-1,-1,-1,-1,-1,-1,-1]
	
	# Load stored search
	storedIndex = $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex]

	if $PokemonGlobal.stored_search
		@dexlist = $PokemonGlobal.stored_search
		@searchResults = true
		refreshDexListGraphics(0)
	else
		@searchResults =  false
		pbRefreshDexList(storedIndex)
	end
	
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
  end

  def generateSpeciesUseData()
		speciesUsed = {}
		GameData::Species.each do |species_data|
			next if species_data.form != 0
			speciesUsed[species_data.species] = []
		end
		
		trainerNamesCompleted = []
		GameData::Trainer.each do |trainerData|
			name = trainerData.real_name
			next if trainerNamesCompleted.include?(name)
			trainerNamesCompleted.push(name)
			trainerData.pokemon.each do |partyEntry|
				species = partyEntry[:species]
				speciesUsed[species].push(trainerData)
			end
		end
		
		unusedPokemon = []
		@speciesUseData = {}
		speciesUsed.each do |species,arrayOfTrainerData|
			arrayOfTrainerData.uniq!
			arrayOfTrainerData.compact!
			@speciesUseData[species] = arrayOfTrainerData.length
		end
  end

  def generateSignaturesData
		@signatureAbilities = getSignatureAbilities()
		@signatureMoves 	= getSignatureMoves()
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
		  
		  if $DEBUG
		  	useCount = @speciesUseData[species] || 0
		  else
			useCount = 0
		  end

		  ret.push([species, species_data.name, height, weight, i + 1, shift, type1, type2, 
		  	color, shape, abilities, lvlmoves, tutormoves, eggmoves, evos, prevos, useCount])
		end
		return ret
	end
	
	def searchStartingList()
		return SEARCHES_STACK ? @dexlist : pbGetDexList
	end

	def autoDisqualifyFromSearch(species_sym)
		return isLegendary(species_sym) && !$Trainer.seen?(species_sym) && !$DEBUG
	end

	def pbRefreshDexList(index=0)
		dexlist = pbGetDexList
		# Sort species in ascending order by Regional Dex number
		dexlist.sort! { |a,b|
			valA = a[4]
			valB = b[4]
			valA -= 5000 if $PokemonGlobal.speciesStarred?(a[0])
			valB -= 5000 if $PokemonGlobal.speciesStarred?(b[0])
			next valA <=> valB
		}
		@dexlist = dexlist
		refreshDexListGraphics(index)
	end
	
	def refreshDexListGraphics(index)
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
		zBase = Color.new(248,248,248)
		zShadow = Color.new(0,0,0)
		iconspecies = @sprites["pokedex"].species
		iconspecies = nil if isLegendary(iconspecies) && !$Trainer.seen?(iconspecies) && !$DEBUG
		dexname = _INTL("MasterDex")
		textpos = [
		   [dexname,Graphics.width/8,-2,2,Color.new(248,248,248),Color.new(0,0,0)]
		]
		textpos.push([GameData::Species.get(iconspecies).name,112,46,2,base,shadow]) if iconspecies
		
		if @searchResults
		  textpos.push([_INTL("Search results"),112,302,2,base,shadow])
		  textpos.push([@dexlist.length.to_s,112,334,2,base,shadow])
		  textpos.push([_INTL("ACTION/Z to search further."),Graphics.width-5,-2,1,zBase,zShadow])
		else
		  textpos.push([_INTL("ACTION/Z to search."),Graphics.width-5,-2,1,zBase,zShadow])
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
		#zOverlay = @sprites["overlay"].bitmap
		#zTextpos = [[_INTL("Press Z or SHIFT to search.") ,Graphics.width/4*3,Graphics.height,0,Color.new(104,104,104),Color.new(248,248,248)]]
		#pbDrawTextPositions(zOverlay,zTextpos)
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
			if Input.press?(Input::CTRL)
				$PokemonGlobal.stored_search = @dexlist
				pbPlayCloseMenuSE
				break
			else
				pbPlayCancelSE
				pbCloseSearch
			end
			# storeCommand = -1
			# cancelCommand = -1
			# cancelAndCloseCommand = -1
			# commands = []
			# # commands[cancelCommand = commands.length] = _INTL("Cancel Search")
			# # commands[cancelAndCloseCommand = commands.length] = _INTL("Cancel Search and Exit")
			# # commands[storeCommand = commands.length] = _INTL("Store Search and Exit")
			# # result = pbMessage(_INTL("You have an active search. What would you like to do?"),commands,0)
            # # if result == storeCommand
			# # 	$PokemonGlobal.stored_search = @dexlist
			# # 	pbPlayCloseMenuSE
			# # 	break
			# # elsif result == cancelCommand
			# # 	pbPlayCancelSE
			# # 	pbCloseSearch
			# # elsif result == cancelAndCloseCommand
			# # 	pbCloseSearch
			# # 	pbPlayCloseMenuSE
			# # 	break
			# # end
          else
            pbPlayCloseMenuSE
            break
          end
        elsif Input.trigger?(Input::USE)
          if $Trainer.pokedex.seen?(@sprites["pokedex"].species) || !isLegendary(@sprites["pokedex"].species) || $DEBUG
            pbPlayDecisionSE
            pbDexEntry(@sprites["pokedex"].index)
          end
		elsif Input.trigger?(Input::SPECIAL)
			if $PokemonGlobal.toggleStarred(@sprites["pokedex"].species)
				pbPlayDecisionSE
			else
				pbPlayCancelSE
			end
			@sprites["pokedex"].refresh
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
		elsif Input.pressex?(0x52) # R, for Random
		  @sprites["pokedex"].index = rand(@dexlist.length)
		  @sprites["pokedex"].refresh
		  pbRefresh
		elsif Input.pressex?(0x47) && $DEBUG # G, for Get
			if debugControl
				@dexlist.each do |dexlist_entry|
					entrySpecies = dexlist_entry[0]
					pbAddPokemonSilent(entrySpecies,$game_variables[26])
				end
				pbMessage("Added every species on the current list!")
			else
				pbAddPokemonSilent(@sprites["pokedex"].species,$game_variables[26])
				pbMessage("Added #{@sprites["pokedex"].species}")
			end
		elsif Input.pressex?(0x57) && $DEBUG # W, for Wild Pokemon
			pbWildBattle(@sprites["pokedex"].species, $game_variables[26])
		elsif Input.pressex?(0x42) && $DEBUG # B, for Boss
			begin
				species = @sprites["pokedex"].species
				if isLegendary?(species)
					pbBigAvatarBattle([species.to_sym, $game_variables[26]])
				else
					pbSmallAvatarBattle([species.to_sym, $game_variables[26]])
				end
			rescue
				pbMessage(_INTL("Unable to start Avatar battle."))
			end
		elsif Input.pressex?(0x4F) && $DEBUG # O, for Own
			@dexlist.each do |dexlist_entry|
				entrySpecies = dexlist_entry[0]
				$Trainer.pokedex.set_owned(entrySpecies, false)
			end
			pbMessage("Marked as owned every species on current list.")
		elsif Input.pressex?(0x50) && $DEBUG # P, for Print
			echoln("Printing the entirety of the current dex list.")
			if Input.press?(Input::CTRL)
				@dexlist.each do |dexEntry|
					echoln(dexEntry[0])
				end
			else
				@dexlist.each do |dexEntry|
					echoln(GameData::Species.get(dexEntry[0]).real_name)
				end
			end
			pbMessage("Printed the current list to the console.")
		elsif Input.pressex?(0x49) && $DEBUG # I, for Investigation
			printDexListInvestigation()
		elsif Input.pressex?(0x54) && $DEBUG # T, for Tutor
			modifyTutorLearnability()
		elsif Input.pressex?(0x46) && $DEBUG # F, for Filter
			acceptSearchResults {
				debugFilterToRegularLine()
			}
		end
      end
    }
  end

  # Used in debug mode to quickly filter to non-legendary pokemon that can't evolve
  def debugFilterToRegularLine()
	dexlist = searchStartingList()
	dexlist = dexlist.find_all { |item|	
		next !isLegendary?(item[0]) && item[14].length == 0
	}
	return dexlist
  end

  def modifyTutorLearnability()
	while true
		moveNameInput = pbEnterText("Move name...", 0, 16)
		if moveNameInput && moveNameInput!=""	
			actualMoveID = nil
			GameData::Move.each do |moveData|
				if moveData.real_name.downcase == moveNameInput.downcase
					actualMoveID = moveData.id
					break
				end
			end
			if actualMoveID.nil?
				pbMessage(_INTL("Invalid input: {1}", moveNameInput))
				next
			end

			tutorActionSelection = pbMessage("Do what with #{actualMoveID}?",[_INTL("Teach"),_INTL("Remove"),_INTL("Replace"),_INTL("Cancel")],4)
	  		return if tutorActionSelection == 3

			if tutorActionSelection == 2
				while true
					replacementMoveNameInput = pbEnterText("Move name...", 0, 16)
					if replacementMoveNameInput && replacementMoveNameInput != ""				
						replacementActualMoveID = nil
						GameData::Move.each do |moveData|
							if moveData.real_name.downcase == replacementMoveNameInput.downcase
								replacementActualMoveID = moveData.id
								break
							end
						end
						if replacementActualMoveID.nil?
							pbMessage(_INTL("Invalid input: {1}", replacementMoveNameInput))
							next
						end
					end
					break
				end
			end

			lineBehaviourSelection = pbMessage("Do what with same line?",[_INTL("Both"),_INTL("Prevos"),_INTL("Evos"),_INTL("Neither"),_INTL("Cancel")],5)
	  		return if lineBehaviourSelection == 4
			
			speciesToEdit = []
			@dexlist.each do |dexlist_entry|
				species = dexlist_entry[0]
				speciesData = GameData::Species.get(species)
				speciesToEdit.push(species)

				# Grab the prevos
				if lineBehaviourSelection == 0 || lineBehaviourSelection == 1
					getPrevosInLineAsList(speciesData).each do |prevoSpecies|
						speciesToEdit.push(prevoSpecies)
					end
				end

				# Grab the prevos
				if lineBehaviourSelection == 0 || lineBehaviourSelection == 2
					getEvosInLineAsList(speciesData).each do |evoSpecies|
						speciesToEdit.push(evoSpecies)
					end
				end
			end

			speciesToEdit.uniq!
			speciesToEdit.compact!
			speciesEdited = 0
			if tutorActionSelection == 0
				echoln("Adding #{actualMoveID} to tutor movesets:")
				speciesToEdit.each do |species|
					speciesData = GameData::Species.get(species)
					next if speciesData.tutor_moves.include?(actualMoveID)
					speciesData.tutor_moves.push(actualMoveID)
					echoln(species)
					speciesEdited += 1
				end
			elsif tutorActionSelection == 1
				echoln("Deleting #{actualMoveID} from tutor movesets:")
				speciesToEdit.each do |species|
					speciesData = GameData::Species.get(species)
					next if !speciesData.tutor_moves.include?(actualMoveID)
					speciesData.tutor_moves.delete(actualMoveID)
					echoln(species)
					speciesEdited += 1
				end
			elsif tutorActionSelection == 2
				echoln("Replacing #{actualMoveID} in tutor movesets with #{replacementActualMoveID}:")
				speciesToEdit.each do |species|
					speciesData = GameData::Species.get(species)
					next if !speciesData.tutor_moves.include?(actualMoveID)
					next if speciesData.tutor_moves.include?(replacementActualMoveID)
					speciesData.tutor_moves.delete(actualMoveID)
					speciesData.tutor_moves.push(replacementActualMoveID)
					echoln(species)
					speciesEdited += 1
				end
			end
			pbMessage("#{speciesEdited} species tutor movesets edited!")

			GameData::Species.save
			Compiler.write_pokemon
		end
		break
	end
  end

  def printDexListInvestigation()
	# Find information about the currently displayed list
	typesCount = {}
	GameData::Type.each do |typesData|
		next if typesData.id == :QMARKS
		typesCount[typesData.id] = 0
	end
	total = 0
	@dexlist.each do |dexEntry|
		#next if isLegendary(dexEntry[0]) || isQuarantined(dexEntry[0])
		speciesData = GameData::Species.get(dexEntry[0])
		disqualify = false
		speciesData.get_evolutions().each do |evolutionEntry|
			evoSpecies = evolutionEntry[0]
			@dexlist.each do |searchDexEntry|
				if searchDexEntry[0] == evoSpecies
					disqualify = true
				end
				break if disqualify
			end
			break if disqualify
		end
		next if disqualify
		typesCount[speciesData.type1] += 1
		typesCount[speciesData.type2] += 1 if speciesData.type2 != speciesData.type1
		total += 1
	end
	
	typesCount = typesCount.sort_by{|type,count| -count}
	
	# Find information about the whole game list
	
	wholeGameTypesCount = {}
	GameData::Type.each do |typesData|
	next if typesData.id == :QMARKS
	wholeGameTypesCount[typesData.id] = 0
	end
	pbGetDexList.each do |dexEntry|
	next if isLegendary(dexEntry[0]) || isQuarantined(dexEntry[0])
	speciesData = GameData::Species.get(dexEntry[0])
	next if speciesData.get_evolutions().length > 0
	wholeGameTypesCount[speciesData.type1] += 1
	wholeGameTypesCount[speciesData.type2] += 1 if speciesData.type2 != speciesData.type1
	end
	
	# Display investigation
	
	echoln("Investigation of the currently displayed dexlist:")
	echoln("Type,Count,PercentOfCurrentList,PercentageTypeCompletion")
	typesCount.each do |type,count|
	percentOfThisList = ((count.to_f/total.to_f) * 10000).floor / 100.0
	percentOfTypeIsInThisMap = ((count.to_f/wholeGameTypesCount[type].to_f) * 10000).floor / 100.0
	echoln("#{type},#{count},#{percentOfThisList},#{percentOfTypeIsInThisMap}")
	end
  end
  
  def pbCloseSearch
    oldsprites = pbFadeOutAndHide(@sprites)
    oldspecies = @sprites["pokedex"].species
    @searchResults = false
	$PokemonGlobal.stored_search = nil
    $PokemonGlobal.pokedexMode = MODENUMERICAL
    @searchParams  = [$PokemonGlobal.pokedexMode,-1,-1,-1,-1,-1,-1,-1,-1,-1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    for i in 0...@dexlist.length
      next if @dexlist[i][0]!=oldspecies
      @sprites["pokedex"].index = i
      pbRefresh
      break
    end
    $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index
    pbFadeInAndShow(@sprites,oldsprites)
  end
  
  def updateSearch2Cursor(index)
	if index >= 6
		index -= 6
		shiftRightABit = true
	end
	@sprites["search2cursor"].x = index % 2 == 0 ? 72 : 296
	@sprites["search2cursor"].x += 4 if shiftRightABit
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
	xLeft = 92
	xLeft2 = 316
	page1textpos = [
	   [_INTL("Choose a Search"),Graphics.width/2,-2,2,shadow,base],
       [_INTL("Name"),xLeft,68,0,base,shadow],
       [_INTL("Types"),xLeft2,68,0,base,shadow],
       [_INTL("Abilities"),xLeft,164,0,base,shadow],
       [_INTL("Moves"),xLeft2,164,0,base,shadow],
	   [_INTL("Evolution"),xLeft,260,0,base,shadow],
	   [_INTL("Available"),xLeft2,260,0,base,shadow]
    ]
	xLeft += 4
	xLeft2 += 4
	page2textpos = [
	   [_INTL("Choose a Search"),Graphics.width/2,-2,2,shadow,base],
       [_INTL("Collecting"),xLeft,68,0,base,shadow],
	   [_INTL("Matchups"),xLeft2,68,0,base,shadow],
       [_INTL("Stats"),xLeft,164,0,base,shadow],
	   [_INTL("Stat Sort"),xLeft2,164,0,base,shadow],
       [_INTL("Filters"),xLeft,260,0,base,shadow],
	   [_INTL("Sorts"),xLeft2,260,0,base,shadow]
    ]
	pbDrawTextPositions(overlay,page1textpos)
	
	# Begin the search screen
	pbFadeInAndShow(@sprites)
	oldIndex = 0
	loop do
      if index!=oldIndex
		pbPlayCursorSE
		
		if oldIndex < 6 && index >=6
			pbFadeOutAndHide(@sprites)
			overlay.clear
			pbDrawTextPositions(overlay,page2textpos)
			@sprites["searchbg2"].visible     = true
			@sprites["overlay"].visible      = true
			@sprites["search2cursor"].visible = true
		elsif oldIndex >= 6 && index < 6
			pbFadeOutAndHide(@sprites)
			overlay.clear
			pbDrawTextPositions(overlay,page1textpos)
			@sprites["searchbg"].visible     = true
			@sprites["overlay"].visible      = true
			@sprites["search2cursor"].visible = true
		end
		
        updateSearch2Cursor(index)
        oldIndex = index
      end
	  
	  Graphics.update
      Input.update
      pbUpdate
	  
      if Input.trigger?(Input::UP)
        index -= 2 if ![0,1,6,7].include?(index)
      elsif Input.trigger?(Input::DOWN)
        index += 2 if ![4,5,10,11].include?(index)
      elsif Input.trigger?(Input::LEFT)
		if index % 2 == 1
			index -= 1
		elsif [6,8,10].include?(index)
			index -= 5
		end
      elsif Input.trigger?(Input::RIGHT)
        if index % 2 == 0
			index += 1
		elsif [1,3,5].include?(index)
			index += 5
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
		when 6
		  searchChanged = acceptSearchResults2 {
			searchByCollecting()
		  }
		when 7
		  searchChanged = acceptSearchResults2 {
			searchByTypeMatchup()
		  }
		when 8
		  searchChanged = acceptSearchResults2 {
			searchByStatComparison()
		  }
		when 9
		  searchChanged = acceptSearchResults2 {
			sortByStat()
		  }
		when 10
		  searchChanged = acceptSearchResults2 {
			searchByMisc()
		  }
		when 11
		  searchChanged = acceptSearchResults2 {
			sortByOther()
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

	def acceptSearchResults(&searchingBlock)
		pbPlayDecisionSE
		@sprites["pokedex"].active = false
		begin
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
		rescue
		pbMessage(_INTL("An unknown error has occured."))
		end
		@sprites["pokedex"].active = true
		pbRefresh
	end
  
  def acceptSearchResults2(&searchingBlock)
	  pbPlayDecisionSE
	  begin
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
	  rescue
		pbMessage(_INTL("An unknown error has occured."))
	  end
	  return false
  end
  
  def searchBySpeciesName()
	  nameInput = pbEnterText("Search species...", 0, 12)
	  if nameInput && nameInput!=""
		  reversed = nameInput[0] == '-'
		  nameInput = nameInput[1..-1] if reversed
		  dexlist = searchStartingList()
		  dexlist = dexlist.find_all { |item|
		  	next false if autoDisqualifyFromSearch(item[0])
			searchPokeName = item[1]
			value = searchPokeName.downcase.include?(nameInput.downcase) ^ reversed # Boolean XOR
			next value
		  }
		  return dexlist
	  end
	  return nil
  end
  
  def searchByAbility()
	  abilitySearchTypeSelection = pbMessage("Which search?",[_INTL("Name"),_INTL("Description"),_INTL("Cancel")],3)
	  return if abilitySearchTypeSelection == 2
	  
	  if abilitySearchTypeSelection == 0
		  while true
			  abilityNameInput = pbEnterText("Search abilities...", 0, 20)
			  if abilityNameInput && abilityNameInput!=""
				reversed = abilityNameInput[0] == '-'
				abilityNameInput = abilityNameInput[1..-1] if reversed

				actualAbility = nil
				GameData::Ability.each do |abilityData|
					if abilityData.real_name.downcase == abilityNameInput.downcase
						actualAbility = abilityData.id
						break
					end
				end
				if actualAbility.nil?
					pbMessage(_INTL("Invalid input: {1}", abilityNameInput))
					next
				end

				dexlist = searchStartingList()
				dexlist = dexlist.find_all { |item|
					next false if autoDisqualifyFromSearch(item[0])
					searchPokeAbilities = item[10]
					value = false
					value = true if searchPokeAbilities.include?(actualAbility)
					value = value ^ reversed # Boolean XOR
					next value
				}
				return dexlist
			  else
				return nil
			  end
		  end
	  elsif abilitySearchTypeSelection == 1
		  abilityDescriptionInput = pbEnterText("Search ability desc...", 0, 20)
		  if abilityDescriptionInput && abilityDescriptionInput!=""
			reversed = abilityDescriptionInput[0] == '-'
			abilityDescriptionInput = abilityDescriptionInput[1..-1] if reversed

			dexlist = searchStartingList()
			dexlist = dexlist.find_all { |item|
				next false if autoDisqualifyFromSearch(item[0])
				searchPokeAbilities = item[10]
				value = false
				value = true if searchPokeAbilities[0] && GameData::Ability.get(searchPokeAbilities[0]).description.downcase.include?(abilityDescriptionInput.downcase)
				value = true if searchPokeAbilities[1] && GameData::Ability.get(searchPokeAbilities[1]).description.downcase.include?(abilityDescriptionInput.downcase)
				value = value ^ reversed # Boolean XOR
				next value
			}
			return dexlist
		  else
			return nil
		  end
	  end
	  return nil
  end
  
  def searchByMoveLearned()
	  learningMethodSelection = pbMessage("Which method?",[_INTL("Any"),_INTL("Level Up"),_INTL("By Specific Level"),_INTL("Tutor"),_INTL("Cancel")],5)
	  return if learningMethodSelection == 4
	  
	  if learningMethodSelection == 2
		while true
			levelTextInput = pbEnterText(_INTL("Enter level..."), 0, 3)
			return nil if levelTextInput.blank?
			reversed = levelTextInput[0] == '-'
			levelTextInput = levelTextInput[1..-1] if reversed

			levelIntAttempt = levelTextInput.to_i
			if levelIntAttempt == 0
				pbMessage(_INTL("Invalid level input."))
				next
			end
			break
		end
	  end
      
	  while true
		  moveNameInput = pbEnterText("Move name...", 0, 16)
		  if moveNameInput && moveNameInput!=""
				reversed = moveNameInput[0] == '-'
				moveNameInput = moveNameInput[1..-1] if reversed
				
				actualMove = nil
			    GameData::Move.each do |moveData|
					if moveData.real_name.downcase == moveNameInput.downcase
						actualMove = moveData.id
						break
					end
			    end
				if actualMove.nil?
					pbMessage(_INTL("Invalid input: {1}", moveNameInput))
					next
				end
				
				dexlist = searchStartingList()
				dexlist = dexlist.find_all { |item|
					next false if autoDisqualifyFromSearch(item[0])
					contains = false
					
					# By level up
					if learningMethodSelection == 0 || learningMethodSelection == 1
						lvlmoves = item[11]
						lvlmoves.each do |learnset_entry|
						  if learnset_entry[1] == actualMove
							contains = true
							break
						  end
						end
					end
					
					# By specific level
					if learningMethodSelection == 2
						lvlmoves = item[11]
						lvlmoves.each do |learnset_entry|
							break if learnset_entry[0] > levelIntAttempt
							if learnset_entry[1] == actualMove
								contains = true
								break
							end
						end
					end
					
					if learningMethodSelection == 0 || learningMethodSelection == 3
						eggmoves = item[13]
						eggmoves.each do |move|
						  if move == actualMove
							contains = true
							break
						  end
						end
						
						tutormoves = item[12]
						tutormoves.each do |move|
						  if move == actualMove
							contains = true
							break
						  end
						end
					end

					next contains ^ reversed # Boolean XOR
				}
			  return dexlist
		  end
		  break
	  end
	  return nil
  end
  
	def searchByType()
	  selections = [_INTL("Either"),_INTL("Full"),_INTL("Cancel")]
	  learningMethodSelection = pbMessage("Either type or full typing?",selections,selections.length)
	  return if learningMethodSelection == selections.length - 1
	  
	  full = learningMethodSelection == 1
	  
	  while true
		  typesInput = pbEnterText(full ? "Search full typing..." : "Search type...", 0, 100)
		  typesInput.downcase!
		  if typesInput && typesInput != ""
			  reversed = typesInput[0] == '-'
			  typesInput = typesInput[1..-1] if reversed
			  typesInputArray = typesInput.split(" ")
			  
			  # Throw out improper input
			  if typesInputArray.length > 1 && !full
				pbMessage(_INTL("Don't input more than one type for \"Either\" type search. "))
				next
			  end
			  
			  # Don't do the search if one of the input type names isn't an actual type
			  invalid = false
			  typesInputArray.each do |type_input_entry|
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
			  end
			  next if invalid
			  
			  if typesInputArray.length == 1
				typesInputArray = [typesInputArray[0],typesInputArray[0]]
			  end
			  
			  dexlist = searchStartingList()
			  dexlist = dexlist.find_all { |item|
				next false if autoDisqualifyFromSearch(item[0])
				searchPokeType1 = item[6]
				searchPokeType1Name = GameData::Type.get(searchPokeType1).real_name.downcase if searchPokeType1
				searchPokeType2 = item[7]
				searchPokeType2Name = GameData::Type.get(searchPokeType2).real_name.downcase if searchPokeType2
				
				pokeTypeNames = [searchPokeType1Name,searchPokeType2Name]
				
				if full
					survivesSearch = pokeTypeNames.eql?(typesInputArray) || pokeTypeNames.reverse.eql?(typesInputArray)
				else
					survivesSearch = pokeTypeNames.include?(typesInputArray[0])
				end
				
				next survivesSearch ^ reversed # Boolean XOR
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
		  dexlist = searchStartingList()
		  dexlist = dexlist.find_all { |item|
			next false if autoDisqualifyFromSearch(item[0])
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

		  levelCheck = roundUpToRelevantCap(levelIntAttempt)
		  
		  dexlist = searchStartingList()
		  dexlist = dexlist.find_all { |item|
			next false if autoDisqualifyFromSearch(item[0])
			available = GameData::Species.get(item[0]).available_by?(levelCheck)
			next available ^ reversed # Boolean XOR
		  }
		  return dexlist
	  end
	  return nil
  end


	def searchByCollecting()
		selection = pbMessage("Which search?",[_INTL("Starred"),_INTL("Owned"),_INTL("Not Starred"),_INTL("Not Owned"),_INTL("Cancel")],5)
	    if selection != 4 
			dexlist = searchStartingList()
			
			dexlist = dexlist.find_all { |item|
				species = item[0]
				next false if autoDisqualifyFromSearch(species)
				
				case selection
				when 0
					next $PokemonGlobal.speciesStarred?(species)
				when 1
					next $Trainer.owned?(species)
				when 2
					next !$PokemonGlobal.speciesStarred?(species)
				when 3
					next !$Trainer.owned?(species)
				end
			}
			
			return dexlist
		end
		return nil
	end
	
	def searchByStatComparison()
		statSelection = pbMessage("Which stat?",[_INTL("HP"),_INTL("Attack"),_INTL("Defense"),
			_INTL("Sp. Atk"),_INTL("Sp. Def"),_INTL("Speed"),_INTL("Total"),_INTL("Phys. EHP"),_INTL("Spec. EHP"),_INTL("Cancel")],10)
	    return if statSelection == 9
		comparisonSelection = pbMessage("Which comparison?",[_INTL("Equal to number"),
			_INTL("Greater than number"),_INTL("Less than number"),_INTL("Equal to stat"),
			_INTL("Greater than stat"),_INTL("Less than stat"),_INTL("Cancel")],7)
		return if comparisonSelection == 6 
		
		stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:PEHP,:SEPH]
		if comparisonSelection <= 2
			statTextInput = pbEnterText("Input value...", 0, 3)
			if statTextInput && statTextInput!=""
				statIntAttempt = statTextInput.to_i
				
				return nil if statIntAttempt == 0
				
				comparitorB = statIntAttempt
			else
				return nil
			end
		elsif
			statSelectionComparison = pbMessage("Compare to which stat?",[_INTL("HP"),_INTL("Attack"),_INTL("Defense"),
			_INTL("Sp. Atk"),_INTL("Sp. Def"),_INTL("Speed"),_INTL("Phys. EHP"),_INTL("Spec. EHP"),_INTL("Cancel")],9)
			return if statSelectionComparison == 8
			
			comparitorB = stats[statSelectionComparison]
		end
		
		comparitorA = stats[statSelection]
		
		dexlist = searchStartingList()
		dexlist = dexlist.find_all { |item|
			next false if autoDisqualifyFromSearch(item[0])
			
			species_data = GameData::Species.get(item[0])
			
			statToCompareA = 0
			case statSelection
			when 0..5
				statToCompareA = species_data.base_stats[comparitorA]
			when 6
				species_data.base_stats.each do |s|
					statToCompareA += s[1]
				end
			when 7
				statToCompareA = species_data.physical_ehp	
			when 8
				statToCompareA = species_data.special_ehp
			end
			
			statToCompareB = 0
			if comparitorB.is_a?(Symbol)
				calced_stats = species_data.base_stats
				calced_stats[:PEHP] = species_data.physical_ehp
				calced_stats[:SEHP] = species_data.special_ehp
				statToCompareB = calced_stats[comparitorB]
			else
				statToCompareB = comparitorB
			end
						
			result = false
			case comparisonSelection % 3
			when 0
				result = statToCompareA == statToCompareB
			when 1
				result =  statToCompareA > statToCompareB
			when 2
				result =  statToCompareA < statToCompareB
			end
			
			next result
		}
		
		return dexlist
	end
	
	def searchByMisc()
		miscSearches 			= []
		cmdTribe				= -1
		cmdMapFound 			= -1
		cmdZooSection 			= -1
		cmdWildItem 			= -1
		cmdIsQuarantined 		= -1
		cmdIsLegendary 			= -1
		cmdMovesetConformance 	= -1
		cmdOneAbility 			= -1
		cmdHasSignatureMove 	= -1
		cmdHasSignatureAbility 	= -1
		cmdHasSignature 		= -1
		cmdAvatarData			= -1
		cmdOneAbility 			= -1
		cmdHasCoverageType		= - 1
		cmdInvertList			= -1
		miscSearches[cmdTribe = miscSearches.length] = _INTL("Tribe")
		miscSearches[cmdMapFound = miscSearches.length] = _INTL("Map Found")
		miscSearches[cmdWildItem = miscSearches.length] = _INTL("Wild Items")
		miscSearches[cmdIsQuarantined = miscSearches.length] = _INTL("Quarantined") if $DEBUG
		miscSearches[cmdIsLegendary = miscSearches.length] = _INTL("Legendary")
		miscSearches[cmdMovesetConformance = miscSearches.length] = _INTL("Moveset Noncomfority") if $DEBUG
		miscSearches[cmdOneAbility = miscSearches.length] = _INTL("One Ability") if $DEBUG
		miscSearches[cmdHasSignatureMove = miscSearches.length] = _INTL("Signature Move")
		miscSearches[cmdHasSignatureAbility = miscSearches.length] = _INTL("Signature Ability")
		miscSearches[cmdHasSignature = miscSearches.length] = _INTL("Signature (D)") if $DEBUG
		miscSearches[cmdAvatarData = miscSearches.length] = _INTL("Avatar Data (D)") if $DEBUG
		miscSearches[cmdHasCoverageType = miscSearches.length] = _INTL("Has Coverage Type (D)") if $DEBUG
		miscSearches[cmdGeneration = miscSearches.length] = _INTL("Generation")
		miscSearches[cmdInvertList = miscSearches.length] = _INTL("Invert Current")
		miscSearches.push(_INTL("Cancel"))
		searchSelection = pbMessage("Which search?",miscSearches,miscSearches.length)
		if cmdTribe > -1 && searchSelection == cmdTribe
			return searchByTribe() 
		elsif cmdMapFound > -1 && searchSelection == cmdMapFound
			return searchByMapFound() 
		elsif cmdZooSection > -1 && searchSelection == cmdZooSection
			return searchByZooSection()
		elsif cmdIsQuarantined > -1 && searchSelection == cmdIsQuarantined
			return searchByQuarantined()
		elsif cmdIsLegendary > -1 && searchSelection == cmdIsLegendary
			return searchByLegendary()
		elsif cmdWildItem > -1 && searchSelection == cmdWildItem
			return searchByWildItem()
		elsif cmdGeneration > -1 && searchSelection == cmdGeneration
			return searchByGeneration()
		elsif cmdMovesetConformance > -1 && searchSelection == cmdMovesetConformance
			return searchByMovesetConformance()
		elsif cmdOneAbility > -1 && searchSelection == cmdOneAbility
			return searchByOneAbility()
		elsif cmdHasSignatureMove > -1 && searchSelection == cmdHasSignatureMove
			return searchBySignatureMove()
		elsif cmdHasSignatureAbility > -1 && searchSelection == cmdHasSignatureAbility
			return searchBySignatureAbility()
		elsif cmdAvatarData > -1 && searchSelection == cmdAvatarData
			return searchByHasAvatarData()
		elsif cmdHasSignature > -1 && searchSelection == cmdHasSignature
			return searchBySignature()
		elsif cmdHasCoverageType > -1 && searchSelection == cmdHasCoverageType
			return searchByHasCoverageType()
		elsif cmdInvertList > -1 && searchSelection == cmdInvertList
			return invertSearchList()
		end
	end

	def searchByTribe()
		dexlist = searchStartingList()

		commands = []
		tribes = []
		GameData::Tribe.each do |tribe|
			tribes.push(tribe.id)
			commands.push(TribalBonus.getTribeName(tribe.id))
		end
		commands.push(_INTL("Cancel"))
		command = pbMessage("Which tribe?",commands,commands.length)
		return if command == commands.length - 1

		chosenTribe = tribes[command]

		echoln("Searching for the tribe #{chosenTribe}")

		dexlist = dexlist.find_all { |dex_item|
				next false if autoDisqualifyFromSearch(dex_item[0])
				
				fSpecies = GameData::Species.get(dex_item[0])

				echoln(fSpecies.tribes)
				
				next fSpecies.tribes.include?(chosenTribe)
		}
		return dexlist
	end

	def searchByHasCoverageType()
		while true
			typeInput = pbEnterText("Search type...", 0, 100)
			typeInput.downcase!
			if typeInput && typeInput != ""
				reversed = typeInput[0] == '-'
				typeInput = typeInput[1..-1] if reversed
				
				# Don't do the search if one of the input type names isn't an actual type
				realTypeSymbol = nil
				GameData::Type.each do |type_data|
					if type_data.real_name.downcase == typeInput
						realTypeSymbol = type_data.id
						break
					end
				end
				if realTypeSymbol.nil?
					pbMessage(_INTL("Invalid input: {1}", typeInput))
					next
				end

				dexlist = searchStartingList()
				
				dexlist = dexlist.find_all { |dex_item|
						next false if autoDisqualifyFromSearch(dex_item[0])
						
						fSpecies = GameData::Species.get(dex_item[0])
						typesOfCoverage = get_bnb_coverage(fSpecies)
						
						next typesOfCoverage.include?(realTypeSymbol) ^ reversed # Boolean XOR
				}
				return dexlist
			end
		end
	end

	def searchByOneAbility()
		dexlist = searchStartingList()
		
		dexlist = dexlist.find_all { |dex_item|
				next false if autoDisqualifyFromSearch(dex_item[0])
				
				fSpecies = GameData::Species.get(dex_item[0])
				
				next fSpecies.abilities.length == 1
		}
		return dexlist
	end

	def searchBySignatureMove()
		dexlist = searchStartingList()
		
		dexlist = dexlist.find_all { |dex_item|
				next false if autoDisqualifyFromSearch(dex_item[0])

				hasSignatureMove = false
				
				# By level up
				dex_item[11].each do |learnset_entry|
					if GameData::Move.get(learnset_entry[1]).is_signature?
						hasSignatureMove = true
						break
					end
				end

				next true if hasSignatureMove
				
				# Egg moves
				dex_item[13].each do |move|
					if GameData::Move.get(move).is_signature?
						hasSignatureMove = true
						break
					end
				end

				next true if hasSignatureMove
				
				# Tutor moves
				dex_item[12].each do |move|
					if GameData::Move.get(move).is_signature?
						hasSignatureMove = true
						break
					end
				end

				next hasSignatureMove
		}
		return dexlist
	end

	def searchBySignatureAbility()
		dexlist = searchStartingList()
		
		dexlist = dexlist.find_all { |dex_item|
				next false if autoDisqualifyFromSearch(dex_item[0])
				
				hasSignatureAbility = false
				dex_item[10].each do |ability|
					hasSignatureAbility = true if GameData::Ability.get(ability).is_signature?
				end
				next hasSignatureAbility
		}
		return dexlist
	end

	def searchByHasAvatarData()
		dexlist = searchStartingList()
		
		dexlist = dexlist.find_all { |dex_item|
				next false if autoDisqualifyFromSearch(dex_item[0])
				
				fSpecies = GameData::Species.get(dex_item[0])
				
				next GameData::Avatar.exists?(fSpecies.species)
		}
		return dexlist
	end

	def searchBySignature()
		selection = pbMessage("Which search?",[_INTL("Has Signature"),_INTL("Doesn't"),_INTL("Cancel")],3)
	    if selection != 2 
			dexlist = searchStartingList()
			
			dexlist = dexlist.find_all { |dex_item|
					next false if autoDisqualifyFromSearch(dex_item[0])
					
					fSpecies = GameData::Species.get(dex_item[0])
					
					if selection == 0
						next @signatureMoves.has_value?(fSpecies.id) || @signatureAbilities.has_value?(fSpecies.id)
					else
						next !@signatureMoves.has_value?(fSpecies.id) && !@signatureAbilities.has_value?(fSpecies.id)
					end
			}
			return dexlist
		end
		return nil
	end
	
	def searchByWildItem
		dexlist = searchStartingList()
		
		wildItemNameTextInput = pbEnterText("Search item name...", 0, 20)
		return if wildItemNameTextInput.blank?
		reversed = wildItemNameTextInput[0] == '-'
		wildItemNameTextInput = wildItemNameTextInput[1..-1] if reversed
		
		dexlist = dexlist.find_all { |dex_item|
			next false if autoDisqualifyFromSearch(dex_item[0])
			
			fSpecies = GameData::Species.get(dex_item[0])
			items = []
			items.push(fSpecies.wild_item_common) if fSpecies.wild_item_common
			items.push(fSpecies.wild_item_uncommon) if fSpecies.wild_item_uncommon
			items.push(fSpecies.wild_item_rare) if fSpecies.wild_item_rare
			items.uniq!
			items.compact!
			
			itemNames = []
			items.each_with_index do |item,index|
				itemNames.push(GameData::Item.get(item).real_name.downcase)
			end
			
			next itemNames.include?(wildItemNameTextInput.downcase) ^ reversed # Boolean XOR
		}
		return dexlist
	end
	
	def searchByMapFound
		dexlist = searchStartingList()
		
		mapNameTextInput = pbEnterText("Search map name...", 0, 20)
		return if mapNameTextInput.blank?
		reversed = mapNameTextInput[0] == '-'
		mapNameTextInput = mapNameTextInput[1..-1] if reversed
		
		speciesPresent = []
		GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
				mapName = pbGetMapNameFromId(enc_data.map)
				next unless mapName.downcase.include?(mapNameTextInput.downcase)
				enc_data.types.each do |key,slots|
					next if !slots
					slots.each { |slot|
						speciesPresent.push(slot[1])
					}
				end
		end
		
		dexlist = dexlist.find_all { |item|
				next false if autoDisqualifyFromSearch(item[0])
				
				next speciesPresent.include?(item[0]) ^ reversed # Boolean XOR
		}
		return dexlist
	end
	
	def searchByQuarantined()
		selection = pbMessage("Which search?",[_INTL("Quarantined"),_INTL("Not Quarantined"),_INTL("Cancel")],3)
	    if selection != 2 
			dexlist = searchStartingList()
			
			dexlist = dexlist.find_all { |item|	
				if selection == 1
					next !isQuarantined?(item[0])
				else
					next isQuarantined?(item[0])
				end
			}
			return dexlist
		end
		return nil
	end
	
	def searchByMovesetConformance()
		dexlist = searchStartingList()
		
		commandAny = -1
		command4Tempo = -1
		commandMaxLevelUp = -1
		commandExcessiveLevel1s = -1
		commandAbove70 = -1
		commandNoEarlyStab = -1
		commandNoProgressStab = -1
		commandNoBBStab = -1
		comandDuplicateMoves = -1
		commands = [_INTL("Cancel")]
		commands[commandAny = commands.length] = _INTL("Any")
		commands[command4Tempo = commands.length] = _INTL("Non-4-Tempo")
		commands[commandMaxLevelUp = commands.length] = _INTL("Ends before value")
		commands[commandExcessiveLevel1s = commands.length] = _INTL("Too Many 1s")
		commands[commandAbove70 = commands.length] = _INTL("Above 70")
		commands[commandNoEarlyStab = commands.length] = _INTL("No Pre-16 Stab")
		commands[commandNoProgressStab = commands.length] = _INTL("No 16-31 Stab")
		commands[commandNoBBStab = commands.length] = _INTL("No 32-44 Stab")
		commands[commandDuplicateMoves = commands.length] = _INTL("Duplicate Moves")
		selection = pbMessage("Which rulebreakers?",commands,3)
		unless selection == 0
			checkedMaxLevel = 70
			if commandMaxLevelUp > -1 && selection == commandMaxLevelUp
				levelTextInput = pbEnterText("Pick final intended moveset level...", 0, 3)
				if levelTextInput && levelTextInput!=""
					checkedMaxLevel = levelTextInput.to_i
					return nil if checkedMaxLevel == 0
				else
					return nil
				end
			end

			dexlist = dexlist.find_all { |item|			
				lvlmoves = item[11]
				types = [item[6],item[7]]
				types.uniq!
				types.compact!
				typeCount = types.length
				
				anyNon4s = false
				anyDuplicates = false
				countOf1s = 0
				maxLevel = 0
				earlyStabDebt,progressStabDebt,bbStabDebt = typeCount,typeCount,typeCount

				allMoves = []

				lvlmoves.each do |learnset_entry|
					learnLevel = learnset_entry[0]
					moveSym = learnset_entry[1]

					maxLevel = learnLevel if learnLevel > maxLevel
					if learnLevel == 1
						countOf1s += 1
					elsif learnLevel % 4 != 0
						anyNon4s = true
					end

					if learnLevel != 0
						if allMoves.include?(moveSym)
							anyDuplicates = true
						else
							allMoves.push(moveSym)
						end
					end
					
					moveData = GameData::Move.get(moveSym)
					if types.include?(moveData.type) && moveData.category != 2 # Damaging move
						if learnLevel < 16
							earlyStabDebt -= 1
						elsif learnLevel < 32
							progressStabDebt -= 1
						elsif learnLevel < 45
							bbStabDebt -= 1
						end
					end
				end
				
				breaks4s = false
				if anyNon4s && (selection == command4Tempo || selection == commandAny)
					next true
				end
				
				if maxLevel < checkedMaxLevel && (selection == commandMaxLevelUp || selection == commandAny)
					next true
				end
				
				if countOf1s > 3 && (selection == commandExcessiveLevel1s || selection == commandAny)
					next true
				end
				
				if maxLevel > 70 && (selection == commandAbove70 || selection == commandAny)
					next true
				end
				
				if earlyStabDebt > 0 && (selection == commandNoEarlyStab || selection == commandAny)
					next true
				end
				
				if progressStabDebt > 0 && (selection == commandNoProgressStab || selection == commandAny)
					next true
				end
				
				if bbStabDebt > 0 && (selection == commandNoBBStab || selection == commandAny)
					next true
				end

				if anyDuplicates && (selection = commandDuplicateMoves || selection == commandAny)
					next true
				end
				
				next false
			}
			return dexlist
		end
		return nil
	end
	
	def searchByLegendary()
		selection = pbMessage("Which search?",[_INTL("Legendary"),_INTL("Not Legendary"),_INTL("Cancel")],3)
	    if selection != 2 
			dexlist = searchStartingList()
			
			dexlist = dexlist.find_all { |item|	
				if selection == 1
					next !isLegendary?(item[0])
				else
					next isLegendary?(item[0])
				end
			}
			return dexlist
		end
		return nil
	end
	
	def searchByGeneration()
		dexlist = searchStartingList()
		
		generationNumber = 0
		while true
			generationNumberTextInput = pbEnterText("Search generation number...", 0, 20)
			return if generationNumberTextInput.blank?
			reversed = generationNumberTextInput[0] == '-'
			generationNumberTextInput = generationNumberTextInput[1..-1] if reversed
			
			generationNumber = generationNumberTextInput.to_i
			if generationNumber <= 0 || generationNumber >= 9
				pbMessage("Please choose a generation number between 1 and 8.")
			else
				break
			end
		end
		
		generationFirstNumber = GENERATION_END_IDS[generationNumber-1]
		generationLastNumber = GENERATION_END_IDS[generationNumber]
		
		dexlist = dexlist.find_all { |item|
				next false if autoDisqualifyFromSearch(item[0])
				id = GameData::Species.get(item[0]).id_number
				
				isInChosenGeneration = id > generationFirstNumber &&
										id <= generationLastNumber
				
				next isInChosenGeneration ^ reversed # Boolean XOR
		}
		return dexlist
	end

	def invertSearchList()
		dexlist = pbGetDexList()
		dexlist = dexlist.find_all { |item|
			next false if autoDisqualifyFromSearch(item[0])
			next !@dexlist.any? { |current_item| current_item[0] == item[0]}
		}
		return dexlist
	end
	
	def searchByTypeMatchup()
		sectionSelection = pbMessage("Which interaction?",[_INTL("Weak To"),_INTL("Resists"),
			_INTL("Immune To"),_INTL("Neutral To"),_INTL("Has Immunity"),_INTL("Has Hyper Weakness"),_INTL("Cancel")],7)
	    return if sectionSelection == 6 
		
		if sectionSelection <= 3
			return searchByTypeEffectiveness(sectionSelection)
		else
			dexlist = searchStartingList()
			dexlist = dexlist.find_all { |item|
				next false if autoDisqualifyFromSearch(item[0])
				
				hasThingOfInterest = false
				GameData::Type.each do |type|
					next if type.pseudo_type

					effectiveness = Effectiveness.calculate(type.id,item[6],item[7])

					if sectionSelection == 4 && Effectiveness.ineffective?(effectiveness)
						hasThingOfInterest = true
						break
					end

					if sectionSelection == 5 && Effectiveness.hyper_effective?(effectiveness)
						hasThingOfInterest = true
						break
					end
				end

				next hasThingOfInterest
			}
			return dexlist
		end
	end

	def searchByTypeEffectiveness(effectivenessSelection)
		while true
			typesInput = pbEnterText("Which type(s)?", 0, 100)
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
					type_symbol = nil
					GameData::Type.each do |type_data|
						if type_data.real_name.downcase == type_input_entry
							typeIsReal = true
							type_symbol = type_data.id
							break
						end
					end
					if !typeIsReal
						pbMessage(_INTL("Invalid input: {1}", type_input_entry))
						invalid = true
						break
					end
					typesSearchInfo[type_symbol] = reversed
				end
				next if invalid
				
				dexlist = searchStartingList()
				dexlist = dexlist.find_all { |item|
					next false if autoDisqualifyFromSearch(item[0])
					
					survivesSearch = true
					typesSearchInfo.each do |type,reversed|
						effect = Effectiveness.calculate(type,item[6],item[7])
								
						case sectionSelection
						when 0
							survivesSearch = false if !Effectiveness.super_effective?(effect) ^ reversed
						when 1
							survivesSearch = false if !Effectiveness.not_very_effective?(effect) ^ reversed
						when 2
							survivesSearch = false if !Effectiveness.ineffective?(effect) ^ reversed
						when 3
							survivesSearch = false if !Effectiveness.normal?(effect) ^ reversed
						end
					end
					next survivesSearch
				}
				return dexlist
			end
			return nil
		end
	end
	
	def sortByStat()
		statSelection = pbMessage("Which stat?",[_INTL("HP"),_INTL("Attack"),_INTL("Defense"),
			_INTL("Sp. Atk"),_INTL("Sp. Def"),_INTL("Speed"),_INTL("Total"),_INTL("Phys. EHP"),_INTL("Spec. EHP"),_INTL("Cancel")],10)
	    return if statSelection == 9
		sortDirection = pbMessage("Which direction?",[_INTL("Descending"),_INTL("Ascending"),_INTL("Cancel")],3)
		return if sortDirection == 2
		dexlist = @dexlist
		dexlist.sort_by! { |entry|
			speciesData = GameData::Species.get(entry[0])
			value = 0
			case statSelection
			when 0
				value = speciesData.base_stats[:HP]
			when 1
				value = speciesData.base_stats[:ATTACK]
			when 2
				value = speciesData.base_stats[:DEFENSE]
			when 3
				value = speciesData.base_stats[:SPECIAL_ATTACK]
			when 4
				value = speciesData.base_stats[:SPECIAL_DEFENSE]
			when 5
				value = speciesData.base_stats[:SPEED]
			when 6
				speciesData.base_stats.each do |s|
					value += s[1]
				end
			when 7
				value = speciesData.physical_ehp
			when 8
				value = speciesData.special_ehp
			end
			
			value *= -1 if sortDirection == 0
			next value
		}
		
		return dexlist
	end
	
	def sortByOther()
		cmdSortByType = -1
		cmdSortByGenderRate = -1
		cmdSortByGrowthRate = -1
		cmdSortByHeight = -1
		cmdSortByWeight = -1
		cmdSortByCatchDifficulty = -1
		cmdSortByExperienceGrant = -1
		cmdSortByTrainerCount = -1
		cmdSortByCoverageTypesCount = -1
		selections = []
		selections[cmdSortByType = selections.length] = _INTL("Type")
		selections[cmdSortByGenderRate = selections.length] = _INTL("Gender Rate")
		selections[cmdSortByGrowthRate = selections.length] = _INTL("Growth Rate")
		selections[cmdSortByHeight = selections.length] = _INTL("Height")
		selections[cmdSortByWeight = selections.length] = _INTL("Weight")
		selections[cmdSortByCatchDifficulty = selections.length] = _INTL("Catch Difficulty")
		selections[cmdSortByExperienceGrant = selections.length] = _INTL("Experience Grant")
		selections[cmdSortByTrainerCount = selections.length] = _INTL("Trainers Using (D)") if $DEBUG
		selections[cmdSortByCoverageTypesCount = selections.length] = _INTL("Coverage Count (D)") if $DEBUG
		selections.push(_INTL("Cancel"))
		selection = pbMessage("Sort by what?",selections,selections.length+1)
	    return if selection == selections.length
		dexlist = @dexlist

		typesCount = 0
		GameData::Type.each { |t| typesCount += 1 if !t.pseudo_type && t.id != :SHADOW }

		dexlist.sort_by! { |entry|
			speciesData = GameData::Species.get(entry[0])
			
			if cmdSortByType > -1 && selection == cmdSortByType
				types = [speciesData.type1,speciesData.type2]
				types.sort_by!{ |type|
					GameData::Type.get(type).id_number
				}
				value = 0
				types.each_with_index do |type,index|
					value += GameData::Type.get(type).id_number * (typesCount ** index)
				end
				
				next value
			elsif cmdSortByGenderRate > -1 && selection == cmdSortByGenderRate
				case speciesData.gender_ratio
				when :Genderless
					next 300
				when :AlwaysMale
					next 0
				when :AlwaysFemale
					next 255
				end
				genderRatioData = GameData::GenderRatio.get(speciesData.gender_ratio)
				next genderRatioData.female_chance
			elsif cmdSortByHeight > -1 && selection == cmdSortByHeight
				next -speciesData.height
			elsif cmdSortByWeight > -1 && selection == cmdSortByWeight
				next -speciesData.weight
			elsif cmdSortByGrowthRate > -1 && selection == cmdSortByGrowthRate
				next -GameData::GrowthRate.get(speciesData.growth_rate).id
			elsif cmdSortByCatchDifficulty > -1 && selection == cmdSortByCatchDifficulty
				next -speciesData.catch_rate
			elsif cmdSortByExperienceGrant > -1 && selection == cmdSortByExperienceGrant
				next speciesData.base_exp
			elsif cmdSortByTrainerCount > -1 && selection == cmdSortByTrainerCount
				next @speciesUseData[entry[0]] || 0
			elsif cmdSortByCoverageTypesCount > -1 && selection == cmdSortByCoverageTypesCount
				next get_bnb_coverage(speciesData).size
			end
		}
		return dexlist
	end
end