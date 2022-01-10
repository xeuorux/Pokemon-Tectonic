DebugMenuCommands.register("relearnsfix", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Bad relearns fix"),
  "description" => _INTL("Swap moves that are 'relearned' at level 1 into the egg moves category of the lines first species."),
  "effect"      => proc { |sprites, viewport|
    GameData::Species.each do |species_data|
		next if species_data.form != 0
		next if species_data.get_prevolutions.length == 0
				
		movesToKeep = []
		firstSpecies = species_data
		
		# Find the first species of this line, and also gather an array of all moves learned by previous pokemon in the line
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
			firstSpecies.moves.each do |learnset_entry|
				movesToKeep.push(learnset_entry[1])
			end
		end
		
		# Also gather any "evolution" moves from the current species
		species_data.moves.each do |learnset_entry|
			next unless learnset_entry[0] == 0
			movesToKeep.push(learnset_entry[1])
		end
		
		movesToKeep.uniq!
		movesToKeep.compact!
		
		newLearnSet = []
		species_data.moves.each do |learnset_entry|
			level = learnset_entry[0]
			move = learnset_entry[1]
			if movesToKeep.include?(move) || level != 1
				newLearnSet.push([level,move])
			else
				echo("Transferring the move #{move} of the species #{species_data.id} to its first line-member #{firstSpecies.id}\n")
				firstSpecies.egg_moves.push(move)
			end
		end
		
		new_species_hash = {
          :id                    => species_data.id,
          :id_number             => species_data.id_number,
          :name                  => species_data.name,
          :form_name             => species_data.form_name,
          :category              => species_data.category,
          :pokedex_entry         => species_data.pokedex_entry,
          :type1                 => species_data.type1,
          :type2                 => species_data.type2,
          :base_stats            => species_data.base_stats,
          :evs                   => species_data.evs,
          :base_exp              => species_data.base_exp,
          :growth_rate           => species_data.growth_rate,
          :gender_ratio          => species_data.gender_ratio,
          :catch_rate            => species_data.catch_rate,
          :happiness             => species_data.happiness,
          :moves                 => newLearnSet, # MODIFIED
          :tutor_moves           => species_data.tutor_moves,
          :egg_moves             => species_data.egg_moves,
          :abilities             => species_data.abilities,
          :hidden_abilities      => species_data.hidden_abilities,
          :wild_item_common      => species_data.wild_item_common,
          :wild_item_uncommon    => species_data.wild_item_uncommon,
          :wild_item_rare        => species_data.wild_item_rare,
          :egg_groups            => species_data.egg_groups,
          :hatch_steps           => species_data.hatch_steps,
          :incense               => species_data.incense,
          :evolutions            => species_data.evolutions,
          :height                => species_data.height,
          :weight                => species_data.weight,
          :color                 => species_data.color,
          :shape                 => species_data.shape,
          :habitat               => species_data.habitat,
          :generation            => species_data.generation,
          :back_sprite_x         => species_data.back_sprite_x,
          :back_sprite_y         => species_data.back_sprite_y,
          :front_sprite_x        => species_data.front_sprite_x,
          :front_sprite_y        => species_data.front_sprite_y,
          :front_sprite_altitude => species_data.front_sprite_altitude,
          :shadow_x              => species_data.shadow_x,
          :shadow_size           => species_data.shadow_size
        }
		GameData::Species.register(new_species_hash)
		
		firstSpecies.egg_moves.uniq!
		firstSpecies.egg_moves.compact!
	end
	GameData::Species.save
	Compiler.write_pokemon
  }
})

