DebugMenuCommands.register("listcutmoves", {
  "parent"      => "analysis",
  "name"        => _INTL("List cut moves"),
  "description" => _INTL("List all moves cut from canon."),
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
			moveLine = moveData.real_name
			moveLine += "\r\n"
			file.write(moveLine)
		end
	}
	pbMessage(_INTL("Cut moves information written to cut_moves.txt"))
  }
})