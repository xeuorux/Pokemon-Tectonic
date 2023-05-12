DebugMenuCommands.register("counttribes", {
  "parent"      => "analysis",
  "name"        => _INTL("Count tribes"),
  "description" => _INTL("Count how many pokemon are in each tribe."),
  "effect"      => proc { |sprites, viewport|
	tribeCount = {}
	GameData::Tribe.each do |tribe|
		tribeCount[tribe.id] = 0
	end

	GameData::Species.each do |species|
		next if species.form != 0
		next if species.get_evolutions().length > 0
		species.tribes.each do |tribe|
			tribeCount[tribe] += 1
		end
	end

	echoln("Tribes count")
	tribeCount.each do |tribe, count|
		echoln("#{tribe},#{count}")
	end

	pbMessage(_INTL("Output the tribes count to the console."))
  }
})