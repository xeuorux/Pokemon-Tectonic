class Scene_Map
    attr_reader :map_renderer

    def createSpritesets
        @map_renderer = TilemapRenderer.new(Spriteset_Map.viewport) if !@map_renderer || @map_renderer.disposed?
        @spritesetGlobal = Spriteset_Global.new if !@spritesetGlobal
        @spritesets = {}	
        for map in $MapFactory.maps	
          @spritesets[map.map_id] = Spriteset_Map.new(map)	
        end	
        $MapFactory.setSceneStarted(self)	
        updateSpritesets(true)	
    end

    def updateSpritesets(refresh = false)
        @spritesets = {} if !@spritesets
        $MapFactory.maps.each do |map|
            @spritesets[map.map_id] = Spriteset_Map.new(map) if !@spritesets[map.map_id]
        end
        keys = @spritesets.keys.clone
        for i in keys
          if !$MapFactory.hasMap?(i)
            @spritesets[i].dispose if @spritesets[i]
            @spritesets[i] = nil
            @spritesets.delete(i)
          else
            @spritesets[i].update
          end
        end
        @spritesetGlobal.update
        for map in $MapFactory.maps
          @spritesets[map.map_id] = Spriteset_Map.new(map) if !@spritesets[map.map_id]
        end
        @map_renderer.refresh if refresh
        @map_renderer.update
        Events.onMapUpdate.trigger(self)
      end
end