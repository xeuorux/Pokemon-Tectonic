class PokemonGlobalMetadata
	def pokedexStars
	  @pokedexStars = {} if @pokedexStars.nil?
	  return @pokedexStars
	end

	def speciesStarred?(species)
		if !pokedexStars.has_key?(species)
			pokedexStars[species] = false
		end
		return pokedexStars[species]
	end

	def toggleStarred(species)
		if !pokedexStars.has_key?(species)
			pokedexStars[species] = true
		else
			pokedexStars[species] = !pokedexStars[species]
		end
	end
end

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
  $Trainer.pokedex.refresh_accessible_dexes()
end

def describeEvolutionMethod(method,parameter=0)
    case method
    when :Level,:Ninjask; return _INTL("at level #{parameter}")
    when :LevelMale; return _INTL("at level #{parameter} if it's male")
    when :LevelFemale; return _INTL("at level #{parameter} if it's female")
    when :LevelDay; return _INTL("at level #{parameter} during the day")
    when :LevelNight; return _INTL("at level #{parameter} during nighttime")
    when :LevelRain; return _INTL("at level #{parameter} while raining")
    when :LevelDarkInParty; return _INTL("at level #{parameter} while a dark type is in the party")
    when :AttackGreater; return _INTL("at level #{parameter} if it has more attack than defense")
    when :AtkDefEqual; return _INTL("at level #{parameter} if it has attack equal to defense" )
    when :DefenseGreater; return _INTL("at level #{parameter} if it has more defense than attack" )
    when :Silcoon; return _INTL("at level #{parameter} half of the time")
    when :Cascoon; return _INTL("at level #{parameter} the other half of the time")
	when :Ability0; return _INTL("at level #{parameter} if it has the first of its possible abilities")
	when :Ability1; return _INTL("at level #{parameter} if it has the second of its possible abilities")
    when :Happiness; return _INTL("when leveled up while it has high happiness")
    when :MaxHappiness; return _INTL("when leveled up while it has maximum happiness")
    when :Beauty; return _INTL("when leveled up while it has maximum beauty")
    when :HasMove; return _INTL("when leveled up while it knows the move #{GameData::Move.get(parameter).real_name}")
    when :HasMoveType; return _INTL("when leveled up while it knows a move of the #{GameData::Move.get(parameter).real_name} type")
    when :Location; return _INTL("when leveled up near a special location")
    when :Item; return _INTL("when a #{GameData::Item.get(parameter).real_name} is used on it")
    when :ItemMale; return _INTL("when a #{GameData::Item.get(parameter).real_name} is used on it if it's male")
    when :ItemFemale; return _INTL("when a #{GameData::Item.get(parameter).real_name} is used on it if it's female")
    when :Trade; return _INTL("when traded")
    when :TradeItem; return _INTL("when traded holding an #{GameData::Item.get(parameter).real_name}")
	when :HasInParty; return _INTL("when leveled up while a #{GameData::Species.get(parameter).name} is also in the party")
	when :Shedinja; return _INTL("also if you have an empty pokeball and party slot")
    when :Originize; return _INTL("when a #{GameData::Item.get(:ORIGINORE).real_name} is used on it at level #{parameter}")
	end
    return "via a method the programmer was too lazy to describe"
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
	typesOfCoverage.sort_by!{|type_id| GameData::Type.get(type_id).id_number}

	return typesOfCoverage
end

def theoreticalCaptureChance(status,current_hp,total_hp,catch_rate)
	return 0 if !defined?(PokeBattle_Battle.captureThresholdCalcInternals)
    y = PokeBattle_Battle.captureThresholdCalcInternals(status,current_hp,total_hp,catch_rate)
    chancePerShake = y.to_f/PokeBattle_Battle::CATCH_BASE_CHANCE.to_f
    overallChance = chancePerShake ** 4
    return overallChance
end

def roundUpToRelevantCap(level)
	minNearestMapCap = 100
	MAPS_AVAILABLE_BY_CAP.each do |capLevel, maps|
		if capLevel >= level
			minNearestMapCap = capLevel
			break
		end
	end
	minNearestItemCap = 100
	ITEMS_AVAILABLE_BY_CAP.each do |capLevel, items|
		if capLevel >= level
			minNearestItemCap = capLevel
			break
		end
	end
	return [minNearestMapCap,minNearestItemCap].min
end