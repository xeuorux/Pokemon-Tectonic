module Settings
	USE_CURRENT_REGION_DEX = true
	def self.pokedex_names
		return [
		_INTL("National Pokédex")
		]
	end
	DEX_SHOWS_ALL_FORMS = true
end


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
	legendaries = [legendaries1,legendaries2,legendaries3,legendaries4,legendaries5,legendaries6,legendaries7,legendaries8,legendaries9].flatten
	return legendaries.include?(GameData::Species.get(species_symbol).id_number)
end

class PokeBattle_Scene
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
	when :HasInParty; return "when leveled up while a #{GameData::Species.get(parameter).name} is also in the party"
    end
    return "via a method the programmer was too lazy to describe"
end

def speciesEntry(species)
	pbFadeOutIn {
		scene = PokemonPokedexInfo_Scene.new
		screen = PokemonPokedexInfoScreen.new(scene)
		screen.pbStartSceneSingle(species)
	}
end

module GameData
	class Species
		def get_prevolutions(exclude_invalid = false)
		  ret = []
		  @evolutions.each do |evo|
			next if !evo[3]   # Is the prevolution
			next if evo[1] == :None && exclude_invalid
			ret.push([evo[0], evo[1], evo[2]])   # [Species, method, parameter]
		  end
		  return ret
		end
	end
end

class PokemonPokedexInfoScreen
	def pbStartSceneSingle(species,battle=false)   # For use from a Pokémon's summary screen
		region = -1
		if Settings::USE_CURRENT_REGION_DEX
		  region = pbGetCurrentRegion
		  region = -1 if region >= $Trainer.pokedex.dexes_count - 1
		else
		  region = $PokemonGlobal.pokedexDex   # National Dex -1, regional Dexes 0, 1, etc.
		end
		dexnum = pbGetRegionalNumber(region,species)
		dexnumshift = Settings::DEXES_WITH_OFFSETS.include?(region)
		dexlist = [[species,GameData::Species.get(species).name,0,0,dexnum,dexnumshift]]
		@scene.pbStartScene(dexlist,0,region,battle)
		@scene.pbScene
		@scene.pbEndScene
	end
end

class Window_Pokedex < Window_DrawableCommand
	def drawItem(index,_count,rect)
		return if index>=self.top_row+self.page_item_max
		rect = Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
		species     = @commands[index][0]
		indexNumber = @commands[index][4]
		indexNumber -= 1 if @commands[index][5]
		if !isLegendary(species) || $Trainer.seen?(species)
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