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

def isLegendary(species_symbol)
	legendaries1 = [144,145,146,150,151]
	legendaries2 = [243,244,245,249,250,251]
	legendaries3 = (377..386).to_a
	legendaries4 = (480..494).to_a
	legendaries5 = (638..649).to_a
	legendaries6 = (716..721).to_a
	legendaries7 = (772..773).to_a
	legendaries8 = (785..809).to_a
	legendaries9 = (888..898).to_a
	legendaries10 = (2026..2028).to_a
	legendaries = [legendaries1,legendaries2,legendaries3,legendaries4,legendaries5,legendaries6,legendaries7,legendaries8,legendaries9,legendaries10].flatten
	return legendaries.include?(GameData::Species.get(species_symbol).id_number)
end

alias isLegendary? isLegendary

def isQuarantined(species_symbol)
	quarantined = [:YUNGOOS,:GUMSHOOS,:FARFETCHD,:PANSEAR,:SIMISEAR,:QWILFISH,
		:FINNEON,:LUMINEON,:ARROKUDA,:BARRASKEWDA,:GOLDEEN,:SEAKING,:WISHIWASHI,:PANPOUR,
		:SIMIPOUR,:BASCULIN,:TYMPOLE,:PALPITOAD,:SEISMITOAD,:CRAMORANT,:BRUXISH,
		:CORSOLA,:BINACLE,:BARBARACLE,:TIRTOUGA,:CARRACOSTA,:CLAMPERL,:HUNTAIL,
		:GOREBYSS,:PANSAGE,:SIMISAGE,:THROH,:SAWK,:WURMPLE,:CASCOON,:SILCOON,
		:DUSTOX,:BEAUTIFLY,:DODUO,:DODRIO,:UNOWN,:BURMY,:WORMADAM,:SHELMET,
		:ACCELGOR,:KARRABLAST,:ESCAVALIER,:DRACOVISH,:ARCTOVISH,:ARCTOZOLT,:DRACOZOLT
	]
	return quarantined.include?(species_symbol)
end

alias isQuarantined? isQuarantined

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

module GameData
	class Species
		def get_prevolutions(exclude_invalid = false)
		  ret = []
		  @evolutions.each do |evo|
			next if !evo[3]   # Is an evolution
			next if evo[1] == :None && exclude_invalid
			ret.push([evo[0], evo[1], evo[2]])   # [Species, method, parameter]
		  end
		  return ret
		end

		def physical_ehp
			hpCalc = calcHPGlobal(base_stats[:HP],EHP_LEVEL,8)
			defenseCalc = calcStatGlobal(base_stats[:DEFENSE],EHP_LEVEL,8)
			return [(hpCalc * defenseCalc / 100),1].max
		end

		def special_ehp
			hpCalc = calcHPGlobal(base_stats[:HP],EHP_LEVEL,8)
			spDefenseCalc = calcStatGlobal(base_stats[:SPECIAL_DEFENSE],EHP_LEVEL,8)
			return [(hpCalc * spDefenseCalc / 100),1].max
		end
	end
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

def pbFindEncounter(enc_types, species)
    return false if !enc_types
    enc_types.each_value do |slots|
      next if !slots
      slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
    end
    return false
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

def getEvolutionsRecursive(species_data)
	evolutions = species_data.get_evolutions
	if evolutions.length == 0
		return {}
	else
		newEvolutions = {}
		evolutions.each do |entry|
			addToHashOfArrays(newEvolutions,species_data.species,entry)
		end
		evolutions.each do |evolutionEntry|
			data = GameData::Species.get(evolutionEntry[0])
			furtherEvos = getEvolutionsRecursive(data)
			furtherEvos.each do |speciesInvolved,furtherEvolutionEntryArray|
				furtherEvolutionEntryArray.each do |furtherEvolutionEntry|
					addToHashOfArrays(newEvolutions,speciesInvolved,furtherEvolutionEntry)
				end
			end
		end
		return newEvolutions
	end
end
  
def getPrevolutionsRecursive(species_data)
	prevolutions_array = species_data.get_prevolutions
	if prevolutions_array.nil? || prevolutions_array.length == 0
		return {}
	else
		newPrevolutions = {}
		prevolutions_array.each do |evolutionEntry|
			data = GameData::Species.get(evolutionEntry[0])
			furtherPrevos = getPrevolutionsRecursive(data)
			furtherPrevos.each do |speciesInvolved,furtherPrevolutionEntryArray|
				furtherPrevolutionEntryArray.each do |furtherPrevolutionEntry|
					addToHashOfArrays(newPrevolutions,speciesInvolved,furtherPrevolutionEntry)
				end
			end
		end
		prevolutions_array.each do |entry|
			addToHashOfArrays(newPrevolutions,species_data.species,entry)
		end
		return newPrevolutions
	end
end

def addToHashOfArrays(hash_of_arrays,key,newValue)
	if hash_of_arrays.has_key?(key)
		hash_of_arrays[key].push(newValue)
	else
		hash_of_arrays[key] = [newValue]
	end
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