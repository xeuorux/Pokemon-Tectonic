class Particle_Engine::Aura < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([0,0,1,20,0,1,-64,
         Graphics.height,-64,Graphics.width,2,2,-5,-13,30,0])
      initParticles("particle",250)
    end
  end