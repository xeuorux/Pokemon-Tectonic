class ParticleEffect_Event
    attr_accessor :event
    attr_reader :opacity

    def initialize(event,viewport=nil)
        @event     = event
        @viewport  = viewport
        @particles = []
        @bitmaps   = {}
        @cullOffscreen = true
        @movesupdown = false
        @movesleftright = false
        @opacityMult = 1.0
        @enabled = true
    end

    def setParameters(params)
        @randomhue,@fade,
        @max_particles,@hue,@slowdown,
        @ytop,@ybottom,@xleft,@xright,
        @xgravity,@ygravity,@xoffset,@yoffset,
        @opacityvar,@originalopacity = params
    end

    def loadBitmap(filename,hue)
        key = [filename,hue]
        bitmap = @bitmaps[key]
        if !bitmap || bitmap.disposed?
            bitmap = AnimatedBitmap.new("Graphics/Fogs/"+filename,hue).deanimate
            @bitmaps[key] = bitmap
        end
        return bitmap
    end

    def initParticles(filename,givenOpacity=255,zOffset=0,blendtype=1)
        @particles = []
        @particlex = []
        @particley = []
        @opacity   = []
        @startingx = self.x + @xoffset
        @startingy = self.y + @yoffset
        @screen_x  = self.x
        @screen_y  = self.y
        @real_x    = @event.real_x
        @real_y    = @event.real_y
        @filename  = filename
        @zoffset   = zOffset
        @bmwidth   = 32
        @bmheight  = 32
        for i in 0...@max_particles
          @particles[i] = ParticleSprite.new(@viewport)
          @particles[i].bitmap = loadBitmap(filename, @hue) if filename
          if i==0 && @particles[i].bitmap
            @bmwidth  = @particles[i].bitmap.width
            @bmheight = @particles[i].bitmap.height
          end
          @particles[i].blend_type = blendtype
          @particles[i].z = self.z + zOffset
          @opacity[i] = givenOpacity

          resetParticle(i)
          initializeParticle(i)
          
          @particles[i].opacity = @opacity[i]
          @particles[i].update
        end

        @particlesEnabled = true
        checkForDisablement
    end

    def initializeParticle(i)
        @opacity[i] = rand(255)
    end

    def x; return ScreenPosHelper.pbScreenX(@event); end
    def y; return ScreenPosHelper.pbScreenY(@event); end
    def z; return ScreenPosHelper.pbScreenZ(@event); end

    def particlesEnabled?
        return false if $PokemonSystem.particle_effects == 1
        return true
    end

    def checkForDisablement
        oldEnabled = @particlesEnabled
        @particlesEnabled = particlesEnabled?

        if oldEnabled && !@particlesEnabled
            @particles.each do |particle|
                next if particle.opacity == 0
                particle.opacity = 0
                particle.update
            end
            return
        elsif !oldEnabled && @particlesEnabled
            reenableParticles
        end
    end

    def reenableParticles
        for i in 0...@max_particles 
            resetParticle(i)
        end
    end

    def update
        checkForDisablement

        return unless @particlesEnabled

        # Don't update particle events whose viewports are off screen
        if @viewport && (@viewport.rect.x >= Graphics.width || @viewport.rect.y >= Graphics.height)
            return
        end

        # Store the pre-update viewport positions
        selfX = self.x
        selfY = self.y
        selfZ = self.z

        # Calculate how to move the particles to maintain the illusion
        # of spawning in the game world
        newRealX = @event.real_x
        newRealY = @event.real_y
        @startingx = selfX + @xoffset
        @startingy = selfY + @yoffset
        @screenmovementx = (@real_x == newRealX) ? 0 : selfX - @screen_x
        @screenmovementy = (@real_y == newRealY) ? 0 : selfY - @screen_y
        @screen_x = selfX
        @screen_y = selfY
        @real_x = newRealX
        @real_y = newRealY

        # Determine if all particles are surely off screen
        # If so, skip updating this particle event
        if @opacityvar > 0 && @viewport

            # Calculate the max extent of random particle spawning
            spawningMinX = @startingx - xExtent
            spawningMaxX = @startingx + xExtent
            spawningMinY = @startingy - yExtent
            spawningMaxY = @startingy + yExtent

            # Find the maximum extent of particle position
            opac = 255.0 / @opacityvar
            minX = opac * (-@xgravity.to_f / @slowdown).floor + spawningMinX
            maxX = opac * (@xgravity.to_f / @slowdown).floor + spawningMaxX
            minY = opac * (-@ygravity.to_f / @slowdown).floor + spawningMinY
            maxY = spawningMaxY

            # Account for the size of the bitmap
            minX -= @bmwidth
            minY -= @bmheight
            maxX += @bmwidth
            maxY += @bmheight

            if maxX < 0 || maxY < 0 || minX >= Graphics.width || minY >= Graphics.height
                return
            end
        end
        particleZ = selfZ + @zoffset

        # Update all particles
        for i in 0...@max_particles
          updateParticle(i,particleZ)
        end
    end

    def xExtent
        return 0
    end

    def yExtent
        return 0
    end

    def updateParticle(i,particleZ)
        @particles[i].z = particleZ
        if @cullOffscreen
            if @particles[i].y <= @ytop
                resetParticle(i)
            end
            if @particles[i].x <= @xleft
                resetParticle(i)
            end
            if @particles[i].y >= @ybottom
                resetParticle(i)
            end
            if @particles[i].x >= @xright
                resetParticle(i)
            end
        end
        if @fade == 0
            if @opacity[i] <= 0
                resetOpacity(i)
                resetParticle(i)
            end
        else
            if @opacity[i] <= 0
                @opacity[i] = 250
                resetParticle(i)
            end
        end
        calcParticlePos(i)
        changeHue(i)
        changeOpacity(i)
        @particles[i].opacity = @opacity[i] * @opacityMult
        @particles[i].update
    end

    def calcParticlePos(i)
        # Calculate the effect of "gravity"
        if @movesleftright && rand(2) == 1
            xo = -@xgravity.to_f / @slowdown
        else
            xo = @xgravity.to_f / @slowdown
        end

        if @movesupdown && rand(2) == 1
            yo = -@ygravity.to_f / @slowdown
        else
            yo = @ygravity.to_f / @slowdown
        end

        # Calculate the particle position change
        @particlex[i] += xo
        @particley[i] += yo
        @particlex[i] -= @screenmovementx
        @particley[i] -= @screenmovementy

        # Actually move the particle
        @particles[i].x = @particlex[i] + @startingx + @xoffset
        @particles[i].y = @particley[i] + @startingy + @yoffset
    end

    def changeHue(i)
        if @randomhue == 1
            @hue += 0.5
            @hue = 0 if @hue >= 360
            @particles[i].bitmap = loadBitmap(@filename, @hue) if @filename
        end
    end

    def resetOpacity(i)
        @opacity[i] = @originalopacity
    end

    def changeOpacity(i)
        @opacity[i] = @opacity[i] - rand(@opacityvar)
    end

    def resetParticle(i)
        @particles[i].y = @startingy + @yoffset
        @particles[i].x = @startingx + @xoffset
        @particlex[i] = 0.0
        @particley[i] = 0.0
    end

    def dispose
        for particle in @particles
          particle.dispose
        end
        for bitmap in @bitmaps.values
          bitmap.dispose
        end
        @particles.clear
        @bitmaps.clear
    end

    def clampHue(hue)
        hue -= 360 while hue >= 360
        hue += 360 while hue < 0
        return hue
    end
end