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

  class LightEffect_Totem < LightEffect
    def initialize(event,viewport=nil,map=nil)
        @light = IconSprite.new(0,0,viewport)
        @light.setBitmap("Graphics/Pictures/ALE")
        @light.z = 1000
        @event = event
        @map = (map) ? map : $game_map
        @disposed = false
        @opacityCounter = 0
        @opacityWavelength = 8.0
        @summonTotem = false
    end

    def update
      return if !@light || !@event
      super

      if !@summonTotem && pbGetSelfSwitch(@event.id,'A')
        echoln("Setting this totem light to the summon version since the #{@event.name}'s A switch is on")
        @light.setBitmap("Graphics/Pictures/ALE_S")
        @summonTotem = true
        @opacityCounter = 0
        opacifyWavelength = 4.0
      elsif @summonTotem && !pbGetSelfSwitch(@event.id,'A')
        echoln("Setting this totem light to the non-summon version since the #{@event.name}'s A switch is off")
        @light.setBitmap("Graphics/Pictures/ALE")
        @summonTotem = false
        @opacityCounter = 0
        opacifyWavelength = 8.0
      end

      @opacityCounter += 1
      @light.opacity = (80 + 40 * Math.sin(@opacityCounter.to_f / @opacityWavelength)).floor
      @light.ox      = (@light.bitmap.width * 2) / 4
      @light.oy      = (@light.bitmap.height * 3) / 4
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
    end
  end

  Events.onSpritesetCreate += proc { |_sender,e|
  spriteset = e[0]      # Spriteset being created
  viewport  = e[1]      # Viewport used for tilemap and characters
  map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
  for i in map.events.keys
    event = map.events[i]
    if event.name[/^outdoorlight\((\w+)\)$/i]
      filename = $~[1].to_s
      spriteset.addUserSprite(LightEffect_DayNight.new(event,viewport,map,filename))
    elsif event.name[/^outdoorlight$/i]
      spriteset.addUserSprite(LightEffect_DayNight.new(event,viewport,map))
    elsif event.name[/^abysslight$/i]
        spriteset.addUserSprite(LightEffect_Abyss.new(event,viewport,map))
    elsif event.name[/^light\((\w+)\)$/i]
      filename = $~[1].to_s
      spriteset.addUserSprite(LightEffect_Basic.new(event,viewport,map,filename))
    elsif event.name[/AvatarTotem/i]
      spriteset.addUserSprite(LightEffect_Totem.new(event,viewport,map))
    elsif event.name[/^light$/i]
      spriteset.addUserSprite(LightEffect_Basic.new(event,viewport,map))
    end
  end
  spriteset.addUserSprite(Particle_Engine.new(viewport,map))
}