
class Particle_Engine::Smokescreen < ParticleEffect_Event
  def initialize(event,viewport)
    super
    setParameters([0,0,0,250,0,0.2,-64,
       Graphics.height,-64,Graphics.width,0.8,0.8,-5,-15,5,80])
    initParticles(nil,100)
    for i in 0...@maxparticless
      rnd = rand(3)
      @opacity[i] = (rnd==0) ? 1 : 100
      filename = (rnd==0) ? "explosionsmoke" : "smoke"
      @particles[i].bitmap = loadBitmap(filename, @hue)
    end
  end

  def calcParticlePos(i)
    if @randomhue==1
      filename = (rand(3)==0) ? "explosionsmoke" : "smoke"
      @particles[i].bitmap = loadBitmap(filename, @hue)
    end
    multiple = 1.7
    xgrav = @xgravity*multiple/@slowdown
    xgrav = -xgrav if (rand(2)==1)
    ygrav = @ygravity*multiple/@slowdown
    ygrav = -ygrav if (rand(2)==1)
    @particlex[i] += xgrav
    @particley[i] += ygrav
    @particlex[i] -= @__offsetx
    @particley[i] -= @__offsety
    @particlex[i] = @particlex[i].floor
    @particley[i] = @particley[i].floor
    @particles[i].x = @particlex[i]+@startingx+@xoffset
    @particles[i].y = @particley[i]+@startingy+@yoffset
  end
end