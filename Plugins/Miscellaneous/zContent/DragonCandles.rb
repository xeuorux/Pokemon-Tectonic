class PokemonGlobalMetadata
    attr_writer :dragonFlames

    def dragonFlames
        @dragonFlames = 0 if @dragonFlames.nil?
        return @dragonFlames
    end
end

def takeDragonFlame(triggerEventID = -1)
    return if $PokemonGlobal.dragonFlames > 0
    if triggerEventID > 0
        if get_event(triggerEventID).at_coordinate?($game_player.x, $game_player.y)
            pbMessage(_INTL("The shadow will envelop you if you remove the flame now!"))
            return
        end
    end
    invertMySwitch('A')
    fadeInDarknessBlock(triggerEventID) if triggerEventID > 0
    $PokemonGlobal.dragonFlames = $PokemonGlobal.dragonFlames + 1
end

def giveDragonFlame(triggerEventID = -1)
    return if $PokemonGlobal.dragonFlames < 1
    invertMySwitch('A')
    fadeOutDarknessBlock(triggerEventID, false) if triggerEventID > 0
    $PokemonGlobal.dragonFlames = $PokemonGlobal.dragonFlames - 1
end