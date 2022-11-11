class OverworldWeather
    MAX_PARTICLES = 60 # Show 60 particles at max strength
    MAX_TILES = 60
    DEFAULT_STRENGTH_CHANGE_FRAMES = 10

    attr_reader :type
    attr_reader :strength # From 0 to 10
    attr_reader :ox
    attr_reader :oy

    def initialize(givenViewport)
        @givenViewport = givenViewport
        @viewport         = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z       = givenViewport.z + 1

        @ox = 0
        @oy = 0

        @particleBitmaps = []
        @particleNames = []
        @tileBitmap = nil
        @tileName = ""

        # Arrays to track all the sprites
        @particles = []
        @particleLifetimes = []
        @tiles = []

        # For weathers with cyclical tones (i.e. sun)
        @tonePhase = 0

        # For weathers with flashes (i.e. storm)
        @time_until_flash     = 0

        @strength = 0
        @targetStrength = 0
        @strengthChangeFrames = 10
        @strengthChangeCount = 0
        @weatherRunning = false

        create_sprites
        updateWeatherSettings(:None,0,DEFAULT_STRENGTH_CHANGE_FRAMES,true)
    end

    def canUseExistingParticles?(newType)
        newData = GameData::Weather.get(newType)
        return @particleNames.sort == newData.particle_names.sort
    end

    def canUseExistingTiles?(newType)
        newData = GameData::Weather.get(newType)
        return @tileName == newData.tile_name
    end

    def updateWeatherSettings(type = :None, strength = 0, framesPerStrength = 0, spritesEnabled = true)
        return if @type == type && @strength == strength

        if @type != type
            # Don't bother fading out if one or both of the graphics should be re-used
            useExistingParticles = canUseExistingParticles?(type)
            useExistingTiles = canUseExistingTiles?(type)
            particlesRemain = usingParticles? && useExistingParticles
            if @strength == 0 || particlesRemain
                newWeather(type,strength,spritesEnabled, !useExistingParticles, !useExistingTiles)
            else
                # Fade out the weather before allowing a new one to apply
                @targetStrength = 0
                @strengthChangeFrames = framesPerStrength
            end
        else
            @targetStrength = strength
            @strengthChangeFrames = framesPerStrength
        end
    end

    def newWeather(type = :None, strength = 0, spritesEnabled = true, resetParticles = true, resetTiles = true)
        @type = type
        @weatherData = GameData::Weather.get(type)
        
        if !@weatherRunning
            @strength = strength
        end
        @weatherRunning = true if type != :None
        @targetStrength = strength
        @strengthChangeFrames = DEFAULT_STRENGTH_CHANGE_FRAMES
        @spritesEnabled = spritesEnabled

        echoln("Beginning new weather #{type} at starting strength #{ @strength} and target strength #{strength}")
        echoln("Resetting particles/tiles? #{resetParticles}, #{resetTiles}")

        @tiles_wide           = 0
        @tiles_tall           = 0
        @tile_x               = 0.0
        @tile_y               = 0.0

        prepare_bitmaps(type,resetParticles,resetTiles)

        set_sprite_visibility

        @lastDisplayX = 0
        @lastDisplayY = 0
    end

    def prepare_bitmaps(type, resetParticles = true, resetTiles = true)
        disposeBitmaps

        # Load and set particle bitmaps
        if resetParticles
            @particleBitmaps = []
            @particleNames = []
            @weatherData.particle_names.each do |name|
                @particleNames.push(name)
                bitmap = RPG::Cache.load_bitmap("Graphics/Weather/", name)
                @particleBitmaps.push(bitmap)
            end
            if !@particleBitmaps.empty?
                eachParticle do |particle,index|
                    set_particle_bitmap(particle,index)
                end
            end
        end

        # Load and set tile bitmap
        if resetTiles
            @tileBitmap = nil
            @tileName = ""
            if @weatherData.tile_name
                @tileName = @weatherData.tile_name
                @tileBitmap = RPG::Cache.load_bitmap("Graphics/Weather/", @weatherData.tile_name)
                w = @tileBitmap.width
                h = @tileBitmap.height
                @tiles_wide = (Graphics.width.to_f / w).ceil + 1
                @tiles_tall = (Graphics.height.to_f / h).ceil + 1

                eachTile do |tile,index|
                    tile.bitmap = @tileBitmap
                end
            end
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

    def usingParticles?
        return !@particleBitmaps.empty? && @spritesEnabled
    end

    def usingTiles?
        return @tileBitmap && @spritesEnabled
    end

    def particleIndexShown?(index)
        return (index < numParticlesUsed) && usingParticles?
    end

    def tileIndexShown?(index)
        return (index < numTilesUsed) && usingTiles?
    end

    # Should only be used while initializing a new weather
    # Otherwise may disable a particle while its on screen
    def set_sprite_visibility()
        eachParticle do |particle,index|
            particle.visible = particleIndexShown?(index)
        end
        
        eachTile do |tile,index|
            tile.visible = tileIndexShown?(index)
        end
    end

    def set_particle_bitmap(sprite,index)
        if rainStyle?
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
        num = (MAX_PARTICLES * strengthRatio).floor
        if @type == :Rain
            num = num / 2
        end
        num -= 1 if num.odd? && rainStyle? # Only allowed an even number of particles
        return num
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
        update_strength
        update_screen_tone
        update_flashes
        update_particles if usingParticles?
        update_tiles if usingTiles?
    end

    def update_strength
        if @targetStrength != @strength
            @strengthChangeCount += 1

            strengthChange = (1.0 / @strengthChangeFrames.to_f)
            strengthChange *= -1 if @targetStrength < @strength
            @strength += strengthChange

            if @strengthChangeCount > @strengthChangeFrames
                @strength = @strength.round
                @strengthChangeCount = 0
            end
        end
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

    def flash_color(intensity)
        value = [160 + 75 * intensity,255].min
        Color.new(255, 255, 255, value)
    end

    def flash_length(intensity)
        seconds = intensity + rand(2.0)
        return seconds * Graphics.frame_rate
    end

    # From 0 to 1
    def random_flash_intensity
        return strengthRatio * 0.5 + rand(0.5)
    end

    def update_flashes
        return if @strength == 0
        # Storm flashes
        if @type == :Storm
            if @time_until_flash > 0
                @time_until_flash -= Graphics.delta_s
                if @time_until_flash <= 0
                    intensity = random_flash_intensity
                    @viewport.flash(flash_color(intensity), flash_length(intensity))
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
        eachParticle do |particle, index|
            # Skip invisible particles
            # Unless a recent strength change should cause them to become visible
            # In which case place them into the world
            if !particle.visible
                if particleIndexShown?(index)
                    particle.visible = true
                    reset_particle(particle,index)
                else
                    next
                end
            end
            update_particle_lifetime(particle, index)
            update_particle_position(particle, index)
        end
    end

    def update_particle_lifetime(particle, index)
        if @particleLifetimes[index] >= 0
            @particleLifetimes[index] -= Graphics.delta_s
            if @particleLifetimes[index] <= 0
                reset_particle(particle, index)
                return
            end
        end
    end

    def rainStyle?
        return @weatherData.category == :Rain
    end

    def isSplash?(index)
        return rainStyle? && index.odd?
    end

    def isRaindrop?(index)
        return rainStyle? && index.even?
    end

    def particleDeltaX
        x_speed = @weatherData.particle_delta_x

        if rainStyle?
            x_speed *= (1.0 + strengthRatio) / 2.0
        else
            x_speed *= strengthRatio
        end

        return x_speed
    end

    def particleDeltaY
        y_speed = @weatherData.particle_delta_y
        if rainStyle?
            y_speed *= (1.0 + strengthRatio) / 2.0
        end
        return y_speed
    end

    def update_particle_position(particle, index)
        # Update position and opacity of sprite
        unless isSplash?(index) # Splash
            dist_x = particleDeltaX * Graphics.delta_s
            dist_y = particleDeltaY * Graphics.delta_s
            particle.x += dist_x
            particle.y += dist_y

            if @type == :Snow
                particle.x += dist_x * (particle.y - @oy) / (Graphics.height * 3)   # Faster when further down screen
                particle.x += [2, 1, 0, -1][rand(4)] * dist_x / 8   # Random movement
                particle.y += [2, 1, 1, 0, 0, -1][index % 6] * dist_y / 10   # Variety
            end

            particle.opacity += @weatherData.particle_delta_opacity * Graphics.delta_s
            x = particle.x - @ox
            y = particle.y - @oy

            # Check if particle is off-screen; if so, reset it
            if particle.opacity < 64 || x < -particle.bitmap.width || y > Graphics.height
                reset_particle(particle, index)
            elsif isRaindrop?(index) && rand(@weatherData.particle_delta_y) < 240
                setSplashForRaindrop(particle,index)
                @particleLifetimes[index] = 0.2
            end
        end
    end

    def reset_particle(particle, index)
        if !particleIndexShown?(index) || isSplash?(index)
            particle.visible = false
            return
        end

        gradient = particleDeltaX.to_f / particleDeltaY
        if gradient.abs > 1
            # Position sprite to the right of the screen
            particle.x = @ox + Graphics.width + rand(Graphics.width)
            particle.y = @oy + Graphics.height - rand(Graphics.height + particle.bitmap.height - Graphics.width / gradient)
            distance_to_cover = particle.x - @ox - Graphics.width / 2 + particle.bitmap.width + rand(Graphics.width * 8 / 5)
            @particleLifetimes[index] = (distance_to_cover.to_f / particleDeltaX).abs
        else
            # Position sprite to the top of the screen
            particle.x = @ox - particle.bitmap.width + rand(Graphics.width + particle.bitmap.width - gradient * Graphics.height)
            particle.y = @oy - particle.bitmap.height - rand(Graphics.height)
            distance_to_cover = @oy - particle.y + Graphics.height / 2 + rand(Graphics.height * 8 / 5)
            @particleLifetimes[index] = (distance_to_cover.to_f / particleDeltaY).abs
        end
        particle.opacity = 255
    end

    def setSplashForRaindrop(rainDropParticle,rainDropIndex)
        splashIndex = rainDropIndex + 1
        splashParticle = @particles[splashIndex]

        splashParticle.x = rainDropParticle.x
        splashParticle.y = rainDropParticle.y + rainDropParticle.bitmap.height
        splashParticle.visible = true
        splashParticle.opacity = 255
        splashLifetime = (20 + rand(20)) * 0.01 # 0.2-0.4 seconds
        @particleLifetimes[splashIndex] = splashLifetime
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