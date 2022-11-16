class PokemonGlobalMetadata
    attr_writer :dragonFlames

    def dragonFlames
        @dragonFlames = 0 if @dragonFlames.nil?
        return @dragonFlames
    end
end

def takeDragonFlame(triggerEventID = -1)
    if $PokemonGlobal.dragonFlames > 0
        pbMessage(_INTL("You are already holding a dragon flame!"))
        return
    end
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
    if $PokemonGlobal.dragonFlames < 1
        pbMessage(_INTL("It looks like it could hold a magical flame."))
        return
    end
    invertMySwitch('A')
    fadeOutDarknessBlock(triggerEventID, false) if triggerEventID > 0
    $PokemonGlobal.dragonFlames = $PokemonGlobal.dragonFlames - 1
end