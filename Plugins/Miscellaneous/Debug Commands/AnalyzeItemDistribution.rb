DebugMenuCommands.register("analyzeitemdistribution", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Analyze item distribution"),
  "description" => _INTL("Find the locations of all item distributions."),
  "effect"      => proc { |sprites, viewport|
	mapData = Compiler::MapData.new
	allItemsGiven = []
    for id in mapData.mapinfos.keys.sort
		map = mapData.getMap(id)
		next if !map || !mapData.mapinfos[id]
		mapName = mapData.mapinfos[id].name
		for key in map.events.keys
			itemsGiven = analyze_items(id,mapName,map.events[key])
			allItemsGiven.concat(itemsGiven)
		end
	end

	echoln("All the items which have not a single distribution")
	GameData::Item.each do |itemData|
		echoln(itemData.id) if !allItemsGiven.include?(itemData.id)
	end
  }}
)

def analyze_items(map_id,map_name,event)
	return [] if !event || event.pages.length==0
	itemsGiven = []
	event.pages.each do |page|
		page.list.each do |eventCommand|
			eventCommand.parameters.each do |parameter|
				next unless parameter.is_a?(String)
				match = parameter.match(/(?:(?:pbReceiveItem)|(?:defeatBoss)|(?:pbPickBerry)|(?:pbItemBall))\((:[A-Z0-9]+)(?:,([0-9]+))?(?:,?.+)?\)/)
				if match
					itemName = match[1][1..-1]
					eventName = event.name.gsub(",","")
					itemCount = match[2] ? match[2] : 1
					string = "#{map_id},#{map_name},#{event.id},#{eventName},#{itemName},#{itemCount}"
					
					itemsGiven.push(itemName.to_sym)
					
					echoln(string)
				end
			end
		end
	end
	return itemsGiven
end
