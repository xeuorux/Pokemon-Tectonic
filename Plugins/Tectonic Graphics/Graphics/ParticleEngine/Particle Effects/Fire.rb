class Particle_Engine::Fire < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([0,0,1,20,40,0.5,-64,
         Graphics.height,-64,Graphics.width,0.5,0.10,-5,-13,30,0])
      initParticles("particle",250)
    end
  end