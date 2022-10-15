class Sprite_Character < RPG::Sprite
    def update
        return if @character.is_a?(Game_Event) && !@character.should_update?
        super
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
    #    self.zoom_x     = Game_Map::TILE_WIDTH / 32.0
    #    self.zoom_y     = Game_Map::TILE_HEIGHT / 32.0
        self.opacity    = @character.opacity
        self.blend_type = @character.blend_type
    #    self.bush_depth = @character.bush_depth
        if @character.animation_id != 0
          animation = $data_animations[@character.animation_id]
          animation(animation, true)
          @character.animation_id = 0
        end
        @reflection.update if @reflection
        @surfbase.update if @surfbase
      end
end