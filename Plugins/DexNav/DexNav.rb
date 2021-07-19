class NewDexNav

  def initialize
	# Set up the three peices of UI
    @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport1.z = 99999
    @viewport2 = Viewport.new(30, 120, Graphics.width, Graphics.height)
    @viewport2.z = 999999
    @viewport3 = Viewport.new(0, 120, Graphics.width, Graphics.height)
    @viewport3.z = 999999
    $viewport1 = nil
    searchmon = 0
    @sprites = {}
    @encarray = []
    encstringarray = []

	# Load encounter data for the given route
	result = getEncounterData()
	if !result
		pbMessage(_INTL("There are no encounters on this map."))
		return
	end
	
	# Remove encounters which you haven't even seen yet
	@stripped_encarray = @encarray.reject{ |entry|
		!$Trainer.seen?(entry)
	}
	
	# Create the sprites that show the encounters for this area
	owned = 0
	@pkmnsprite = []
    @stripped_encarray.each_with_index do |species,iconIndex|
        encstringarray.push(GameData::Species.get(species).name)
        @pkmnsprite[iconIndex]=PokemonSpeciesIconSprite.new(species,@viewport2)
		@pkmnsprite[iconIndex].silhouette = true
		if $Trainer.pokedex.owned?(species)
			owned += 1
			@pkmnsprite[iconIndex].silhouette = false
		end
        if iconIndex > 6 && iconIndex < 14
			@pkmnsprite[iconIndex].y += 64
			@pkmnsprite[iconIndex].x = (64 * (iconIndex-7))
        elsif iconIndex > 13
			@pkmnsprite[iconIndex].y += 128
			@pkmnsprite[iconIndex].x = (64 * (iconIndex-14))
        else
        @pkmnsprite[iconIndex].x += 64 * iconIndex
        end
    end
	
	# Show information about the map and if you've completed it
	loctext = _INTL("#{$game_map.name}")
	status = "Incomplete"
	status = "No species seen!" if @stripped_encarray.length == 0
	status = "All seen!" if @stripped_encarray.length == @encarray.length
	status = "All owned!" if owned == @encarray.length
	loctext += _INTL("<al>#{status}</al>")
    loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
	
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport1
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=20
    @sprites["locwindow"].width=512
    @sprites["locwindow"].height=344
    @sprites["locwindow"].setSkin("Graphics/Windowskins/frlgtextskin")
    @sprites["locwindow"].opacity=100
    @sprites["locwindow"].visible=true
    @sprites["nav"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport3)
    @sprites["nav"].x = 5
    @sprites["nav"].y = 18
    @sprites["nav"].visible
    @sprites["nav"].play
    pbFadeInAndShow(@sprites)
    openMainDexNavScreen
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  
  def pushEncounterListX(encounterData,listOfEncounterLists,indexOfList)
    return if !listOfEncounterLists[indexOfList]
	for i in 0...listOfEncounterLists[indexOfList].length
		encounterData.push(listOfEncounterLists[indexOfList][i][1])
	end
  end

  def getEncounterData
    mapid = $game_map.map_id
    encounters = GameData::Encounter.get(mapid, $PokemonGlobal.encounter_version)
    return false if encounters == nil
    encounter_tables = Marshal.load(Marshal.dump(encounters.types))
	encounterListsList = []
	encounters.types.keys.each do |encounter_type|
		encounterListsList.push(encounter_tables[encounter_type])
	end
    
	allEncounters = []
	for i in 0...encounterListsList.length
		pushEncounterListX(allEncounters,encounterListsList,i)
	end
	  
    allEncounters.uniq!
    allEncounters = allEncounters.compact
    @encarray = allEncounters.sort!{|a,b| GameData::Species.get(a).id_number <=> GameData::Species.get(b).id_number}
	return true
  end
  
  # Get the encounter terrain of the player's current location
  def getEncounterTerrain
	  pLoc = $game_map.terrain_tag($game_player.x,$game_player.y)
      if GameData::TerrainTag.get(pLoc).id == :Snow
        encTerr = :Snow
      elsif GameData::TerrainTag.get(pLoc).id == :Grass || GameData::TerrainTag.get(pLoc).id == :None
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          encTerr = :OldRod
        else
          if !$PokemonEncounters.has_normal_land_encounters?
            encTerr = :Sand if $PokemonEncounters.has_sandy_encounters?
            encTerr = :Graveyard if $PokemonEncounters.has_graveyard_encounters?
            encTerr = :Snow if $PokemonEncounters.has_snow_encounters?
            encTerr = :HighBridge if $PokemonEncounters.has_high_bridge_encounters?
            encTerr = :Water if $PokemonEncounters.has_water_encounters?
            encTerr = :Cave if $PokemonEncounters.has_cave_encounters?
          else
            encTerr = :Land
          end
        end
      elsif GameData::TerrainTag.get(pLoc).id == :HighBridge
        encTerr = :HighBridge
      elsif GameData::TerrainTag.get(pLoc).id == :Graveyard
        encTerr = :Graveyard
      elsif GameData::TerrainTag.get(pLoc).id == :Snow
        if $MapFactory.getFacingTerrainTag== :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          encTerr = :OldRod
        else
          encTerr = :Sand if $PokemonEncounters.has_sandy_encounters?
          encTerr = :Graveyard if $PokemonEncounters.has_graveyard_encounters?
          encTerr = :Snow if $PokemonEncounters.has_snow_encounters?
          encTerr = :HighBridge if $PokemonEncounters.has_high_bridge_encounters?
          encTerr = :Water if $PokemonEncounters.has_water_encounters?
          encTerr = :Cave if $PokemonEncounters.has_cave_encounters?
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Sandy || GameData::TerrainTag.get(pLoc).id == :Sand
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          encTerr = :OldRod
        else
          encTerr = :Sand if $PokemonEncounters.has_sandy_encounters?
          encTerr = :Graveyard if $PokemonEncounters.has_graveyard_encounters?
          encTerr = :Snow if $PokemonEncounters.has_snow_encounters?
          encTerr = :HighBridge if $PokemonEncounters.has_high_bridge_encounters?
          encTerr = :Water if $PokemonEncounters.has_water_encounters?
          encTerr = :Cave if $PokemonEncounters.has_cave_encounters?
        end
      elsif GameData::TerrainTag.get(pLoc).can_surf || GameData::TerrainTag.get(pLoc).id == :Bridge
        encTerr = :Water
      end
	  return encTerr
  end

  def openMainDexNavScreen
    navMon = 0
    lastMon = @stripped_encarray.length - 1
	
    @sprites["selectedSpeciesName"] = Window_AdvancedTextPokemon.new("Unknown")
    @sprites["selectedSpeciesName"].viewport = @viewport1
    @sprites["selectedSpeciesName"].x=340
    @sprites["selectedSpeciesName"].y=52
    @sprites["selectedSpeciesName"].width=156
    @sprites["selectedSpeciesName"].windowskin = nil
	
	@sprites["nav"].visible = false if @stripped_encarray.length == 0
	
	# Begin taking input for the main dexnav screen
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::DOWN) && (navMon + 7) <= lastMon
        navMon += 7
        @sprites["nav"].y += 64
      elsif Input.trigger?(Input::UP) && navMon > 6
        navMon -=7
        @sprites["nav"].y -= 64
      elsif Input.trigger?(Input::LEFT) && navMon % 7 != 0
        navMon -=1
        @sprites["nav"].x -= 64
      elsif Input.trigger?(Input::RIGHT) && navMon % 7 != 6 && navMon < lastMon
        navMon +=1
        @sprites["nav"].x += 64
      elsif Input.trigger?(Input::C)
        if !($Trainer.pokedex.owned?(@stripped_encarray[navMon]) || ($DEBUG && Input.press?(Input::CTRL)))
          pbMessage(_INTL("You cannot search for this Pokémon, because you haven't owned one yet!"))
          next
        elsif $currentDexSearch != nil
          pbMessage(_INTL("You're already searching for a Pokémon!"))
          @viewport2.dispose
          break
        else
			searchTime = 20 + rand(80)
            pbMessage(_INTL("Searching\\ts[15]...\\wtnp[#{searchTime}]"))
            pbMessage(_INTL("Oh! A Pokemon was found nearby!"))
		    species=@stripped_encarray[navMon]
		    # We generate the pokemon they found (added to the encounters),
		    # giving it some rare "egg moves"to incentivize using  this function
		    $currentDexSearch=[species,getRandomEggMove(species)]
		    pbFadeOutAndHide(@sprites)
		    break
        end
      elsif Input.trigger?(Input::B)
        navMon = -1
        dispose
        break
      end
	  name = $Trainer.pokedex.owned?(@stripped_encarray[navMon]) ? GameData::Species.get(@stripped_encarray[navMon]).name : "Unknown"
	  @sprites["selectedSpeciesName"].text = _INTL("<c2=FFCADE00>{1}</c2>",name)
    end
    if navMon != -1
      @viewport2.dispose
      beginSearchWithOverlay
    end
  end

  def beginSearchWithOverlay
    searchmon = GameData::Species.get($currentDexSearch[0]).id
	
	# Determine which of the Pokemon's abilities it will have, and store that info for later
    navRand = rand(2)
    $game_variables[400] = navRand
    navAbil1 = GameData::Species.get_species_form(searchmon,0).abilities
    if navAbil1[1] != nil
      navAbil = [navAbil1[0],navAbil1[1]]
    else
      navAbil = [navAbil1[0],navAbil1[0]]
    end
	
	# Display information about the pokemon being searched for
	if $currentDexSearch[1] == nil
      dexMove = "-"
    else
      dexMove = GameData::Move.get($currentDexSearch[1]).name
    end
    @sprites["search"] = Window_AdvancedTextPokemon.newWithSize("",265,130,250,126,@viewport3)
    @sprites["search"].text = _INTL("{1}\n{2}\n{3}",
		GameData::Species.get(searchmon).name,GameData::Ability.get(navAbil[navRand]).name,dexMove)
    @sprites["search"].setSkin("Graphics/Windowskins/frlgtextskin")
    @sprites["search"].opacity = 140
    @sprites["searchIcon"] = PokemonSpeciesIconSprite.new(searchmon,@viewport3)
    @sprites["searchIcon"].x = 450
    @sprites["searchIcon"].y = 65

	Graphics.update
	$viewport1 = @viewport3
    pbFadeInAndShow(@sprites) {pbUpdate}
    $game_switches[350] = true
  end
