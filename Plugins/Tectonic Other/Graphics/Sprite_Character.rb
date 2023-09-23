class Sprite_Character < RPG::Sprite
    attr_accessor :steps
    attr_accessor :character

    def initialize(viewport, character = nil, is_follower = false)
      @viewport = viewport
      @is_follower = is_follower
      @ombrelist = []
      @character = character
      super(viewport)
      @oldbushdepth = 0
      @spriteoffset = false
      if !character || character == $game_player || (character.name[/reflection/i] rescue false)
        @reflection = Sprite_Reflection.new(self, character, viewport)
      end
      @surfbase = Sprite_SurfBase.new(self, character, viewport) if character == $game_player
      update
      @steps = []
    end

    def groundY
      return @character.screen_y_ground
    end
  
    def visible=(value)
      super(value)
      @reflection.visible = value if @reflection
    end
  
    def dispose
      @bushbitmap.dispose if @bushbitmap
      @bushbitmap = nil
      @charbitmap.dispose if @charbitmap
      @charbitmap = nil
      @reflection.dispose if @reflection
      @reflection = nil
      @surfbase.dispose if @surfbase
      @surfbase = nil
      super
    end

    def update
      follow_update
      @old_x ||= @character.x
      @old_y ||= @character.y
      if (@character.x != @old_x || @character.y != @old_y) && !["", "nil"].include?(@character.character_name)
        if @character == $game_player && $PokemonTemp.dependentEvents &&
          $PokemonTemp.dependentEvents.respond_to?(:realEvents) &&
          $PokemonTemp.dependentEvents.realEvents.select { |e| !["", "nil"].include?(e.character_name) }.size > 0 &&
          !DUPLICATE_FOOTSTEPS_WITH_FOLLOWER
          if !EVENTNAME_MAY_NOT_INCLUDE.include?($PokemonTemp.dependentEvents.realEvents[0].name) &&
            !FILENAME_MAY_NOT_INCLUDE.include?($PokemonTemp.dependentEvents.realEvents[0].character_name)
            make_steps = false
          else
            make_steps = true
          end
        elsif @character.respond_to?(:name) && !(EVENTNAME_MAY_NOT_INCLUDE.include?(@character.name) && FILENAME_MAY_NOT_INCLUDE.include?(@character.character_name))
          tilesetid = @character.map.instance_eval { @map.tileset_id }
          make_steps = [2,1,0].any? do |e|
            tile_id = @character.map.data[@old_x, @old_y, e]
            next false if tile_id.nil?
            next $data_tilesets[tilesetid].terrain_tags[tile_id] == PBTerrain::Sand
          end
        end
        if make_steps
          fstep = Sprite.new(self.viewport)
          fstep.z = 0
          dirs = [nil,"DownLeft","Down","DownRight","Left","Still","Right","UpLeft",
              "Up", "UpRight"]
          if @character == $game_player && $PokemonGlobal.bicycle
            fstep.bmp("Graphics/Characters/Footprints/steps#{dirs[@character.direction]}Bike")
          else
            fstep.bmp("Graphics/Characters/Footprints/steps#{dirs[@character.direction]}")
          end
          @steps ||= []
          if @character == $game_player && $PokemonGlobal.bicycle
            x = BIKE_X_OFFSET
            y = BIKE_Y_OFFSET
          else
            x = WALK_X_OFFSET
            y = WALK_Y_OFFSET
          end
          @steps << [fstep, @character.map, @old_x + x / Game_Map::TILE_WIDTH.to_f, @old_y + y / Game_Map::TILE_HEIGHT.to_f]
        end
      end
      @old_x = @character.x
      @old_y = @character.y
      update_footsteps

      # Update shadows
      if @ombrelist.length>0
        for i in 0...@ombrelist.size
          @ombrelist[i].update
        end
      end
    end

    def setReflection(event, viewport)
      @reflection = Sprite_Reflection.new(self,event,viewport) if !@reflection
    end

    def setShadows(map,shadows)
      if character.is_a?(Game_Event) && shadows.length > 0
        params = XPML_read(map,"Shadow",@character,4)
        if params != nil
          for i in 0...shadows.size
            @ombrelist.push(Sprite_Shadow.new(viewport, @character, shadows[i]))
          end
        end
      end
      if character.is_a?(Game_Player) && shadows.length > 0
        for i in 0...shadows.size
          @ombrelist.push(Sprite_Shadow.new(viewport, $game_player, shadows[i]))
        end
      end
      update
    end
  
    def clearShadows
      @ombrelist.each { |s| s.dispose if s }
      @ombrelist.clear
    end

    def update
      return if @character.is_a?(Game_Event) && !@character.should_update?
      super
      character_update
    end

    def character_update
      if @tile_id != @character.tile_id ||
        @character_name != @character.character_name ||
        @character_hue != @character.character_hue ||
        @oldbushdepth != @character.bush_depth
      @tile_id        = @character.tile_id
      @character_name = @character.character_name
      @character_hue  = @character.character_hue
      @oldbushdepth   = @character.bush_depth
      if @tile_id >= 384
        @charbitmap.dispose if @charbitmap
        @charbitmap = pbGetTileBitmap(@character.map.tileset_name, @tile_id,
                                      @character_hue, @character.width, @character.height)
        @charbitmapAnimated = false
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap = nil
        @spriteoffset = false
        @cw = Game_Map::TILE_WIDTH * @character.width
        @ch = Game_Map::TILE_HEIGHT * @character.height
        self.src_rect.set(0, 0, @cw, @ch)
        self.ox = @cw / 2
        self.oy = @ch
        @character.sprite_size = [@cw, @ch]
      else
        @charbitmap.dispose if @charbitmap
        @charbitmap = AnimatedBitmap.new(
            'Graphics/Characters/' + @character_name, @character_hue)
        RPG::Cache.retain('Graphics/Characters/', @character_name, @character_hue) if @character == $game_player
        @charbitmapAnimated = true
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap = nil
        @spriteoffset = @character_name[/offset/i]
        @cw = @charbitmap.width / 4
        @ch = @charbitmap.height / 4
        self.ox = @cw / 2
        @character.sprite_size = [@cw, @ch]
      end
    end
    @charbitmap.update if @charbitmapAnimated
    bushdepth = @character.bush_depth
    if bushdepth == 0
      self.bitmap = (@charbitmapAnimated) ? @charbitmap.bitmap : @charbitmap
    else
      @bushbitmap = BushBitmap.new(@charbitmap, (@tile_id >= 384), bushdepth) if !@bushbitmap
      self.bitmap = @bushbitmap.bitmap
    end
    self.visible = !@character.transparent
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = ((@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
      self.oy = (@spriteoffset rescue false) ? @ch - 16 : @ch
      self.oy -= @character.bob_height
    end
    if self.visible
      if @character.is_a?(Game_Event) && @character.name[/regulartone/i]
        self.tone.set(0, 0, 0, 0)
      else
        pbDayNightTint(self)
      end
    end
    self.x          = @character.screen_x
    self.y          = @character.screen_y
    self.z          = @character.screen_z(@ch)
    self.opacity    = @character.opacity
    self.blend_type = @character.blend_type
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
    @reflection.update if @reflection
    @surfbase.update if @surfbase
    end
end