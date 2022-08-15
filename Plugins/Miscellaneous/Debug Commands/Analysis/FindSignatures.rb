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