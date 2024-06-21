class Particle_Engine::Teleport < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([1,1,1,10,rand(360),1,-64,
         Graphics.height,-64,Graphics.width,0,3,-8,-15,20,0])
      initParticles("wideportal",250)
      for i in 0...@maxparticless
        @particles[i].ox = 16
        @particles[i].oy = 16
      end
    end
  end