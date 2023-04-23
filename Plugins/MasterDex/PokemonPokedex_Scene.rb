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
	@search2Cursorbitmap	= AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/cursor_search"))
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites,"background","Pokedex/bg_list",@viewport)
    addBackgroundPlane(@sprites,"searchbg","Pokedex/bg_search",@viewport)
	addBackgroundPlane(@sprites,"searchbg2","Pokedex/bg_search_2",@viewport)
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
					pbAddPokemonSilent(entrySpecies,getLevelCap)
				end
				pbMessage("Added every species on the current list!")
			else
				pbAddPokemonSilent(@sprites["pokedex"].species,getLevelCap)
				pbMessage("Added #{@sprites["pokedex"].species}")
			end
		elsif Input.pressex?(0x57) && $DEBUG # W, for Wild Pokemon
			pbWildBattle(@sprites["pokedex"].species, getLevelCap)
		elsif Input.pressex?(0x42) && $DEBUG # B, for Boss
			begin
				species = @sprites["pokedex"].species
				if isLegendary?(species)
					pbBigAvatarBattle([species.to_sym, getLevelCap])
				else
					pbSmallAvatarBattle([species.to_sym, getLevelCap])
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
		moveNameInput = pbEnterText("Move name...", 0, 20)
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
				echoln("Deleting #{actualMoveID} from tutor/line movesets:")
				speciesToEdit.each do |species|
					speciesData = GameData::Species.get(species)
					edited = false
					if speciesData.tutor_moves.include?(actualMoveID)
						speciesData.tutor_moves.delete(actualMoveID)
						edited = true
					end
					if speciesData.egg_moves.include?(actualMoveID)
						speciesData.egg_moves.delete(actualMoveID)
						edited = true
					end
					if edited
						echoln(species)
						speciesEdited += 1
					end
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
       [_INTL("Tribe"),xLeft,68,0,base,shadow],
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
			searchByTribe()
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
end