#===============================================================================
# Location signpost
#===============================================================================
class LocationWindow
    def initialize(name)
      @window = Window_AdvancedTextPokemon.new(name)
      @window.resizeToFit(name,Graphics.width)
      @window.x        = 0
      @window.y        = -@window.height
      @window.viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @window.viewport.z = 99999
      @currentmap = $game_map.map_id
      @frames = 0
    end
  
    def disposed?
      @window.disposed?
    end
  
    def dispose
      @window.dispose
    end
  
    def update
      return if @window.disposed?
      @window.update
      if $game_temp.message_window_showing || @currentmap!=$game_map.map_id
        @window.dispose
        return
      end
      if @frames > Graphics.frame_rate * 2
        @window.y -= 4
        @window.dispose if @window.y+@window.height<0
      else
        @window.y += 4 if @window.y<0
        @frames += 1
      end
    end
  end