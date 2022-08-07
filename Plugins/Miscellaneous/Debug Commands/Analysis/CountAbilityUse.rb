DebugMenuCommands.register("countabilityuse", {
  "parent"      => "analysis",
  "name"        => _INTL("Count ability use"),
  "description" => _INTL("Count the number of uses of each ability by fully evolved base forms."),
  "effect"      => proc { |sprites, viewport|
	ability_counts = {}
	GameData::Ability.each do |ability_data|
		ability_counts[ability_data.id] = [0,0]
	end
	
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form that isn't a regional form
		next if species_data.form != 0
		# ... or if its not fully evolved
		next if species_data.get_evolutions().length > 0
		# ... or if its legendary
		if isLegendary?(species_data.id)
			species_data.abilities.each do |ability_id|
				ability_counts[ability_id][1] += 1
			end
		else
			species_data.abilities.each do |ability_id|
				ability_counts[ability_id][0] += 1
			end
		end
	end
	
	# Find the outliers
	sorted_info = ability_counts.sort_by { |ability, count| -count[0] }
	sorted_info.each do |ability,count|
		echoln("#{ability},#{count[0]},#{count[1]}")
	end

	pbMessage(_INTL("Printed out ability counts to the console."))
  }
})