class OverworldWeather
    MAX_PARTICLES = 60 # Show 60 particles at max strength
    MAX_TILES = 60

    attr_reader :type
    attr_reader :strength # From 0 to 10
    attr_reader :ox
    attr_reader :oy

    def initialize(givenViewport, type = :None, strength = 0, fadeInTime = 0, spritesEnabled = true)
        @givenViewport = givenViewport
        @viewport         = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z       = givenViewport.z + 1

        @ox = 0
        @oy = 0

        # Arrays to track all the sprites
        @particles = []
        @particleLifetimes = []
        @tiles = []

        # For weathers with cyclical tones (i.e. sun)
        @tonePhase = 0

        # For weathers with flashes (i.e. storm)
        @time_until_flash     = 0

        create_sprites
        startWeather(type,strength,fadeInTime,spritesEnabled)
    end

    def startWeather(type = :None, strength = 0, fadeInTime = 0, spritesEnabled = true)
        return if @type == type && @strength == strength

        if @type != type
            newWeather(type,strength,spritesEnabled)
        else
            @strength = strength
            update_sprite_assignment
        end
    end

    def newWeather(type = :None, strength = 0, spritesEnabled = true)
        @type = type
        @strength = strength
        @spritesEnabled = spritesEnabled

        @tiles_wide           = 0
        @tiles_tall           = 0
        @tile_x               = 0.0
        @tile_y               = 0.0

        prepare_weather(type)

        update_sprite_assignment

        @lastDisplayX = 0
        @lastDisplayY = 0
    end

    def prepare_weather(type)
        disposeBitmaps

        @particleBitmaps = []
        @tileBitmap = nil

        @weatherData = GameData::Weather.get(type)

        @weatherData.particle_names.each do |name|
            bitmap = RPG::Cache.load_bitmap("Graphics/Weather/", name)
            @particleBitmaps.push(bitmap)
        end

        if @weatherData.tile_name
            @tileBitmap = RPG::Cache.load_bitmap("Graphics/Weather/", @weatherData.tile_name)
            w = @tileBitmap.width
            h = @tileBitmap.height
            @tiles_wide = (Graphics.width.to_f / w).ceil + 1
            @tiles_tall = (Graphics.height.to_f / h).ceil + 1
        end
    end
    
    def create_sprites()
        for i in 0...MAX_PARTICLES
            particleSprite = Sprite.new(@givenViewport)
            particleSprite.z       = 1000
            particleSprite.ox      = @ox
            particleSprite.oy      = @oy
            particleSprite.opacity = 0
            particleSprite.visible = false
            @particles[i] = particleSprite
            @particleLifetimes[i] = 0
        end

        for i in 0...MAX_TILES
            tileSprite = Sprite.new(@givenViewport)
            tileSprite.z       = 1000
            tileSprite.ox      = @ox
            tileSprite.oy      = @oy
            tileSprite.opacity = 0
            tileSprite.visible = false
            @tiles[i] = tileSprite
        end
    end

    def eachParticle(onlyVisible=false)
        @particles.each_with_index do |particle,index|
            next if onlyVisible && !particle.visible
            yield particle,index
        end
    end

    def eachTile(onlyVisible=false)
        @tiles.each_with_index do |tile,index|
            next if onlyVisible && !tile.visible
            yield tile,index
        end
    end

    def update_sprite_assignment()
        usingParticles = !@particleBitmaps.empty? && @spritesEnabled
        
        eachParticle do |particle,index|
            visible = (index < numParticlesUsed) && usingParticles
            particle.visible = visible
            set_particle_bitmap(particle,index) if visible
        end
        
        usingTiles = @tileBitmap && @spritesEnabled
        eachTile do |tile,index|
            visible = (index < numTilesUsed) && usingTiles
            tile.visible = visible
            tile.bitmap = @tileBitmap if visible
        end
    end

    def set_particle_bitmap(sprite,index)
        if @weatherData.category == :Rain
            last_index = @particleBitmaps.length - 1 # Last sprite is a splash
            if index.even?
              sprite.bitmap = @particleBitmaps[index % last_index]
            else
              sprite.bitmap = @particleBitmaps[last_index]
            end
        else
            sprite.bitmap = @particleBitmaps[index % @particleBitmaps.length]
        end
    end

    def dispose
        disposeSprites
        disposeBitmaps
        @viewport.dispose
    end

    def disposeSprites
        @particles.each { |sprite| sprite.dispose if sprite } if @particles
        @tiles.each { |sprite| sprite.dispose if sprite } if @tiles
    end

    def disposeBitmaps
        @particleBitmaps.each { |bitmap| bitmap.dispose if bitmap } if @particleBitmap
        @tileBitmap.dispose if @tileBitmap
    end

    def ox=(value)
        return if value == @ox
        @ox = value
        @particles.each { |sprite| sprite.ox = @ox if sprite }
        @tiles.each { |sprite| sprite.ox = @ox if sprite }
    end
  
    def oy=(value)
        return if value == @oy
        @oy = value
        @particles.each { |sprite| sprite.oy = @oy if sprite }
        @tiles.each { |sprite| sprite.oy = @oy if sprite }
    end

    def spritesEnabled=(value)
        return if @spritesEnabled == value
        @spritesEnabled = value
        if !@spritesEnabled
          @particles.each { |sprite| sprite.visible = false }
          @tiles.each { |sprite| sprite.visible = false }
        end
    end

    def numParticlesUsed
        return MAX_PARTICLES * strengthRatio
    end

    def numTilesUsed
        return @tiles_wide * @tiles_tall
    end

    def weatherTone
        return @weatherData.tone(@strength)
    end

    def strengthRatio
        return @strength / 10.0
    end

    def update
        update_screen_tone
        update_flashes
        update_particles if @particleBitmaps.length > 0
        update_tiles if @tileBitmap
    end

    # Set tone of viewport (general screen brightening/darkening)
    def update_screen_tone
        @tonePhase += Graphics.delta_s

        base_tone = weatherTone
        tone_red = base_tone.red
        tone_green = base_tone.green
        tone_blue = base_tone.blue
        tone_gray = base_tone.gray

        # Modify base tone
        if @type == :Sun
            maxMagnitude = 30 * strengthRatio
            sunShift = maxMagnitude.to_f * Math.sin(@tonePhase)
            tone_red += sunShift
            tone_green += sunShift
            tone_blue += sunShift / 2
        end

        # Apply screen tone
        @viewport.tone.set(tone_red, tone_green, tone_blue, tone_gray)
    end

    def update_flashes
        # Storm flashes
        if @type == :Storm
            if @time_until_flash > 0
                @time_until_flash -= Graphics.delta_s
                if @time_until_flash <= 0
                    @viewport.flash(Color.new(255, 255, 255, 230), (2 + rand(3)) * 20)
                end
            end
            if @time_until_flash <= 0
                @time_until_flash = (1 - strengthRatio) * 10 + (1 + rand(12)) * 0.5
                # 0.5-6 seconds at max strength, 10.5-16.5 seconds at min
            end
        end
        @viewport.update
    end

    def update_particles
        eachParticle(true) do |particle, index|
            update_particle_position(particle, index)
        end
    end

    def update_particle_position(sprite, index)
        delta_t = Graphics.delta_s

        if @particleLifetimes[index] >= 0
            @particleLifetimes[index] -= delta_t
            if @particleLifetimes[index] <= 0
                reset_particle_position(sprite, index)
                return
            end
        end

        # Update position and opacity of sprite
        if @weatherData.category == :Rain && index.odd?   # Splash
            sprite.opacity = (@particleLifetimes[index] < 0.2) ? 255 : 0 # 0.2 seconds
        else
            particleVelX = @weatherData.particle_delta_x  * strengthRatio
            particleVelY = @weatherData.particle_delta_y
            dist_x = particleVelX * delta_t
            dist_y = particleVelY * delta_t
            sprite.x += dist_x
            sprite.y += dist_y

            if @type == :Snow
                sprite.x += dist_x * (sprite.y - @oy) / (Graphics.height * 3)   # Faster when further down screen
                sprite.x += [2, 1, 0, -1][rand(4)] * dist_x / 8   # Random movement
                sprite.y += [2, 1, 1, 0, 0, -1][index % 6] * dist_y / 10   # Variety
            end

            sprite.opacity += @weatherData.particle_delta_opacity * delta_t
            x = sprite.x - @ox
            y = sprite.y - @oy

            # Check if sprite is off-screen; if so, reset it
            if sprite.opacity < 64 || x < -sprite.bitmap.width || y > Graphics.height
                reset_particle_position(sprite, index)
            end
        end
    end

    def reset_particle_position(particle, index)
        if @weatherData.category == :Rain && index.odd? # Splash
            particle.x = @ox - particle.bitmap.width + rand(Graphics.width + particle.bitmap.width * 2)
            particle.y = @oy - particle.bitmap.height + rand(Graphics.height + particle.bitmap.height * 2)
            @particleLifetimes[index] = (30 + rand(20)) * 0.01 # 0.3-0.5 seconds
        else
            x_speed = @weatherData.particle_delta_x * strengthRatio
            y_speed = @weatherData.particle_delta_y
            gradient = x_speed.to_f / y_speed
            if gradient.abs >= 1
                # Position sprite to the right of the screen
                particle.x = @ox + Graphics.width + rand(Graphics.width)
                particle.y = @oy + Graphics.height - rand(Graphics.height + particle.bitmap.height - Graphics.width / gradient)
                distance_to_cover = particle.x - @ox - Graphics.width / 2 + particle.bitmap.width + rand(Graphics.width * 8 / 5)
                @particleLifetimes[index] = (distance_to_cover.to_f / x_speed).abs
            else
                # Position sprite to the top of the screen
                particle.x = @ox - particle.bitmap.width + rand(Graphics.width + particle.bitmap.width - gradient * Graphics.height)
                particle.y = @oy - particle.bitmap.height - rand(Graphics.height)
                distance_to_cover = @oy - particle.y + Graphics.height / 2 + rand(Graphics.height * 8 / 5)
                @particleLifetimes[index] = (distance_to_cover.to_f / y_speed).abs
            end
        end
        particle.opacity = 255
    end

    def update_tiles
        recalculate_tileing
        opacity = (strengthRatio * 255).floor
        if @type == :Dusty
            opacity /= 2
        end
        eachTile(true) do |tile, index|
            tile.x = (@ox + @tile_x + (index % @tiles_wide) * tile.bitmap.width).round
            tile.y = (@oy + @tile_y + (index / @tiles_wide) * tile.bitmap.height).round
            tile.x += @tiles_wide * tile.bitmap.width if tile.x - @ox < -tile.bitmap.width
            tile.y -= @tiles_tall * tile.bitmap.height if tile.y - @oy > Graphics.height
            tile.visible = @spritesEnabled
            tile.opacity = opacity
        end
    end

    def recalculate_tileing
        # Move the tiles based on the weather's intended tile movement
        @tile_x += @weatherData.tile_delta_x * Graphics.delta_s * strengthRatio
        @tile_y += @weatherData.tile_delta_y * Graphics.delta_s

        # Move the tiles in the opposite direction as the player
        if @lastDisplayX != 0
            moveX = $game_map.display_x - @lastDisplayX
            moveY = $game_map.display_y - @lastDisplayY

            @tile_x -= moveX / Game_Map::X_SUBPIXELS
            @tile_y -= moveY / Game_Map::Y_SUBPIXELS
        end
        @lastDisplayX = $game_map.display_x
        @lastDisplayY = $game_map.display_y

        # Have tiles loop around as needed
        tileWidth = @tileBitmap.width
        tileHeight = @tileBitmap.height

        jumpDistanceX = @tiles_tall * tileHeight
        if @tile_x < -@tiles_wide * tileWidth
            @tile_x += jumpDistanceX
        elsif @tile_x > 0 
            @tile_x -= jumpDistanceX
        end

        jumpDistanceY = @tiles_tall * tileHeight
        if @tile_y > @tiles_tall * tileHeight
            @tile_y -= jumpDistanceY
        elsif @tile_y < 0
            @tile_y += jumpDistanceY
        end
    end
end