# Particle Engine, Peter O., 2007-11-03
# Based on version 2 by Near Fantastica, 04.01.06
# In turn based on the Particle Engine designed by PinkMan
class Particle_Engine
    def initialize(viewport = nil, map = nil)
        @map       = map || $game_map
        @viewport  = viewport
        @effect    = []
        @disposed  = false
        @firsttime = true
        @effects   = {
           # PinkMan's Effects
           "fire"         => Particle_Engine::Fire,
           "smoke"        => Particle_Engine::Smoke,
           "teleport"     => Particle_Engine::Teleport,
           "spirit"       => Particle_Engine::Spirit,
           "explosion"    => Particle_Engine::Explosion,
           "aura"         => Particle_Engine::Aura,
           # BlueScope's Effects
           "soot"         => Particle_Engine::Soot,
           "sootsmoke"    => Particle_Engine::SootSmoke,
           "rocket"       => Particle_Engine::Rocket,
           "fixteleport"  => Particle_Engine::FixedTeleport,
           "smokescreen"  => Particle_Engine::Smokescreen,
           "flare"        => Particle_Engine::Flare,
           "splash"       => Particle_Engine::Splash,
           # By Peter O.
           "starteleport" => Particle_Engine::StarTeleport,
           
           # By Zeu
           "starfield"    => Particle_Engine::StarField,
        }
    end
end

def pbEventCommentInput(*args)
    parameters = []
    list = args[0].list   # Event or event page
    elements = args[1]    # Number of elements
    trigger = args[2]     # Trigger
    return nil if list == nil
    return nil unless list.is_a?(Array)
    for item in list
      next unless item.code == 108 || item.code == 408
      if item.parameters[0] == trigger
        start = list.index(item) + 1
        finish = start + elements
        for id in start...finish
          next if !list[id]
          parameters.push(list[id].parameters[0])
        end
        return parameters
      end
    end
    return nil
end

class ParticleEffect_Event
    def initParticles(filename,opacity,zOffset=0,blendtype=1)
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
        @opacityMult = 1.0
        for i in 0...@maxparticless
          @particlex[i] = -@xoffset
          @particley[i] = -@yoffset
          @particles[i] = ParticleSprite.new(@viewport)
          @particles[i].bitmap = loadBitmap(filename, @hue) if filename
          if i==0 && @particles[i].bitmap
            @bmwidth  = @particles[i].bitmap.width
            @bmheight = @particles[i].bitmap.height
          end
          @particles[i].blend_type = blendtype
          @particles[i].y = @startingy
          @particles[i].x = @startingx
          @particles[i].z = self.z+zOffset
          @opacity[i] = rand(opacity/4)
          @particles[i].opacity = @opacity[i]
          @particles[i].update
        end
      end

    def update
        if @viewport &&
           (@viewport.rect.x >= Graphics.width ||
           @viewport.rect.y >= Graphics.height)
          return
        end
        selfX = self.x
        selfY = self.y
        selfZ = self.z
        newRealX = @event.real_x
        newRealY = @event.real_y
        @startingx = selfX + @xoffset
        @startingy = selfY + @yoffset
        @__offsetx = (@real_x==newRealX) ? 0 : selfX-@screen_x
        @__offsety = (@real_y==newRealY) ? 0 : selfY-@screen_y
        @screen_x = selfX
        @screen_y = selfY
        @real_x = newRealX
        @real_y = newRealY
        if @opacityvar > 0 && @viewport
          opac = 255.0 / @opacityvar
          minX = opac * (-@xgravity*1.0 / @slowdown).floor + @startingx
          maxX = opac * (@xgravity*1.0 / @slowdown).floor + @startingx
          minY = opac * (-@ygravity*1.0 / @slowdown).floor + @startingy
          maxY = @startingy
          minX -= @bmwidth
          minY -= @bmheight
          maxX += @bmwidth
          maxY += @bmheight
          if maxX<0 || maxY<0 || minX>=Graphics.width || minY>=Graphics.height
            return # Skip this update step
          end
        end
        particleZ = selfZ+@zoffset

        # Update all particles
        for i in 0...@maxparticless
          updateParticle(i,particleZ)
        end
    end

    def updateParticle(i,particleZ)
        @particles[i].z = particleZ
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
        if @fade == 0
            if @opacity[i] <= 0
                @opacity[i] = initOpacity(i)
                resetParticle(i)
            end
        else
            if @opacity[i] <= 0
                @opacity[i] = 250
                resetParticle(i)
            end
        end
        calcParticlePos(i)
        if @randomhue == 1
            @hue += 0.5
            @hue = 0 if @hue >= 360
            @particles[i].bitmap = loadBitmap(@filename, @hue) if @filename
        end
        @opacity[i] = @opacity[i] - rand(@opacityvar)
        @particles[i].opacity = @opacity[i] * @opacityMult
        @particles[i].update
    end

    def initOpacity(i)
        return @originalopacity
    end

    def resetParticle(i)
        @particles[i].y = @startingy + @yoffset
        @particles[i].x = @startingx + @xoffset
        @particlex[i] = 0.0
        @particley[i] = 0.0
    end
end

class Particle_Engine::StarField < ParticleEffect_Event
    def initialize(event,viewport)
        super
        setParameters([
            5, # Random hue
            1, # left right
            0.05, # fade
            10, # max particles
            0, # hue
            1, # slowdown
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
        initParticles("particle",100)
        for i in 0...@maxparticless
            @particles[i].ox = 48
            @particles[i].oy = 48
        end
        @xrandom = 300
        @yrandom = 150
        @opacityMult = 0.2
    end

    def resetParticle(i)
        xRand = rand(@xrandom) - @xrandom / 2
        yRand = rand(@yrandom) - @yrandom / 2
        @particles[i].x = @startingx + @xoffset + xRand
        @particles[i].y = @startingy + @yoffset + yRand
        @particlex[i] = xRand
        @particley[i] = yRand
    end

    def initOpacity(i)
        return @originalopacity + rand(50)
    end
end