DebugMenuCommands.register("viewdistribution", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("View move distribution"),
  "description" => _INTL("See the total distribution of each move."),
  "effect"      => proc { |sprites, viewport|
	move_counts = {}
	GameData::Move.each do |move|
		move_counts[move.id] = [0,0,0,0,0,0]
		# 0 = Species learn by level up
		# 1 = Species learn by TM
		# 2 = Species learn by egg
		# 3 = Species learn as same-type
		# 4 = Species learn as off-type
		# 5 = Species of the same type which don't learn it
	end
		
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form
		if species_data.form != 0
			formName = species_data.real_form_name
			formName.gsub!("%","") if formName
			echoln("Skipping #{species_data.real_name} (#{formName})")
			next
		end
		
		learnSet = []
		species_data.moves.each do |learnset_entry|
			move_id = learnset_entry[1]
			next if learnSet.include?(move_id)
			move_counts[move_id][0] += 1
			learnSet.push(move_id)
		end
		
		species_data.tutor_moves.each do |move_id|
			move_counts[move_id][1] += 1
			learnSet.push(move_id)
		end
		
		species_data.egg_moves.each do |move_id|
			move_counts[move_id][2] += 1
			learnSet.push(move_id)
		end
		
		species_types = [species_data.type1,species_data.type2]
		
		learnSet.uniq!
		learnSet.compact!
		learnSet.each do |move_id|
			moveData = GameData::Move.get(move_id)
			if species_types.include?(moveData.type)
				move_counts[move_id][3] += 1
			else
				move_counts[move_id][4] += 1
			end
		end
		GameData::Move.each do |move|
			next unless species_types.include?(move.type)
			next if learnSet.include?(move.id)
			move_counts[move.id][5] += 1
		end
	end
	
	move_counts = move_counts.sort_by{|move_id,counts| move_id}
	
	move_counts.each do |move_id,counts|
		moveData = GameData::Move.get(move_id)
		echoln("#{move_id},#{moveData.type},#{counts[0]},#{counts[1]},#{counts[2]},#{counts[3]},#{counts[4]},#{counts[5]}")
	end
  }
})

DebugMenuCommands.register("detectmonotypeabilities", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Detect monotype abilities"),
  "description" => _INTL("See which abilities have too many usages by species-lines of the same type."),
  "effect"      => proc { |sprites, viewport|
	ability_type_counts = {}
	GameData::Ability.each do |ability_data|
		ability_type_counts[ability_data.id] = {}
		GameData::Type.each do |type_data|
			ability_type_counts[ability_data.id][type_data.id] = 0
		end
	end
	
	abilities_by_lines = {}
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form that isn't a regional form
		next if species_data.form != 0
		# ... or if its not fully evolved
		next if species_data.get_evolutions().length > 0
		next if isLegendary?(species_data.id) || isQuarantined?(species_data.id)

				
		species_data.abilities.each do |ability_id|
			ability_type_counts[ability_id][species_data.type1] += 1
			ability_type_counts[ability_id][species_data.type2] += 1 if species_data.type2 != species_data.type1
		end
	end
	
	# Find the outliers
	sorted_info = {}
	ability_type_counts.each do |ability,type_counts|
		type_counts.each do |type,count|
			if count > 0
				sorted_info[[ability,type]] = count
			end
		end
	end
	sorted_info = sorted_info.sort_by { |ability_and_type, count| [-count,ability_and_type[0]] }
	sorted_info.each do |ability_and_type,count|
		ability = ability_and_type[0]
		type = ability_and_type[1]
		echoln("#{ability} is given to #{count} species-lines of the #{type} type.")
	end
  }
})

DebugMenuCommands.register("regionalformsfix", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Regional Forms as Species"),
  "description" => _INTL("Recode regional forms as their own separate species"),
  "effect"      => proc { |sprites, viewport|
	newSpeciesID = 2000
    GameData::Species.each do |species_data|
		next if species_data.form == 0
		next if !species_data.id
		formName = species_data.real_form_name
		next if !formName || formName == ""
		next unless formName.include?("Galarian") || formName.include?("Alolan")
		
		prefix = formName.include?("Galarian") ? "G" : "A"
		trimmedID = species_data.id.to_s[0..-3]
		newID = (prefix + trimmedID).to_sym
		echoln(newID)
	
		new_species_hash = {
          :id                    => newID,
          :id_number             => newSpeciesID,
          :name                  => species_data.name,
		  :form					 => 0,
          :form_name             => "",
          :category              => species_data.category,
          :pokedex_entry         => species_data.pokedex_entry,
          :type1                 => species_data.type1,
          :type2                 => species_data.type2,
          :base_stats            => species_data.base_stats,
          :evs                   => species_data.evs,
          :base_exp              => species_data.base_exp,
          :growth_rate           => species_data.growth_rate,
          :gender_ratio          => species_data.gender_ratio,
          :catch_rate            => species_data.catch_rate,
          :happiness             => species_data.happiness,
          :moves                 => species_data.moves, # MODIFIED
          :tutor_moves           => species_data.tutor_moves,
          :egg_moves             => species_data.egg_moves,
          :abilities             => species_data.abilities,
          :hidden_abilities      => species_data.hidden_abilities,
          :wild_item_common      => species_data.wild_item_common,
          :wild_item_uncommon    => species_data.wild_item_uncommon,
          :wild_item_rare        => species_data.wild_item_rare,
          :egg_groups            => species_data.egg_groups,
          :hatch_steps           => species_data.hatch_steps,
          :incense               => species_data.incense,
          :evolutions            => species_data.evolutions,
          :height                => species_data.height,
          :weight                => species_data.weight,
          :color                 => species_data.color,
          :shape                 => species_data.shape,
          :habitat               => species_data.habitat,
          :generation            => species_data.generation,
          :back_sprite_x         => species_data.back_sprite_x,
          :back_sprite_y         => species_data.back_sprite_y,
          :front_sprite_x        => species_data.front_sprite_x,
          :front_sprite_y        => species_data.front_sprite_y,
          :front_sprite_altitude => species_data.front_sprite_altitude,
          :shadow_x              => species_data.shadow_x,
          :shadow_size           => species_data.shadow_size
        }
		GameData::Species.register(new_species_hash)
		GameData::Species::DATA.delete(species_data.id)
		
		["Back","Back shiny","Front","Front shiny","Icons","Icons shiny","Footprints"].each do |subfolder|
			source = "Graphics/Pokemon/" + subfolder + "/" + species_data.id.to_s + ".png"
			destination = "Graphics/Pokemon/" + subfolder + "/" + newID.to_s + ".png"
			File.copy(source, destination) rescue nil
		end
		
		cry_source = "Audio/SE/Cries/" + trimmedID + ".ogg"
		cry_destination = "Audio/SE/Cries/" + "/" + newID.to_s + ".ogg"
		File.copy(cry_source, cry_destination) rescue nil
		
		newSpeciesID += 1
	end
	GameData::Species.save
	Compiler.write_pokemon
	Compiler.write_pokemon_forms
  }
})

