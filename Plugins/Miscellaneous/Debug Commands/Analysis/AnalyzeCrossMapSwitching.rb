DebugMenuCommands.register("analyzecrossmapswitching", {
  "parent"      => "analysis",
  "name"        => _INTL("Analyze Cross-Map Switching"),
  "description" => _INTL("Find the events which affect events on other maps through pbSetSelfSwitch"),
  "effect"      => proc { |sprites, viewport|
	writeAllCodeInstances(/pbSetSelfSwitch\(([0-9]+),('[A,B,C,D,a,b,c,d]'),((?:true)|(?:false)),([0-9]+)\)/, "switching_analysis.txt")
  }}
)

def WACI(regex, fileName = "code_instances.txt")
	writeAllCodeInstances(regex, fileName)
end

def writeAllCodeInstances(regex, fileName)
	mapData = Compiler::MapData.new
	File.open(fileName,"wb") { |file|
		for id in mapData.mapinfos.keys.sort
			map = mapData.getMap(id)
			next if !map || !mapData.mapinfos[id]
			mapName = mapData.mapinfos[id].name
			for key in map.events.keys
				describeCodeInstances(id,mapName,map.events[key],file,regex)
			end
		end
	}

	pbMessage(_INTL("Code instance analysis written to #{fileName}"))
end

def describeCodeInstances(map_id,map_name,event,file,regex)
	return [] if !event || event.pages.length==0
	event.pages.each do |page|
		page.list.each do |eventCommand|
			eventCommand.parameters.each do |parameter|
				next unless parameter.is_a?(String)
				match = parameter.match(regex)
				if match
					eventName = event.name.gsub(",","")

					string = "Map #{map_name} (#{map_id}), event #{eventName} (#{event.id})\r\n"
										
					file.write(string)
				end
			end
		end
	end
end
