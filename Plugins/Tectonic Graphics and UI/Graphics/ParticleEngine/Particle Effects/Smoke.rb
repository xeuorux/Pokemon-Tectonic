class Particle_Engine::Smoke < ParticleEffect_Event
    def initialize(event,viewport)
      super
      setParameters([
            0, # Random hue
            0, # fade
            80, # max particles
            20, # hue
            0.5, # slowdown
            -Graphics.height, # ytop
            Graphics.height, # ybottom
            0, # xleft
            Graphics.width, # xright
            0, # xgravity
            -0.5, # ygravity
            -5, # xoffset
            -15, # yoffset
            5, # opacity var
            80 # original opacity
            ])
      initParticles("smoke",50)
    end
  end
  