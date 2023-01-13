DebugMenuCommands.register("findtextinevents", {
  "parent"      => "analysis",
  "name"        => _INTL("Find Text In Events"),
  "description" => _INTL("Find events which have a peice of text in the params of their command list."),
  "effect"      => proc { |sprites, viewport|
	textEntered = pbEnterText("Enter text...", 0, 32)

	mapData = Compiler::MapData.new
	for id in mapData.mapinfos.keys.sort
		map = mapData.getMap(id)
		next if !map || !mapData.mapinfos[id]
		mapName = mapData.mapinfos[id].name
		for key in map.events.keys
			find_text_in_event(id,mapName,map.events[key],textEntered)
		end
	end
  }}
)

def find_text_in_event(map_id,map_name,event,text_entered)
	return [] if !event || event.pages.length==0
	event.pages.each do |page|
		page.list.each do |eventCommand|
			eventCommand.parameters.each do |parameter|
				next unless parameter.is_a?(String)
				match = parameter.downcase.match(/#{text_entered.downcase}/)
				if match
					eventName = event.name.gsub(",","")
					echoln "Event \"#{eventName}\" (#{event.id}) on map #{map_name} (#{map_id})"
					echoln "\"#{parameter}\"\r\n"
				end
			end
		end
	end
end
