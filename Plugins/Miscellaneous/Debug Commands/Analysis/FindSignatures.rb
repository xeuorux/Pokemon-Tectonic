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
	abilities = abilities.sort_by {|ability,weilder| GameData::Species.get(weilder).id_number}
	File.open("signature_abilities.txt","wb") { |file|
		abilities.each do |ability,weilder|
			abilityLine = describeAbility(ability)
			abilityLine += "\r\n"
			file.write(abilityLine)
		end
	}

	pbMessage(_INTL("Printed out signature abilities to signature_abilities.txt"))
  }
})

def describeAbility(abilityID)
	abilityData = GameData::Ability.get(abilityID)
	abilityLine = "#{abilityData.real_name},\"#{abilityData.description}\""
	if abilityData.is_signature?
		weilderName = GameData::Species.get(abilityData.signature_of).real_name 
		abilityLine += "," + weilderName
	end

	return abilityLine
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
  	moves = getSignatureMoves()
	moves = moves.sort_by {|move,weilder| GameData::Species.get(weilder).id_number}
	File.open("signature_moves.txt","wb") { |file|
		moves.each do |move,weilder|
			moveLine = describeMove(move)
			moveLine += "\r\n"
			file.write(moveLine)
		end
	}

	pbMessage(_INTL("Printed out signature moves to signature_moves.txt."))
  }
})

def describeMove(move)
	categoryDescriptions = ["Physical","Special","Status"]

	moveData = GameData::Move.get(move)
	typeName = GameData::Type.get(moveData.type).real_name
	categoryDescriptor = categoryDescriptions[moveData.category]
	accuracyLabel = moveData.accuracy == 0 ? "-" : moveData.accuracy.to_s
	priorityLabel = moveData.priority == 0 ? "-" : moveData.priority.to_s
	if moveData.priority < 0
		priorityLabel = "-" + priorityLabel
	elsif moveData.priority > 0
		priorityLabel = "+" + priorityLabel
	end
	tag = ""
	moveData.flags.split('').each do |flag|
		case flag
		when 'i'
			tag = "Bite"
		when 'j'
			tag = "Punch"
		when 'k'
			tag = "Sound"
		when 'l'
			tag = "Powder"
		when 'm'
			tag = "Pulse"
		when 'o'
			tag = "Dance"
		when 'p'
			tag = "Blade"
		when 'q'
			tag = "Wind"
		end
	end
	weilderName = ""
	if moveData.is_signature?
		weilderName = GameData::Species.get(moveData.signature_of).real_name
	end
	procChanceLabel = (moveData.effect_chance == 0 || moveData.effect_chance == 100) ? "-" : moveData.effect_chance.to_s
	moveLine = "#{moveData.real_name},#{weilderName},#{typeName},\"#{moveData.description}\",#{moveData.base_damage},#{categoryDescriptor},"
	moveLine += "#{accuracyLabel},#{moveData.total_pp},#{moveData.target},#{priorityLabel},#{procChanceLabel},#{tag}"
	return moveLine
end