class Particle_Engine::CircleStarField < ParticleEffect_Event
    def initialize(event,viewport)
        super
        setParameters([
            0, # Random hue
            0, # fade
            50, # max particles
            -80, # hue
            5, # slowdown
            -Graphics.height, # ytop
            Graphics.height, # ybottom
            0, # xleft
            Graphics.width, # xright
            0, # xgravity
            0, # ygravity
            0, # xoffset
            0, # yoffset
            3, # opacity var
            5 # original opacity
            ])
        @opacityMult = 0.9
        @huerange = 80
        @cullOffscreen = false
        @movesleftright = true
        @movesupdown = true
        @radius = 350
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

        hue = @hue + rand(@huerange) - @huerange / 2
        hue -= 360 if @hue >= 360
        hue += 360 if @hue <= 0

        @particles[i].bitmap = loadBitmap(@filename, hue)
    end

    def resetOpacity(i)
        @opacity[i] = 1
        @particles[i].state = 0
    end

    def initializeParticle(i)
        @opacity[i] = rand(249)
    end

    def changeOpacity(i)
        if @particles[i].state == 0
            @opacity[i] += rand(3)
            if @opacity[i] >= 250
                @particles[i].state = 1
            end
        else
            @opacity[i] -= rand(3)
        end
    end

    def xExtent
        return @radius
    end

    def yExtent
        return @radius
    end
end