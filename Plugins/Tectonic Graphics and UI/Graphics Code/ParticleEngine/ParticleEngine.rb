# Particle Engine, Peter O., 2007-11-03
# Based on version 2 by Near Fantastica, 04.01.06
# In turn based on the Particle Engine designed by PinkMan
class Particle_Engine
    def initialize(viewport = nil, map = nil)
        @map       = map || $game_map
        @viewport  = viewport
        @effect    = []
        @disposed  = false
        @firsttime = true
        @effects   = {
           # PinkMan's Effects
           "fire"         => Particle_Engine::Fire,
           "smoke"        => Particle_Engine::Smoke,
           "teleport"     => Particle_Engine::Teleport,
           "spirit"       => Particle_Engine::Spirit,
           "explosion"    => Particle_Engine::Explosion,
           "aura"         => Particle_Engine::Aura,
           # BlueScope's Effects
           "soot"         => Particle_Engine::Soot,
           "sootsmoke"    => Particle_Engine::SootSmoke,
           "rocket"       => Particle_Engine::Rocket,
           "fixteleport"  => Particle_Engine::FixedTeleport,
           "smokescreen"  => Particle_Engine::Smokescreen,
           "flare"        => Particle_Engine::Flare,
           "splash"       => Particle_Engine::Splash,
           # By Peter O.
           "starteleport" => Particle_Engine::StarTeleport,

           # By Zeu
           "starfield"      => Particle_Engine::CircleStarField,
           "wormhole"       => Particle_Engine::Wormhole,
           "steamy"         => Particle_Engine::Steamy,
           "steamy2"        => Particle_Engine::Steamy2,
           "timeteleporter" => Particle_Engine::TimeTeleporter,
           "latentsoil"     => Particle_Engine::LatentSoil,
           "stinkbomb"      => Particle_Engine::StinkBomb,
           "shinyobject"    => Particle_Engine::ShinyObject,
        }
    end

    def dispose
        return if disposed?
        for particle in @effect
            next if particle.nil?
            particle.dispose
        end
        @effect.clear
        @map = nil
        @disposed = true
    end

    def disposed?
        return @disposed
    end

    def add_effect(event, type = nil)
        if type
            cls = @effects[type]
            return if cls.nil?
            @effect[event.id] = cls.new(event, @viewport)
        else
            @effect[event.id] = pbParticleEffect(event)
        end
    end

    def remove_effect(event)
        return if @effect[event.id].nil?
        @effect[event.id].dispose
        @effect.delete_at(event.id)
    end

    def realloc_effect(event, particle)
        type = pbEventCommentInput(event, 1, "Particle Engine Type")
        if type.nil?
            particle.dispose if particle
            return nil
        end
        type = type[0].downcase
        cls = @effects[type]
        if cls.nil?
            particle.dispose if particle
            return nil
        end
        if !particle || !particle.is_a?(cls)
            particle.dispose if particle
            particle = cls.new(event, @viewport)
        end
        return particle
    end

    def pbParticleEffect(event)
        return realloc_effect(event, nil)
    end

    def update
        if @firsttime
            @firsttime = false
            for event in @map.events.values
                remove_effect(event)
                add_effect(event)
            end
        end
        for i in 0...@effect.length
            particle = @effect[i]
            next if particle.nil?
            if particle.event.is_a?(Game_Event) && particle.event.pe_refresh
                event = particle.event
                event.pe_refresh = false
                particle = realloc_effect(event, particle)
                @effect[i] = particle
            end
            particle.update if particle
        end
    end
end

Events.onSpritesetCreate += proc { |_sender, e|
    spriteset = e[0] # Spriteset being created
    viewport = e[1] # Viewport used for tilemap and characters
    map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
    spriteset.addParticleEngine(Particle_Engine.new(viewport, map)) if $PokemonSystem.particle_effects == 0
}
