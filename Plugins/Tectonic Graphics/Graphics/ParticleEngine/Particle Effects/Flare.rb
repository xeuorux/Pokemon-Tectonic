class Particle_Engine::Flare < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([0,0,1,30,10,1,-64,
         Graphics.height,-64,Graphics.width,2,2,-5,-12,30,0])
      initParticles("particle",255)
    end
  end