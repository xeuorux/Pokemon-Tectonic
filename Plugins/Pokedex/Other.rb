module Settings
	USE_CURRENT_REGION_DEX = true
	def self.pokedex_names
		return [
		_INTL("National Pokédex")
		]
	end
	DEX_SHOWS_ALL_FORMS = true
end

def openSingleDexScreen(pokemon)
	if pokemon.respond_to?('species')
		$Trainer.pokedex.register_last_seen(pokemon)
		pokemon = pokemon.species
	end
	ret = nil
	pbFadeOutIn {
		scene = PokemonPokedexInfo_Scene.new
		screen = PokemonPokedexInfoScreen.new(scene)
		ret = screen.pbStartSceneSingle(pokemon)
	}
	if ret.is_a?(Symbol)
		echoln("Opening single dex screen from hyperlink to: #{ret}")
		openSingleDexScreen(ret)
	end
end
alias speciesEntry openSingleDexScreen

def unlockDex
  $Trainer.pokedex.unlock(-1)
  $Trainer.pokedex.set_seen(:TREECKO,false)
  $Trainer.pokedex.set_seen(:TORCHIC,false)
  $Trainer.pokedex.set_seen(:MUDKIP,false)
  $Trainer.pokedex.refresh_accessible_dexes()
end

class PokeBattle_Scene
  #=============================================================================
  # Shows the Pokédex entry screen for a newly caught Pokémon
  #=============================================================================
  def pbShowPokedex(species)
	openSingleDexScreen(species)
  end
end

def describeEvolutionMethod(method,parameter=0)
    case method
    when :Level,:Ninjask; return "at level #{parameter}"
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
	when :HasInParty; return "when leveled up while a #{GameData::Species.get(parameter).name} is also in the party"
	when :Shedinja; return "also if you have an empty pokeball and party slot"
    end
    return "via a method the programmer was too lazy to describe"
end

class Window_Pokedex < Window_DrawableCommand
	def drawItem(index,_count,rect)
		return if index>=self.top_row+self.page_item_max
		rect = Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
		species     = @commands[index][0]
		indexNumber = @commands[index][4]
		indexNumber -= 1 if @commands[index][5]
		if !isLegendary(species) || $Trainer.seen?(species) || $DEBUG
		  if $Trainer.owned?(species)
			pbCopyBitmap(self.contents,@pokeballOwn.bitmap,rect.x-6,rect.y+8)
		  else
			pbCopyBitmap(self.contents,@pokeballSeen.bitmap,rect.x-6,rect.y+8)
		  end
		  text = sprintf("%03d%s %s",indexNumber," ",@commands[index][1])
		else
		  text = sprintf("%03d  ----------",indexNumber)
		end
		pbDrawShadowText(self.contents,rect.x+36,rect.y+6,rect.width,rect.height,
		   text,self.baseColor,self.shadowColor)
	end
end

def catchDifficultyFromRareness(rareness)
	if rareness>= 250
		return "F"
	elsif rareness>= 230
		return "D-"
	elsif rareness>= 210
		return "D"
	elsif rareness>= 190
		return "D+"
	elsif rareness>= 170
		return "C-"
	elsif rareness>= 150
		return "C"
	elsif rareness>= 130
		return "C+"
	elsif rareness>= 110
		return "B-"
	elsif rareness>= 90
		return "B"
	elsif rareness >= 70
		return "B+"
	elsif rareness >= 50
		return "A-"
	elsif rareness >= 30
		return "A"
	elsif rareness >= 10
		return "A+"
	else
		return "S"
	end
	return "-"
end

def get_bnb_coverage(species_data)
	moves = []
	species_data.moves.each do |learnsetEntry|
		moves.push(learnsetEntry[1])
	end
	
	moves.concat(species_data.egg_moves)
	moves.concat(species_data.tutor_moves)
	moves.uniq!
	moves.compact!
	
	typesOfCoverage = []
	moves.each do |move|
		moveData = GameData::Move.get(move)
		next if moveData.category == 2
		next unless moveData.base_damage >= 75
		typesOfCoverage.push(moveData.type)
	end
	typesOfCoverage.uniq!
	typesOfCoverage.compact!

	return typesOfCoverage
end