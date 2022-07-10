DebugMenuCommands.register("seteventswitch", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Set Event Switch"),
  "description" => _INTL("Set a switch of an event on a map"),
  "effect"      => proc {
    chosenMap = pbListScreen("Choose Map",MapLister.new($game_map.map_id))
    if chosenMap >= 0
      chosenEvent = pbListScreen("Choose Event on #{pbGetMapNameFromId(chosenMap)}",EventLister.new(chosenMap))
      if chosenEvent >= 0
        while true
          currentA = $game_self_switches[[chosenMap, chosenEvent, 'A']]
          currentB = $game_self_switches[[chosenMap, chosenEvent, 'B']]
          currentC = $game_self_switches[[chosenMap, chosenEvent, 'C']]
          currentD = $game_self_switches[[chosenMap, chosenEvent, 'D']]

          cmdA = -1
          cmdB = -1
          cmdC = -1
          cmdD = -1
          switchCommands = [_INTL("Done")]
          switchCommands[cmdA = switchCommands.length] = _INTL("Switch A (#{currentA})")
          switchCommands[cmdB = switchCommands.length] = _INTL("Switch B (#{currentB})")
          switchCommands[cmdC = switchCommands.length] = _INTL("Switch C (#{currentC})")
          switchCommands[cmdD = switchCommands.length] = _INTL("Switch D (#{currentD})")
          pbMessage(_INTL("Which switch would you like to swap?"))
          tileCommand = pbShowCommands(nil, switchCommands, -1)
          break if tileCommand == 0
          switchName = ['A','B','C','D'][tileCommand-1]
          $game_self_switches[[chosenMap, chosenEvent, switchName]] = !$game_self_switches[[chosenMap, chosenEvent, switchName]]
          pbRefreshSceneMap
        end
      end
    end
  }
})

class EventLister
  def initialize(mapID)
    @commands = []
    mapData = Compiler::MapData.new
    @map = mapData.getMap(mapID)
    @events = []
    for key in @map.events.keys
      event = @map.events[key]
      next if !event || event.pages.length==0
      @events.push(event)
    end
    @index = 0
  end

  def startIndex
    return @index
  end

  def setViewport(viewport); end

  def commands
    @commands.clear
    for i in 0...@events.length
      event = @events[i]
      @commands.push("#{event.name} (#{event.id})")
    end
    return @commands
  end

  def value(index)
    return (index<0) ? -1 : @events[index].id
  end

  def refresh(index); end

  def dispose; end
end