DebugMenuCommands.register("generatechangelog", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Generate species changelog"),
  "description" => _INTL("See the changelog for each species between the Old and New pokemon.txt files."),
  "effect"      => proc { |sprites, viewport|
	firstNumberInput = pbEnterText("First ID number", 0, 3)
	if firstNumberInput.blank?
		next
	end
	firstNumberAttempt = firstNumberInput.to_i
	return nil if firstNumberAttempt == 0
	lastNumberInput = pbEnterText("Last ID number", 0, 3)
	if lastNumberInput.blank?
		next
	end
	lastNumberAttempt = lastNumberInput.to_i
	return nil if lastNumberAttempt == 0
	unchanged = []
    GameData::SpeciesOld.each do |species_data|
		next if species_data.form != 0
		next if species_data.id_number < firstNumberAttempt
		break if species_data.id_number > lastNumberAttempt
		newSpeciesData = GameData::Species.get(species_data.id) || nil
		next if newSpeciesData.nil?
		changeLog = []
		
		# Check for type changes
		oldTypes = [species_data.type1]
		oldTypes.push(species_data.type2) if species_data.type1 != species_data.type2
		
		newTypes = [newSpeciesData.type1]
		newTypes.push(newSpeciesData.type2) if newSpeciesData.type1 != newSpeciesData.type2
		
		oldTypes.each do |oldType|
			changeLog.push("Removed type #{oldType}") if !newTypes.include?(oldType)
		end
		
		newTypes.each do |newType|
			changeLog.push("Added type #{newType}") if !oldTypes.include?(newType)
		end
		
		# Check for stat changes
		stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
		oldBST = 0
		newBST = 0
		stats.each do |s|
				oldStat = species_data.base_stats[s]
				oldBST += oldStat
				newStat = newSpeciesData.base_stats[s]
				newBST += newStat
				if oldStat != newStat
					difference = (newStat - oldStat)
					difference = "+" + difference.to_s if difference > 0
					changeLog.push("#{s}: #{oldStat} => #{newStat} (#{difference})")
				end
		end
		bstDiff = (newBST - oldBST)
		bstDiff = "+" + bstDiff.to_s if bstDiff > 0
		changeLog.push("BST: #{oldBST} => #{newBST} (#{bstDiff})") if oldBST != newBST
		
		# Check for ability changes
		abilityRenames = {
			:ADAPTABILITY => :ADAPTED,
			:QUEENLYMAJESTY => :ROYALMAJESTY
		}
		if species_data.abilities[0] != newSpeciesData.abilities[0]
			renamed = abilityRenames[species_data.abilities[0]] || nil
			if renamed != newSpeciesData.abilities[0]
				if species_data.abilities[0].nil?
					changeLog.push("Ability 1: Added #{newSpeciesData.abilities[0]}")
				else
					changeLog.push("Ability 1: #{species_data.abilities[0]} => #{newSpeciesData.abilities[0]}")
				end
			end
		end
		if species_data.abilities[1] != newSpeciesData.abilities[1]
			renamed = abilityRenames[species_data.abilities[1]] || nil
			if renamed != newSpeciesData.abilities[1]
				if species_data.abilities[1].nil?
					changeLog.push("Ability 2: Added #{newSpeciesData.abilities[1]}")
				else
					changeLog.push("Ability 2: #{species_data.abilities[1]} => #{newSpeciesData.abilities[1]}")
				end
			end
		end
		
=begin
		# Check for move list changes
		if species_data.moves != newSpeciesData.moves
			changeLog.push("Learnset changed.")
		end
		if species_data.tutor_moves != newSpeciesData.tutor_moves
			changeLog.push("Tutor learnset changed.")
		end
		if species_data.egg_moves != newSpeciesData.egg_moves
			changeLog.push("Egg moveset changed.")
		end
=end
		
		#Check for which specific moves have been changed
		moveRenames = {
			:CHARM => :POUT,
			:ROCKSMASH => :SMASH,
			:SMARTSTRIKE => :SMARTHORN,
			:SWEETKISS => :ANGELSKISS,
		}
		moveRenamesInverted = moveRenames.invert
		allCutMoves = [:TOXIC,:DOUBLETEAM]
		
		oldMovesLearned = []
		species_data.moves.each do |learnsetEntry|
			oldMovesLearned.push(learnsetEntry[1])
		end
		species_data.tutor_moves.each do |move|
			oldMovesLearned.push(move)
		end
		species_data.egg_moves.each do |move|
			oldMovesLearned.push(move)
		end
		oldMovesLearned.uniq!
		oldMovesLearned.compact!
		
		newMovesLearned = []
		newSpeciesData.moves.each do |learnsetEntry|
			newMovesLearned.push(learnsetEntry[1])
		end
		newSpeciesData.tutor_moves.each do |move|
			newMovesLearned.push(move)
		end
		newSpeciesData.egg_moves.each do |move|
			newMovesLearned.push(move)
		end
		newMovesLearned.uniq!
		newMovesLearned.compact!
		
		cutMoves = []
		
		oldMovesLearned.each do |oldMove|
			moveRename = moveRenames[oldMove] || oldMove
			if !newMovesLearned.include?(moveRename) && !allCutMoves.include?(moveRename)
				cutMoves.push(oldMove)
			end
		end
		
		if cutMoves.length > 0
			str = "Removed Moves: "
			cutMoves.each_with_index do |move,index|
				str += move.to_s
				str += ", " if index != cutMoves.length - 1
			end
			changeLog.push(str)
		end
		
		newMoves = []
		
		newMovesLearned.each do |newMove|
			moveRename = moveRenamesInverted[newMove] || newMove
			newMoves.push(newMove) if !oldMovesLearned.include?(moveRename)
		end
		
		if newMoves.length > 0
			str = "Added Moves: "
			newMoves.each_with_index do |move,index|
				str += move.to_s
				str += ", " if index != newMoves.length - 1
			end
			changeLog.push(str)
		end
		
		# Check for evolution changes
		species_data.evolutions.each do |evolutionData|
			next if evolutionData[3]
			method = evolutionData[1]
			parameter = evolutionData[2]
			species = evolutionData[0]
			
			speciesStillThere = false
			newSpeciesData.evolutions.each do |newEvolutionData|
				next if newEvolutionData[3]
				newSpecies = newEvolutionData[0]
				newMethod = newEvolutionData[1]
				newParameter = newEvolutionData[2]
				if species == newSpecies
					speciesStillThere = true
					if method == newMethod
						if parameter != newParameter
							changeLog.push("Evolution to #{species} parameter: #{parameter} => #{newParameter}") 
						end
					else
						descriptor = method.to_s
						descriptor += "(" + parameter.to_s + ")" if !parameter.nil?
						newDescriptor = newMethod.to_s
						newDescriptor += "(" + newParameter.to_s + ")" if !newParameter.nil?
						changeLog.push("Evolution to #{species} method: #{descriptor} => #{newDescriptor}") 
					end
					break
				end
			end
			changeLog.push("Evolution to #{species} cut.") if !speciesStillThere
		end
		
		newSpeciesData.evolutions.each do |newEvolutionData|
			newSpecies = newEvolutionData[0]
			newMethod = newEvolutionData[1]
			newParameter = newEvolutionData[2]
			didEvoExistBefore = false
			species_data.evolutions.each do |evolutionData|
				didEvoExistBefore = true if newSpecies == evolutionData[0]
			end
			if !didEvoExistBefore
				changeLog.push("Evolution added: #{newSpecies},#{newMethod},#{newParameter}")
			end
		end
		
		# Print out the changelog
		if changeLog.length == 0
			unchanged.push(species_data.id)
		else
			echoln("#{species_data.real_name} changelog:")
			changeLog.each do |change|
				echoln(change)
			end
			echoln("")
		end
	end
	echoln("Species that were unchanged: #{unchanged.to_s}")
  }
})

