class LightEffect_Abyss < LightEffect
    def initialize(event,viewport=nil,map=nil,filename=nil)
        @light = IconSprite.new(0,0,viewport)
        if filename!=nil && filename!="" && pbResolveBitmap("Graphics/Pictures/"+filename)
          @light.setBitmap("Graphics/Pictures/"+filename)
        else
          @light.setBitmap("Graphics/Pictures/LEAbyssal")
        end
        @light.z = 1000
        @event = event
        @map = (map) ? map : $game_map
        @disposed = false
      end

    def update
      return if !@light || !@event
      super
      @light.opacity = 100
      @light.ox      = 32 * 4
      @light.oy      = 32 * 4.5
      if (Object.const_defined?(:ScreenPosHelper) rescue false)
        @light.x      = ScreenPosHelper.pbScreenX(@event)
        @light.y      = ScreenPosHelper.pbScreenY(@event)
        @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
      else
        @light.x      = @event.screen_x
        @light.y      = @event.screen_y
        @light.zoom_x = 1.0
      end
      @light.zoom_y = @light.zoom_x
      @light.tone   = $game_screen.tone
      @light.blend_type = 1
    end
  end

  Events.onSpritesetCreate += proc { |_sender,e|
  spriteset = e[0]      # Spriteset being created
  viewport  = e[1]      # Viewport used for tilemap and characters
  map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
  for i in map.events.keys
    if map.events[i].name[/^outdoorlight\((\w+)\)$/i]
      filename = $~[1].to_s
      spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i],viewport,map,filename))
    elsif map.events[i].name[/^outdoorlight$/i]
      spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i],viewport,map))
    elsif map.events[i].name[/^abysslight$/i]
        spriteset.addUserSprite(LightEffect_Abyss.new(map.events[i],viewport,map))
    elsif map.events[i].name[/^light\((\w+)\)$/i]
      filename = $~[1].to_s
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i],viewport,map,filename))
    elsif map.events[i].name[/^light$/i]
      spriteset.addUserSprite(LightEffect_Basic.new(map.events[i],viewport,map))
    end
  end
  spriteset.addUserSprite(Particle_Engine.new(viewport,map))
}