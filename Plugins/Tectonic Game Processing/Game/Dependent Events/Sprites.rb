class DependentEventSprites
    attr_accessor :sprites

    def initialize(viewport, map)
        @disposed = false
        @sprites = []
        @map = map
        @viewport = viewport
        refresh
        @lastUpdate = nil
    end

    def refresh
        for sprite in @sprites
            sprite.dispose
        end
        @sprites.clear
        $PokemonTemp.dependentEvents.eachEvent do |event, data|
            if data[2] == @map.map_id # Check current map
                spr = Sprite_Character.new(@viewport, event)
                spr.setReflection(event, @viewport)
                if $PokemonTemp.dependentEvents.can_refresh? && (defined?(EVENTNAME_MAY_NOT_INCLUDE) && spr.follower)
                    spr.steps = $FollowerSteps
                    $FollowerSteps = nil
                end
                @sprites.push(spr)
            end
        end
    end

    def update
        if $PokemonTemp.dependentEvents.lastUpdate != @lastUpdate
            refresh
            @lastUpdate = $PokemonTemp.dependentEvents.lastUpdate
        end
        for sprite in @sprites
            sprite.update
        end
        for i in 0...@sprites.length
            pbDayNightTint(@sprites[i])
            first_pkmn = $Trainer.first_able_pokemon
            next if !$PokemonGlobal.dependentEvents[i] || !$PokemonGlobal.dependentEvents[i][8][/FollowerPkmn/i]
            unless $PokemonGlobal.follower_toggled && FollowerSettings::APPLYSTATUSTONES && first_pkmn && first_pkmn.status != :NONE
                next
            end
            status_tone = FollowerSettings.getToneFromStatus(first_pkmn.status)
            next unless status_tone
            @sprites[i].tone.set(@sprites[i].tone.red + status_tone[0],
                                 @sprites[i].tone.green + status_tone[1],
                                 @sprites[i].tone.blue + status_tone[2],
                                 @sprites[i].tone.gray + status_tone[3])
        end
    end

    def dispose
        return if @disposed
        for sprite in @sprites
            sprite.dispose
        end
        @sprites.clear
        @disposed = true
    end

    def disposed?
        @disposed
    end
end

Events.onSpritesetCreate += proc { |_sender, e|
    spriteset = e[0]   # Spriteset being created
    viewport  = e[1]   # Viewport used for tilemap and characters
    map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
    spriteset.addUserSprite(DependentEventSprites.new(viewport, map))
}

Events.onMapSceneChange += proc { |_sender, e|
    mapChanged = e[1]
    $PokemonTemp.dependentEvents.pbMapChangeMoveDependentEvents if mapChanged
}
