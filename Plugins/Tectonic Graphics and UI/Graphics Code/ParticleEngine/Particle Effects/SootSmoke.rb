class Particle_Engine::SootSmoke < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([0,0,0,30,0,0.5,-64,
         Graphics.height,-64,Graphics.width,0.5,0.10,-5,-15,5,80])
      initParticles("smoke",100,0)
    end

    def initializeParticle(i)
      @particles[i].blend_type = rand(6) < 3 ? 1 : 2
    end
  end