GENERATION_END_IDS = [0,151,251,386,493,649,721,809,898]

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

def pbFindEncounter(enc_types, species)
    return false if !enc_types
    enc_types.each_value do |slots|
      next if !slots
      slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
    end
    return false
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

        def generationNumber()
            GENERATION_END_IDS.each_with_index do |generationEndID,index|
                if @id_number <= generationEndID
                    return index
                end
            end
            return -1
        end
	end
end
