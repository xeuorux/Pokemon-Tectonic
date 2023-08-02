
#===============================================================================
# This class keeps track of erased and moved events so their position
# can remain after a game is saved and loaded.  This class also includes
# variables that should remain valid only for the current map.
#===============================================================================
class PokemonMapMetadata
    attr_reader :erasedEvents
    attr_reader :movedEvents
    attr_accessor :strengthUsed
    attr_accessor :blackFluteUsed
    attr_accessor :whiteFluteUsed
  
    def initialize
      clear
    end
  
    def clear
      @erasedEvents   = {}
      @movedEvents    = {}
      @strengthUsed   = false
      @blackFluteUsed = false
      @whiteFluteUsed = false
    end
  
    def addErasedEvent(eventID)
      key = [$game_map.map_id,eventID]
      @erasedEvents[key] = true
    end
  
    def addMovedEvent(eventID)
      key               = [$game_map.map_id,eventID]
      event             = $game_map.events[eventID] if eventID.is_a?(Integer)
      @movedEvents[key] = [event.x,event.y,event.direction,event.through] if event
    end
  
    def updateMap
      for i in @erasedEvents
        if i[0][0]==$game_map.map_id && i[1]
          event = $game_map.events[i[0][1]]
          event.erase if event
        end
      end
      for i in @movedEvents
        if i[0][0]==$game_map.map_id && i[1]
          next if !$game_map.events[i[0][1]]
          $game_map.events[i[0][1]].moveto(i[1][0],i[1][1])
          case i[1][2]
          when 2 then $game_map.events[i[0][1]].turn_down
          when 4 then $game_map.events[i[0][1]].turn_left
          when 6 then $game_map.events[i[0][1]].turn_right
          when 8 then $game_map.events[i[0][1]].turn_up
          end
        end
        if i[1][3]!=nil
          $game_map.events[i[0][1]].through = i[1][3]
        end
      end
    end
  end