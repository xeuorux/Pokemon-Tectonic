DebugMenuCommands.register("analyzeitemdistribution", {
  "parent"      => "analysis",
  "name"        => _INTL("Analyze item distribution"),
  "description" => _INTL("Find the locations of all item distributions."),
  "effect"      => proc { |sprites, viewport|
	mapData = Compiler::MapData.new
	allItemsGiven = []
	File.open("item_distribution.txt","wb") { |file|
		for id in mapData.mapinfos.keys.sort
			map = mapData.getMap(id)
			next if !map || !mapData.mapinfos[id]
			mapName = mapData.mapinfos[id].name
			for key in map.events.keys
				itemsGiven = analyze_items(id,mapName,map.events[key],file)
				allItemsGiven.concat(itemsGiven)
			end
		end

		file.write("All the items which have not a single distribution:")
		writeIndex = 0
		GameData::Item.each do |itemData|
			next if allItemsGiven.include?(itemData.id)
			str = itemData.id.to_s + (writeIndex % 6 == 0 ? "\r\n" : ", ")
			writeIndex += 1
			file.write(str) 
		end
	}

	pbMessage(_INTL("Item distribution analysis written to item_distribution.txt"))
  }}
)

def analyze_items(map_id,map_name,event,file)
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
					string = "#{map_id},#{map_name},#{event.id},#{eventName},#{itemName},#{itemCount}\r\n"
					
					itemsGiven.push(itemName.to_sym)
					
					file.write(string)
				end
			end
		end
	end
	return itemsGiven
end
