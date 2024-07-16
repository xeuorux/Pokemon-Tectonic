class Particle_Engine::ShinyObject < ParticleEffect_Event
    def initialize(event,viewport)
        super
        setParameters([
            0, # Random hue
            0, # fade
            12, # max particles
            80, # hue
            1, # slowdown
            -Graphics.height, # ytop
            Graphics.height, # ybottom
            0, # xleft
            Graphics.width, # xright
            0, # xgravity
            0, # ygravity
            0, # xoffset
            -12, # yoffset
            3, # opacity var
            5 # original opacity
            ])
        @opacityMult = 0.9
        @huerange = 0
        @cullOffscreen = false
        @movesleftright = true
        @movesupdown = true
        @radius = 12
        @rad2 = @radius * @radius

        initParticles("particle",100)
    end

    def resetParticle(i)
        randomRad = Math.sqrt(rand(@rad2))
        randomAngle = rand(360)
        xRand = Math.cos(randomAngle) * randomRad
        yRand = Math.sin(randomAngle) * randomRad
        @particles[i].x = @startingx + @xoffset + xRand
        @particles[i].y = @startingy + @yoffset + yRand
        @particlex[i] = xRand
        @particley[i] = yRand
        @particles[i].state = 0
        @particles[i].zoom_x = 0.25
        @particles[i].zoom_y = 0.25

        hue = @hue + rand(@huerange) - @huerange / 2
        hue -= 360 if @hue >= 360
        hue += 360 if @hue <= 0

        @particles[i].bitmap = loadBitmap(@filename, hue)
    end

    def resetOpacity(i)
        @opacity[i] = 200
        @particles[i].state = 0
    end

    def initializeParticle(i)
        @opacity[i] = rand(100...200)
        @particles[i].state = rand(5)
    end

    def changeOpacity(i)
        thresholdOffset = 10 * @particles[i].state
        if @particles[i].state == 5
            @opacity[i] -= 5
        elsif @particles[i].state.even?
            @opacity[i] += 5
            if @opacity[i] >= 200 - thresholdOffset
                @particles[i].state += 1
            end
        else
            @opacity[i] -= 5
            if @opacity[i] <= 100 - thresholdOffset
                @particles[i].state += 1
            end
        end
    end

    def xExtent
        return @radius
    end

    def yExtent
        return @radius
    end
end
