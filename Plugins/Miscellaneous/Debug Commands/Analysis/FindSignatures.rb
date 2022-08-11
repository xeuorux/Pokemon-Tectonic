DebugMenuCommands.register("countabilityuse", {
  "parent"      => "analysis",
  "name"        => _INTL("Count ability use"),
  "description" => _INTL("Count the number of uses of each ability by fully evolved base forms."),
  "effect"      => proc { |sprites, viewport|
  	echoln("AbilityName,Non-legend Count,Legend Count")
  	abilityCounts = getAbilityCounts()
  	abilityCounts.each do |ability,count|
		echoln("#{ability},#{count[0]},#{count[1]}")
	end

	pbMessage(_INTL("Printed out ability counts to the console."))
  }
})

DebugMenuCommands.register("getsignatureabilities", {
  "parent"      => "analysis",
  "name"        => _INTL("List signature abilities"),
  "description" => _INTL("List each ability that is only used by one fully evolved base form."),
  "effect"      => proc { |sprites, viewport|
  	echoln("Ability Name, Weilder")
  	abilities = getSignatureAbilities()
	abilities.each do |ability,weilder|
		echoln("#{ability},#{weilder}")
	end

	pbMessage(_INTL("Printed out signature abilities to the console."))
  }
})


def getSignatureAbilities()
	abilityCounts = getAbilityCounts()
	abilityCounts.delete_if{|ability,groups| (groups[0].length + groups[1].length) != 1}

	return abilityCounts.map{|ability,groups| [ability,groups[0].concat(groups[1])[0]]}.to_h
end

def getAbilityCounts()
	ability_counts = {}
	GameData::Ability.each do |ability_data|
		ability_counts[ability_data.id] = [[],[]]
	end
	
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form that isn't a regional form
		next if species_data.form != 0
		# ... or if its not fully evolved
		next if species_data.get_evolutions().length > 0
		arrayID = isLegendary?(species_data.id) ? 1 : 0
		species_data.abilities.each do |ability_id|
			ability_counts[ability_id][arrayID].push(species_data.id)
		end
	end

	GameData::Ability.each do |ability_data|
		ability_counts[ability_data.id][0].uniq!
		ability_counts[ability_data.id][1].uniq!
		ability_counts[ability_data.id][0].compact!
		ability_counts[ability_data.id][1].compact!
	end
	
	return ability_counts.sort_by { |ability, groups| -groups[0].length }
end

DebugMenuCommands.register("countmoveuse", {
  "parent"      => "analysis",
  "name"        => _INTL("Count move use"),
  "description" => _INTL("Count the number of uses of each move by fully evolved base forms."),
  "effect"      => proc { |sprites, viewport|
  echoln("MoveName,Non-legend Count,Legend Count")
  	moveCounts = getMoveLearnableGroups()
	moveCounts.each do |move,groups|
		echoln("#{move},#{groups[0].length},#{groups[1].length}")
	end

	pbMessage(_INTL("Printed out move counts to the console."))
  }
})

DebugMenuCommands.register("getsignaturemoves", {
  "parent"      => "analysis",
  "name"        => _INTL("List signature moves"),
  "description" => _INTL("List each move that is only used by one fully evolved base form."),
  "effect"      => proc { |sprites, viewport|
  	echoln("Move Name, Weilder")
  	moves = getSignatureMoves()
	moves.each do |move,weilder|
		echoln("#{move},#{weilder}")
	end

	pbMessage(_INTL("Printed out signature moves to the console."))
  }
})

def getSignatureMoves()
	moveCounts = getMoveLearnableGroups()
	moveCounts.delete_if{|move,groups| (groups[0].length + groups[1].length) != 1}

	return moveCounts.map {|move,groups| [move,groups[0].concat(groups[1])[0]] }.to_h
end

def getMoveLearnableGroups()
	move_counts = {}
	GameData::Move.each do |move_data|
		move_counts[move_data.id] = [[],[]]
	end
	
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form that isn't a regional form
		next if species_data.form != 0
		# ... or if its not fully evolved
		next if species_data.get_evolutions().length > 0
		groupIndex = isLegendary?(species_data.id) ? 1 : 0
		species_data.moves.each do |learnset_entry|
			move = learnset_entry[1]
			move_counts[move][groupIndex].push(species_data.id)
		end
		species_data.tutor_moves.each do |tutorMoveID|
			move_counts[tutorMoveID][groupIndex].push(species_data.id)
		end
		species_data.egg_moves.each do |eggMoveID|
			move_counts[eggMoveID][groupIndex].push(species_data.id)
		end
	end

	GameData::Move.each do |move_data|
		move_counts[move_data.id][0].uniq!
		move_counts[move_data.id][0].compact!
		move_counts[move_data.id][1].uniq!
		move_counts[move_data.id][1].compact!
	end
	
	return move_counts.sort_by { |ability, groups| -groups[0].length }
end