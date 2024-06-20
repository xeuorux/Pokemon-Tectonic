class Particle_Engine::StinkBomb < ParticleEffect_Event
    def initialize(event,viewport)
      super
      maxParticles = (STINK_BOMB_RANGE) ** 2
      setParameters([
        0, # Random hue
        0, # fade
        maxParticles, # max particles
        -30, # hue
        0.5, # slowdown
        -Graphics.height, # ytop
        Graphics.height, # ybottom
        0, # xleft
        Graphics.width, # xright
        0, # xgravity
        -0.5, # ygravity
        -32, # xoffset
        -32, # yoffset
        5, # opacity var
        5 # original opacity
        ])
      @huerange = 10

      @xStart = -32 * (STINK_BOMB_RANGE-1)
      @yStart = -32 * (STINK_BOMB_RANGE-1)
      @movesleftright = false
      @movesupdown = true

      @maxOpacity = 100

      initParticles("stink_cloud",10)
    end

    def resetParticle(i)
      xThis = @xStart + (i % (STINK_BOMB_RANGE * 2)) * 32
      yThis = @yStart + (i / (STINK_BOMB_RANGE * 2)) * 64
      @particles[i].x = @startingx + @xoffset + xThis
      @particles[i].y = @startingy + @yoffset + yThis
      @particlex[i] = xThis
      @particley[i] = yThis
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
      @opacity[i] = 5
    end

    def changeOpacity(i)
      if @particles[i].state == 0
          @opacity[i] += 3
          if @opacity[i] >= @maxOpacity
              @particles[i].state = 1
          end
      else
          @opacity[i] -= 2
      end
  end
end