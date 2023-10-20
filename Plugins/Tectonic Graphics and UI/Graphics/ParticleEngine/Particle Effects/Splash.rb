class Particle_Engine::Splash < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([0,0,1,30,255,1,-64,
         Graphics.height,-64,Graphics.width,4,2,-5,-12,30,0])
      initParticles("smoke",50)
    end
  
    def update
      super
      for i in 0...@maxparticless
        @particles[i].opacity = 50
        @particles[i].update
      end
    end
  end
  