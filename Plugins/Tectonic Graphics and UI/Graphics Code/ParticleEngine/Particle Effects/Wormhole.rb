class Particle_Engine::Wormhole < ParticleEffect_Event
    def initialize(event,viewport)
        super
        setParameters([
            0, # Random hue
            0, # fade
            6, # max particles
            0, # hue
            5, # slowdown
            0, # ytop
            0, # ybottom
            0, # xleft
            0, # xright
            0, # xgravity
            0, # ygravity
            0, # xoffset
            0, # yoffset
            3, # opacity var
            5 # original opacity
            ])
        @opacityMult = 0.8
        @cullOffscreen = false
        @movesleftright = false
        @movesupdown = false

        initParticles("wormhole_portal")
    end

    def resetOpacity(i)
        return
    end

    def initializeParticle(i)
        particleSprite = @particles[i]

        particleSprite.ox = @bmwidth / 2
        particleSprite.oy = @bmheight / 2
        particleSprite.angle = 360 * i / @max_particles.to_f

        particleSprite.zoom_x = 2.5

        hue = @hue + 360 * i / @max_particles.to_f
        hue = clampHue(hue)
        echoln(hue)
        particleSprite.bitmap = loadBitmap(@filename, hue)
    end

    def changeOpacity(i)
        return
    end

    def xExtent
        return 50
    end

    def yExtent
        return 50
    end

    def updateParticle(i,particleZ)
        if i % 2 == 0
            @particles[i].angle += 1
        else
            @particles[i].angle -= 1
        end
        super
    end
end