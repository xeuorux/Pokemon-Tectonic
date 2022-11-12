class Spriteset_Map
    def initialize(map=nil)
        @usersprites = []
        @map = (map) ? map : $game_map

        $scene.map_renderer.add_tileset(@map.tileset_name)
        @map.autotile_names.each { |filename| $scene.map_renderer.add_autotile(filename) }
        $scene.map_renderer.add_extra_autotiles(@map.tileset_id)

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

    def update
        @@viewport3.tone = Tone.new(0, 0, 0, 0)
        pbDayNightTint($scene.map_renderer)
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
end