class Spriteset_Map
    attr_reader   :map
    attr_accessor :tilemap
    attr_reader   :weather
    attr_accessor :shadows
    attr_reader   :particle_engine
    
    @@viewport0 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Panorama
    @@viewport0.z = -100
    @@viewport1 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Map, events, player, fog
    @@viewport1.z = 0
    @@viewport3 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Flashing
    @@viewport3.z = 500
  
    def Spriteset_Map.viewport   # For access by Spriteset_Global
      return @@viewport1
    end
  
    def initialize(map=nil)
      @shadows = []
      warn = false
      map = $game_map if !map
      for k in map.events.keys.sort
        ev = map.events[k]
        warn = true if (ev.list != nil && ev.list.length > 0 &&
          ev.list[0].code == 108 &&
          (ev.list[0].parameters == ["s"] || ev.list[0].parameters == ["o"]))
        params = XPML_read(map,"Shadow Source", ev, 4)
        @shadows.push([ev] + params) if params != nil
      end
      if warn == true
        p "Warning : At least one event on this map uses the obsolete way to add shadows"
      end

      @usersprites = []
      @map = (map) ? map : $game_map
  
      if $scene.is_a?(Scene_Map)
        $scene.map_renderer.add_tileset(@map.tileset_name)
        @map.autotile_names.each { |filename| $scene.map_renderer.add_autotile(filename) }
        $scene.map_renderer.add_extra_autotiles(@map.tileset_id)
      end
  
      @panorama = AnimatedPlane.new(@@viewport0)
      @fog = AnimatedPlane.new(@@viewport1)
      @fog.z = 3000
      @character_sprites = []
      for i in @map.events.keys.sort	
        sprite = Sprite_Character.new(@@viewport1,@map.events[i])
        @character_sprites.push(sprite)
      end
      @weather = OverworldWeather.new(@@viewport1)
      pbOnSpritesetCreate(self,@@viewport1)
      update

      for sprite in @character_sprites
        sprite.setShadows(map, @shadows)
      end
      $scene.spritesetGlobal.playersprite.setShadows(map, @shadows)
    end
  
    def dispose	
      if $scene.is_a?(Scene_Map)
          $scene.map_renderer.remove_tileset(@map.tileset_name)
          @map.autotile_names.each { |filename| $scene.map_renderer.remove_autotile(filename) }
          $scene.map_renderer.remove_extra_autotiles(@map.tileset_id)
      end	
      @panorama.dispose	
      @fog.dispose	
      for sprite in @character_sprites	
        sprite.dispose	
      end	
      @weather.dispose	
      @panorama = nil	
      @fog = nil	
      @character_sprites.clear	
      @weather = nil
      for i in 0...@usersprites.length
          @usersprites[i].dispose
      end
      @usersprites.clear
    end
  
    def getAnimations
      return @usersprites
    end
  
    def restoreAnimations(anims)
      @usersprites = anims
    end

    def addUserAnimation(animID,x,y,tinting=false,height=3)
      sprite=AnimationSprite.new(animID,$game_map,x,y,@@viewport1,tinting,height)
      addUserSprite(sprite)
      return sprite
    end
  
    def addUserSprite(sprite)
      for i in 0...@usersprites.length
        if @usersprites[i]==nil || @usersprites[i].disposed?
          @usersprites[i]=sprite
          return
        end
      end
      @usersprites.push(sprite)
    end

    def addParticleEngine(sprite)
      raise _INTL("Sprite set already has a particle engine, cannot add another!") if @particle_engine

      addUserSprite(sprite)
      @particle_engine = sprite
    end
  
    def update
      @@viewport3.tone.set(0,0,0,0)
      pbDayNightTint($scene.map_renderer) if $scene.is_a?(Scene_Map)
      if @panorama_name!=@map.panorama_name || @panorama_hue!=@map.panorama_hue
        @panorama_name = @map.panorama_name
        @panorama_hue  = @map.panorama_hue
        @panorama.setPanorama(nil) if @panorama.bitmap!=nil
        @panorama.setPanorama(@panorama_name,@panorama_hue) if @panorama_name!=""
        Graphics.frame_reset
      end
      if @fog_name!=@map.fog_name || @fog_hue!=@map.fog_hue
        @fog_name = @map.fog_name
        @fog_hue = @map.fog_hue
        @fog.setFog(nil) if @fog.bitmap!=nil
        @fog.setFog(@fog_name,@fog_hue) if @fog_name!=""
        Graphics.frame_reset
      end
      tmox = (@map.display_x/Game_Map::X_SUBPIXELS).round
      tmoy = (@map.display_y/Game_Map::Y_SUBPIXELS).round
      @@viewport1.rect.set(0,0,Graphics.width,Graphics.height)
      @@viewport1.ox = 0
      @@viewport1.oy = 0
      @@viewport1.ox += $game_screen.shake
      @panorama.ox = tmox/2
      @panorama.oy = tmoy/2
      @fog.ox         = tmox+@map.fog_ox
      @fog.oy         = tmoy+@map.fog_oy
      @fog.zoom_x     = @map.fog_zoom/100.0
      @fog.zoom_y     = @map.fog_zoom/100.0
      @fog.opacity    = @map.fog_opacity
      @fog.blend_type = @map.fog_blend_type
      @fog.tone       = @map.fog_tone
      @panorama.update
      @fog.update
  
      for sprite in @character_sprites
        sprite.update
      end
  
      if self.map != $game_map
        $game_screen.resetWeather
        echoln("Resetting weather from the spriteset map")
      end
  
      $game_screen.updateWeather(@weather)
      
      @weather.ox   = tmox
      @weather.oy   = tmoy
      @weather.update
      @@viewport1.tone = $game_screen.tone
      @@viewport3.color = $game_screen.flash_color
      @@viewport1.update
      @@viewport3.update
      for i in 0...@usersprites.length
        @usersprites[i].update if !@usersprites[i].disposed?
      end
    end
    
    def force_update_characters
      @character_sprites.each do |characterSprite|
        next unless characterSprite
        characterSprite.character_update
      end
    end
  end
  