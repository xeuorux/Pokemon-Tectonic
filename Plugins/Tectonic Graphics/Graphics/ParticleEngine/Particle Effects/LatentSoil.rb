class Particle_Engine::LatentSoil < ParticleEffect_Event
    def initialize(event,viewport)
        super
        setParameters([
            0, # Random hue
            0, # fade
            20, # max particles
            -100, # hue
            1, # slowdown
            -Graphics.height, # ytop
            Graphics.height, # ybottom
            0, # xleft
            Graphics.width, # xright
            0, # xgravity
            -0.2, # ygravity
            0, # xoffset
            -8, # yoffset
            2, # opacity var
            0, # original opacity
            ])
        @opacityMult = 0.2
        @radius = 8
        @rad2 = @radius * @radius

        initParticles("particle",255,-1)
    end

    def initializeParticle(i)
        particleSprite = @particles[i]
        particleSprite.ox = @bmwidth / 2
        particleSprite.oy = @bmheight / 2
        #particleSprite.zoom_x = 0.6
        #particleSprite.zoom_y = 0.6

        @opacity[i] = rand(255)
    end

    def particlesEnabled?
        return super && !pbGetSelfSwitch(@event.id,'A')
    end

    def resetOpacity(i)
        @opacity[i] = 255
    end

    def changeOpacity(i)
        @opacity[i] = @opacity[i] - 1
    end

    TRIANGLE_SIDE_SIZE = 16

    def resetParticle(i)
        randomAngle = rand(360)
        xRand = Math.cos(randomAngle) * @radius
        yRand = Math.sin(randomAngle) * @radius

        @particles[i].x = @startingx + @xoffset + xRand
        @particles[i].y = @startingy + @yoffset + yRand
        @particlex[i] = xRand
        @particley[i] = yRand
    end
end