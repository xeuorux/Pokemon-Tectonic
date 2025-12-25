class BushBitmap
    def initialize(bitmap, isTile, depth)
      @bitmaps  = []
      @bitmap   = bitmap
      @isTile   = isTile
      @isBitmap = @bitmap.is_a?(Bitmap)
      @depth    = depth
    end
  
    def dispose
      @bitmaps.each { |b| b.dispose if b }
    end
  
    def bitmap
      thisBitmap = (@isBitmap) ? @bitmap : @bitmap.bitmap
      current = (@isBitmap) ? 0 : @bitmap.currentIndex
      if !@bitmaps[current]
        if @isTile
          @bitmaps[current] = pbBushDepthTile(thisBitmap, @depth)
        else
          @bitmaps[current] = pbBushDepthBitmap(thisBitmap, @depth)
        end
      end
      return @bitmaps[current]
    end
  
    def pbBushDepthBitmap(bitmap, depth)
      ret = Bitmap.new(bitmap.width, bitmap.height)
      charheight = ret.height / 4
      cy = charheight - depth - 2
      for i in 0...4
        y = i * charheight
        if cy >= 0
          ret.blt(0, y, bitmap, Rect.new(0, y, ret.width, cy))
          ret.blt(0, y + cy, bitmap, Rect.new(0, y + cy, ret.width, 2), 170)
        end
        ret.blt(0, y + cy + 2, bitmap, Rect.new(0, y + cy + 2, ret.width, 2), 85) if cy + 2 >= 0
      end
      return ret
    end
  
    def pbBushDepthTile(bitmap, depth)
      ret = Bitmap.new(bitmap.width, bitmap.height)
      charheight = ret.height
      cy = charheight - depth - 2
      y = charheight
      if cy >= 0
        ret.blt(0, y, bitmap, Rect.new(0, y, ret.width, cy))
        ret.blt(0, y + cy, bitmap, Rect.new(0, y + cy, ret.width, 2), 170)
      end
      ret.blt(0, y + cy + 2, bitmap, Rect.new(0, y + cy + 2, ret.width, 2), 85) if cy + 2 >= 0
      return ret
    end
  end
  
  
  
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
        @reflection = Sprite_Reflection.new(self, character, viewport)
        @surfbase = Sprite_SurfBase.new(self, character, viewport) if character == $game_player
        update
        @steps = []
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
  
      def setReflection(event, viewport)
          @reflection ||= Sprite_Reflection.new(self, event, viewport)
      end
      
      def groundY
        return @character.screen_y_ground
      end
    
      def visible=(value)
        super(value)
        @reflection.visible = value if @reflection
      end
      
      def setShadows(map, shadows)
          if character.is_a?(Game_Event) && shadows.length > 0
              params = XPML_read(map, "Shadow", @character, 4)
              unless params.nil?
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
                  @bushbitmap.dispose if @bushbitmap
                  @bushbitmap = nil
                  @charbitmap.dispose if @charbitmap
                
                  file_name, is_auto_tile = $scene.map_renderer.get_bitmap_filename_for_tile(@character.map, @tile_id)
                  if is_auto_tile
                    @charbitmap = AnimatedBitmap.new("Graphics/Autotiles/" + file_name, @character_hue, numFrames: 8, delay: 12)
                    @charbitmapAnimated = true
                  else
                    @charbitmap = pbGetTileBitmap(@character.map.tileset_name, @tile_id, @character_hue, @character.width, @character.height)
                    @charbitmapAnimated = false
                  end
                  
                  @spriteoffset = false
                  @cw = Game_Map::TILE_WIDTH * @character.width
                  @ch = Game_Map::TILE_HEIGHT * @character.height
                  src_rect.set(0, 0, @cw, @ch)
                  self.ox = @cw / 2
                  self.oy = @ch
                  @character.sprite_size = [@cw, @ch]
              else
                  @charbitmap.dispose if @charbitmap
                  @charbitmap = AnimatedBitmap.new(
                      "Graphics/Characters/" + @character_name, @character_hue)
                  RPG::Cache.retain("Graphics/Characters/", @character_name, @character_hue) if @character == $game_player
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
              self.bitmap = @charbitmapAnimated ? @charbitmap.bitmap : @charbitmap
          else
              @bushbitmap ||= BushBitmap.new(@charbitmap, (@tile_id >= 384), bushdepth)
              self.bitmap = @bushbitmap.bitmap
          end
          self.visible = !@character.transparent
          if @tile_id == 0
              sx = @character.pattern * @cw
              sy = ((@character.direction - 2) / 2) * @ch
              src_rect.set(sx, sy, @cw, @ch)
              self.oy = if begin
                  @spriteoffset
              rescue StandardError
                  false
              end
                            @ch - 16
                        else
                            @ch
                        end
              self.oy -= @character.bob_height
          end
          if visible
              if @character.is_a?(Game_Event) && @character.name[/regulartone/i]
                  tone.set(0, 0, 0, 0)
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
  