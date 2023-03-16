DebugMenuCommands.register("listnewmoves", {
  "parent"      => "analysis",
  "name"        => _INTL("List new moves"),
  "description" => _INTL("List all new moves added to the game."),
  "effect"      => proc { |sprites, viewport|
	
	moveDataSorted = []
	GameData::Move.each do |moveData|
		next unless moveData.tectonic_new
		moveDataSorted.push(moveData)
	end

	moveDataSorted.sort_by! { |data|
		GameData::Type.get(data.type).id_number * 10_000 + data.category * 1000 + data.base_damage
	}

	File.open("new_moves.txt","wb") { |file|
		moveDataSorted.each do |moveData|
			moveLine = describeMove(moveData.id)
			moveLine += "\r\n"
			file.write(moveLine)
		end
	}
	pbMessage(_INTL("New moves information written to new_moves.txt"))
  }
})