end

Events.onStartBattle+=proc {|_sender,e|
  if $game_switches[350] == true
    $viewport1.dispose
    $game_switches[350] = false
  end
}

Events.onMapChanging +=proc {|_sender,e|
  if $game_switches[350] == true
    $viewport1.dispose
    $currentDexSearch = nil
    $game_switches[350] = false
  end
}

Events.onWildPokemonCreate+=proc {|sender,e|
    pokemon=e[0]
    # Checks current search value, if it exists, sets the Pokemon to it
    if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
        pokemon.species=$currentDexSearch[0]
        pokemon.name=GameData::Species.get(pokemon.species).name
        pokemon.ability_index = $game_variables[400]
        maps = GameData::MapMetadata.try_get($game_map.map_id)
        pform = 0
        if pform == 0 && maps && maps==0
          if isConst?(pokemon.species,GameData::Species,:RIOLU)||isConst?(pokemon.species,GameData::Species,:LUCARIO)||isConst?(pokemon.species,GameData::Species,:BUNEARY)||isConst?(pokemon.species,GameData::Species,:LOPUNNY)||isConst?(pokemon.species,GameData::Species,:NUMEL)||isConst?(pokemon.species,GameData::Species,:CAMERUPT)||isConst?(pokemon.species,GameData::Species,:ROCKRUFF)||isConst?(pokemon.species,GameData::Species,:YAMASK)
            pform += 2
          elsif isConst?(pokemon.species,GameData::Species,:CACNEA)||isConst?(pokemon.species,GameData::Species,:CACTURNE)||isConst?(pokemon.species,GameData::Species,:SANDYGAST)||isConst?(pokemon.species,GameData::Species,:PALOSSAND)||isConst?(pokemon.species,GameData::Species,:DEINO)||isConst?(pokemon.species,GameData::Species,:ZWEILOUS)||isConst?(pokemon.species,GameData::Species,:HYDREIGON)||isConst?(pokemon.species,GameData::Species,:TRAPINCH)||isConst?(pokemon.species,GameData::Species,:HORSEA)||isConst?(pokemon.species,GameData::Species,:SEADRA)||isConst?(pokemon.species,GameData::Species,:EXEGGCUTE)||isConst?(pokemon.species,GameData::Species,:EXEGGUTOR)||isConst?(pokemon.species,GameData::Species,:SEEL)||isConst?(pokemon.species,GameData::Species,:DEWGONG)||isConst?(pokemon.species,GameData::Species,:DROWZEE)||isConst?(pokemon.species,GameData::Species,:PHANPY)||isConst?(pokemon.species,GameData::Species,:ZEBSTRIKA)
            pform += 1
          else
            pform = pform
          end
        end
        pokemon.form = pform
        pokemon.reset_moves
        pokemon.learn_move(Pokemon::Move.new($currentDexSearch[1])) if $currentDexSearch[1]
        # There is a higher chance for shininess, so we give it another chance to force it to be shiny
        tempInt = $PokemonBag.pbQuantity(GameData::Item.get(:SHINYCHARM))>0 ? 256 : 768
        if rand(tempInt)==1
         pokemon.makeShiny
        end
        $currentDexSearch = nil
    end
}

