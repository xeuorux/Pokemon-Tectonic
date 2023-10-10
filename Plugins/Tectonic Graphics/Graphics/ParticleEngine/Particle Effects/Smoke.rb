class Particle_Engine::Smoke < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([0,0,0,80,20,0.5,-64,
         Graphics.height,-64,Graphics.width,0.5,0.10,-5,-15,5,80])
      initParticles("smoke",250)
    end
  end
  