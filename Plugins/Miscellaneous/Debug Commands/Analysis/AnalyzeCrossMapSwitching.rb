DebugMenuCommands.register("analyzecrossmapswitching", {
  "parent"      => "analysis",
  "name"        => _INTL("Analyze Cross-Map Switching"),
  "description" => _INTL("Find the events which affect events on other maps through pbSetSelfSwitch"),
  "effect"      => proc { |sprites, viewport|
	mapData = Compiler::MapData.new
	allItemsGiven = []
	File.open("switching_analysis.txt","wb") { |file|
		file.write("Caller Event Map ID, Caller Event Map Name, Caller Event ID, Caller Event Name," +
		   "Modified Event Map ID, Modified Event Map Name, Modified Event ID, Switch Set, Switch Value\r\n")
		for id in mapData.mapinfos.keys.sort
			map = mapData.getMap(id)
			next if !map || !mapData.mapinfos[id]
			mapName = mapData.mapinfos[id].name
			for key in map.events.keys
				analyze_switching(id,mapName,map.events[key],file)
			end
		end
	}

	pbMessage(_INTL("Cross-Map Switching Analysis written to switching_analysis.txt"))
  }}
)

def analyze_switching(map_id,map_name,event,file)
	return [] if !event || event.pages.length==0
	event.pages.each do |page|
		page.list.each do |eventCommand|
			eventCommand.parameters.each do |parameter|
				next unless parameter.is_a?(String)
				match = parameter.match(/pbSetSelfSwitch\(([0-9]+),('[A,B,C,D,a,b,c,d]'),((?:true)|(?:false)),([0-9]+)\)/)
				if match
					eventName = event.name.gsub(",","")

					otherEventID = match[1]
					switchName = match[2]
					switchValue = match[3]
					otherMapID = match[4]

					otherMapName = pbGetMessage(MessageTypes::MapNames,otherMapID.to_i)

					string = "#{map_id},#{map_name},#{event.id},#{eventName},#{otherMapID},#{otherMapName},#{otherEventID},#{switchName},#{switchValue}\r\n"
										
					file.write(string)
				end
			end
		end
	end
end
