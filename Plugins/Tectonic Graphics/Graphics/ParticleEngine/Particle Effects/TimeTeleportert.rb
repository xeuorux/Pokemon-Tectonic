class Particle_Engine::TimeTeleporter < ParticleEffect_Event
    def initialize(event,viewport)
        super
        setParameters([
            0, # Random hue
            0, # fade
            60, # max particles
            -100, # hue
            1, # slowdown
            -Graphics.height, # ytop
            Graphics.height, # ybottom
            0, # xleft
            Graphics.width, # xright
            0, # xgravity
            -0.05, # ygravity
            8, # xoffset
            0, # yoffset
            2, # opacity var
            0, # original opacity
            ])
        @opacityMult = 0.2
        @radius = 50

        initParticles("particle",255,-1)
    end

    def initializeParticle(i)
        particleSprite = @particles[i]
        particleSprite.ox = @bmwidth / 2
        particleSprite.oy = @bmheight / 2
        particleSprite.zoom_x = 0.6
        particleSprite.zoom_y = 0.6

        @opacity[i] = rand(255)
    end

    def particlesEnabled?
        return false unless super
        return true if $game_player.at_coordinate?(@event.x, @event.y)
        map = $MapFactory.getMapNoAdd($game_map.map_id)
        map.events.each_value do |event|
            next unless event.name.downcase[/pushboulder/]
            next unless event.at_coordinate?(@event.x, @event.y)
            return true
        end
        return false
    end

    def resetOpacity(i)
        @opacity[i] = 255
    end

    def changeOpacity(i)
        @opacity[i] = @opacity[i] - 3
    end

    TRIANGLE_SIDE_SIZE = 16

    def resetParticle(i)
        xRand = 0
        yRand = 0
        case rand(6)
        when 0
            randVal = rand(TRIANGLE_SIDE_SIZE)
            xRand = -randVal
            yRand = -randVal
        when 1
            randVal = rand(TRIANGLE_SIDE_SIZE)
            xRand = -TRIANGLE_SIDE_SIZE - randVal
            yRand = -TRIANGLE_SIDE_SIZE + randVal
        when 2
            xRand = -rand(TRIANGLE_SIDE_SIZE * 2)
            yRand = 0
        when 3
            randVal = rand(TRIANGLE_SIDE_SIZE)
            xRand = -randVal
            yRand = -TRIANGLE_SIDE_SIZE * 2 + randVal
        when 4
            randVal = rand(TRIANGLE_SIDE_SIZE)
            xRand = -TRIANGLE_SIDE_SIZE - randVal
            yRand = -TRIANGLE_SIDE_SIZE - randVal
        when 5
            xRand = -rand(TRIANGLE_SIDE_SIZE * 2)
            yRand = -TRIANGLE_SIDE_SIZE * 2
        else
            xRand = 200
            yRand = 200
        end

        @particles[i].x = @startingx + @xoffset + xRand
        @particles[i].y = @startingy + @yoffset + yRand
        @particlex[i] = xRand
        @particley[i] = yRand
    end
end