DebugMenuCommands.register("analyzeitemdistribution", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Analyze item distribution"),
  "description" => _INTL("Find the locations of all item distributions."),
  "effect"      => proc { |sprites, viewport|
	mapData = Compiler::MapData.new
	allItemsGiven = []
    for id in mapData.mapinfos.keys.sort
		map = mapData.getMap(id)
		next if !map || !mapData.mapinfos[id]
		mapName = mapData.mapinfos[id].name
		for key in map.events.keys
			itemsGiven = analyze_items(id,mapName,map.events[key])
			allItemsGiven.concat(itemsGiven)
		end
	end

	echoln("All the items which have not a single distribution")
	GameData::Item.each do |itemData|
		echoln(itemData.id) if !allItemsGiven.include?(itemData.id)
	end
  }}
)

def analyze_items(map_id,map_name,event)
	return [] if !event || event.pages.length==0
	itemsGiven = []
	event.pages.each do |page|
		page.list.each do |eventCommand|
			eventCommand.parameters.each do |parameter|
				next unless parameter.is_a?(String)
				match = parameter.match(/(?:(?:pbReceiveItem)|(?:defeatBoss)|(?:pbPickBerry)|(?:pbItemBall))\((:[A-Z0-9]+)(?:,([0-9]+))?(?:,?.+)?\)/)
				if match
					itemName = match[1][1..-1]
					eventName = event.name.gsub(",","")
					itemCount = match[2] ? match[2] : 1
					string = "#{map_id},#{map_name},#{event.id},#{eventName},#{itemName},#{itemCount}"
					
					itemsGiven.push(itemName.to_sym)
					
					echoln(string)
				end
			end
		end
	end
	return itemsGiven
