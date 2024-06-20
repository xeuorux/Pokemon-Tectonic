# By Peter O.
class Particle_Engine::StarTeleport < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([0,0,1,10,0,1,
         -Graphics.height,Graphics.height,0,Graphics.width,0,3,-8,-15,10,0])
      initParticles("star",250)
      for i in 0...@maxparticless
        @particles[i].ox = 48
        @particles[i].oy = 48
      end
    end
  end