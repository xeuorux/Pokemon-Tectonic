DebugMenuCommands.register("listnewabilities", {
  "parent"      => "analysis",
  "name"        => _INTL("List new abilities"),
  "description" => _INTL("List all new abilities added to the game."),
  "effect"      => proc { |sprites, viewport|
	
	abilityDataSorted = []
	GameData::Ability.each do |abilityData|
		next unless abilityData.id_number >= 269
		break if abilityData.id_number >= 1000
		abilityDataSorted.push(abilityData)
	end

	abilityDataSorted.sort_by! { |data|
		data.real_name
	}

	File.open("new_abilities.txt","wb") { |file|
		abilityDataSorted.each do |abilityData|
			abilityLine = describeAbility(abilityData.id)
			abilityLine += "\r\n"
			file.write(abilityLine)
		end
	}
	pbMessage(_INTL("New ability information written to new_abilities.txt"))
  }
})