# Gets a random ID of a legal egg move of the given species and returns it as a move object.
def getRandomEggMove(species)
	baby = GameData::Species.get(species).get_baby_species
	maps = GameData::MapMetadata.try_get($game_map.map_id)
	form = 0
	if form == 0 && maps && maps==0
	  if isConst?(baby,GameData::Species,:RIOLU)||isConst?(baby,GameData::Species,:LUCARIO)||isConst?(baby,GameData::Species,:BUNEARY)||isConst?(baby,GameData::Species,:LOPUNNY)||isConst?(baby,GameData::Species,:NUMEL)||isConst?(baby,GameData::Species,:CAMERUPT)||isConst?(baby,GameData::Species,:ROCKRUFF)||isConst?(baby,GameData::Species,:YAMASK)
		form += 2
	  elsif isConst?(baby,GameData::Species,:CACNEA)||isConst?(baby,GameData::Species,:CACTURNE)||isConst?(baby,GameData::Species,:SANDYGAST)||isConst?(baby,GameData::Species,:PALOSSAND)||isConst?(baby,GameData::Species,:DEINO)||isConst?(baby,GameData::Species,:ZWEILOUS)||isConst?(baby,GameData::Species,:HYDREIGON)||isConst?(baby,GameData::Species,:TRAPINCH)||isConst?(baby,GameData::Species,:HORSEA)||isConst?(baby,GameData::Species,:SEADRA)||isConst?(baby,GameData::Species,:EXEGGCUTE)||isConst?(baby,GameData::Species,:EXEGGUTOR)||isConst?(baby,GameData::Species,:SEEL)||isConst?(baby,GameData::Species,:DEWGONG)||isConst?(baby,GameData::Species,:DROWZEE)||isConst?(baby,GameData::Species,:PHANPY)||isConst?(baby,GameData::Species,:ZEBSTRIKA)
		form += 1
	  else
		form = form
	  end
	end
	egg = GameData::Species.get_species_form(baby,form).egg_moves
	moveChoice = rand(egg.length)
	move = egg[moveChoice]
	return move
end


class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :silhouette

  def initialize(species,viewport=nil)
    super(viewport)
    @species      = species
    @gender       = 0
    @form         = 0
    @shiny        = false
    @numFrames    = 0
    @currentFrame = 0
    @counter      = 0
	@silhouette   = false
    refresh
  end
  
  def silhouette=(value)
    @silhouette = value
    refresh
  end

  def refresh
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny)
    return if !bitmapFileName
    @animBitmap = AnimatedBitmap.new(bitmapFileName)
    self.bitmap = @animBitmap.bitmap
	if @silhouette
		self.bitmap = @animBitmap.bitmap.clone
		for x in 0..bitmap.width
			for y in 0..bitmap.height
			  bitmap.set_pixel(x,y,Color.new(200,200,200,255)) if bitmap.get_pixel(x,y).alpha > 0
			end
		end
	end
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width / @animBitmap.height
    @currentFrame = 0 if @currentFrame>=@numFrames
    changeOrigin
  end
end
