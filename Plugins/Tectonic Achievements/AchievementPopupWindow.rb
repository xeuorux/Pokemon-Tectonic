class AchievementPopupWindow
    def initialize(name, duration = nil)
      @window = Window_AdvancedTextPokemon.new(name)
      @window.resizeToFit(name,Graphics.width)
      @window.x        = 0
      @window.y        = -@window.height
      @window.viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @window.viewport.z = 99999
      @frames = 0
      @duration = duration || Graphics.frame_rate * 2
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
      if @frames > @duration
        @window.y -= 4
        @window.dispose if @window.y+@window.height<0
      else
        @window.y += 4 if @window.y<0
        @frames += 1
      end
    end
end