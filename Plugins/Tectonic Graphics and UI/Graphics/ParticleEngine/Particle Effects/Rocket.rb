class Particle_Engine::Rocket < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([0,0,0,60,0,0.5,-64,
         Graphics.height,-64,Graphics.width,0.5,0,-5,-15,5,80])
      initParticles("smoke",100,-1)
    end
  end