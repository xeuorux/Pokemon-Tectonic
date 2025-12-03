class Sprite_Character_Player < Sprite_Character
    def initialize(viewport, character = nil, is_follower = false)
        @playerOverlayBitmaps = []
        @playerOverlaySprites = []
        super
    end
    
    def dispose
        disposeOverlays
        super
    end

    def disposeOverlays
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.dispose
        end
        @playerOverlayBitmaps.each do |overlayBitmap|
            overlayBitmap.dispose
        end
        @playerOverlayBitmaps = []
        @playerOverlaySprites = []
    end

    def reloadBitmaps
        @charbitmap.dispose if @charbitmap
        characterBitmapPath = "Graphics/Characters/" + @character_name
        @charbitmap = AnimatedBitmap.new(characterBitmapPath, @character_hue)
        if @character == $game_player
            RPG::Cache.retain("Graphics/Characters/", @character_name, @character_hue)

            # Overlays
            disposeOverlays
            overlayPath = "_overlay"
            if pbResolveBitmap(characterBitmapPath + overlayPath)
                newBitmap = AnimatedBitmap.new(characterBitmapPath + overlayPath, PLAYER_OVERLAYS_HUE)
                @playerOverlayBitmaps.push(newBitmap)
                RPG::Cache.retain("Graphics/Characters/", @character_name + overlayPath, PLAYER_OVERLAYS_HUE)

                newSprite = SpriteWrapper.new(@viewport)
                newSprite.bitmap = newBitmap.bitmap
                @playerOverlaySprites.push(newSprite)
            end
        end
    end

    def x=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.x = value
        end
    end

    def y=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.y = value
        end
    end

    def z=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.z = value
        end
    end

    def ox=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.ox = value
        end
    end

    def oy=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.oy = value
        end
    end

    def visible=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.visible = value
        end
    end

    def opacity=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.opacity = value
        end
    end

    def blend_type=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.blend_type = value
        end
    end

    def character_update
		if @character_name != @character.character_name ||
			@character_hue != @character.character_hue ||
			@oldbushdepth != @character.bush_depth

			@character_name = @character.character_name
			@character_hue  = @character.character_hue
			@oldbushdepth   = @character.bush_depth

            reloadBitmaps

            @charbitmapAnimated = true
            @bushbitmap.dispose if @bushbitmap
            @bushbitmap = nil
            @spriteoffset = @character_name[/offset/i]
            @cw = @charbitmap.width / 4
            @ch = @charbitmap.height / 4
            self.ox = @cw / 2
            @character.sprite_size = [@cw, @ch]
		end
        if @charbitmapAnimated
		    @charbitmap.update
            
            @playerOverlayBitmaps.each do |overlayBitmap|
                overlayBitmap.update
            end
        end
		bushdepth = @character.bush_depth
		if bushdepth == 0
			self.bitmap = @charbitmapAnimated ? @charbitmap.bitmap : @charbitmap
		else
			@bushbitmap ||= BushBitmap.new(@charbitmap, false, bushdepth)
			self.bitmap = @bushbitmap.bitmap
		end
		self.visible = !@character.transparent

        # Calculate sprite source rectangle
        sx = @character.pattern * @cw
        sy = ((@character.direction - 2) / 2) * @ch
        src_rect.set(sx, sy, @cw, @ch)
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.src_rect.set(sx, sy, @cw, @ch)
        end

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

        # Add tint
		if visible
			pbDayNightTint(self)
            @playerOverlaySprites.each do |overlaySprite|
                pbDayNightTint(overlaySprite)
            end
		end

        # Align with player
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