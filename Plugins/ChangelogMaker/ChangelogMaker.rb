DebugMenuCommands.register("changelog", {
  "parent"      => "main",
  "name"        => _INTL("Changelogs..."),
  "description" => _INTL("Generate species changelogs of various types."),
})

DebugMenuCommands.register("generatechangelogrange", {
  "parent"      => "changelog",
  "name"        => _INTL("Generate species changelog between ids"),
  "description" => _INTL("See the changelog for each species between the Old and New pokemon.txt files for a specific range of IDs."),
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
	createChangeLogBetween(firstNumberAttempt,lastNumberAttempt)
  }
})

DebugMenuCommands.register("generatechangelog", {
  "parent"      => "changelog",
  "name"        => _INTL("Generate species changelog"),
  "description" => _INTL("See the changelog for each species between the Old and New pokemon.txt files."),
  "effect"      => proc { |sprites, viewport|
  createChangeLogBetween(1,9999)
  }
})

DebugMenuCommands.register("generatechangelogpergen", {
  "parent"      => "changelog",
  "name"        => _INTL("Generate changelog per generation"),
  "description" => _INTL("Generate a species changelog per generation of Pokemon"),
  "effect"      => proc { |sprites, viewport|
	if !safeIsDirectory?("Changelogs")
		Dir.mkdir("Changelogs") rescue nil
	end
	for index in 1...GENERATION_END_IDS.length
		startID = GENERATION_END_IDS[index-1] + 1
		endID = GENERATION_END_IDS[index]
		echoln("Creating the changelog between the IDs of #{startID} and #{endID}")
		createChangeLogBetween(startID,endID,"Changelogs/changelog_gen#{index.to_s}.txt")
	end
  }
})

def createChangeLogBetween(firstID,lastID,fileName = "changelog.txt")
	unchanged = []
	
	stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
	statNames = {:HP => "HP",:ATTACK => "Attack",:DEFENSE => "Defense",:SPECIAL_ATTACK => "Sp. Atk",:SPECIAL_DEFENSE => "Sp. Def",:SPEED => "Speed"}
	
	File.open(fileName,"wb") { |f|
		GameData::SpeciesOld.each do |species_data|
			next if species_data.form != 0
			next if species_data.id_number < firstID
			break if species_data.id_number > lastID
			
			newSpeciesData = GameData::Species.get(species_data.id) || nil
			next if newSpeciesData.nil?
			changeLog = []
			
			# Check for type changes
			oldTypes = [species_data.type1]
			oldTypes.push(species_data.type2) if species_data.type1 != species_data.type2
			
			newTypes = [newSpeciesData.type1]
			newTypes.push(newSpeciesData.type2) if newSpeciesData.type1 != newSpeciesData.type2
			
			oldTypes.each do |oldType|
				changeLog.push("Removed type #{GameData::Type.get(oldType).real_name}") if !newTypes.include?(oldType)
			end
			
			newTypes.each do |newType|
				changeLog.push("Added type #{GameData::Type.get(newType).real_name}") if !oldTypes.include?(newType)
			end
			
			# Check for stat changes
			
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
						spacesString = ""
						(12-statNames[s].length).times do
							spacesString += " "
						end
						changeLog.push("#{statNames[s]}: #{spacesString}#{oldStat} => #{newStat} (#{difference})")
					end
			end
			bstDiff = (newBST - oldBST)
			bstDiff = "+" + bstDiff.to_s if bstDiff > 0
			changeLog.push("Stat total:   #{oldBST} => #{newBST} (#{bstDiff})") if oldBST != newBST
			
			# Check for ability changes
			[0,1].each do |i|
				if species_data.abilities[i] != newSpeciesData.abilities[i]
					renamed = ABILITY_RENAMES[species_data.abilities[i]] || nil
					if renamed != newSpeciesData.abilities[i]
						if !newSpeciesData.abilities[i].nil?
							newAbilityData = GameData::Ability.get(newSpeciesData.abilities[i])
							newRealName = newAbilityData.real_name
						end
						if species_data.abilities[i].nil?
							changeLog.push("Ability #{i+1}:    Added #{newRealName}")
						else
							oldAbilityData = GameData::Ability.get(species_data.abilities[i])
							oldRealName = oldAbilityData.real_name
							if newSpeciesData.abilities[i].nil?
								changeLog.push("Ability #{i+1}:    #{oldRealName} removed")
							else
								changeLog.push("Ability #{i+1}:    #{oldRealName} => #{newRealName}")
							end
						end
						# Write out the description of the new ability if its custom
						if !newSpeciesData.abilities[i].nil? && newAbilityData.id_number >= NEW_ABILITIES_STARTING_ID
							desc = newAbilityData.description.gsub("%"," percent")
							changeLog.push("\t\"#{desc}\"")
						end
					end
				end
			end
					
			#Check for which specific moves have been changed
			moveRenamesInverted = MOVE_RENAMES.invert
			
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
				moveRename = MOVE_RENAMES[oldMove] || oldMove
				if !newMovesLearned.include?(moveRename) && !CUT_FROM_EVERYONE.include?(moveRename)
					cutMoves.push(oldMove)
				end
			end
			
			if cutMoves.length > 0
				str = "Removed Moves: \r\n\t"
				cutMoves.each_with_index do |move,index|
					str += GameData::Move.get(move).real_name
					str += ", " if index != cutMoves.length - 1
				end
				changeLog.push(str)
			end
			
			newMoves = []
			
			newMovesLearned.each do |newMove|
				moveRename = moveRenamesInverted[newMove] || newMove
				newMoves.push(newMove) if !oldMovesLearned.include?(moveRename) && !ADDED_TO_EVERYONE.include?(moveRename)
			end
			
			if newMoves.length > 0
				str = "Added Moves: \r\n\t"
				newMoves.each_with_index do |move,index|
					str += GameData::Move.get(move).real_name
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
				speciesName = GameData::Species.get(species).real_name
				
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
								changeLog.push("Evolution to #{speciesName} parameter: #{parameter} => #{newParameter}") 
							end
						else
							descriptor = method.to_s
							descriptor += "(" + parameter.to_s + ")" if !parameter.nil?
							newDescriptor = newMethod.to_s
							newDescriptor += "(" + newParameter.to_s + ")" if !newParameter.nil?
							changeLog.push("Evolution to #{speciesName} method: #{descriptor} => #{newDescriptor}") 
						end
						break
					end
				end
				changeLog.push("Evolution to #{speciesName} cut.") if !speciesStillThere
			end
			
			newSpeciesData.evolutions.each do |newEvolutionData|
				newSpecies = newEvolutionData[0]
				newSpeciesName = GameData::Species.get(newSpecies).real_name
				newMethod = newEvolutionData[1]
				newParameter = newEvolutionData[2]
				didEvoExistBefore = false
				species_data.evolutions.each do |evolutionData|
					didEvoExistBefore = true if newSpecies == evolutionData[0]
				end
				if !didEvoExistBefore
					changeLog.push("Evolution added: #{newSpeciesName}: #{newMethod},#{newParameter}")
				end
			end
			
			# Print out the changelog
			if changeLog.length == 0
				unchanged.push(species_data.id)
			else
				f.write("#{species_data.real_name}:\r\n")
				changeLog.each do |change|
					next if change.nil?
					f.write(change + "\r\n")
				end
				f.write("--------------------------------------------\r\n")
			end
		end
		f.write("Species that were unchanged: #{unchanged.to_s}")
	}
	pbMessage(_INTL("Species changelog written to #{fileName}"))
end