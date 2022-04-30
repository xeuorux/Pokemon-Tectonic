DebugMenuCommands.register("analyzesmashables", {
  "parent"      => "analysis",
  "name"        => _INTL("Count smashable rocks"),
  "description" => _INTL("Find the locations of all smashable rocks."),
  "effect"      => proc { |sprites, viewport|
	mapData = Compiler::MapData.new
	echoln("Listing all smashable rocks")
    for id in mapData.mapinfos.keys.sort
		map = mapData.getMap(id)
		next if !map || !mapData.mapinfos[id]
		mapName = mapData.mapinfos[id].name
		for key in map.events.keys
			event = map.events[key]
			next if !event || event.pages.length==0
			event.pages.each do |page|
				page.list.each do |eventCommand|
					eventCommand.parameters.each do |parameter|
						next unless parameter.is_a?(String)
						match = parameter.match(/pbRockSmash/)
						if match
							eventName = event.name.gsub(",","")
							string = "#{id},#{mapName},#{event.id},#{eventName}"
							echoln(string)
						end
					end
				end
			end
		end
	end

  }}
)