end

 
DebugMenuCommands.register("countsmashables", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Count smashable rocks"),
  "description" => _INTL("Find the locations of all dynamiteable rocks."),
  "effect"      => proc { |sprites, viewport|
	mapData = Compiler::MapData.new
	echoln("Listing all smashable rocks")
    for id in mapData.mapinfos.keys.sort
		map = mapData.getMap(id)
		next if !map || !mapData.mapinfos[id]
		mapName = mapData.mapinfos[id].name
		for key in map.events.keys
			event = map.events[key]
			next if !event || event.pages.length==0
			event.pages.each do |page|
				page.list.each do |eventCommand|
					eventCommand.parameters.each do |parameter|
						next unless parameter.is_a?(String)
						match = parameter.match(/pbRockSmashDynamite/)
						if match
							eventName = event.name.gsub(",","")
							string = "#{id},#{mapName},#{event.id},#{eventName}"
							echoln(string)
						end
					end
				end
			end
		end
	end

  }}
)

DebugMenuCommands.register("analyzetrainers", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Analyze Trainers"),
  "description" => _INTL("Find out which Pokemon arent yet used, or used multiple times."),
  "effect"      => proc { |sprites, viewport|
	echoln("Analyzing trainers")
	
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
	pokemonUsedMoreThanOnce = []
	pokemonUsedWhichShouldntBe = []
	speciesUsed.each do |species,arrayOfTrainerData|
		if isLegendary?(species) || isQuarantined?(species)
			if arrayOfTrainerData.length >= 1
				pokemonUsedWhichShouldntBe.push([species,arrayOfTrainerData])
			end
		else
			if arrayOfTrainerData.length == 0
				unusedPokemon.push(species)
			elsif arrayOfTrainerData.length >= 2
				pokemonUsedMoreThanOnce.push([species,arrayOfTrainerData])
			end
		end
	end
	
	echoln("All the species which have been used whom should not be (#{pokemonUsedWhichShouldntBe.length}): ")
	pokemonUsedWhichShouldntBe.each do |entry|
		echoln(entry[0].to_s)
	end
	
	echoln("All the species which have been used more than once (#{pokemonUsedMoreThanOnce.length}): ")
	pokemonUsedMoreThanOnce.each do |entry|
		echoln(entry[0].to_s)
	end
	
	echoln("All the species which have not been used and should be (#{unusedPokemon.length}): ")
	unusedPokemon.each do |species|
		species_data = GameData::Species.get(species)
		echoln("#{species.to_s},#{species_data.type1},#{species_data.type2}")
	end
  }}
)